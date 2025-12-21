module Api
  module V1
    class SchoolsController < BaseController
      load_and_authorize_resource except: [ :index, :create ]

      def index
        authorize! :manage, School

        @schools = School.all
        render json: SchoolBlueprint.render(@schools), status: :ok
      end

      def show
        render json: SchoolBlueprint.render(@school), status: :ok
      end

      def create
        authorize! :create, School
        @school = School.new(school_params)

        if @school.save
          render json: SchoolBlueprint.render(@school), status: :created
        else
          render json: { errors: @school.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def school_params
        params.require(:school).permit(:name, :address, :subdomain)
      end
    end
  end
end
