class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    # 1. Authorization Guard
    authorize! :index, User

    # 2. Dynamic Title & Breadcrumbs
    if current_user.admin?
      @page_title = "User Directory"
      btn_label = "Add New User"
      # Admin sees Students and School Admins
      @students = User.where(role: [ :student, :school_admin ])
    else
      @page_title = "Student Directory"
      btn_label = "Add New Student"
      # School Admin sees ONLY students from their school
      @students = User.where(role: :student, school_id: current_user.school_id)
    end

    @breadcrumb_list = [ [ "Home", root_path ], [ "Users", nil ] ]

    # 3. Dynamic Action Button
    if can? :create, User
      @actions = [ [ btn_label, new_user_path ] ]
    else
      @actions = []
    end

    # 4. Search Logic
    if params[:search].present?
      term = "%#{params[:search]}%"
      @students = @students.where("name ILIKE ? OR email ILIKE ?", term, term)
    end

    # 5. Pagination
    @students = @students.order(created_at: :desc).page(params[:page]).per(10)
  end

  def show
    @student = User.find(params[:id])

    # Using 'authorize!' ensures School Admins can't view users from other schools
    # (as defined in Ability.rb)
    authorize! :read, @student

    @page_title = @student.name
    @breadcrumb_list = [ [ "Home", root_path ], [ "Users", users_path ], [ @student.name, nil ] ]

    @actions = []
    if can? :update, @student
      @actions << [ "Edit Profile", edit_user_path(@student) ]
    end

    # Only show enrollments if the user is a student
    if @student.student?
      @enrollments = @student.enrollments.includes(batch: :course).order(created_at: :desc)
    end
  end

  def new
    authorize! :create, User
    @user = User.new

    # Dynamic Page Title
    title = current_user.admin? ? "Register New User" : "Register New Student"
    @page_title = title
    @breadcrumb_list = [ [ "Home", root_path ], [ "Users", users_path ], [ "New", nil ] ]
    @actions = []
  end

  def create
    authorize! :create, User
    @user = User.new(user_params)

    # --- ROLE & SCHOOL ASSIGNMENT LOGIC ---
    if current_user.school_admin?
      # STRICT: School Admins can only create Students for their own school
      @user.role = :student
      @user.school_id = current_user.school_id
    elsif current_user.admin?
      # FLEXIBLE: Admin can set role via form, but we ensure a default if missing
      @user.role ||= :student
      # Admin can optionally set school_id via form (required for SchoolAdmin role)
    end

    if @user.save
      redirect_to users_path, notice: "#{@user.role.humanize} created successfully."
    else
      @page_title = current_user.admin? ? "Register New User" : "Register New Student"
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
    authorize! :update, @user

    @page_title = "Edit User: #{@user.name}"
    @breadcrumb_list = [ [ "Home", root_path ], [ "Users", users_path ], [ "Edit", nil ] ]
    @actions = []
  end

  def update
    @user = User.find(params[:id])
    authorize! :update, @user

    # Handle password update: if blank, remove keys so Devise doesn't invalidate the record
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update(user_params)
      redirect_to user_path(@user), notice: "User details updated successfully."
    else
      @page_title = "Edit User"
      render :edit
    end
  end

  private

  def user_params
    # Base permitted params
    permitted = [ :name, :email, :password, :password_confirmation ]

    # Admin allows Role and School assignment
    if current_user.admin?
      permitted += [ :role, :school_id ]
    end

    params.require(:user).permit(permitted)
  end
end
