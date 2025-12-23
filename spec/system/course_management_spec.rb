require 'rails_helper'

RSpec.describe "Course Management", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let(:school) { create(:school) }
  let(:school_admin) { create(:user, :school_admin, school: school) }

  before do
    # Helper to sign in quickly in specs (requires Devise integration helper in rails_helper)
    sign_in school_admin 
  end

  it "allows a School Admin to create a new course" do
    visit root_path
    
    # Navigate using the actual links on the page
    click_link "Courses" 
    
    # Expect to see the course list, then click Add
    expect(page).to have_content("Courses")
    click_link "Add Course"

    # Fill out the form
    fill_in "Name", with: "Advanced Ruby on Rails"
    fill_in "Description", with: "Learn system testing with Capybara"
    click_button "Create Course"

    # Verify the result
    expect(page).to have_content("Course created.")
    expect(page).to have_content("Advanced Ruby on Rails")
    expect(page).to have_content("Learn system testing with Capybara")
  end
end