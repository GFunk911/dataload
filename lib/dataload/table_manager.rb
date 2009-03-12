class TableManager
  include TableModule
  def delete_rows!
    return unless ar_cls.table_exists?
    ar_cls.connection.execute("DELETE from #{table_name}")
    puts "Deleted rows from #{table_name}"
  end
end