class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @page_title = "Dashboard"
    @breadcrumb_list = { "Home" => "/" }
    @actions = {}

    if current_user.admin?
      # --- SUPER ADMIN STATS ---
      @stats = {
        schools: School.count,
        students: User.where(role: :student).count,
        courses: Course.count,
        batches: Batch.count,
        enrollments: {
          pending: Enrollment.pending.count,
          approved: Enrollment.approved.count,
          denied: Enrollment.denied.count
        }
      }

    elsif current_user.school_admin?
      # --- SCHOOL ADMIN STATS ---
      @school = current_user.school
      @stats = {
        students: User.where(school: @school, role: :student).count,
        courses: @school.courses.count,
        batches: Batch.joins(:course).where(courses: { school_id: @school.id }).count,
        enrollments: {
          pending: Enrollment.joins(batch: :course).where(courses: { school_id: @school.id }, status: :pending).count,
          approved: Enrollment.joins(batch: :course).where(courses: { school_id: @school.id }, status: :approved).count,
          denied: Enrollment.joins(batch: :course).where(courses: { school_id: @school.id }, status: :denied).count
        }
      }

    elsif current_user.student?
      # --- STUDENT STATS ---
      @my_enrollments = current_user.enrollments.includes(batch: :course)
      @stats = {
        applied: @my_enrollments.count,
        approved: @my_enrollments.approved.count,
        pending: @my_enrollments.pending.count
      }
    end
  end
end
