require 'rubygems'
begin
  require "/Code/mharris_ext/lib/mharris_ext"
rescue
  require 'mharris_ext'
end
require 'fastercsv'
require 'activerecord'

%w(migration column).each { |x| require File.dirname(__FILE__) + "/#{x}" }
Dir[File.dirname(__FILE__) + "/ext/*.rb"].each { |x| require x }

class TableLoader
  attr_accessor :db_ops
  attr_accessor_nn :table_name, :source_filename
  fattr(:columns) { [] }
  fattr(:source_rows) do
    Enumerable::Enumerator.new(FasterCSV,:foreach,source_filename,:headers => true).to_a
  end
  def target_hash_for_row(row)
    columns.inject({}) { |h,col| h.merge(col.target_name => col.target_value(row)) }
  end
  def target_hashes
    source_rows.map { |x| target_hash_for_row(x) }
  end
  fattr(:migration) do
    DataloadMigration.new_migration(:cols => columns, :table_name => table_name) do
      create_table table_name do |t|
        cols.each do |col|
          t.column col.target_name, :string
        end
      end
    end
  end
  fattr(:ar_cls) do
    Class.new(ActiveRecord::Base).tap { |x| x.set_table_name(table_name) }
  end
  def migrate!
    migration.migrate(:up) unless ar_cls.table_exists?
  end
  fattr(:ar_objects) do
    target_hashes.map { |h| ar_cls.new(h) }
  end
  def load!
    ActiveRecord::Base.establish_connection(db_ops)
    migrate!
    ar_objects.each { |x| x.save! }
  end
end
