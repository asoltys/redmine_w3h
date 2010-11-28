class AddForecastToDeliverables < ActiveRecord::Migration
  def self.up
    add_column :deliverables, :forecast, :decimal, :precision => 15, :scale => 2
  end
  
  def self.down
    remove_column :deliverables, :forecast
  end
end

