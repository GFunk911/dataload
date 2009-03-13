require 'rubygems'
require File.dirname(__FILE__) + '/../lib/dataload'

#setup the sample source file
source_filename = File.dirname(__FILE__) + "/../tmp/sample_source.csv"
db_path = File.dirname(__FILE__) + "/../tmp/sample.sqlite3"

source_text = <<EOF
Bob Smith,24,Atlanta,GA
Jane Doe,35,Buffalo,NY
Evan Stein,31,Princeton,NJ
EOF
source_text = "name,age,city,state\n" + (1..10000).map { source_text }.join
File.create(source_filename,source_text)

#load into a database, creating the table if needed
table_dataload do
  # csv file the data is being sourced from
  source source_filename
  
  # database/table the data should be loaded into.
  # the table will be created if it does not already exist
  #database :adapter => 'sqlite3', :database => db_path, :timeout => 5000
  #database :adapter => 'sqlserver', :host => '192.168.1.49', :username => 'pci-tae', :password => 'fgfgf', :database => 'fgfgfgf'
  table 'people'
  
  #field delimiter in source file
  delimiter ","
    
  # columns in the new table
  # available types are string, text, integer, float, decimal, datetime, timestamp, time, date, binary, boolean
  #
  # The first argument is the name of the new column
  # The block describes the value to be populated
  #
  # Example: string(:full_name) { name } 
  # This creates a field 'full_name' of type string in the new table, and populates it with the name field from the csv
  #
  # Example: boolean(:is_tall) { height_in_inches.to_i > 74 }
  # Creates a field 'is_tall' and populates with true if the height_in_inches field in the csv is greater than 74
  #
  # A column without a block just passes through the same field in the csv
  # integer(:age) creates an integer field 'age' in the new table, populated with the age field in the csv
  string(:full_name) { name }
  string(:first_name) { name.split[0] }
  string(:last_name) { name.split[1] }
  integer(:age)
  string(:city_state) { "#{city}, #{state}" }
end

master_dataload do
  database :adapter => 'sqlite3', :database => db_path, :timeout => 5000
  #database :adapter => 'mysql', :database => 'dataload_test', :username => 'root'
  load_order :people
  block_size 1000
end