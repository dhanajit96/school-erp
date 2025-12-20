class UsersController < ApplicationController
  before_action :authenticate_user!

  # We manually authorize for safety, or use load_and_authorize_resource logic carefully

  def index
    authorize! :index, User
    @page_title = "Student Directory"
    @breadcrumb_list = [ [ "Home", root_path ], [ "Students", nil ] ]

    # Action Button for School Admin/Admin
    if can? :create, User
      @actions = [ [ "Add New Student", new_user_path ] ]
    else
      @actions = []
    end

    @students = User.where(role: :student)
    @students = @students.where(school_id: current_user.school_id) if current_user.school_admin?

    if params[:search].present?
      term = "%#{params[:search]}%"
      @students = @students.where("name ILIKE ? OR email ILIKE ?", term, term)
    end

    @students = @students.order(created_at: :desc).page(params[:page]).per(10)
  end

  def show
    @student = User.find(params[:id])
    authorize! :read, @student

    @page_title = "Student Profile"
    @breadcrumb_list = [ [ "Home", root_path ], [ "Students", users_path ], [ @student.name, nil ] ]
    @actions = []

    # Allow edit from show page
    if can? :update, @student
      @actions << [ "Edit Profile", edit_user_path(@student) ]
    end

    @enrollments = @student.enrollments.includes(batch: :course).order(created_at: :desc)
  end

  # --- NEW METHODS ---

  def new
    authorize! :create, User
    @user = User.new
    @page_title = "Register New Student"
    @breadcrumb_list = [ [ "Home", root_path ], [ "Students", users_path ], [ "New", nil ] ]
    @actions = []
  end

  def create
    authorize! :create, User
    @user = User.new(user_params)

    # Force role to student
    @user.role = :student

    # Assign School: If School Admin, force their school. If Super Admin, use form selection or nil.
    if current_user.school_admin?
      @user.school_id = current_user.school_id
    end

    if @user.save
      redirect_to users_path, notice: "Student created successfully."
    else
      @page_title = "Register New Student"
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
    authorize! :update, @user

    @page_title = "Edit Student: #{@user.name}"
    @breadcrumb_list = [ [ "Home", root_path ], [ "Students", users_path ], [ "Edit", nil ] ]
    @actions = []
  end

  def update
    @user = User.find(params[:id])
    authorize! :update, @user

    # Handle password update: if blank, remove it so Devise doesn't complain
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update(user_params)
      redirect_to user_path(@user), notice: "Student details updated."
    else
      @page_title = "Edit Student"
      render :edit
    end
  end

  private

  def user_params
    # Only allow Admin to set school_id explicitly
    permitted = [ :name, :email, :password, :password_confirmation ]
    permitted << :school_id if current_user.admin?
    params.require(:user).permit(permitted)
  end
end
