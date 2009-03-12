require 'rubygems'
require File.dirname(__FILE__) + '/../dataload'

#setup the sample source file
source_filename = File.dirname(__FILE__) + "/sample_source.csv"
source_text = <<EOF
name,age,city,state
Bob Smith,24,Atlanta,GA
Jane Doe,35,Buffalo,NY
Evan Stein,31,Princeton,NJ
EOF
File.create(source_filename,source_text)

#load into a database, creating the table if needed
table_dataload do
  #clear_table_first
  # csv file the data is being sourced from
  source source_filename
  
  # database/table the data should be loaded into.
  # the table will be created if it does not already exist
  database :adapter => 'sqlite3', :database => "db.sqlite3", :timeout => 5000
  #database :adapter => 'sqlserver', :host => '192.168.1.49', :username => 'pci-tae', :password => 'fgfgf', :database => 'fgfgfgf'
  table 'people'
  
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