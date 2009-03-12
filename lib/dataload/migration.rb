class DataloadMigration < ActiveRecord::Migration
  class << self
    attr_accessor :cols, :table_name
    include FromHash
  end
  def self.new_migration(ops,&b)
    cls = Class.new(DataloadMigration)
    cls.from_hash(ops)
    cls.class_eval do
      def self.up
        instance_eval(&b)
      end
    end
    cls
  end
end