class CreateWorkingSubcategories < ActiveRecord::Migration
  def change
    create_table :working_subcategories do |t|
      t.integer :working_category_id
      t.string :name

      t.timestamps null: false
    end
  end
end
