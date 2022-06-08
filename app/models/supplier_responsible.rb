class SupplierResponsible < ActiveRecord::Base
  belongs_to :supplier_master
  has_many :purchase_order_datum
end
