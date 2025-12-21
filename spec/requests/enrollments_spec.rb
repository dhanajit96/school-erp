require 'rails_helper'

RSpec.describe "Enrollments", type: :request do
  let(:school) { create(:school) }
  let(:school_admin) { create(:user, :school_admin, school: school) }


  let(:course) { create(:course, school: school) }
  let(:batch) { create(:batch, course: course) }
  let(:student) { create(:user, :student, school: school) }

  before { sign_in school_admin, scope: :user }

  describe "POST /batches/:id/enrollments (Direct Add)" do
    it "adds a student directly as approved" do
      expect {
        post batch_enrollments_path(batch), params: { user_id: student.id }
      }.to change(Enrollment, :count).by(1)

      expect(Enrollment.last.status).to eq("approved")
      expect(flash[:notice]).to include("Successfully added")
    end
  end

  describe "PATCH /enrollments/:id/approve" do
    let(:enrollment) { create(:enrollment, batch: batch, user: student, status: :pending) }

    it "approves a pending request" do
      patch approve_enrollment_path(enrollment)
      expect(enrollment.reload.status).to eq("approved")
    end
  end
end
