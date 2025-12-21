module Api
  module V1
    class CoursesController < BaseController
      load_and_authorize_resource

      def index
        @courses = @courses.page(params[:page]).per(10)
        render json: {
          data: JSON.parse(CourseBlueprint.render(@courses)),
          meta: {
            current_page: @courses.current_page,
            total_pages: @courses.total_pages
          }
        }
      end

      def show
        render json: CourseBlueprint.render(@course, view: :detail)
      end

      def create
        @course.school_id = current_user.school_id
        if @course.save
          render json: CourseBlueprint.render(@course), status: :created
        else
          render json: { errors: @course.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def course_params
        params.require(:course).permit(:name, :description)
      end
    end
  end
end
