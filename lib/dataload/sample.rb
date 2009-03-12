require 'rubygems'
require 'dataload'

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
dataload do
  source source_filename
  database :adapter => 'sqlite3', :database => "db.sqlite3", :timeout => 5000
  table 'people'
  string(:full_name) { name }
  string(:first_name) { name.split[0] }
  string(:last_name) { name.split[1] }
  integer(:age)
  string(:city_state) { "#{city}, #{state}" }
end