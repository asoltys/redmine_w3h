#!/usr/bin/env ruby
require 'redmine_plugin_support'

Dir[File.expand_path(File.dirname(__FILE__)) + "/lib/tasks/**/*.rake"].sort.each { |ext| load ext }

RedminePluginSupport::Base.setup do |plugin|
  plugin.project_name = 'redmine_w3h'
  plugin.default_task = [:spec]
  plugin.tasks = [:doc, :release, :clean, :spec, :stats]
  # TODO: gem not getting this automaticly
  plugin.redmine_root = File.expand_path(File.dirname(__FILE__) + '/../../../')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "redmine_w3h"
    s.summary = "A Timesheet plugin for Redmine to show timelogs for all projects"
    s.email = "edavis@littlestreamsoftware.com"
    s.homepage = "https://projects.littlestreamsoftware.com/projects/redmine-timesheet"
    s.description = "A plugin to show and filter timelogs across all projects in Redmine."
    s.authors = ["Eric Davis"]
    s.files =  FileList[
                        "[A-Z]*",
                        "init.rb",
                        "{bin,generators,lib,test,app,assets,config}/**/*",
                        'lib/jeweler/templates/.gitignore'
                       ]
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
