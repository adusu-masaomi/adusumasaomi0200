class OutsourcingCost < ActiveRecord::Base
  belongs_to :construction_datum
  belongs_to :staff
  
  attr_accessor :billing_amount_tax
  attr_accessor :payment_total_amount
end
