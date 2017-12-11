class QuotationBreakdownHistory < ActiveRecord::Base
  belongs_to :QuotationHeaderHistory, :foreign_key => "quotation_header_history_id"
  belongs_to :WorkingUnit, :foreign_key => "working_unit_id"
  
  def self.choices 
    [["項目", 1], ["備考", 2]] 
  end
  
  def self.serial_number
    [[("<行選択>").to_s , (1..999).to_a ]]
  end 
  
  #行挿入用
  attr_accessor :check_line_insert
  #マスターセット用
  attr_accessor :check_update_item
  attr_accessor :check_update_all
  
  #金額合計(見積)
  def self.sumpriceQuote  
    #工事種別が通常かまたは値引の場合のみ合算。
    where("construction_type = ? or construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:quote_price)
  end
  #金額合計(実行)
  def self.sumpriceExecution  
    #工事種別が通常かまたは値引の場合のみ合算。
    where("construction_type = ? or construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:execution_price)
  end
  
  #合計(歩掛り)
  def self.sumLaborProductivityUnit  
    sum(:labor_productivity_unit)
  end
  #合計(歩掛り計)
  def self.sumLaborProductivityUnitTotal  
    #工事種別が通常かまたは値引の場合のみ合算。
    where("construction_type = ? or construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:labor_productivity_unit_total)
  end
  
  #合計(歩掛り-配管配線集計用)
  scope :sum_LPU_PipingWiring, -> quotation_header_history_id {where(:piping_wiring_flag => 1).where(quotation_header_history_id: quotation_header_history_id ).
                                   sum(:labor_productivity_unit)}
  #合計(歩掛り計-配管配線集計用)
  scope :sum_LPUT_PipingWiring, -> quotation_header_history_id {where(:piping_wiring_flag => 1).where(quotation_header_history_id: quotation_header_history_id ).
                                   sum(:labor_productivity_unit_total)}
  #合計(歩掛り-機器取付集計用)
  scope :sum_LPU_equipment_mounting, -> quotation_header_history_id {where(:equipment_mounting_flag => 1).where(quotation_header_history_id: quotation_header_history_id ).
                                   sum(:labor_productivity_unit)}
  #合計(歩掛り-機器取付集計用)
  scope :sum_LPUT_equipment_mounting, -> quotation_header_history_id {where(:equipment_mounting_flag => 1).where(quotation_header_history_id: quotation_header_history_id ).
                                   sum(:labor_productivity_unit_total)}
  #合計(歩掛り-労務費集計用)
  scope :sum_LPU_labor_cost, -> quotation_header_history_id {where(:labor_cost_flag => 1).where(quotation_header_history_id: quotation_header_history_id ).
                                   sum(:labor_productivity_unit)}
  #合計(歩掛り-労務費集計用)
  scope :sum_LPUT_labor_cost, -> quotation_header_history_id {where(:labor_cost_flag => 1).where(quotation_header_history_id: quotation_header_history_id ).
                                   sum(:labor_productivity_unit_total)}
  
  #scope :with_header_id, -> (quotation_detail_large_classifications_quotation_header_id=1) { joins(:QuotationHeader).where("quotation_headers.id = ?", quotation_detail_large_classifications_quotation_header_id )}
   
  #def self.ransackable_scopes(auth_object=nil)
  #   [:with_header_id]
  #end
end
