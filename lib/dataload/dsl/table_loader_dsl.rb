class Both
  include FromHash
  fattr(:objs) { [] }
  def method_missing(sym,*args,&b)
    objs.each { |x| x.send(sym,*args,&b) }
  end
end

class TableLoaderDSL
  fattr(:table_name) { loader.table_name }
  fattr(:loader) { TableLoader.new }
  fattr(:manager) { TableManager.new }
  fattr(:both) { Both.new(:objs => [loader,manager]) }
  def master
    MasterLoader.instance
  end
  def initialize(&b)
    @blk = b
    instance_eval(&@blk)
    master.add(self)
  end
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
  def table(name)
    both.table_name = name
  end
  def run!
    manager.delete_rows! if @delete_existing_rows
    loader.load!
  end
end

def table_dataload(&b)
  TableLoaderDSL.new(&b)
end
