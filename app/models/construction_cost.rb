class ConstructionCost < ActiveRecord::Base

  belongs_to :construction_datum, :touch => :construction_start_date
  accepts_nested_attributes_for :construction_datum
  
  has_one :construction_daily_reports
  
  belongs_to :purchase_order_datum
  
 # has_many :supplier_masters, :through => :PurchaseDatum, :foreign_key => "supplier_id"
  
  # has_many :supplier_masters, through purchase_datum
  
  # include ActiveModel::Model
  # attr_accessor :purchase_order_amount
  # validates :name, presence: true
  
  scope :with_construction, -> (construction_costs_construction_datum_id=1) { joins(:construction_datum).where("construction_data.id = ?", construction_costs_construction_datum_id )}
  
  def self.ransackable_scopes(auth_object=nil)
  		[:with_construction]
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
