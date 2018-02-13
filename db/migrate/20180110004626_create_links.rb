class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.integer :construction_datum_id
      t.integer :source
      t.integer :target
      t.string :link_type

      t.timestamps null: false
    end
  end
end
