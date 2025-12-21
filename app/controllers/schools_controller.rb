class SchoolsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @page_title = "Manage Schools"
    @breadcrumb_list = [ [ "Home", root_path ], [ "Schools", nil ] ]
    # The 'nil' url makes it the active/last item in breadcrumb logic

    @actions = [ [ "Add School", new_school_path ] ]
  end

  def show
    # @school is already loaded by load_and_authorize_resource
    #
    @school_admins = @school.users.where(role: :school_admin)

    @page_title = @school.name
    @breadcrumb_list = [ [ "Home", root_path ], [ "Schools", schools_path ], [ @school.name, nil ] ]

    # Action buttons for Admin
    @actions = []
    if can? :update, @school
      @actions << [ "Edit School", edit_school_path(@school) ]
    end

    # Data Fetching
    # 1. Students belonging to this school
    @students = @school.users.where(role: :student).order(created_at: :desc).page(params[:student_page]).per(5)

    # 2. Courses belonging to this school
    @courses = @school.courses.includes(:batches)

    # 3. Recent/Active Batches (Through courses)
    @batches = @school.batches.includes(:course).order(start_date: :desc).page(params[:batch_page]).per(5)
  end

  def new
    @page_title = "Create New School"
    @breadcrumb_list = [ [ "Home", root_path ], [ "Schools", schools_path ], [ "New", nil ] ]
    @actions = []
  end

  def create
    if @school.save
      redirect_to schools_path, notice: "School created successfully."
    else
      @page_title = "Create New School"
      @breadcrumb_list = [ [ "Home", root_path ], [ "Schools", schools_path ], [ "New", nil ] ]
      render :new
    end
  end

  def edit
    @page_title = "Edit School"
    @breadcrumb_list = [ [ "Home", root_path ], [ "Schools", schools_path ], [ @school.name, nil ] ]
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
