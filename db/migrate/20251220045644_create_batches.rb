class CreateBatches < ActiveRecord::Migration[8.0]
  def change
    create_table :batches do |t|
      t.string :name
      t.datetime :start_date
      t.datetime :end_date
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
