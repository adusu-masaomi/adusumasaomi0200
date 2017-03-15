class QuotationDetailLargeClassification < ActiveRecord::Base
  belongs_to :QuotationHeader, :foreign_key => "quotation_header_id"
  #belongs_to :QuotationUnit, :foreign_key => "quotation_unit_id"
  belongs_to :WorkingUnit, :foreign_key => "working_unit_id"
  has_many :quotation_detail_middle_classifications

  def self.choices 
    [["項目", 1], ["備考", 2]] 
  end
  
  #del170308 
  #def self.types 
    #[["通常", 0], ["配管配線工事", 1], ["機器取付工事", 2], ["労務費", 3]] 
  #end

  #enum serial_number: {1: 1, 2: 2, 3: 3 }
  def self.serial_number
    #[["1",1],["2",2],["3",3],["4",4],["5",5]]
    #[[("1".."100").to_a , (1..100).to_a ]]
    [[("<行選択>").to_s , (1..100).to_a ]]
  end 
  
  #行挿入用
  attr_accessor :check_line_insert
  #マスターセット用
  attr_accessor :check_update_item
  attr_accessor :check_update_all
  
  #金額合計(見積)
  def self.sumpriceQuote  
    #sum(:quote_price)
    #upd170308
    #工事種別が通常かまたは値引の場合のみ合算。
    where("construction_type = ? or construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:quote_price)
  end
  #金額合計(実行)
  def self.sumpriceExecution  
    #sum(:execution_price)
    #upd170308
    #工事種別が通常かまたは値引の場合のみ合算。
    where("construction_type = ? or construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:execution_price)
  end
  
  #合計(歩掛り)
  def self.sumLaborProductivityUnit  
    sum(:labor_productivity_unit)
  end
  #合計(歩掛り計)
  def self.sumLaborProductivityUnitTotal  
    #where(:construction_type => "0").sum(:labor_productivity_unit_total)
    #upd170308
    #工事種別が通常かまたは値引の場合のみ合算。
    where("construction_type = ? or construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:labor_productivity_unit_total)
  end
  
  #合計(歩掛り-配管配線集計用)
  scope :sum_LPU_PipingWiring, -> quotation_header_id {where(:piping_wiring_flag => 1).where(quotation_header_id: quotation_header_id ).
                                   sum(:labor_productivity_unit)}
  #合計(歩掛り計-配管配線集計用)
  scope :sum_LPUT_PipingWiring, -> quotation_header_id {where(:piping_wiring_flag => 1).where(quotation_header_id: quotation_header_id ).
                                   sum(:labor_productivity_unit_total)}
  #合計(歩掛り-機器取付集計用)
  scope :sum_LPU_equipment_mounting, -> quotation_header_id {where(:equipment_mounting_flag => 1).where(quotation_header_id: quotation_header_id ).
                                   sum(:labor_productivity_unit)}
  #合計(歩掛り-機器取付集計用)
  scope :sum_LPUT_equipment_mounting, -> quotation_header_id {where(:equipment_mounting_flag => 1).where(quotation_header_id: quotation_header_id ).
                                   sum(:labor_productivity_unit_total)}
  #合計(歩掛り-労務費集計用)
  scope :sum_LPU_labor_cost, -> quotation_header_id {where(:labor_cost_flag => 1).where(quotation_header_id: quotation_header_id ).
                                   sum(:labor_productivity_unit)}
  #合計(歩掛り-労務費集計用)
  scope :sum_LPUT_labor_cost, -> quotation_header_id {where(:labor_cost_flag => 1).where(quotation_header_id: quotation_header_id ).
                                   sum(:labor_productivity_unit_total)}
  
  scope :with_header_id, -> (quotation_detail_large_classifications_quotation_header_id=1) { joins(:QuotationHeader).where("quotation_headers.id = ?", quotation_detail_large_classifications_quotation_header_id )}
   
  def self.ransackable_scopes(auth_object=nil)
     [:with_header_id]
  end
 
end
