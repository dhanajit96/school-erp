require 'rails_helper'

RSpec.describe "API V1 Schools", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:school_admin) { create(:user, :school_admin) }
  let!(:schools) { create_list(:school, 3) }

  describe 'GET /api/v1/schools' do
    context 'as Super Admin' do
      it 'returns list of schools' do
        get '/api/v1/schools', headers: authenticated_header(admin)
        expect(response).to have_http_status(200)
        expect(json.size).to eq(3)
      end
    end

    context 'as School Admin' do
      it 'returns forbidden' do
        get '/api/v1/schools', headers: authenticated_header(school_admin)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /api/v1/schools' do
    let(:valid_params) { { school: { name: 'New API School', address: 'Web', subdomain: 'api' } } }

    it 'creates a school if admin' do
      expect {
        post '/api/v1/schools', params: valid_params.to_json, headers: authenticated_header(admin)
      }.to change(School, :count).by(1)
      expect(response).to have_http_status(:created)
    end
  end
end
