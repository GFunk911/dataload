require File.dirname(__FILE__) + "/dataload/table_loader"
Dir[File.dirname(__FILE__) + "/dataload/dsl/*.rb"].each { |x| require x }