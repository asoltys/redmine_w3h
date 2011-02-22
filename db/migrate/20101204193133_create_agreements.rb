class CreateAgreements < ActiveRecord::Migration
  def self.up
    create_table "agreements", :force => true do |t|
      t.string  "subject"
      t.text    "description"
      t.string  "category"
      t.integer "project_id"
      t.decimal "budget",                    :precision => 15, :scale => 2
      t.date    "due"
      t.string  "number"
      t.decimal "invoiced",                  :precision => 10, :scale => 2
      t.decimal "forecast",                  :precision => 10, :scale => 2
      t.boolean "project_manager_signoff",   :default => false
      t.boolean "client_signoff",            :default => false
      t.boolean "financial_coding_provided"
      t.boolean "signed_copy_delivered"
    end
  end

  def self.down
  end
end
