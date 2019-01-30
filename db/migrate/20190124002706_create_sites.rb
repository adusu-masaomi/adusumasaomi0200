class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :name
      t.string :post
      t.string :address
      t.string :house_number
      t.string :address2

      t.timestamps null: false
    end
  end
end
