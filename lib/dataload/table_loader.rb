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
  fattr(:block_size) { 1000 }
  fattr(:columns) { [] }
  fattr_tm(:source_rows) do
    Enumerable::Enumerator.new(FasterCSV,:foreach,source_filename,:headers => true).to_a
  end
  def target_hash_for_row(row)
    columns.inject({}) { |h,col| h.merge(col.target_name => col.target_value(row)) }
  end
  fattr(:target_hashes) do
    source_rows.map { |x| target_hash_for_row(x) }
  end
  fattr(:target_hash_groups) do
    Enumerable::Enumerator.new(target_hashes,:each_by,block_size).to_a
  end
  def load!
    migrate!
    #ar_objects.each { |x| x.save! }
    tm("target_hash_groups") { target_hash_groups }
    tm("actual insert") do
      target_hash_groups.each do |hs|
        BatchInsert.new(:rows => hs, :table_name => table_name).insert!
      end
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
