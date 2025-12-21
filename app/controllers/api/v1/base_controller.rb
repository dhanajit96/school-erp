module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_user!

      rescue_from CanCan::AccessDenied do |exception|
        render json: { error: "Access Denied", message: exception.message }, status: :forbidden
      end

      rescue_from ActiveRecord::RecordNotFound do |exception|
        render json: { error: "Not Found", message: exception.message }, status: :not_found
      end

      def current_user
        @current_user ||= super
      end
    end
  end
end
