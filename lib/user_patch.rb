require_dependency 'user'

module UserPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      named_scope :active, :conditions => ['status = ?', User::STATUS_ACTIVE]
      named_scope :time_recorders, :conditions => "users.id IN (SELECT DISTINCT user_id FROM time_entries)"
    end
  end
  
  module ClassMethods

  end
  
  module InstanceMethods
    def budget
      deliverables.map!{|d| d.budget}.sum
    end


    def leader
      return nil if members.empty?

      leaders = members.select{|m| m.roles.map{|r| r.name}.include? 'Lead Developer'}
      return leaders.first.user unless leaders.empty?

      return members.first.user
    end
  end    
end


