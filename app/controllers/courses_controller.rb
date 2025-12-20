class CoursesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @page_title = "Courses"
    @breadcrumb_list = [["Home", root_path], ["Courses", nil]]
    @actions = [["Add Course", new_course_path]]
  end

  def new
    @page_title = "Add New Course"
    @breadcrumb_list = [["Home", root_path], ["Courses", courses_path], ["New", nil]]
    @actions = []
  end

  def create
    @course.school = current_user.school
    if @course.save
      redirect_to courses_path, notice: 'Course created.'
    else
      @page_title = "Add New Course"
      render :new
    end
  end

  # ... other actions ...
  
  private
  def course_params
    params.require(:course).permit(:name, :description)
  end
end