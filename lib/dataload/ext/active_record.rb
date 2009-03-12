class Hash
  def sorted_column_names
    keys.sort_by { |x| x.to_s }
  end
  def insert_values_sql
    res = sorted_column_names.map { |x| "'#{self[x]}'" }.join(",")
    "(#{res})"
  end
end