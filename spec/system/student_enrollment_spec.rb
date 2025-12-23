require 'rails_helper'

RSpec.describe "Student Enrollment", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let(:school) { create(:school) }
  let(:student) { create(:user, :student, school: school) }
  let(:course) { create(:course, school: school, name: "Physics 101") }
  let!(:batch) { create(:batch, course: course, name: "Morning Batch") }

  before do
    sign_in student
  end

  it "allows a student to request enrollment" do
    visit root_path

    # 1. Go to courses
    click_link "Courses"

    # 2. Find the batch in the accordion/list
    expect(page).to have_content("Physics 101")
    expect(page).to have_content("Morning Batch")

    # 3. Click the Enroll button
    # Note: If you used 'button_to' in Rails, this must be 'click_button'
    click_button "Request Enrollment"

    # 4. Verify Success Message
    expect(page).to have_content("Enrollment request sent successfully")

    # 5. Verify the button changed state (e.g., to a status badge)
    expect(page).to have_content("Pending")
  end
end
