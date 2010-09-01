class AddQuotaToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :quota, :decimal, :precision => 15, :scale => 2
  end

  def self.down
    remove_column :users, :quota
  end
end
