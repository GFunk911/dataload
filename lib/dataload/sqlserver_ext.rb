#Dir["C:/Ruby/lib/ruby/gems/1.8/gems/activerecord-sqlserver-adapter*/**/*.rb"].each { |x| puts x; require x }

module ActiveRecord
  class Base
    class << self
      alias_method :orig_sqlserver_connection, :sqlserver_connection
      #puts "redeffing sqlserver_connection"
      def sqlserver_connection(config) #:nodoc:
        #puts "in redeffed sqlserver connection"
        require_library_or_gem 'dbi' unless self.class.const_defined?(:DBI)
        
        config = config.symbolize_keys

        mode        = config[:mode] ? config[:mode].to_s.upcase : 'ADO'
        username    = config[:username] ? config[:username].to_s : 'sa'
        password    = config[:password] ? config[:password].to_s : ''
        autocommit  = config.key?(:autocommit) ? config[:autocommit] : true
        if mode == "ODBC"
          raise ArgumentError, "Missing DSN. Argument ':dsn' must be set in order for this adapter to work." unless config.has_key?(:dsn)
          dsn       = config[:dsn]
          driver_url = "DBI:ODBC:#{dsn}"
        else
          raise ArgumentError, "Missing Database. Argument ':database' must be set in order for this adapter to work." unless config.has_key?(:database)
          database  = config[:database]
          host      = config[:host] ? config[:host].to_s : 'localhost'
          if username =~ /PCI/
            driver_url = "DBI:ADO:Provider=SQLOLEDB;Data Source=#{host};Initial Catalog=#{database};Integrated Security=SSPI;"
          else
            driver_url = "DBI:ADO:Provider=SQLOLEDB;Data Source=#{host};Initial Catalog=#{database};User ID=#{username};Password=#{password};"
          end
        end
        #puts "DriverURL: #{driver_url}"
        conn      = DBI.connect(driver_url, username, password)
        conn["AutoCommit"] = autocommit
        ConnectionAdapters::SQLServerAdapter.new(conn, logger, [driver_url, username, password])
      end
    end
  end
end
    
