class CreateTaskContents < ActiveRecord::Migration
  def change
    create_table :task_contents do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
