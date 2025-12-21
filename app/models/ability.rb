class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud

    user ||= User.new
    if user.admin?
      can :manage, :all

    elsif user.school_admin?
      can [ :read, :update ], School, id: user.school_id

      can :manage, Course, school_id: user.school_id
      can :manage, Batch, course: { school_id: user.school_id }
      can :create, Batch, course: { school_id: user.school_id }

      can :manage, Enrollment, batch: { course: { school_id: user.school_id } }

      can :create, User

      can :manage, User, role: "student", school_id: user.school_id
      can :read, User, id: user.id

    elsif user.student?
      can :read, Course, school_id: user.school_id

      can :index, Batch, course: { school_id: user.school_id }

      can :create, Enrollment

      can :read, Enrollment, user_id: user.id

      can :enroll, Batch do |batch|
        batch.course.school_id == user.school_id && !user.enrollments.exists?(batch_id: batch.id)
      end

      can :show, Batch do |batch|
        user.enrollments.approved.exists?(batch_id: batch.id)
      end

      can [ :read ], User, id: user.id

      cannot :index, User
    end
  end
end
