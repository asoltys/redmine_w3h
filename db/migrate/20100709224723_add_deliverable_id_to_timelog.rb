class AddDeliverableIdToTimelog < ActiveRecord::Migration
  def self.up
    add_column :time_entries, :deliverable_id, :integer
  end

  def self.down
    remove_column :time_entries, :deliverable_id
  end
end
