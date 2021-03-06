class ConstructionDailyReport < ActiveRecord::Base
  paginates_per 200  # 1ページあたり項目表示
  
  #belongs_to :construction_datum, :touch => :construction_start_date
  belongs_to :construction_datum
  accepts_nested_attributes_for :construction_datum, update_only: true
  #attr_accessor :construction_datum
  
  #has_many :Staffs
  belongs_to :Staff, :foreign_key => "staff_id"  
  
  #みなし勤務判定用
  attr_accessor :regard_one_day
  attr_accessor :regard_half_day
  
  #休日フラグ
  attr_accessor :holiday_flag
  
  #労務費（加算なしのもの--後で消す？）
  attr_accessor :labor_cost_no_add
  
  #add170707
  #所属
  attr_accessor :affiliation
  
  #validation
  validates :working_date, presence: true
  validates :staff_id, presence: true
  validates :working_details, presence: true
  
  #validates :construction_datum_id, presence: true
  # 数値であり、0以上の場合有効
  validates :working_times, numericality: {
            only_integer: true, greater_than_or_equal_to: 0
          }
  
  #作業日＆時間の重複登録防止
  validates :construction_datum_id,  presence: true, uniqueness: { scope: [:working_date, :staff_id, :start_time_1, :end_time_1] }
  
  #入力チェック(日またがりで計算がおかしくなるのを防止)
  # ↑ 計算異常を修正したので下記は未使用にした
  #validate :time_too_large
  
  
  #scope
  scope :with_construction, -> (construction_daily_reports_construction_datum_id=1) { joins(:construction_datum).where("construction_data.id = ?", construction_daily_reports_construction_datum_id )}

 # scope :with_staff, -> (construction_daily_reports_staff_id=1) { joins(:Staffs).where("Staffs.id = ?", construction_daily_reports_staff_id )}


  def self.ransackable_scopes(auth_object=nil)
  		[:with_construction]
  end

  
   #入力チェック用
   def time_too_large
     #22:00~4:00のように入力すると計算がおかしくなるため、２行に入力させるため警告する
     if end_time_1.to_s(:time) != "00:00"
       if start_time_1 > end_time_1
         errors.add(:time1, ": 日またがりの場合は、０時以降を時間２へ入力してくだい。")
       end
     end
   end
   
   #労務費合計
   def self.sumprice  
    	sum(:labor_cost)
    	#User.sumでもかまいません
    	#カラム名(フィールド名)は大文字使ってもいいですが、普通小文字の方がよいです
   end
   #作業時間合計
   def self.sumtimes  
    	sum = sum(:working_times)
		if sum.present?
		  sum = sum / 3600
		end
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
