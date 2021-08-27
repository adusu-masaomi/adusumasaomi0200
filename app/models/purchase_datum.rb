class PurchaseDatum < ActiveRecord::Base
    paginates_per 200  # 1ページあたり項目表示　

    belongs_to :unit_master , :foreign_key => "unit_id"
    belongs_to :MakerMaster , :foreign_key => "maker_id"
    
    belongs_to :MaterialMaster, :foreign_key => "material_id"
    accepts_nested_attributes_for :MaterialMaster, update_only: true
	
    belongs_to :PurchaseUnitPrice, foreign_key: [:supplier_id, :material_id]
    accepts_nested_attributes_for :PurchaseUnitPrice, update_only: true

    belongs_to :purchase_order_datum , :class_name => 'PurchaseOrderDatum',  :foreign_key => "purchase_order_datum_id"
	belongs_to :construction_datum
	belongs_to :SupplierMaster,  :foreign_key => "supplier_id"
	belongs_to :CustomerMaster,  :foreign_key => "customer_id"
	belongs_to :PurchaseDivision,  :foreign_key => "division_id"
    belongs_to :purchase_header  
    
    #has_many :SupplierMaster,  :foreign_key => "supplier_id"
    
    #belongs_to :outsourcing_cost    #add190213
    
    #belongs_to :material_category #add180626
    
    #単価M更新切り分け用
    #attr_accessor :check_unit
    #仕入先品番選択用
	attr_accessor :supplier_material_code
	attr_accessor :supplier_id_hide
    attr_accessor :unit_price_hide
    attr_accessor :supplier_material_code
    
    #add180223登録フラグ
    attr_accessor :complete_flag
    attr_accessor :complete_flag_hide
    
    attr_accessor :labor_cost_set  #add190129
    
    #attr_accessor :purchase_header_id_hide
    
    #外注判定用
    attr_accessor :outsourcing
	attr_accessor :construction_datum_id_hide
	attr_accessor :material_category_id_hide
    attr_accessor :outsourcing_flag_hide 
    attr_accessor :price_disp_flag
    attr_accessor :closing_date_hide      
    attr_accessor :payment_due_date_hide  
    
    #validation
    validates :material_id, presence: true
    validates :material_code, presence: true
    validates :maker_id, presence: true
    validates :supplier_id, presence: true
    validates :unit_id, presence: true
    validates :check_unit, acceptance: true 
    validates :purchase_order_datum_id, presence:true
    validates_numericality_of :purchase_amount, :only_integer => true, :allow_nil => false
    validate :purchase_order_code_check   
	validate :check_complete    
    
    #add210628
    VALID_HALF_REGEX = /\A[a-z0-9]+\z/i
    validates :slip_code, format: { with: VALID_HALF_REGEX }, allow_blank: true
    #
    
    def purchase_order_code_check
	#注文番号のチェック（既に集計済みなら除外する）
    #add171108  
	  #if construction_datum.calculated_flag == 1
      #upd200702
      if construction_datum.present? && construction_datum.calculated_flag == 1
	    errors.add(:purchase_order_datum_id, ": 工事集計済みのNoです。確認してください。" << 
        "　　　　　　　" << "（やむなく登録したい場合は、一旦集計フラグを解除して下さい。）")
      end 
	end
	
    #add180223
    def check_complete
      if purchase_header.present? && purchase_header.complete_flag == 1
        errors.add(:slip_code, ": 既に入力済みです。納品伝票を確認してください。")
      end
    end
    
