class SupplierMaster < ActiveRecord::Base
  paginates_per 200  # 1ページあたり項目表示　

	belongs_to :PurchaseDatum  #--> necessary??
  has_many :purchase_unit_prices	
  #add210319
  has_many :purchase_data, :foreign_key => "supplier_id"

	#バリデーション
	# validates :customer_id, presence: true, if: "customer_id.nil?"
	
end
