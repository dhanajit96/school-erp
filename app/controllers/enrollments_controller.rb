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

  def approve
    @enrollment.approved!
    redirect_back fallback_location: enrollments_path, notice: "Student approved."
  end

  def deny
    @enrollment.denied!
    redirect_back fallback_location: enrollments_path, notice: "Student denied."
  end
end
