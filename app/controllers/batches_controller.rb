class BatchesController < ApplicationController
  before_action :authenticate_user!
  # Load course if course_id is present (for nested routes)
  load_and_authorize_resource :course, except: [:enroll, :show]
  load_and_authorize_resource :batch, through: :course, only: [:create, :new]
  load_and_authorize_resource only: [:enroll, :show]

  def new
    @page_title = "Add Batch to #{@course.name}"
    @breadcrumb_list = [
      ["Home", root_path], 
      ["Courses", courses_path], 
      [@course.name, nil],
      ["New Batch", nil]
    ]
    @actions = []
  end

  def create
    if @batch.save
      redirect_to courses_path, notice: 'Batch created.'
    else
      @page_title = "Add Batch"
      render :new
    end
  end

  def show
    @page_title = "Batch Details: #{@batch.name}"
    @breadcrumb_list = [
      ["Home", root_path], 
      ["My Batches", root_path],
      [@batch.name, nil]
    ]
    @actions = []
    @students = @batch.students
  end

  def enroll
    enrollment = current_user.enrollments.build(batch: @batch, status: :pending)
    if enrollment.save
      redirect_to root_path, notice: 'Request sent.'
    else
      redirect_to root_path, alert: 'Could not enroll.'
    end
  end

  private
  def batch_params
    params.require(:batch).permit(:name, :start_date, :end_date)
  end
end