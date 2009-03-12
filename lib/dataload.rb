require File.dirname(__FILE__) + "/dataload/loader"
Dir[File.dirname(__FILE__) + "/dataload/dsl/*.rb"].each { |x| require x }