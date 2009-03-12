class ActiveRecord::Base
  def sorted_column_names
    attributes.keys.sort_by { |x| x.to_s }
  end
  def insert_values_sql
    res = sorted_column_names.map { |x| "'#{attributes[x]}'" }.join(",")
    "(#{res})"
  end
end