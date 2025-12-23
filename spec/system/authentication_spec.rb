require 'rails_helper'

RSpec.describe "User Authentication", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let(:user) { create(:user, email: "test@example.com", password: "password123") }

  it "enables a user to sign in" do
    visit new_user_session_path

    # FIX: Use the Rails-generated IDs because there are no visible labels
    fill_in "user_email", with: user.email
    fill_in "user_password", with: "password123"

    click_button "Log in"

    # Verify successful login
    expect(page).to have_content("Signed in successfully.")
    expect(page).to have_current_path(root_path)
  end

  it "shows error for invalid password" do
    visit new_user_session_path

    # FIX: Use IDs here too
    fill_in "user_email", with: user.email
    fill_in "user_password", with: "wrongpass"

    click_button "Log in"

    # Verify error message
    expect(page).to have_content("Invalid Email or password")
  end
end
