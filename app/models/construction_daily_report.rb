class ConstructionDailyReport < ActiveRecord::Base
  paginates_per 120  # 1ページあたり項目表示
  
  #belongs_to :construction_datum, :touch => :construction_start_date
  belongs_to :construction_datum
  accepts_nested_attributes_for :construction_datum, update_only: true
  #attr_accessor :construction_datum
  
  #has_many :Staffs
  belongs_to :Staff, :foreign_key => "staff_id"  
  
  #validation
  validates :working_date, presence: true
  validates :staff_id, presence: true
  validates :construction_datum_id, presence: true
  # 数値であり、0以上の場合有効
  validates :working_times, numericality: {
            only_integer: true, greater_than_or_equal_to: 0
          }
  
  #scope
  scope :with_construction, -> (construction_daily_reports_construction_datum_id=1) { joins(:construction_datum).where("construction_data.id = ?", construction_daily_reports_construction_datum_id )}

 # scope :with_staff, -> (construction_daily_reports_staff_id=1) { joins(:Staffs).where("Staffs.id = ?", construction_daily_reports_staff_id )}


  def self.ransackable_scopes(auth_object=nil)
  		[:with_construction]
  end

  #after_update :my_callback_method
  
   #def my_callback_method
    # self.construction_datum.update(construction_start_date: "2011/01/01")  これは機能した
  #end
   
   #労務費合計
   def self.sumprice  
    	sum(:labor_cost)
    	#User.sumでもかまいません
    	#カラム名(フィールド名)は大文字使ってもいいですが、普通小文字の方がよいです
   end

    #以下、全てcsv用
   def self.to_csv(options = {})
      CSV.generate do |csv|
        csv << ["working_date", "staff_id",  "man_month", "labor_cost", "construction_code", "construction_name" ]
		all.order('working_date').each do |construction_daily_reports|
          csv << construction_daily_reports.csv_column_values
		end
          #this doesnt work
          #csv.sort_by{ |csv_column_values| csv_column_values[1]}
      end
      
    end
	
	def csv_column_headers
	  ["working_date", "staff_id",  "man_month", "labor_cost", "construction_code", "construction_name" ]
	end
	def csv_column_values
      # [working_date.strftime("%Y/%m/%d") , staff_id, man_month, labor_cost,   construction_datum.construction_code, construction_datum.construction_name ]
	  [working_date.strftime("%m/%d") , staff_id, man_month, labor_cost,   construction_datum.construction_code, construction_datum.construction_name ]
    end
	# def material_code
	#   MaterialMaster.where("id = ?", material_id).pluck(:material_code).flatten.join(" ")
	# end
	# def customer_name
	#  CustomerMaster.where("id = ?", construction_datum.customer_id).pluck(:customer_name).flatten.join(" ")
	# end
   # ここまで
end
