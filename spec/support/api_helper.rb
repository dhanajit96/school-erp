module ApiHelper
  def authenticated_header(user)
    require 'devise/jwt/test_helpers'
    headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
    # This generates a valid JWT token for the specific user
    auth_headers = Devise::JWT::TestHelpers.auth_headers(headers, user)
    auth_headers
  end

  def json
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include ApiHelper, type: :request
end
