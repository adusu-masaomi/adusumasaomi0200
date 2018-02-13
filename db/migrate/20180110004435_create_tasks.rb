class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer :construction_datum_id
      t.string :text
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :work_start_date
      t.datetime :work_end_date
      t.integer :duration
      t.integer :parent
      t.decimal :progress
      t.integer :sortorder

      t.timestamps null: false
    end
  end
end
