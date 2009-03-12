class Column
  include FromHash
  attr_accessor :target_name, :blk
  def target_value(row)
    row.instance_eval(&blk)
  end
end 
