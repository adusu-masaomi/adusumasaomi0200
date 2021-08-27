class QuotationDetailMiddleClassification < ActiveRecord::Base

  #kaminari用設定
  paginates_per 200  # 1ページあたり項目表示
   

  belongs_to :QuotationHeader, :foreign_key => "quotation_header_id"
  belongs_to :QuotationDetailLargeClassification, :foreign_key => "quotation_detail_large_classification_id"
  belongs_to :QuotationLargeItem, :foreign_key => "quotation_detail_large_classification_id"
  belongs_to :WorkingUnit, :foreign_key => "working_unit_id"
  
  #行挿入用
  attr_accessor :check_line_insert
  
  #マスターセット用
  attr_accessor :check_update_item
  attr_accessor :check_update_all
  
  #短縮名手入力用(add170822)
  attr_accessor :working_middle_item_short_name_manual
  
  #add 1711004
  #attr_accessor :category
  attr_accessor :quotation_middle_item_id
  attr_accessor :master_insert_flag
  #ajax用（リスト）
  #attr_accessor :working_middle_item_category_id_call
  attr_accessor :working_middle_item_id_select_hide
  attr_accessor :working_middle_item_short_name_select_hide
  #
  #attr_accessor :working_middle_item_subcategory_id_call
  attr_accessor :working_subcategory_select_hide
  #
  #add180210
  attr_accessor :category_save_flag_child
  #
  
  def self.serial_number
    [[("<行選択>").to_s , (1..999).to_a ]]
    #[[("<行選択>").to_s , (0..999).to_a ]]
  end 
  
  #金額合計(見積)
  def self.sumpriceQuote  
    #工事種別が通常かまたは値引の場合のみ合算。
    #where("quotation_detail_middle_classifications.construction_type = ? or quotation_detail_middle_classifications.construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:quote_price)
    
    #upd180105
	#工事種別が小計以外は加算する
    where("quotation_detail_middle_classifications.construction_type <> ? ", $INDEX_SUBTOTAL.to_s ).sum(:quote_price)
  
  end
  #金額合計(実行)
  def self.sumpriceExecution  
    #工事種別が通常かまたは値引の場合のみ合算。
    #where("quotation_detail_middle_classifications.construction_type = ? or quotation_detail_middle_classifications.construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:execution_price)
    #upd180105
    #工事種別が小計以外は加算する
    where("quotation_detail_middle_classifications.construction_type <> ? ", $INDEX_SUBTOTAL.to_s ).sum(:execution_price)
  end
  #合計(歩掛り)
  def self.sumLaborProductivityUnit 
    sum(:labor_productivity_unit).round(3)
  end 
   #合計(歩掛り計)
  def self.sumLaborProductivityUnitTotal 
    #工事種別が通常かまたは値引の場合のみ合算。
    #where("quotation_detail_middle_classifications.construction_type = ? or quotation_detail_middle_classifications.construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:labor_productivity_unit_total).round(3)
  
    #upd180105
    #工事種別が小計以外は加算する
    where("quotation_detail_middle_classifications.construction_type <> ? ", $INDEX_SUBTOTAL.to_s ).sum(:labor_productivity_unit_total).round(3)
	
  end 
  
  #scope
  #合計(歩掛り-配管配線集計用)
  scope :sum_LPU_PipingWiring, -> quotation_header_id, quotation_detail_large_classification_id {where(:piping_wiring_flag => 1).where(quotation_header_id: quotation_header_id ).
                                   where(quotation_detail_large_classification_id: quotation_detail_large_classification_id ).sum(:labor_productivity_unit)}
  #合計(歩掛り計-配管配線集計用)
  scope :sum_LPUT_PipingWiring, -> quotation_header_id, quotation_detail_large_classification_id {where(:piping_wiring_flag => 1).where(quotation_header_id: quotation_header_id ).
                                    where(quotation_detail_large_classification_id: quotation_detail_large_classification_id ).sum(:labor_productivity_unit_total)}
  
  #合計(歩掛り-機器取付集計用)
  scope :sum_LPU_equipment_mounting, -> quotation_header_id, quotation_detail_large_classification_id {where(:equipment_mounting_flag => 1).where(quotation_header_id: quotation_header_id ).
                                    where(quotation_detail_large_classification_id: quotation_detail_large_classification_id ).sum(:labor_productivity_unit)}
  #合計(歩掛り-機器取付集計用)
  scope :sum_LPUT_equipment_mounting, -> quotation_header_id, quotation_detail_large_classification_id {where(:equipment_mounting_flag => 1).where(quotation_header_id: quotation_header_id ).
                                    where(quotation_detail_large_classification_id: quotation_detail_large_classification_id ).sum(:labor_productivity_unit_total)}
  #合計(歩掛り-労務費集計用)
  scope :sum_LPU_labor_cost, -> quotation_header_id, quotation_detail_large_classification_id {where(:labor_cost_flag => 1).where(quotation_header_id: quotation_header_id ).
                                    where(quotation_detail_large_classification_id: quotation_detail_large_classification_id ).sum(:labor_productivity_unit)}
  #合計(歩掛り-労務費集計用)
  scope :sum_LPUT_labor_cost, -> quotation_header_id, quotation_detail_large_classification_id {where(:labor_cost_flag => 1).where(quotation_header_id: quotation_header_id ).
                                    where(quotation_detail_large_classification_id: quotation_detail_large_classification_id ).sum(:labor_productivity_unit_total)}
  
  ######
  #add180105
  #配管・機器・労務集計において、金額の計も算出する
  
  #見積金額計
  
  #(配管配線集計用)
  scope :sum_quote_price_PipingWiring, -> quotation_header_id, quotation_detail_large_classification_id {where(:piping_wiring_flag => 1).where(quotation_header_id: quotation_header_id ).
                                    where(quotation_detail_large_classification_id: quotation_detail_large_classification_id ).sum(:quote_price)}
  #(機器取付集計用)
  scope :sum_quote_price_equipment_mounting, -> quotation_header_id, quotation_detail_large_classification_id {where(:equipment_mounting_flag => 1).where(quotation_header_id: quotation_header_id ).
                                    where(quotation_detail_large_classification_id: quotation_detail_large_classification_id ).sum(:quote_price)}
  #(労務費集計用)
  scope :sum_quote_price_labor_cost, -> quotation_header_id, quotation_detail_large_classification_id {where(:labor_cost_flag => 1).where(quotation_header_id: quotation_header_id ).
                                    where(quotation_detail_large_classification_id: quotation_detail_large_classification_id ).sum(:quote_price)}
  
  #実行金額計
  
  #(配管配線集計用)
  scope :sum_execution_price_PipingWiring, -> quotation_header_id, quotation_detail_large_classification_id {where(:piping_wiring_flag => 1).where(quotation_header_id: quotation_header_id ).
                                    where(quotation_detail_large_classification_id: quotation_detail_large_classification_id ).sum(:execution_price)}
  #(機器取付集計用)
  scope :sum_execution_price_equipment_mounting, -> quotation_header_id, quotation_detail_large_classification_id {where(:equipment_mounting_flag => 1).where(quotation_header_id: quotation_header_id ).
                                    where(quotation_detail_large_classification_id: quotation_detail_large_classification_id ).sum(:execution_price)}
  #(労務費集計用)
  scope :sum_execution_price_labor_cost, -> quotation_header_id, quotation_detail_large_classification_id {where(:labor_cost_flag => 1).where(quotation_header_id: quotation_header_id ).
                                    where(quotation_detail_large_classification_id: quotation_detail_large_classification_id ).sum(:execution_price)}
  ######

  
  scope :with_header_id, -> (quotation_detail_middle_classifications_quotation_header_id=1) { joins(:QuotationHeader).where("quotation_headers.id = ?", quotation_detail_middle_classifications_quotation_header_id )}

  scope :with_large_item, -> (quotation_detail_middle_classifications_quotation_detail_large_classification_id=1, hoge) { joins(:QuotationDetailLargeClassification)
  .where("quotation_detail_large_classifications.working_large_item_name = ?", quotation_detail_middle_classifications_quotation_detail_large_classification_id )
  .where("quotation_detail_large_classifications.working_large_specification = ?", hoge )}
  
  
  def self.ransackable_scopes(auth_object=nil)
     [:with_header_id, :with_large_item, :with_large_specification]
  end

end
