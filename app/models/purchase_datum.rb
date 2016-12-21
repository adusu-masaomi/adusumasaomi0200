class PurchaseDatum < ActiveRecord::Base
   paginates_per 200  # 1ページあたり項目表示　

    belongs_to :unit_master , :foreign_key => "unit_id"
    belongs_to :MakerMaster , :foreign_key => "maker_id"
    #has_many :MaterialMaster
    #has_one :MaterialMaster
    
    belongs_to :MaterialMaster, :foreign_key => "material_id"
    accepts_nested_attributes_for :MaterialMaster, update_only: true
	
    belongs_to :PurchaseUnitPrice, foreign_key: [:supplier_id, :material_id]
    accepts_nested_attributes_for :PurchaseUnitPrice, update_only: true
    
    #単価M更新切り分け用
    attr_accessor :check_unit
    #仕入先品番選択用
	attr_accessor :supplier_material_code
	
    #金額合計
    def self.sumprice  
      sum(:purchase_amount)
      #User.sumでもかまいません
      #カラム名(フィールド名)は大文字使ってもいいですが、普通小文字の方がよいです
    end
	
    belongs_to :purchase_order_datum , :class_name => 'PurchaseOrderDatum',  :foreign_key => "purchase_order_datum_id"
	#belongs_to :purchase_order_datum
	
	belongs_to :construction_datum
	#test del
	#delegate :purchase_order_datum, to: :construction_datum
    
	# has_many :SupplierMaster
	# bad?? changed 16/08/23
	belongs_to :SupplierMaster,  :foreign_key => "supplier_id"
	  	
	belongs_to :CustomerMaster,  :foreign_key => "customer_id"
	
	# has_many :PurchaseDivision
	# bad?? changed 16/08/23
	belongs_to :PurchaseDivision,  :foreign_key => "division_id"
	
    #validation
    validates :material_id, presence: true
    validates :maker_id, presence: true
    validates :supplier_id, presence: true
    validates :unit_id, presence: true
    # 数値であり、0以上の場合有効
    validates :quantity, numericality: {
            only_integer: true
          }
       
    validates :check_unit, acceptance: true 

# scope 

	scope :with_purchase_order, -> (purchase_order_data_construction_datum_id=1) { joins(:purchase_order_datum).where("purchase_order_data.construction_datum_id = ?", purchase_order_data_construction_datum_id )}
    scope :with_construction, -> (purchase_order_data_construction_datum_id=1) { joins(:construction_datum).where("construction_data.id = ?", purchase_order_data_construction_datum_id )}
	scope :with_customer, -> (construction_datum_customer_id=1){joins(:construction_datum).where("construction_data.customer_id = ?", construction_datum_customer_id )}
	
	# scope :with_maker, -> (material_id=1){joins(:MaterialMaster, :MakerMaster).where("maker_masters.id = material_masters.maker_id" )}
	
	#test
	scope :with_material, -> (material_id=1) { joins(:material_masters).where("material_masters.id = ?", material_id  ) }
	
	#scope :with_purchase_order_join,
	#   lambda { |purchase_order_datum|
    #   where(purchase_order_datum_construction_id: purchase_order_data.construction_id)
	#}
	
	def self.ransackable_scopes(auth_object=nil)
  		[:with_purchase_order, :with_customer, :with_construction, :with_material]
	end
	

	# before_save do
	#   self.material_code = MaterialMaster.select(:material_code).where("id = ?", PurchaseDatum.material_id)
	# end
	
	def self.to_csv(options = {})
      CSV.generate do |csv|
        # column_namesはカラム名を配列で返す
        # 例: ["id", "name", "price", "released_on", ...]
		#@purchase_data = PurchaseDatum.includes(:purchase_order_datum)
        #csv << column_names
        csv << ["purchase_date", "purchase_order_code", "construction_code", "construction_name", "customer_name", "material_code", "material_name","maker_name", "quantity", "unit", "purchase_unit_price",
		        "purchase_amount", "list_price", "supplier_name", "purchase_division_name"]
		all.each do |purchase_datum|
          # attributes はカラム名と値のハッシュを返す
          # 例: {"id"=>1, "name"=>"レコーダー", "price"=>3000, ... }
          # valudes_at はハッシュから引数で指定したキーに対応する値を取り出し、配列にして返す
          # 下の行は最終的に column_namesで指定したvalue値の配列を返す
          # csv << purchase_datum.attributes.values_at(*column_names)
          
		  #@material_code = MaterialMaster.select("material_name").where("id = ?", purchase_datum.material_id)
	      #@material_code = MaterialMaster.where("id = ?", purchase_datum.material_id).where("id is NOT NULL").pluck(:material_code)
		  
		  csv << purchase_datum.csv_column_values
		end
      end
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
