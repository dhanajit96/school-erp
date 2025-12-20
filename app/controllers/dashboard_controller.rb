class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @page_title = "Dashboard"
    @breadcrumb_list = { "Home" => "/" }
    @actions = {}

    if current_user.admin?
      @schools_count = School.count
      @users_count = User.count
    elsif current_user.school_admin?
      @school = current_user.school
      @courses = @school.courses
      @pending_requests = Enrollment.where(batch_id: @school.batches.ids, status: :pending)
    elsif current_user.student?
      @my_enrollments = current_user.enrollments.includes(batch: :course)
      @available_batches = Batch.where.not(id: current_user.batch_ids)
    end
  end
end
