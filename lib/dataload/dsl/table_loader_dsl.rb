class TableLoaderDSL
  fattr(:loader) { TableLoader.new }
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

def table_dataload(&b)
  dsl = TableLoaderDSL.new
  dsl.instance_eval(&b)
  dsl.loader.load!
  puts "Row Count: " + dsl.loader.ar_cls.find(:all).size.to_s
end
