require 'rails_helper'

RSpec.describe "CoursesController", type: :request do
  # --- Setup Data ---
  let(:school) { create(:school) }
  let(:other_school) { create(:school) }

  # Users
  let(:school_admin) { create(:user, :school_admin, school: school) }
  let(:student) { create(:user, :student, school: school) }
  let(:other_school_user) { create(:user, :school_admin, school: other_school) }

  # Courses
  let!(:course_math) { create(:course, school: school, name: "Mathematics") }
  let!(:course_science) { create(:course, school: school, name: "Science") }
  let!(:other_course) { create(:course, school: other_school, name: "Other School History") }

  # --- GET /courses (Index) ---
  describe "GET /courses" do
    context "when user is not logged in" do
      it "redirects to login page" do
        get courses_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in as School Admin" do
      before do
        sign_in school_admin, scope: :user
        get courses_path
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "shows courses belonging to their school" do
        expect(response.body).to include("Mathematics")
        expect(response.body).to include("Science")
      end

      it "does NOT show courses from other schools" do
        expect(response.body).not_to include("Other School History")
      end

      it "shows the 'Add Course' button" do
        expect(response.body).to include("Add Course")
      end
    end

    context "when logged in as Student" do
      before do
        sign_in student, scope: :user
        get courses_path
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "shows courses belonging to their school" do
        expect(response.body).to include("Mathematics")
      end

      it "does NOT show the 'Add Course' button" do
        # Students can read courses but cannot create them
        expect(response.body).not_to include("Add New Course")
      end
    end
  end

  # --- GET /courses/new ---
  describe "GET /courses/new" do
    context "when logged in as School Admin" do
      before { sign_in school_admin, scope: :user }

      it "renders the new template" do
        get new_course_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when logged in as Student" do
      before { sign_in student, scope: :user }

      it "redirects to root (Access Denied)" do
        get new_course_path
        # CanCanCan usually redirects to root on AccessDenied
        expect(response).to redirect_to(root_path)
      end
    end
  end

  # --- POST /courses (Create) ---
  describe "POST /courses" do
    let(:valid_attributes) { { name: "Physics", description: "Intro to Physics" } }
    let(:invalid_attributes) { { name: "", description: "" } }

    context "when logged in as School Admin" do
      before { sign_in school_admin, scope: :user }

      context "with valid parameters" do
        it "creates a new Course" do
          expect {
            post courses_path, params: { course: valid_attributes }
          }.to change(Course, :count).by(1)
        end

        it "assigns the course to the current user's school" do
          post courses_path, params: { course: valid_attributes }
          expect(Course.last.school).to eq(school)
        end

        it "redirects to the courses list" do
          post courses_path, params: { course: valid_attributes }
          expect(response).to redirect_to(courses_path)
        end
      end

      context "with invalid parameters" do
        it "does not create a new Course" do
          expect {
            post courses_path, params: { course: invalid_attributes }
          }.to change(Course, :count).by(0)
        end

        it "renders the new template again" do
          post courses_path, params: { course: invalid_attributes }
          expect(response.body).to include("Add New Course")
        end
      end
    end

    context "when logged in as Student" do
      before { sign_in student, scope: :user }

      it "does not create a course" do
        expect {
          post courses_path, params: { course: valid_attributes }
        }.not_to change(Course, :count)
      end

      it "redirects (Access Denied)" do
        post courses_path, params: { course: valid_attributes }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
