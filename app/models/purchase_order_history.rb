class PurchaseOrderHistory < ActiveRecord::Base

    belongs_to :purchase_order_datum
	belongs_to :supplier_master
	
	has_many :orders
    #accepts_nested_attributes_for :orders, :allow_destroy => true
	accepts_nested_attributes_for :orders, allow_destroy: true
    
	#has_many :material_maters
    #accepts_nested_attributes_for :material_maters
	
	#eメール取得用
    attr_accessor :email_responsible
	
	#ボタン切り分け用
	attr_accessor :sent_flag
	
	#工事画面からの遷移にて使用
	#attr_accessor :construction_id
	#attr_accessor :move_flag
	
	validates_associated :orders
	
	#validates :quantity, presence: true
    #validate :no_quantity
	
	#def no_quantity
    #  if attributes[:quantity].blank?
	#    $quantity_nothing = true
    #	errors.add(:orders, "に関係するエラーを追加")
	#	errors[:base] << "数量が未入力の行があります。確認してください。"
	#  end
	#end

end
