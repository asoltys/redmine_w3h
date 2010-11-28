class AddStatusFieldsToDeliverables < ActiveRecord::Migration
  def self.up
    add_column :deliverables, :financial_coding_provided, :boolean
    add_column :deliverables, :signed_copy_delivered, :boolean
  end

  def self.down
    remove_column :deliverables, :financial_coding_provided
    remove_column :deliverables, :signed_copy_delivered
  end
end
