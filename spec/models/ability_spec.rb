require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  describe "Super Admin" do
    let(:admin) { create(:user, :admin) }
    subject { Ability.new(admin) }

    it "can manage everything" do
      expect(subject).to be_able_to(:manage, :all)
    end
  end

  describe "School Admin" do
    let(:school1) { create(:school) }
    let(:school2) { create(:school) }
    let(:admin) { create(:user, :school_admin, school: school1) }
    let(:student1) { create(:user, :student, school: school1) }
    let(:student2) { create(:user, :student, school: school2) }
    let(:course1) { create(:course, school: school1) }
    let(:course2) { create(:course, school: school2) }

    subject { Ability.new(admin) }

    it "can manage their own school" do
      expect(subject).to be_able_to(:update, school1)
    end

    it "cannot manage other schools" do
      expect(subject).not_to be_able_to(:update, school2)
    end

    it "can manage students in their school" do
      expect(subject).to be_able_to(:manage, student1)
    end

    it "cannot manage students in other schools" do
      expect(subject).not_to be_able_to(:manage, student2)
    end

    it "can manage courses in their school" do
      expect(subject).to be_able_to(:create, Course)
      expect(subject).to be_able_to(:update, course1)
    end

    it "cannot manage courses in other schools" do
      expect(subject).not_to be_able_to(:update, course2)
    end
  end

  describe "Student" do
    let(:school) { create(:school) }
    let(:user) { create(:user, :student, school: school) }
    let(:course) { create(:course, school: school) }
    let(:batch) { create(:batch, course: course) }

    subject { Ability.new(user) }

    it "can read courses from their school" do
      expect(subject).to be_able_to(:read, course)
    end

    it "can create enrollment requests" do
      expect(subject).to be_able_to(:create, Enrollment)
    end

    it "cannot access classmates (show batch) if pending" do
      create(:enrollment, user: user, batch: batch, status: :pending)
      expect(subject).not_to be_able_to(:show, batch)
    end

    it "can access classmates if approved" do
      create(:enrollment, :approved, user: user, batch: batch)
      expect(subject).to be_able_to(:show, batch)
    end
  end
end
