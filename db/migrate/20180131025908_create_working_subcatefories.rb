class CreateWorkingSubcatefories < ActiveRecord::Migration
  def change
    create_table :working_subcatefories do |t|
      t.integer :working_category_id
      t.string :name

      t.timestamps null: false
    end
  end
end
