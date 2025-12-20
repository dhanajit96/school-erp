class CreateSchools < ActiveRecord::Migration[8.0]
  def change
    create_table :schools do |t|
      t.string :name
      t.text :address
      t.string :subdomain

      t.timestamps
    end
  end
end
