class Ability
  include CanCan::Ability

  def initialize(user)
    # Define aliases for clarity and future expansion
    alias_action :create, :read, :update, :destroy, to: :crud

    # Guest User (Not Logged In)
    user ||= User.new

    # ==========================================================
    # 1. SUPER ADMIN (God Mode)
    # ==========================================================
    if user.admin?
      can :manage, :all

    # ==========================================================
    # 2. SCHOOL ADMIN (Manager of a specific tenant/school)
    # ==========================================================
    elsif user.school_admin?
      # --- School Management ---
      # Can read and update their own school details
      # Cannot :destroy or :create new schools (only Super Admin does that)
      can [ :read, :update ], School, id: user.school_id

      # --- Academic Management ---
      # Full control over Courses and Batches within their school
      can :manage, Course, school_id: user.school_id
      can :manage, Batch, course: { school_id: user.school_id }

      # --- Enrollment Management ---
      # Can approve/deny/view requests for their school's batches
      can :manage, Enrollment, batch: { course: { school_id: user.school_id } }

      # --- Student Management ---
      # Can create new users (The controller must assign the school_id automatically)
      can :create, User

      # Can manage (Edit/Delete) ONLY users who are 'students' AND belong to this school.
      # strict_loading prevents them from editing other SchoolAdmins or Super Admins.
      can :manage, User, role: "student", school_id: user.school_id

    # ==========================================================
    # 3. STUDENT (Consumer)
    # ==========================================================
    elsif user.student?
      # --- Discovery ---
      # Can view Courses to see what is available in their school
      can :read, Course, school_id: user.school_id

      # Can view the LIST of batches to choose one (Index only)
      can :index, Batch, course: { school_id: user.school_id }

      # --- Enrollment Logic ---
      # Can create a request
      can :create, Enrollment

      # Can view their own history
      can :read, Enrollment, user_id: user.id

      # Custom Action: 'enroll'
      # Can only enroll if the batch is in their school AND they are not already in it
      can :enroll, Batch do |batch|
        batch.course.school_id == user.school_id && !user.enrollments.exists?(batch_id: batch.id)
      end

      # --- Privacy / Classroom Access ---
      # Can ONLY view the 'show' page (Classmates/Progress) if they are APPROVED
      can :show, Batch do |batch|
        user.enrollments.approved.exists?(batch_id: batch.id)
      end

      # --- Self Management ---
      # Can read and update their own profile (e.g. change password/name)
      can [ :read, :update ], User, id: user.id

      # STRICTLY FORBIDDEN: Seeing the list of all users
      cannot :index, User
    end
  end
end
