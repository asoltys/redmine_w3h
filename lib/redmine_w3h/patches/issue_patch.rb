module RedmineGOC
  module Patches
    module IssuePatch
      def self.included(base) 
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable 
          belongs_to :deliverable
          after_save :update_time_entries

          def update_time_entries
            TimeEntry.update_all("deliverable_id = #{deliverable_id}", "issue_id = #{id}") if deliverable_id.is_a? Numeric
          end

          def spent_hours(user = nil, date = nil)
            filtered_entries = time_entries.clone
            filtered_entries = filtered_entries.select{|e| e.user == user} unless user.nil?
            filtered_entries = filtered_entries.select{|e| e.spent_on == date} unless date.nil?
            filtered_entries.map!{|e| e.hours}.sum
          end

          def get_image(day)
            if day == start_date && day == due_date
              'bullet_diamond.png'
            elsif day == start_date
              'bullet_go.png'
            elsif day == due_date
              'bullet_end.png'
            end
          end
        end
      end
      
      module ClassMethods
      end
      
      module InstanceMethods
        # Wraps the association to get the Deliverable subject.  Needed for the 
        # Query and filtering
        def deliverable_subject
          unless self.deliverable.nil?
            return self.deliverable.subject
          end
        end
      end    
    end
  end
end
