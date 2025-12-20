class Course < ApplicationRecord
  belongs_to :school
  has_many :batches, dependent: :destroy

  validates :name, presence: true
end
