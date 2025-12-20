class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.admin?
      can :manage, :all
    elsif user.school_admin?
      # Can manage their own school
      can :read, School, id: user.school_id
      can :update, School, id: user.school_id

      # Can manage courses/batches belonging to their school
      can :manage, Course, school_id: user.school_id
      can :manage, Batch, course: { school_id: user.school_id }

      # Can manage enrollments for batches in their school
      can :manage, Enrollment, batch: { course: { school_id: user.school_id } }

      can :manage, User, role: "student", school_id: user.school_id
    elsif user.student?
      # Can read batches in their school to enroll
      can :read, Batch, course: { school_id: user.school_id }

      # Can create an enrollment request
      can :create, Enrollment

      # Can read their own enrollments
      can :read, Enrollment, user_id: user.id

      can :read, User, id: user.id

      # Can see classmates only if their enrollment is approved
      can :classmates, Batch do |batch|
        user.enrollments.approved.exists?(batch_id: batch.id)
      end
    end
  end
end
