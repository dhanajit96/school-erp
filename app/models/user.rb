class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  belongs_to :school, optional: true
  has_many :enrollments
  has_many :batches, through: :enrollments

  # Use enums for clean role management
  enum :role, { admin: 0, school_admin: 1, student: 2 }

  # Validations
  validates :name, :email, presence: true
  # Ensure only students/school_admins need a school_id, Admins don't
  validates :school, presence: true, unless: :admin?

  # def jwt_payload
  #   super
  # end
  #
  def jwt_payload
    {
      "email" => email,
      "role" => role,
      "jti" => jti # JTI is mandatory for revocation strategy
    }
  end
end
