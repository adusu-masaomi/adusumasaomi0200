class PurchaseOrderHistory < ActiveRecord::Base

    belongs_to :purchase_order_datum
    belongs_to :supplier_master

    has_many :orders
    accepts_nested_attributes_for :orders, allow_destroy: true
    
    #納品場所
    def self.delivery_place 
      #[["現場", 0], ["事務所", 1], ["引取", 2]] 
      [["現場", 0], ["事務所", 1], ["倉庫", 2], ["引取", 3]] 
    end
    
    #add220108
    #画面遷移用
    #attr_accessor :construction_id
    #attr_accessor :move_flag
    
    #eメール取得用
    attr_accessor :email_responsible

    #担当者
    attr_accessor :responsible
    
    #ボタン切り分け用
    attr_accessor :sent_flag
 
    #画面見出し用
    attr_accessor :purchase_order_code
    attr_accessor :construction_name
    attr_accessor :supplier_name
    
    #fax
    attr_accessor :format
    #attr_accessor :fax_flag
	
    #add220526
    #帳票切り分け用  
    attr_accessor :print_type
        
    #資材ID自動セット用
    attr_accessor :material_id_hide
    attr_accessor :material_id_select_hide
    #資材コード(ajax明細用)
    attr_accessor :material_code_hide
    attr_accessor :material_code_select_hide
    #資材名(ajax明細用)
    attr_accessor :material_name_hide
    #メーカーID用(ajax明細用)
    attr_accessor :maker_id_hide
    
    #単位(ajax明細用)
    attr_accessor :unit_id_hide
	#定価(ajax明細用)
    attr_accessor :list_price_hide
    #分類(ajax明細用)
    attr_accessor :material_category_id_hide
    
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
