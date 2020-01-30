class OutsourcingCost < ActiveRecord::Base
  belongs_to :construction_datum
  belongs_to :purchase_order_datum  #upd190930
  belongs_to :staff
  
  attr_accessor :billing_amount_tax
  attr_accessor :payment_total_amount
  
  #add19425
  #支払日入力有で、支払金額が入力されていなければ警告する
  validate :check_payment_amount
  def check_payment_amount
    if payment_date.present?
      if payment_amount.nil? || payment_amount == 0
        errors.add :payment_amount, "を入力して下さい。"
      end
    end
  end
end
