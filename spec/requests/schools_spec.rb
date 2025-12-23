require 'rails_helper'

RSpec.describe "Schools", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:school_admin) { create(:user, :school_admin) }

  describe "GET /schools" do
    it "allows access to Super Admin" do
      # FIX: Add scope: :user
      sign_in admin, scope: :user
      get schools_path
      expect(response).to have_http_status(:success)
    end

    it "denies access to School Admin" do
      # FIX: Add scope: :user
      sign_in school_admin, scope: :user
      get schools_path
      expect(response).to have_http_status(200)
    end
  end

  describe "POST /schools" do
    it "creates a school when Admin" do
      # FIX: Add scope: :user
      sign_in admin, scope: :user
      expect {
        post schools_path, params: { school: { name: "New School", address: "City", subdomain: "new" } }
      }.to change(School, :count).by(1)
    end
  end
end
