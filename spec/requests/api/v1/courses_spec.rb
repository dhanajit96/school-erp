require 'rails_helper'

RSpec.describe "API V1 Courses", type: :request do
  let(:school_a) { create(:school) }
  let(:school_b) { create(:school) }

  let(:admin_a) { create(:user, :school_admin, school: school_a) }
  let(:student_a) { create(:user, :student, school: school_a) }

  let!(:course_a) { create(:course, school: school_a, name: "Math A") }
  let!(:course_b) { create(:course, school: school_b, name: "Math B") }

  describe 'GET /api/v1/courses' do
    it 'shows only courses from the user\'s school (School Admin)' do
      get '/api/v1/courses', headers: authenticated_header(admin_a)

      expect(response).to have_http_status(200)
      names = json['data'].map { |c| c['name'] }
      expect(names).to include("Math A")
      expect(names).not_to include("Math B")
    end

    it 'shows only courses from the user\'s school (Student)' do
      get '/api/v1/courses', headers: authenticated_header(student_a)

      expect(response).to have_http_status(200)
      names = json['data'].map { |c| c['name'] }
      expect(names).to include("Math A")
    end
  end

  describe 'POST /api/v1/courses' do
    let(:params) { { course: { name: "New Course", description: "Desc" } } }

    it 'allows School Admin to create course' do
      expect {
        post '/api/v1/courses', params: params.to_json, headers: authenticated_header(admin_a)
      }.to change(Course, :count).by(1)

      # Ensure it was assigned to School A automatically
      expect(Course.last.school).to eq(school_a)
    end

    it 'forbids Student from creating course' do
      post '/api/v1/courses', params: params.to_json, headers: authenticated_header(student_a)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
