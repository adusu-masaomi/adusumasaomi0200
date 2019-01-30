class OutsourcingCost < ActiveRecord::Base
  belongs_to :construction_datum
  belongs_to :staff
end
