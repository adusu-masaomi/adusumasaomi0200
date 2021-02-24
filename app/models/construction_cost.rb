class ConstructionCost < ActiveRecord::Base

  belongs_to :construction_datum, :touch => :construction_start_date
  accepts_nested_attributes_for :construction_datum
  has_one :construction_daily_reports
  #belongs_to :purchase_order_datum
  
  def self.final_division 
     [["−", 0], ["Ａ", 1], ["Ｂ", 2], ["Ｃ", 3], ["Ｄ", 4], ["-", 5], ["-", 6], ["-", 7], ["-", 8], ["Ｚ", 9]]
  end
  
  def self.final_division_with_explain 
     [["- 通常", 0], ["Ａ-手間のみの作業", 1], ["Ｂ-一般に売ったもの", 2], ["Ｃ-業者に売ったもの", 3], ["Ｄ-レンタル", 4]]
  end
  
  #労務費(日報)
  attr_accessor :labor_cost_origin
  #差額
  attr_accessor :differense
  #小計1
  attr_accessor :subtotal_1
  #小計2
  attr_accessor :subtotal_2
  
  #PDF切り分け用
  #attr_accessor :random_param_name
  
  attr_accessor :print_flag_hide
  
  #バリデーション
  validates :construction_datum_id, uniqueness: true # 値がユニークであれば検証成功
  
  scope :with_construction, -> (construction_costs_construction_datum_id=1) { joins(:construction_datum).where("construction_data.id = ?", construction_costs_construction_datum_id )}
  
  #add210208
  #開始ID コードで比較できればベターであるが..
  scope :with_construction_from, -> (construction_costs_construction_datum_id=1) { joins(:construction_datum).where("construction_data.id >= ?", construction_costs_construction_datum_id )}
  
  #終了ID コードで比較できればベターであるが..
  scope :with_construction_to, -> (construction_costs_construction_datum_id=1) { joins(:construction_datum).where("construction_data.id <= ?", construction_costs_construction_datum_id )}
  
  def self.ransackable_scopes(auth_object=nil)
  		[:with_construction, :with_construction_from, :with_construction_to]
  end
  
  #scope :with_purchase_order, -> PurchaseDatum.joins(:PurchaseOrdrDatum).where(:construction_datum_id => params[:construction_datum_id]).group(:purchase_order_code).sum(:purchase_amount).flatten.join(",")
  #                                                   (construction_datum_id=1){joins(:purchase_order_data).where("construction_data.customer_id = ?", construction_datum_customer_id )}
  
  
   #以下、全てcsv用
   def self.to_csv(options = {})
      CSV.generate do |csv|
        csv << ["construction_code", "customer_name", "construction_name",  "construction_end_date", "supplies_expense", "labor_cost", "misellaneous_expense" , "constructing_amount" , "purchase_order_amount"]
		all.each do |construction_costs|
          csv << construction_costs.csv_column_values
		end
      end
    end
	
	#なぜか代入できないので保留
	# def csv_column_headers
	#  ["working_date", "staff_id",  "man_month", "labor_cost", "construction_code", "construction_name" ]
	# end
	def csv_column_values
	  [construction_datum.construction_code, customer_name, construction_datum.construction_name, construction_datum.construction_end_date, supplies_expense, labor_cost, misellaneous_expense, constructing_amount, purchase_order_amount ]
    end
	
	#def purchase_order_amount_custom
	#  str=purchase_order_amount
    #  str.gsub!('"', '')
    #  puts str
	#  purchase_order_amount_custom = str
	#end
	
	 def customer_name
	  CustomerMaster.where("id = ?", construction_datum.customer_id).pluck(:customer_name).flatten.join(" ")
	 end
   # ここまで
   
end
