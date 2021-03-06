class DeliverablesController < ApplicationController
  unloadable
  layout 'base'
  before_filter :find_project
  before_filter :authorize, :except => :summary
  before_filter :set_year
  before_filter :find_deliverables, :only => [:index, :create]

  helper :sort
  include SortHelper
  helper :attachments
  include AttachmentsHelper

  # Main deliverable list
  def index
    respond_to do |format|
      format.html { render :action => 'index', :layout => !request.xhr? }
    end
  end

  def new
		@deliverable_custom_fields = DeliverableCustomField.find(:all, :order => "#{CustomField.table_name}.position")
    @deliverable = Deliverable.new
    @deliverable.project = @project
  end
  
  # Saves a new Deliverable
  def create
		@deliverable_custom_fields = DeliverableCustomField.find(:all, :order => "#{CustomField.table_name}.position")
    @deliverable = Deliverable.new(params[:deliverable])
    @deliverable.project = @project

    respond_to do |format|
      if @deliverable.save
        attachments = Attachment.attach_files(@deliverable, params[:attachments])
        render_attachment_warning_if_needed(@deliverable)
        @flash = l(:notice_successful_create)
        format.html { redirect_to :action => 'index', :id => @project.id }
      else
        format.html { render :action => 'new', :id => @project.id}
      end
    end

  end

  # Builds the edit form for the Deliverable
  def edit
    @deliverable = Deliverable.find_by_id_and_project_id(params[:deliverable_id], params[:id])
  end

  # Updates an existing Deliverable, optionally changing it's type
  def update
    @deliverable = Deliverable.find(params[:deliverable_id])
    
    respond_to do |format|
      if @deliverable.update_attributes(params[:deliverable])
        Attachment.attach_files(@deliverable, params[:attachments])
        render_attachment_warning_if_needed(@deliverable)
        @flash = l(:notice_successful_create)
        format.html { redirect_to :action => 'index', :id => @project.id }
      else
        format.html { render :action => 'edit', :id => @project.id}
      end
    end
  end
  
  # Removes the Deliverable
  def destroy
    @deliverable = Deliverable.find_by_id_and_project_id(params[:deliverable_id], @project.id)
    
    render_404 and return unless @deliverable
    render_403 and return unless @deliverable.editable_by?(User.current)
    @deliverable.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to :action => 'index', :id => @project.id
  end
  
  # Create a query in the session and redirects to the issue list with that query
  def issues
    @query = Query.new(:name => "_")
    @query.project = @project
    unless params[:deliverable_id] == 'none'
      @query.add_filter("deliverable_id", '=', [params[:deliverable_id]])
    else
      @query.add_filter("deliverable_id", '!*', ['']) # None
      @query.add_filter("status_id", '*', ['']) # All statuses
    end

    session[:query] = {:project_id => @query.project_id, :filters => @query.filters}

    redirect_to :controller => 'issues', :action => 'index', :project_id => @project.id
  end
  
  # Assigns issues to the Deliverable based on their Version
  def bulk_assign_issues
    @deliverable = Deliverable.find_by_id_and_project_id(params[:deliverable_id], @project.id)
    
    render_404 and return unless @deliverable
    render_403 and return unless @deliverable.editable_by?(User.current)
    
    number_updated = @deliverable.assign_issues_by_version(params[:version][:id])
    
    flash[:notice] = l(:message_updated_issues, number_updated)
    redirect_to :action => 'index', :id => @project.id
  end

  private

  def find_project
    if params[:id]
      @project = Project.find(params[:id])
    end
  end

  def find_deliverables
    @deliverables = Deliverable.find(:all, 
      { 
       :include => :project,
       :conditions => "#{@project.project_condition(Setting.display_subprojects_issues?)} 
        AND due BETWEEN '#{params[:year]}-04-01' AND '#{params[:year].to_i + 1}-03-31'",
       :order => 'deliverables.number ASC'
      }
    )
  end
  
  def get_settings
		@deliverable_custom_fields = DeliverableCustomField.find(:all, :order => "#{CustomField.table_name}.position")
    @settings = Setting.plugin_redmine_w3h
  end

  # Sorting orders
  def sort_order
    if session[@sort_name] && %w(score spent progress labor_budget).include?(session[@sort_name][:key])
      return {  }
    else
      return { :order => sort_clause }
    end
  end
  
  # Sort +deliverables+ manually using the virtual fields
  def sort_if_needed(deliverables)
    if session[@sort_name] && %w(score spent progress labor_budget).include?(session[@sort_name][:key])
      case session[@sort_name][:key]
      when "score"
          sorted = deliverables.sort {|a,b| a.score <=> b.score}
      when "spent"
          sorted = deliverables.sort {|a,b| a.spent <=> b.spent}
      when "progress"
          sorted = deliverables.sort {|a,b| a.progress <=> b.progress}
      when "labor_budget"
          sorted = deliverables.sort {|a,b| a.labor_budget <=> b.labor_budget}
      end

      return sorted if session[@sort_name][:order] == 'asc'
      return sorted.reverse! if session[@sort_name][:order] == 'desc'
    else
      return deliverables
    end
  end

  def set_year
    params[:year] ||= Date.today.month < 4 ? Date.today.year - 1 : Date.today.year
  end
end
