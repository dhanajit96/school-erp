require 'rails_helper'

RSpec.describe "API V1 Authentication", type: :request do
  let(:user) { create(:user, email: 'test@example.com', password: 'password123') }
  let(:url) { '/api/v1/login' }
  let(:params) do
    {
      user: {
        email: user.email,
        password: 'password123'
      }
    }
  end

  context 'when params are correct' do
    before do
      post url, params: params
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'returns JTI token in Authorization header' do
      expect(response.headers['Authorization']).to be_present
    end

    it 'returns the user email' do
      expect(json['user']['email']).to eq(user.email)
    end
  end

  context 'when login fails' do
    before do
      post url, params: { user: { email: user.email, password: 'wrong_password' } }
    end

    it 'returns unathorized status' do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when logging out' do
    it 'returns 200 on logout' do
      delete '/api/v1/logout', headers: authenticated_header(user)
      expect(response).to have_http_status(200)
    end
  end
end
