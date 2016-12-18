class SupplierMaster < ActiveRecord::Base
	paginates_per 200  # 1ページあたり項目表示　
	
	belongs_to :PurchaseDatum
    has_many :purchase_unit_prices	

	#バリデーション
	# validates :customer_id, presence: true, if: "customer_id.nil?"
	
end
