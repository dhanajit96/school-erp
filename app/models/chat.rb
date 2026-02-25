class Chat < ApplicationRecord
  belongs_to :user_one, class_name: "User"
  belongs_to :user_two, class_name: "User"
  has_many :messages, dependent: :destroy

  # Helper to find a chat between two specific users
  def self.between(user_a, user_b)
    # Ensure IDs are always in the same order (e.g., [min, max])
    # so we don't accidentally create two chats for the same pair.
    id1, id2 = [ user_a.id, user_b.id ].sort

    # find_or_create_by! ensures the record is saved to the DB and has an ID
    find_or_create_by!(user_one_id: id1, user_two_id: id2)
  end
end
