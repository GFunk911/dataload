class TableLoaderDSL
  fattr(:loader) { TableLoader.new }
  def initialize(&b)
    @blk = b
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
  def database(ops)
    loader.db_ops = ops
  end
  def table(name)
    loader.table_name = name
  end
  def run!
    instance_eval(&@blk)
    loader.load!
    puts "Row Count: #{loader.ar_cls.count}"
  end
end

def table_dataload(&b)
  TableLoaderDSL.new(&b).run!
end
