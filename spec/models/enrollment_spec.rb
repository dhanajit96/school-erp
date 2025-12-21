require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  it "validates uniqueness of user within a batch" do
    user = create(:user)
    batch = create(:batch)
    create(:enrollment, user: user, batch: batch)

    duplicate = build(:enrollment, user: user, batch: batch)
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:user_id]).to include("is already enrolled in this batch")
  end
end
