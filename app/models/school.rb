class School < ApplicationRecord
  has_many :users
  has_many :courses
  has_many :batches, through: :courses

  validates :name, presence: true, uniqueness: true
end
