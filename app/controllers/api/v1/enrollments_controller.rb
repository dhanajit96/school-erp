module Api
  module V1
    class EnrollmentsController < BaseController

      def create
        batch = Batch.find(params[:batch_id])
        authorize! :enroll, batch 

        enrollment = current_user.enrollments.build(batch: batch, status: :pending)

        if enrollment.save
          render json: { message: "Enrollment requested successfully" }, status: :created
        else
          render json: { errors: enrollment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def index
        authorize! :manage, Enrollment
        @pending = Enrollment.joins(batch: :course)
                             .where(courses: { school_id: current_user.school_id })
                             .where(status: :pending)

        render json: @pending.as_json(include: { user: { only: [ :name, :email ] }, batch: { only: :name } })
      end

      def approve
        enrollment = Enrollment.find(params[:id])
        authorize! :manage, enrollment
        enrollment.approved!
        render json: { message: "Approved" }
      end
    end
  end
end
