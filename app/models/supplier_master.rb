class SupplierMaster < ActiveRecord::Base
	belongs_to :PurchaseDatum
        has_many :purchase_unit_prices	

	#バリデーション
	# validates :customer_id, presence: true, if: "customer_id.nil?"
	
end
