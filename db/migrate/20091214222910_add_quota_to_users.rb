class AddQuotaToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :quota, :decimal
  end

  def self.down
    remove_column :users, :quota
  end
end
