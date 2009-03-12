require 'rubygems'
begin
  require "/Code/mharris_ext/lib/mharris_ext"
rescue
  require 'mharris_ext'
end
require 'fastercsv'
require 'activerecord'
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
  fattr(:columns) { [] }
  fattr(:source_row_groups) do
    e = enum(FasterCSV,:foreach,source_filename,:headers => true, :col_sep => delimiter)
    enum(e,:each_by,block_size)
  end
  def target_hash_for_row(row)
    columns.inject({}) { |h,col| h.merge(col.target_name => col.target_value(row)) }
  end
  def target_hashes(rows)
    rows.map { |x| target_hash_for_row(x) }
  end
  def target_hash_groups
    source_row_groups.each_with_index do |rows,i|
      yield(target_hashes(rows),(i+1)*block_size)
    end
  end
  def load!
    migrate!
    target_hash_groups do |hs,num_inserted|
      BatchInsert.new(:rows => hs, :table_name => table_name).insert!
      puts "Inserted #{num_inserted} #{Time.now}" if num_inserted%25000 == 0
    end
    puts "#{table_name} Row Count: #{ar_cls.count}"
  end
end

module TableCreation
  fattr(:migration) do
    DataloadMigration.new_migration(:cols => columns, :table_name => table_name) do
      create_table table_name do |t|
        cols.each do |col|
          t.column col.target_name, :string
        end
      end
    end
  end
  def migrate!
    migration.migrate(:up) unless ar_cls.table_exists?
  end
end
TableLoader.send(:include,TableCreation)
