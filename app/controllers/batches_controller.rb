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
    @page_title = "Batch Details: #{@batch.name}"
    @breadcrumb_list = [
      [ "Home", root_path ],
      [ "My Batches", courses_path ],
      [ @batch.name, nil ]
    ]
    @actions = []
    @students = @batch.students
  end

  def enroll
    enrollment = current_user.enrollments.build(batch: @batch, status: :pending)
    if enrollment.save
      redirect_to root_path, notice: "Request sent."
    else
      redirect_to root_path, alert: "Could not enroll."
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
