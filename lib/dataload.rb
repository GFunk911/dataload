def handle_errors
  yield
rescue => exp
  msg = [exp.message,exp.backtrace.join("\n")].join("\n")
  Dataload.log msg
  puts exp.message
  raise "Error occured and logged.  Exiting."
end

require File.dirname(__FILE__) + "/dataload/table_loader"
require File.dirname(__FILE__) + "/dataload/table_manager"
require File.dirname(__FILE__) + "/dataload/master_loader"
Dir[File.dirname(__FILE__) + "/dataload/dsl/*.rb"].each { |x| require x }

class Dataload
  class << self
    fattr(:logger) { DataloadLogger.new }
    def log(str)
      logger.log(str)
    end
  end
end

class DataloadLogger
  fattr(:first) { true }
  def log(str)
    File.create(current_filename,"") if first
    File.append(timestamp_filename,"#{Time.now.short_dt} #{str}\n")
    File.append(current_filename,"#{Time.now.short_dt} #{str}\n")
    self.first = false
  end
  fattr(:timestamp_filename) do
    t = Time.now.strftime("%Y%m%d%H%M%S")
    res = File.expand_path("dataload_#{t}.log")
    puts "Logging to #{res}"
    res
  end
  fattr(:current_filename) do
    File.expand_path("dataload.log")
  end
end