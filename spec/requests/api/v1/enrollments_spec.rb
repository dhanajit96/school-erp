require 'rails_helper'

RSpec.describe "API V1 Enrollments", type: :request do
  let(:school) { create(:school) }
  let(:admin) { create(:user, :school_admin, school: school) }
  let(:student) { create(:user, :student, school: school) }

  let(:course) { create(:course, school: school) }
  let(:batch) { create(:batch, course: course) }

  describe 'POST /api/v1/batches/:id/enroll' do
    it 'allows a student to request enrollment' do
      expect {
        post "/api/v1/batches/#{batch.id}/enroll", headers: authenticated_header(student)
      }.to change(Enrollment, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(Enrollment.last.status).to eq('pending')
    end
  end

  describe 'GET /api/v1/enrollments' do
    let!(:enrollment) { create(:enrollment, user: student, batch: batch, status: :pending) }

    it 'lists pending enrollments for the School Admin' do
      get '/api/v1/enrollments', headers: authenticated_header(admin)
      expect(response).to have_http_status(200)
      expect(json.first['user']['name']).to eq(student.name)
    end
  end

  describe 'PATCH /api/v1/enrollments/:id/approve' do
    let!(:enrollment) { create(:enrollment, user: student, batch: batch, status: :pending) }

    it 'approves the enrollment' do
      patch "/api/v1/enrollments/#{enrollment.id}/approve", headers: authenticated_header(admin)
      expect(response).to have_http_status(200)
      expect(enrollment.reload.status).to eq('approved')
    end
  end
end
