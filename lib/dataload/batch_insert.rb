class StandardBatchInsert
  include FromHash
  attr_accessor :rows, :table_name, :ar_class, :block_size
  fattr(:column_names) { rows.first.sorted_column_names }
  fattr(:values_sql) do
    "VALUES " + rows.map { |x| x.insert_values_sql }.join(", ")
  end
  fattr(:columns_sql) do
    "(" + column_names.join(", ") + ")"
  end
  fattr(:insert_sql) do
    "INSERT into #{table_name} #{columns_sql} #{values_sql};"
  end
  def insert!
    ActiveRecord::Base.connection.execute(insert_sql) 
  end
end

class SqlServerBatchInsert < StandardBatchInsert
  fattr(:load_file_str) do
    cols = ar_class.columns.map { |x| x.name }
    rows.map do |row|
      #raise cols.inspect + "|" + row.inspect
      cols.map { |c| row[c.to_sym] }.join("|")
    end.join("______")
  end
  fattr(:load_file_path) { File.expand_path("temp_load_file.txt") }
  def write_load_file!
    File.create(load_file_path,load_file_str)
    Dataload.log "Temp file for bulk insert created at #{load_file_path}"
  end
  def insert_sql
    "BULK INSERT #{table_name} FROM '#{load_file_path}' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '______', BATCHSIZE = #{block_size})"
  end
  def insert!
    write_load_file!
    ActiveRecord::Base.connection.execute(insert_sql)
  end
end
    
class OracleBatchInsert < StandardBatchInsert
  fattr(:insert_sql) do
    str = ["INSERT ALL "]
    rows.each do |row|
      str << "INTO #{table_name} #{columns_sql} VALUES #{row.insert_values_sql}"
    end
    str.join("\n") + "\nSELECT * from dual"
  end
end

class BatchInsert
  def self.get_class
    adapter = MasterLoader.instance.db_ops[:adapter].to_s
    if %w(oci oci8 oracle).include?(adapter)
      OracleBatchInsert
    elsif adapter == 'sqlserver'
      SqlServerBatchInsert
    else
      StandardBatchInsert
    end
  end
end

