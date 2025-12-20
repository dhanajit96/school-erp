class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  layout :set_layout
  before_action :set_breadcrumb_defaults


  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: exception.message.presence || "You are not authorized to access this page."
  end
  private

  def set_layout
    if devise_controller?
      "auth"
    else
      "soyuz"
    end
  end

  def set_breadcrumb_defaults
    @page_title = "Dashboard"
    @breadcrumb_list = [] # Format: [ ["Title", url], ["Title", url] ]
    @actions = []         # Format: [ ["Button Text", url] ]
  end
end
