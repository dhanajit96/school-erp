class SchoolsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @page_title = "Manage Schools"
    @breadcrumb_list = [["Home", root_path], ["Schools", nil]]
    # The 'nil' url makes it the active/last item in breadcrumb logic
    
    @actions = [["Add School", new_school_path]]
  end

  def new
    @page_title = "Create New School"
    @breadcrumb_list = [["Home", root_path], ["Schools", schools_path], ["New", nil]]
    @actions = []
  end

  def create
    if @school.save
      redirect_to schools_path, notice: "School created successfully."
    else
      @page_title = "Create New School"
      @breadcrumb_list = [["Home", root_path], ["Schools", schools_path], ["New", nil]]
      render :new
    end
  end

  def edit
    @page_title = "Edit School"
    @breadcrumb_list = [["Home", root_path], ["Schools", schools_path], [@school.name, nil]]
    @actions = []
  end

  def update
    if @school.update(school_params)
      redirect_to schools_path, notice: "School updated."
    else
      @page_title = "Edit School"
      render :edit
    end
  end

  private

  def school_params
    params.require(:school).permit(:name, :address, :subdomain)
  end
end