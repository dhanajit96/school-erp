class EnrollmentsController < ApplicationController
  before_action :authenticate_user!

  # 1. We limit CanCanCan automatic loading to non-nested actions to avoid bugs.
  #    We will manually authorize :new and :create inside their methods.
  load_and_authorize_resource only: [ :index, :approve, :deny ]

  # --- LIST OF REQUESTS (For Dashboard) ---
  def index
    @page_title = "Enrollment Requests"
    @breadcrumb_list = [ [ "Home", root_path ], [ "Enrollments", nil ] ]
    @actions = []

    # Filter for the current school admin
    @pending_enrollments = Enrollment.joins(batch: :course)
                                     .where(courses: { school_id: current_user.school_id })
                                     .where(status: :pending)
  end

  # --- APPROVAL ACTIONS ---
  def approve
    @enrollment.approved!
    redirect_back fallback_location: enrollments_path, notice: "Student approved."
  end

  def deny
    @enrollment.denied!
    redirect_back fallback_location: enrollments_path, notice: "Student denied."
  end

  # --- NEW: SEARCH & ADD STUDENT (Nested under Batch) ---

  # GET /batches/:batch_id/enrollments/new
  def new
    @batch = Batch.find(params[:batch_id])

    # Manual Authorization check for creating enrollment
    authorize! :create, Enrollment

    @page_title = "Add Student to #{@batch.name}"
    @breadcrumb_list = [
      [ "Home", root_path ],
      [ "Courses", courses_path ],
      [ @batch.name, batch_path(@batch) ],
      [ "Add Student", nil ]
    ]
    @actions = []

    # --- SEARCH LOGIC ---
    # 1. Base Scope: Students from the same school
    scope = User.where(role: :student, school_id: current_user.school_id)

    # 2. Exclude: Students already enrolled in this batch
    already_enrolled_ids = @batch.enrollments.pluck(:user_id)
    scope = scope.where.not(id: already_enrolled_ids)

    # 3. Search Filter
    if params[:search].present?
      term = "%#{params[:search]}%"
      scope = scope.where("name ILIKE ? OR email ILIKE ?", term, term)
    end

    # 4. Pagination (Kaminari)
    @available_students = scope.order(:name).page(params[:page]).per(10)
  end

  # POST /batches/:batch_id/enrollments
  def create
    @batch = Batch.find(params[:batch_id])
    authorize! :create, Enrollment

    # We expect :user_id to be passed directly (from the button) OR via params[:enrollment]
    user_id = params[:user_id] || params.dig(:enrollment, :user_id)

    @enrollment = @batch.enrollments.build(user_id: user_id)

    # Direct add by Admin = Automatically Approved
    @enrollment.status = :approved
    @enrollment.request_date = Time.now

    if @enrollment.save
      # Redirect back to NEW so the admin can add another student immediately
      redirect_to new_batch_enrollment_path(@batch), notice: "Successfully added #{@enrollment.user.name}."
    else
      redirect_to new_batch_enrollment_path(@batch), alert: "Could not add student. They might already be enrolled."
    end
  end
end
