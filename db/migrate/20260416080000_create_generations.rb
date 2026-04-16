class CreateGenerations < ActiveRecord::Migration[8.0]
  def change
    create_table :generations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :genre, null: false
      t.string :theme, null: false
      t.text   :serifus, null: false

      t.timestamps
    end

    add_index :generations, [:user_id, :created_at]
  end
end
