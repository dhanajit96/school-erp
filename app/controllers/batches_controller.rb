class BatchesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :course, except: [ :enroll, :show ]
  load_and_authorize_resource :batch, through: :course, only: [ :new, :create ]
  load_and_authorize_resource :batch, only: [ :show, :enroll, :edit, :update ]


  def new
    @page_title = "Add Batch to #{@course.name}"
    @breadcrumb_list = [
      [ "Home", root_path ],
      [ "Courses", courses_path ],
      [ @course.name, nil ],
      [ "New Batch", nil ]
    ]
    @actions = []
  end

  def create
    if @batch.save
      redirect_to courses_path, notice: "Batch created."
    else
      @page_title = "Add Batch"
      render :new
    end
  end

  def show
    @batch = Batch.find(params[:id])

    unless can?(:read, @batch) || (current_user.student? && current_user.enrollments.approved.exists?(batch_id: @batch.id))
      redirect_to root_path, alert: "Access Denied."
      return
    end

    @page_title = "Batch: #{@batch.name}"
    @breadcrumb_list = [ [ "Home", root_path ], [ "Courses", courses_path ], [ "Classmates", nil ] ]
    @actions = []

    # --- NEW: Add Action Button for School Admins ---
    if can? :create, Enrollment
      # Links to the new search form we are about to build
      @actions << [ "Add Student", new_batch_enrollment_path(@batch) ]
    end
    @students = @batch.students.joins(:enrollments).where(enrollments: { status: :approved })
  end

  # Student Action: Request to join
  def enroll
    # Check if already enrolled
    if current_user.enrollments.exists?(batch_id: @batch.id)
      redirect_to courses_path, alert: "You have already requested to join this batch."
      return
    end

    enrollment = current_user.enrollments.build(batch: @batch, status: :pending)

    if enrollment.save
      redirect_to root_path, notice: "Enrollment request sent successfully. Waiting for approval."
    else
      redirect_to courses_path, alert: "Unable to send request."
    end
  end

  def edit
    @page_title = "Edit Batch"
    @breadcrumb_list = [
      [ "Home", root_path ],
      [ "Courses", courses_path ],
      [ @batch.course.name, nil ],
      [ "Edit Batch", nil ]
    ]
    @actions = []
  end

  def update
    if @batch.update(batch_params)
      redirect_to batch_path(@batch), notice: "Batch was successfully updated."
    else
      @page_title = "Edit Batch"
      render :edit
    end
  end

  private
  def batch_params
    params.require(:batch).permit(:name, :start_date, :end_date)
  end
end
