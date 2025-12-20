class EnrollmentsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @page_title = "Enrollment Requests"
    @breadcrumb_list = [ [ "Home", root_path ], [ "Enrollments", nil ] ]
    @actions = [] # No actions, just a list to approve/deny

    # Filter for the current school admin
    @pending_enrollments = Enrollment.joins(batch: :course)
                                     .where(courses: { school_id: current_user.school_id })
                                     .where(status: :pending)
  end

  # GET /batches/:batch_id/enrollments/new
  def new
    @batch = Batch.find(params[:batch_id])
    @enrollment = @batch.enrollments.build

    # Filter students:
    # 1. Must be a student role
    # 2. Must belong to the current admin's school
    # 3. Must NOT already be enrolled in this batch
    enrolled_ids = @batch.enrollments.pluck(:user_id)
    @available_students = User.where(role: :student, school_id: current_user.school_id)
                              .where.not(id: enrolled_ids)

    @page_title = "Add Student to Batch"
    @breadcrumb_list = [ [ "Home", root_path ], [ "Courses", courses_path ], [ @batch.name, batch_path(@batch) ], [ "Add Student", nil ] ]
  end

  # POST /batches/:batch_id/enrollments
  def create
    @batch = Batch.find(params[:batch_id])
    @enrollment = @batch.enrollments.build(enrollment_params)

    # Direct add = Automatically Approved
    @enrollment.status = :approved
    @enrollment.request_date = Time.now

    if @enrollment.save
      redirect_to batch_path(@batch), notice: "#{@enrollment.user.name} was successfully added to the batch."
    else
      redirect_to new_batch_enrollment_path(@batch), alert: "Could not add student. Please select a valid student."
    end
  end

  def approve
    @enrollment.approved!
    redirect_back fallback_location: enrollments_path, notice: "Student approved."
  end

  def deny
    @enrollment.denied!
    redirect_back fallback_location: enrollments_path, notice: "Student denied."
  end

  private

  def enrollment_params
    params.require(:enrollment).permit(:user_id)
  end
end
