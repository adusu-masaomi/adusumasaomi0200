class ConstructionDatum < ActiveRecord::Base
	#kaminari用設定
	paginates_per 200  # 1ページあたり項目表示

        #belongs_to :CustomerMaster
        belongs_to :CustomerMaster, :foreign_key => "customer_id"
        accepts_nested_attributes_for :CustomerMaster 
        #belongs_to :purchase_order_datum
	belongs_to :PurchaseDivisionMaster
    #belongs_to :purchase_order_datum, :foreign_key => "construction_id"
	has_many :purchase_order_datum
	has_many :construction_daily_reports
	
	#発行日用
    attr_accessor :issue_date
	
	#バリデーション
	validates :customer_id, presence: true
    validates :construction_code, presence: true, uniqueness: true
	validates :alias_name, presence: true
	
	#scope :with_id, -> { where(id: "purchase_order_data.construction_id")} 
	#scope :with_customer, -> (ConstructionDatum_customer_id=1) { joins(:ConstructionDatum).where("construction_data.customer_id = ?", ConstructionDatum_customer_id ).merge(ConstructionDatum.with_id)}
	#scope :with_id, -> (customer_id=1) { where("construction_data.customer_id = ?", customer_id ). where(id: "purchase_order_data.construction_id") }
	#scope :with_id, -> (customer_id=1) { joins(:purchase_order_datum).where("purchase_order_data.customer_id = ?", customer_id ). joins(:purchase_order_datum).where(id: "purchase_order_data.construction_id") } 
	#scope :with_id, -> (customer_id=1) { where("customer_id = ?", customer_id ). joins(:purchase_order_datum).where(id: "construction_id") }
	#scope :with_id, -> (customer_id=1) { where("customer_id = ?", customer_id ). joins(:purchase_order_datum).where(construction_id: "construction_id") }
	
	#mouchott_
	#scope :with_id, -> (customer_id=1) { where("customer_id = ?", customer_id )}
	scope :with_id, -> { where(id: "purchase_order_data.construction_id")} 
	
	#scope :with_id, -> {joins(:purchase_order_datum).where(construction_id: "construction_id") }
    
	#scope :with_id, -> {joins(:purchase_order_datum).where(id: "id") .where("construction_data.customer_id = ?", construction_datum_customer_id )}
	#scope :with_id, -> {joins(:purchase_order_datum).where(id: "id") .where("customer_id = ?", customer_id )}
	
	#scope :with_id, ->  (customer_id=1){ joins(:purchase_order_datum).where(id: "purchase_order_data.construction_datum_id").where("customer_id = ?", customer_id )}
	#scope :with_id,  ->  (purchase_order_datum_construction_datum_id) { where(id: purchase_order_datum_construction_datum_id) }
	scope :with_id,  -> { joins(:purchase_order_datum) }
	
	#scope :with_id, -> (customer_id=1) { where("customer_id = ?", customer_id ). joins(:purchase_order_datum).where(id: "purchase_order_data.construction_datum_id") }
	#scope :with_id, ->  (customer_id=1){joins(:purchase_order_datum).where(id: "purchase_order_data.construction_datum_id").where("construction_data.customer_id = ?", construction_datum_customer_id )}
	#scope :with_id, -> (customer_id=1) { joins(:purchase_order_datum).where(id: "purchase_order_data.construction_id") }
	#scope :with_id, -> (customer_id=1) { joins(:purchase_order_datum).where("purchase_order_data.construction_id = ?" , purchase_order_datum.construction_id) }
	#scope :with_purchase_order, -> (purchase_order_data_construction_id=1) { joins(:purchase_order_datum).where("purchase_order_data.construction_id = ?", purchase_order_data_construction_id )}
	#scope :with_id, -> (id=1){joins(:purchase_order_datum).where("purchase_order_data.construction_id = " , id) }
	
	def self.ransackable_scopes(auth_object=nil)
  		[:with_id]
	end
	
	#リスト表示用(CD/名称)
	def p_cd_name
        if self.construction_code.nil?
           construction_code = "-"
        else 
           construction_code = self.construction_code
        end
        if self.construction_name.nil?
           construction_name = "-"
        else 
           construction_name = self.construction_name
        end        

        #self.construction_code + ':' + self.construction_name
        construction_code + ':' + construction_name 
    end
	
	def self.bills_check_list 
      [["未", 0], ["済", 1]] 
    end
  
end
