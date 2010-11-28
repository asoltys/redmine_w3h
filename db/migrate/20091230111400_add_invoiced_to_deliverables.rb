class AddInvoicedToDeliverables < ActiveRecord::Migration
  def self.up
    add_column :deliverables, :invoiced, :decimal, :precision => 15, :scale => 2
  end
  
  def self.down
    remove_column :deliverables, :invoiced
  end
end

