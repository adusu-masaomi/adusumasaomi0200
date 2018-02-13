class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.integer :construction_datum_id
      t.string :content_name
      t.date :estimated_start_date
      t.date :estimated_end_date
      t.date :work_start_date
      t.date :work_end_date

      t.timestamps null: false
    end
  end
end
