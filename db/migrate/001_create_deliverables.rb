class CreateDeliverables < ActiveRecord::Migration
  class SchemaMigration < ActiveRecord::Base
    set_primary_key :version
  end

  def self.up
    # Pretend like we've run the migrations in the w3h plugin if we've already run them for the old budget and timesheet plugins
    ['budget_plugin', 'timesheet_plugin'].each do |legacy_plugin|
      SchemaMigration.find(:all, :conditions => "version LIKE '%#{legacy_plugin.gsub('_', '\\_')}%'").each do |migration|
        unless migration.version == '1-budget_plugin'
          s = SchemaMigration.new
          s.version = migration.version.gsub(legacy_plugin, 'redmine_w3h')
          s.save
        end
      end
    end

    if SchemaMigration.find(:all, :conditions => "version = '1-budget_plugin'").empty?
      create_table :deliverables do |t|
        t.column :subject, :string
        t.column :due_date, :date
        t.column :description, :text
        t.column :type, :string
        t.column :cost, :decimal, :precision => 15, :scale => 2
        t.column :project_manager_signoff, :boolean, :default => false
        t.column :client_signoff, :boolean, :default => false
      end
    end
  end

  def self.down
    drop_table :deliverables
  end
end
