class TableManager
  include TableModule
  def delete_rows!
    return unless ar_cls.table_exists?
    Dataload.log "Deleting #{ar_cls.count} rows from table '#{table_name}'"
    ar_cls.connection.execute("DELETE from #{table_name}")
    Dataload.log "Deleted rows from table '#{table_name}'"
  end
end