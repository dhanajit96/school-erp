class CreateChats < ActiveRecord::Migration[8.0]
  def change
    create_table :chats do |t|
      t.bigint :user_one_id, null: false
      t.bigint :user_two_id, null: false

      t.timestamps
    end

    add_index :chats, [ :user_one_id, :user_two_id ], unique: true
  end
end
