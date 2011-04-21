module RedmineW3H
  module Patches
    module CustomFieldHelperPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          has_many :deliverables

          def ancestor_deliverables
            (deliverables + ancestors.map{|a| a.deliverables}.flatten).uniq & Deliverable.all
          end
        end
      end

      module InstanceMethods
        def budget
          deliverables.map!{|d| d.budget}.sum
        end

        def leader
          return nil if members.empty?

          leaders = members.select{|m| m.roles.map{|r| r.name}.include? 'Lead'}
          return leaders.first.user unless leaders.empty?

          return members.first.user
        end
      end    
    end
  end
end
