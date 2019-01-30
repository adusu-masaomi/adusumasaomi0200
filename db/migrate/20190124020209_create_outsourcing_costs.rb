class CreateOutsourcingCosts < ActiveRecord::Migration
  def change
    create_table :outsourcing_costs do |t|
      t.integer :construction_datum_id
      t.integer :staff_id
      t.integer :purchase_amount
      t.integer :supplies_expense
      t.integer :labor_cost
      t.integer :misellaneous_expense
      t.integer :execution_amount
      t.integer :billing_amount
      t.string :purchase_order_amount
      t.date :closing_date
      t.integer :payment_amount
      t.integer :unpaid_amount
      t.date :payment_due_date
      t.date :payment_date

      t.timestamps null: false
    end
  end
end
