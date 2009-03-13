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
  attr_accessor :source_filename
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
    cls = Class.new(ActiveRecord::Migration)
    class << cls
      attr_accessor :cols
    end
    cls.cols = columns
    cls.class_eval do
      def self.up
        create_table :foo do |t|
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
    cls.class_eval do
      set_table_name :foo
    end
    cls
  end
  def migrate!
    ar.find(:first)
  rescue
    migration.migrate(:up)
  end
  fattr(:ar_objects) do
    target_hashes.map { |h| ar.new(h) }
  end
  def load!
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
  def column(name,&blk)
    blk ||= lambda { |x| x.send(name) }
    loader.columns << Column.new(:target_name => name, :blk => blk)
  end
  def source(file)
    loader.source_filename = file
  end
  def database(ops)
    ActiveRecord::Base.establish_connection(ops)
  end
end

def dataload(&b)
  dsl = LoaderDSL.new
  dsl.instance_eval(&b)
  dsl.loader.migrate!
  dsl.loader.load!
  puts "Row Count: " + dsl.loader.ar.find(:all).size.to_s
end

class Foo
  attr_accessor :bar
  include FromHash
end

class TargetRow
  attr_accessor :h
  include FromHash
end

def foo
  l = Loader.new
  l.columns << Column.new(:target_name => 'abc', :blk => lambda { |x| x.bar+"x"} )
  l.source_rows = [Foo.new(:bar => "Cat")]
  puts l.columns.first.target_value(l.source_rows.first)
  puts l.target_hashes.inspect
end

dataload do
  source "source.csv"
  column(:cat) { bar + "_cat" }
  database :adapter => 'sqlite3', :database => "db.sqlite3", :timeout => 5000
end

