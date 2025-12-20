class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string
    add_column :users, :role, :integer
    add_reference :users, :school, null: false, foreign_key: true
  end
end
