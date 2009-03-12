class DataloadMigration < ActiveRecord::Migration
  class << self
    attr_accessor :cols, :table_name, :b
    include FromHash
  end
  def self.new_migration(ops,&b)
    cls = Class.new(DataloadMigration)
    cls.from_hash(ops)
    cls.b = b
    cls.class_eval do
      def self.up
        instance_eval(&b)
        Dataload.log "Created table #{table_name}"
      end
    end
    cls
  end
end