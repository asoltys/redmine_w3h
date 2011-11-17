#!/usr/bin/env ruby

Dir[File.expand_path(File.dirname(__FILE__)) + "/lib/tasks/**/*.rake"].sort.each { |ext| load ext }

RedminePluginSupport::Base.setup do |plugin|
  plugin.project_name = 'redmine_w3h'
  plugin.tasks = [:doc, :release, :clean, :stats]
  plugin.redmine_root = File.expand_path(File.dirname(__FILE__) + '/../../../')
end
