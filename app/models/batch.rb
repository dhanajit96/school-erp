class Batch < ApplicationRecord
  belongs_to :course
  has_many :enrollments
  has_many :students, through: :enrollments, source: :user
  validates :name, presence: true
end
