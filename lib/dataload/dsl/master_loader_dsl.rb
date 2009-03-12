class MasterLoaderDSL
  fattr(:master) { MasterLoader.instance }
  def initialize(&b)
    @blk = b
    instance_eval(&b)
  end
  def database(ops)
    master.db_ops = ops
  end
  def load_order(*tables)
    master.raw_table_load_order = tables.flatten
  end
  def delete_order(*tables)
    master.raw_table_delete_order = tables.flatten
  end
  def block_size(n)
    master.block_size = n
  end
  def run!
    master.run!
  end
end

def master_dataload(&b)
  MasterLoaderDSL.new(&b).run!
end