# scope 

	scope :with_purchase_order, -> (purchase_order_data_construction_datum_id=1) { joins(:purchase_order_datum).where("purchase_order_data.construction_datum_id = ?", purchase_order_data_construction_datum_id )}
    scope :with_construction, -> (purchase_order_data_construction_datum_id=1) { joins(:construction_datum).where("construction_data.id = ?", purchase_order_data_construction_datum_id )}
	scope :with_customer, -> (construction_datum_customer_id=1){joins(:construction_datum).where("construction_data.customer_id = ?", construction_datum_customer_id )}
	scope :with_material, -> (material_id=1) { joins(:MaterialMaster).where("material_masters.id = ?", material_id  ) }
	
	scope :with_material_code, -> (material_id=1) { 
	  if material_id.present?
	    joins(:MaterialMaster).where("material_masters.id = ?", material_id )
	  end
    }
	scope :with_material_code_include, -> material_code { 
	  if material_code.present?
	    joins(:MaterialMaster).where("material_masters.material_code like ?", '%' + material_code + '%' )
	  end
    }
	scope :with_material_name_include, -> material_name { 
	  if material_name.present?
	    joins(:MaterialMaster).where("material_masters.material_name like ?", '%' + material_name + '%' )
	  end
    }
    #add190206
    #scope :with_internal_code, -> (id=1) { 
	#  if id.present?
	#    joins(:MaterialMaster).where("material_masters.id = ?", id )
	#  end
    #}
    
    scope :with_material_category, -> (material_category_id=1) { 
	  if material_category_id.present?
	    joins(:MaterialMaster).where("material_category_id = ?", material_category_id )
	  end
    }
    
    #add190401
    #scope :with_payment_date_gteq, -> (payment_date=1) { 
	#  if payment_date.present?
	#    joins(:OutsourcingCost).where("payment_date => ?", payment_date )
	#  end
    #}
    
    def self.ransackable_scopes(auth_object=nil)
        [:with_purchase_order, :with_customer, :with_construction, :with_material, :with_material_code, 
         :with_material_code_include, :with_material_category, :with_material_name_include]
	end
	
	def self.to_csv(options = {})
      CSV.generate do |csv|
        # column_namesはカラム名を配列で返す
        # 例: ["id", "name", "price", "released_on", ...]
	    #csv << column_names
        csv << ["purchase_date", "purchase_order_code", "construction_code", "construction_name", "customer_name", "material_code", "material_name","maker_name", "quantity", "unit", "purchase_unit_price",
		        "purchase_amount", "list_price", "supplier_name", "purchase_division_name"]
		all.each do |purchase_datum|
          # attributes はカラム名と値のハッシュを返す
          # 例: {"id"=>1, "name"=>"レコーダー", "price"=>3000, ... }
          # valudes_at はハッシュから引数で指定したキーに対応する値を取り出し、配列にして返す
          # 下の行は最終的に column_namesで指定したvalue値の配列を返す
    	  
		  csv << purchase_datum.csv_column_values
		end
      end
    end
	
	#金額合計
    def self.sumprice  
      sum(:purchase_amount)
      #User.sumでもかまいません
      #カラム名(フィールド名)は大文字使ってもいいですが、普通小文字の方がよいです
    end
	
    #数量合計（出庫は除く）
    def self.sumQuantity
      where.not(:division_id => $INDEX_DIVISION_SHIPPING).sum(:quantity) 
    end
    #数量合計（出庫をマイナスで集計する）
    def self.sumShipQuantity
      where(:division_id => $INDEX_DIVISION_SHIPPING).sum(:quantity) * -1
    end
	
    #add190130
    #請求・支払いチェック用(外注)
    def self.invoice_check_list 
      [["未", 0], ["済", 1]] 
    end
    
    def self.payment_check_list 
      [["未", 0], ["済", 1]] 
    end
	
	#以下、全てcsv用
	def csv_column_headers
	  ["purchase_date", "purchase_order_code", "construction_name", "material_code"]
	end
	def csv_column_values
      [purchase_date.strftime("%Y/%m/%d") , purchase_order_datum.purchase_order_code, construction_datum.construction_code,construction_datum.construction_name, 
	   customer_name, material_code,  material_name, maker_name, quantity, unit_name, purchase_unit_price.to_i, purchase_amount, list_price, supplier_name,purchase_division_name]
    end
    #def material_code
    #  MaterialMaster.where("id = ?", material_id).pluck(:material_code).flatten.join(" ")
    #end
	def customer_name
	  CustomerMaster.where("id = ?", construction_datum.customer_id).pluck(:customer_name).flatten.join(" ")
	end
	def unit_name
	  UnitMaster.where("id = ?", unit_id).pluck(:unit_name).flatten.join(" ")
	end
	def supplier_name
	  #SupplierMaster.where("id = ?", purchase_id).pluck(:supplier_name).flatten.join(" ")
          SupplierMaster.where("id = ?", supplier_id).pluck(:supplier_name).flatten.join(" ") 
	end
	def purchase_division_name
	  PurchaseDivision.where("id = ?", division_id).pluck(:purchase_division_name).flatten.join(" ")
	end 
	
end
