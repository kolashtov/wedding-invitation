class CreateGuests < ActiveRecord::Migration
  def change
    create_table :guests do |t|
      t.string :name
      t.references :invitation, index: true, foreign_key: true
      t.string :meal
      t.string :drink

      t.timestamps null: false
    end
  end
end
