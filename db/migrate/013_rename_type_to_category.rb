class RenameTypeToCategory < ActiveRecord::Migration
  def self.up
    rename_column :deliverables, :type, :category
  end
  
  def self.down
    rename_column :deliverables, :category, :type
  end
end

