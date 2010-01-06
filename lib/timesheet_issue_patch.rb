require_dependency 'issue'

# Patches Redmine's Issues dynamically.  Adds a relationship 
# Issue +belongs_to+ to Deliverable
module TimesheetIssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      def spent_hours(user = nil, date = nil)
        filtered_entries = time_entries.clone
        filtered_entries = filtered_entries.select{|e| e.user == user} unless user.nil?
        filtered_entries = filtered_entries.select{|e| e.spent_on == date} unless date.nil?
        filtered_entries.map!{|e| e.hours}.sum
      end
    end

  end
  
  module ClassMethods
    
  end
  
  module InstanceMethods

  end    
end


