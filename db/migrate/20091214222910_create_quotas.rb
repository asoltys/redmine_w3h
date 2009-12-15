class CreateQuotas < ActiveRecord::Migration
  def self.up
    create_table :quotas do |t|
      t.column :user_id, :integer
      t.column :quota, :decimal
    end
  end

  def self.down
    drop_table :quotas
  end
end
