require 'rubygems'
require 'mharris_ext'
#require "/Code/mharris_ext/lib/mharris_ext"
require 'fastercsv'
require 'active_record'
require 'facets/enumerable'

%w(migration column table_module batch_insert).each { |x| require File.dirname(__FILE__) + "/#{x}" }
Dir[File.dirname(__FILE__) + "/ext/*.rb"].each { |x| require x }

class Object
  def fattr_tm(name,&b)
    fattr(name) do
      tm(name) do
        instance_eval(&b)
      end
    end
  end
end
      
class TableLoader
  include TableModule
  attr_accessor_nn :source_filename
  fattr(:delimiter) { "," }
  fattr(:block_size) { 1000 }
  def master
    MasterLoader.instance
  end
  def effective_block_size
    if master.db_ops[:adapter].to_s == 'sqlserver' 
      100000
    else
      block_size
    end
  end
  fattr(:columns) { [] }
  fattr(:source_row_groups) do
    e = enum(FasterCSV,:foreach,source_filename,:headers => true, :col_sep => delimiter)
    enum(e,:each_by,effective_block_size)
  end
  def target_hash_for_row(row)
    columns.inject({}) { |h,col| h.merge(col.target_name => col.target_value(row)) }
  end
  def target_hashes(rows)
    rows.map { |x| target_hash_for_row(x) }
  end
  def target_hash_groups
    source_row_groups.each_with_index do |rows,i|
      yield(target_hashes(rows),i*effective_block_size+rows.size)
    end
  end
  def load!
    migrate!
    Dataload.log "Starting load of table '#{table_name}'"
    total = 0
    target_hash_groups do |hs,num_inserted|
      BatchInsert.get_class.new(:rows => hs, :table_name => table_name, :ar_class => ar_cls, :block_size => block_size).insert!
      Dataload.log "Inserted #{num_inserted - total} rows into table '#{table_name}'.  Total of #{num_inserted} rows inserted."
      total = num_inserted
    end
    Dataload.log "Finished load of table '#{table_name}'.  Loaded #{total} rows."
  end
end

module TableCreation
  fattr(:migration) do
    DataloadMigration.new_migration(:cols => columns, :table_name => table_name) do
      create_table(table_name, :id => false) do |t|
        cols.each do |col|
          t.column col.target_name, col.column_type
        end
      end
    end
  end
  def migrate!
    migration.migrate(:up) unless ar_cls.table_exists?
  end
end
TableLoader.send(:include,TableCreation)
