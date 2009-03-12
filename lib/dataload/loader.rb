require 'rubygems'
require 'mharris_ext'
require 'fastercsv'
require 'activerecord'

class FasterCSV::Row
  def method_missing(sym,*args,&b)
    if self[sym.to_s]
      self[sym.to_s]
    else
      super(sym,*args,&b)
    end
  end
end

class Loader
  fattr(:columns) { [] }
  attr_accessor :source_filename, :db_ops, :table_name
  fattr(:source_rows) do
    res = []
    FasterCSV.foreach(source_filename, :headers => true) do |row|
      res << row
    end
    res
  end
  def target_hash_for_row(row)
    h = {}
    columns.each do |col|
      h[col.target_name] = col.target_value(row)
    end
    h
  end
  def target_hashes
    source_rows.map { |x| target_hash_for_row(x) }
  end
  def target_column_names
    columns.map { |x| x.target_name }
  end
  def new_struct
    Struct.new(*target_column_names)
  end
  fattr(:migration) do
    raise "must define table" unless table_name
    cls = Class.new(ActiveRecord::Migration)
    class << cls
      attr_accessor :cols, :table_name
    end
    cls.cols = columns
    cls.table_name = table_name
    puts "Table: #{table_name}"
    cls.class_eval do
      def self.up
        create_table table_name do |t|
          cols.each do |col|
            t.column col.target_name, :string
          end
        end
      end
    end
    cls
  end
  fattr(:ar) do
    cls = Class.new(ActiveRecord::Base)
    cls.send(:set_table_name, table_name)
    cls
  end
  def migrate!
    ar.find(:first)
  rescue => exp
    puts "find failed"
    puts exp.inspect
    migration.migrate(:up)
  end
  fattr(:ar_objects) do
    target_hashes.map { |h| ar.new(h) }
  end
  def load!
    ActiveRecord::Base.establish_connection(db_ops)
    migrate!
    ar_objects.each { |x| x.save! }
  end
end

class Column
  include FromHash
  attr_accessor :target_name, :blk
  def target_value(row)
    if blk.arity == 1
      blk.call(row)
    else
      row.instance_eval(&blk)
    end
  end
end 

class LoaderDSL
  fattr(:loader) { Loader.new }
  def column(name,type,&blk)
    blk ||= lambda { |x| x.send(name) }
    loader.columns << Column.new(:target_name => name, :blk => blk)
  end
  def method_missing(sym,*args,&b)
    if [:string, :text, :integer, :float, :decimal, :datetime, :timestamp, :time, :date, :binary, :boolean].include?(sym)
      column(args.first,sym,&b)
    else
      super(sym,*args,&b)
    end
  end
  def source(file)
    loader.source_filename = file
  end
  def database(ops)
    loader.db_ops = ops
  end
  def table(name)
    loader.table_name = name
  end
end

def dataload(&b)
  dsl = LoaderDSL.new
  dsl.instance_eval(&b)
  dsl.loader.load!
  puts "Row Count: " + dsl.loader.ar.find(:all).size.to_s
end

dataload do
  source "source.csv"
  database :adapter => 'sqlite3', :database => "db.sqlite3", :timeout => 5000
  table 'foobar'
  string(:cat) { bar + "_cat" }
end

