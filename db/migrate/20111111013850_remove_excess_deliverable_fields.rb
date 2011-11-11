class RemoveExcessDeliverableFields < ActiveRecord::Migration
  def self.up
    remove_column :deliverables, :forecast
    remove_column :deliverables, :project_manager_signoff
    remove_column :deliverables, :client_signoff
    remove_column :deliverables, :overhead
    remove_column :deliverables, :materials
    remove_column :deliverables, :profit
    remove_column :deliverables, :cost_per_hour
    remove_column :deliverables, :total_hours
    remove_column :deliverables, :fixed_cost
    remove_column :deliverables, :overhead_percent
    remove_column :deliverables, :materials_percent
    remove_column :deliverables, :profit_percent
    remove_column :deliverables, :financial_coding_provided
    remove_column :deliverables, :signed_copy_delivered
    remove_column :deliverables, :invoiced
  end

  def self.down
  end
end
