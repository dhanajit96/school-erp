require 'rails_helper'

RSpec.describe "Users (Students)", type: :request do
  let(:school1) { create(:school) }
  let(:school2) { create(:school) }

  let(:admin) { create(:user, :school_admin, school: school1) }
  let(:student1) { create(:user, :student, school: school1, name: "Alice") }
  let(:student2) { create(:user, :student, school: school2, name: "Bob") }

  before do
    student1 # create users
    student2
    sign_in admin, scope: :user
  end

  describe "GET /students (Index)" do
    it "shows only students from the same school" do
      get users_path
      expect(response.body).to include("Alice")
      expect(response.body).not_to include("Bob")
    end
  end

  describe "POST /students (Create)" do
    it "forces the new student into the admin's school" do
      post users_path, params: { user: { name: "New Kid", email: "new@test.com", password: "password" } }

      new_user = User.last
      expect(new_user.school).to eq(school1)
      expect(new_user.role).to eq("student")
    end
  end
end
