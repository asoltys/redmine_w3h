class AddNumberToDeliverables < ActiveRecord::Migration
  def self.up
    add_column :deliverables, :number, :string
  end
  
  def self.down
    remove_column :deliverables, :number
  end
end
