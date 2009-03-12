module TableModule
  attr_accessor_nn :table_name
  fattr(:ar_cls) do
    Class.new(ActiveRecord::Base).tap { |x| x.set_table_name(table_name) }
  end
end
  