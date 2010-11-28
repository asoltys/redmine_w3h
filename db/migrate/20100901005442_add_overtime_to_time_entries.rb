class AddOvertimeToTimeEntries < ActiveRecord::Migration
  def self.up
    add_column :time_entries, :overtime, :boolean
  end

  def self.down
    remove_column :time_entries, :overtime
  end
end
