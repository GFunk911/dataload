require File.dirname(__FILE__) + "/dataload/table_loader"
require File.dirname(__FILE__) + "/dataload/table_manager"
require File.dirname(__FILE__) + "/dataload/master_loader"
Dir[File.dirname(__FILE__) + "/dataload/dsl/*.rb"].each { |x| require x }