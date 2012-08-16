class CreateRestaurants < ActiveRecord::Migration
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :zip
      t.text :address
      t.text :review_text
      t.string :reviewer_name
      t.string :reviewer_location
      t.integer :rating
      t.text :other

      t.timestamps
    end
  end
end
