module RedmineW3H
  module Patches
    module TimelogControllerPatch 
      def self.included(base) # :nodoc:
        # Same as typing in the class 
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          def create
            @time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :user => User.current, :spent_on => User.current.today)
            @time_entry.attributes = params[:time_entry]
            
            call_hook(:controller_timelog_edit_before_save, { :params => params, :time_entry => @time_entry })

            success = true
            unless params[:date_from].empty?
              Date.parse(params[:date_from])
              Date.parse(params[:date_to])

              (params[:date_from]..params[:date_to]).each do |date|
                t = @time_entry.clone
                t.spent_on = date
                set_hours(t)
                success &&= t.save
              end
            else
              set_hours(@time_entry)
              success = @time_entry.save
            end

            if success
              respond_to do |format|
                format.html {
                  flash[:notice] = l(:notice_successful_update)
                  redirect_back_or_default :action => 'index', :project_id => @time_entry.project
                }
                format.api  { render :action => 'show', :status => :created, :location => time_entry_url(@time_entry) }
              end
            else
              respond_to do |format|
                format.html { render :action => 'edit' }
                format.api  { render_validation_errors(@time_entry) }
              end
            end    
          end

          def set_hours(time_entry)
            if params[:quota_specified] == "true"
              existing = User.current.time_entries.find(:all, :conditions => ['spent_on = ?', time_entry.spent_on]).map(&:hours).sum
              time_entry.hours = [0, User.current.quota - existing].max
            end
          end
        end
      end
    end
  end
end
