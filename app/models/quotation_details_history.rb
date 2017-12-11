class QuotationDetailsHistory < ActiveRecord::Base
  
  belongs_to :QuotationBreakdownHistory, :foreign_key => "quotation_breakdown_history_id"
  belongs_to :WorkingUnit, :foreign_key => "working_unit_id"
  
  #行挿入用
  attr_accessor :check_line_insert
  
  #マスターセット用
  attr_accessor :check_update_item
  attr_accessor :check_update_all
  
  def self.serial_number
    [[("<行選択>").to_s , (1..999).to_a ]]
  end 
  
  #金額合計(見積)
  def self.sumpriceQuote  
    #工事種別が通常かまたは値引の場合のみ合算。
    where("quotation_details_histories.construction_type = ? or quotation_details_histories.construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:quote_price)
  end
  #金額合計(実行)
  def self.sumpriceExecution  
    #工事種別が通常かまたは値引の場合のみ合算。
    where("quotation_details_histories.construction_type = ? or quotation_details_histories.construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:execution_price)
  end
  #合計(歩掛り)
  def self.sumLaborProductivityUnit 
    sum(:labor_productivity_unit).round(3)
  end 
   #合計(歩掛り計)
  def self.sumLaborProductivityUnitTotal 
      #工事種別が通常かまたは値引の場合のみ合算。
    where("quotation_details_histories.construction_type = ? or quotation_details_histories.construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:labor_productivity_unit_total).round(3)
  end 
  
  #合計(歩掛り-配管配線集計用)
  scope :sum_LPU_PipingWiring, -> quotation_header_history_id, quotation_breakdown_history_id {where(:piping_wiring_flag => 1).where(quotation_header_history_id: quotation_header_history_id ).
                                   where(quotation_breakdown_history_id: quotation_breakdown_history_id ).sum(:labor_productivity_unit)}
  #合計(歩掛り計-配管配線集計用)
  scope :sum_LPUT_PipingWiring, -> quotation_header_history_id, quotation_breakdown_history_id {where(:piping_wiring_flag => 1).where(quotation_header_history_id: quotation_header_history_id ).
                                    where(quotation_breakdown_history_id: quotation_breakdown_history_id ).sum(:labor_productivity_unit_total)}
  #合計(歩掛り-機器取付集計用)
  scope :sum_LPU_equipment_mounting, -> quotation_header_history_id, quotation_breakdown_history_id {where(:equipment_mounting_flag => 1).where(quotation_header_history_id: quotation_header_history_id ).
                                    where(quotation_breakdown_history_id: quotation_breakdown_history_id ).sum(:labor_productivity_unit)}
  #合計(歩掛り-機器取付集計用)
  scope :sum_LPUT_equipment_mounting, -> quotation_header_history_id, quotation_breakdown_history_id {where(:equipment_mounting_flag => 1).where(quotation_header_history_id: quotation_header_history_id ).
                                    where(quotation_breakdown_history_id: quotation_breakdown_history_id ).sum(:labor_productivity_unit_total)}
  #合計(歩掛り-労務費集計用)
  scope :sum_LPU_labor_cost, -> quotation_header_history_id, quotation_breakdown_history_id {where(:labor_cost_flag => 1).where(quotation_header_history_id: quotation_header_history_id ).
                                    where(quotation_breakdown_history_id: quotation_breakdown_history_id ).sum(:labor_productivity_unit)}
  #合計(歩掛り-労務費集計用)
  scope :sum_LPUT_labor_cost, -> quotation_header_history_id, quotation_breakdown_history_id {where(:labor_cost_flag => 1).where(quotation_header_history_id: quotation_header_history_id ).
                                    where(quotation_breakdown_history_id: quotation_breakdown_history_id ).sum(:labor_productivity_unit_total)}
  
  scope :with_header_id, -> (quotation_details_histories_quotation_header_history_id=1) { joins(:QuotationHeader).where("quotation_headers.id = ?", quotation_details_histories_quotation_header_history_id )}

  scope :with_large_item, -> (quotation_details_histories_quotation_breakdown_history_id=1, hoge) { joins(:QuotationDetailLargeClassification)
  .where("quotation_detail_large_classifications.working_large_item_name = ?", quotation_details_histories_quotation_breakdown_history_id )
  .where("quotation_detail_large_classifications.working_large_specification = ?", hoge )}
  
  
  def self.ransackable_scopes(auth_object=nil)
     [:with_header_id, :with_large_item, :with_large_specification]
  end
  
end
