class DeliverySlipDetailMiddleClassification < ActiveRecord::Base
  belongs_to :DeliverySlipHeader, :foreign_key => "delivery_slip_header_id"
  
  belongs_to :DeliverySlipDetailLargeClassification, :foreign_key => "delivery_slip_detail_large_classification_id"
  #belongs_to :WorkingLargeItem, :foreign_key => "delivery_slip_detail_large_classification_id"
  belongs_to :WorkingUnit, :foreign_key => "working_unit_id"
  
  #行挿入用
  attr_accessor :check_line_insert
  
  #マスターセット用
  attr_accessor :check_update_item
  attr_accessor :check_update_all
  
  #短縮名手入力用(add170822)
  attr_accessor :working_middle_item_short_name_manual
  #add 1711004
  attr_accessor :quotation_large_item_id
  attr_accessor :master_insert_flag
  #ajax用（リスト）
  attr_accessor :working_middle_item_id_select_hide
  attr_accessor :working_middle_item_short_name_select_hide
  attr_accessor :working_subcategory_select_hide
  
  #del180210
  #attr_accessor :working_middle_item_category_id_call
  #attr_accessor :working_middle_item_subcategory_id_call
  
  #add180210
  attr_accessor :category_save_flag_child
  
  def self.serial_number
    [[("<行選択>").to_s , (1..999).to_a ]]
  end 
  
  #add170223
  #def self.types 
  #  [["通常", 0], ["配管配線工事", 1], ["機器取付工事", 2], ["労務費", 3]] 
  #end
  
  #金額合計(納品)
  def self.sumpriceDeliverySlip  
    #sum(:delivery_slip_price)
    #工事種別が通常かまたは値引の場合のみ合算。
    #where("delivery_slip_detail_middle_classifications.construction_type = ? or 
    #       delivery_slip_detail_middle_classifications.construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:delivery_slip_price)
    
	#upd180105
	#工事種別が小計以外は加算する
    where("delivery_slip_detail_middle_classifications.construction_type <> ? ", $INDEX_SUBTOTAL.to_s ).sum(:delivery_slip_price)
	

  end
  #金額合計(実行)
  def self.sumpriceExecution  
    #sum(:execution_price)
	
    #工事種別が通常かまたは値引の場合のみ合算。
    #where("delivery_slip_detail_middle_classifications.construction_type = ? or 
    #       delivery_slip_detail_middle_classifications.construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:execution_price)
    
    #upd180105
    #工事種別が小計以外は加算する
    where("delivery_slip_detail_middle_classifications.construction_type <> ? ", $INDEX_SUBTOTAL.to_s ).sum(:execution_price)
	
  end
  #合計(歩掛り)
  def self.sumLaborProductivityUnit 
    sum(:labor_productivity_unit).round(3)
  end 
   #合計(歩掛り計)
  def self.sumLaborProductivityUnitTotal 
    #sum(:labor_productivity_unit_total).round(3)
    #工事種別が通常かまたは値引の場合のみ合算。
    #where("delivery_slip_detail_middle_classifications.construction_type = ? or 
    #      delivery_slip_detail_middle_classifications.construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:labor_productivity_unit_total).round(3)
    
	#upd180105
    #工事種別が小計以外は加算する
    where("delivery_slip_detail_middle_classifications.construction_type <> ? ", $INDEX_SUBTOTAL.to_s ).sum(:labor_productivity_unit_total).round(3)
	
  end 
  
  #scope
  #合計(歩掛り-配管配線集計用)
  scope :sum_LPU_PipingWiring, -> delivery_slip_header_id, delivery_slip_detail_large_classification_id {where(:piping_wiring_flag => 1).where(delivery_slip_header_id: delivery_slip_header_id ).
                                   where(delivery_slip_detail_large_classification_id: delivery_slip_detail_large_classification_id ).sum(:labor_productivity_unit)}
  #合計(歩掛り計-配管配線集計用)
  scope :sum_LPUT_PipingWiring, -> delivery_slip_header_id, delivery_slip_detail_large_classification_id {where(:piping_wiring_flag => 1).where(delivery_slip_header_id: delivery_slip_header_id ).
                                    where(delivery_slip_detail_large_classification_id: delivery_slip_detail_large_classification_id ).sum(:labor_productivity_unit_total)}
  #合計(歩掛り-機器取付集計用)
  scope :sum_LPU_equipment_mounting, -> delivery_slip_header_id, delivery_slip_detail_large_classification_id {where(:equipment_mounting_flag => 1).where(delivery_slip_header_id: delivery_slip_header_id ).
                                    where(delivery_slip_detail_large_classification_id: delivery_slip_detail_large_classification_id ).sum(:labor_productivity_unit)}
  #合計(歩掛り-機器取付集計用)
  scope :sum_LPUT_equipment_mounting, -> delivery_slip_header_id, delivery_slip_detail_large_classification_id {where(:equipment_mounting_flag => 1).where(delivery_slip_header_id: delivery_slip_header_id ).
                                    where(delivery_slip_detail_large_classification_id: delivery_slip_detail_large_classification_id ).sum(:labor_productivity_unit_total)}
  #合計(歩掛り-労務費集計用)
  scope :sum_LPU_labor_cost, -> delivery_slip_header_id, delivery_slip_detail_large_classification_id {where(:labor_cost_flag => 1).where(delivery_slip_header_id: delivery_slip_header_id ).
                                    where(delivery_slip_detail_large_classification_id: delivery_slip_detail_large_classification_id ).sum(:labor_productivity_unit)}
  #合計(歩掛り-労務費集計用)
  scope :sum_LPUT_labor_cost, -> delivery_slip_header_id, delivery_slip_detail_large_classification_id {where(:labor_cost_flag => 1).where(delivery_slip_header_id: delivery_slip_header_id ).
                                    where(delivery_slip_detail_large_classification_id: delivery_slip_detail_large_classification_id ).sum(:labor_productivity_unit_total)}
  ######
  #add180105
  #配管・機器・労務集計において、金額の計も算出する
  
  #見積金額計
  
  #(配管配線集計用)
  scope :sum_delivery_slip_price_PipingWiring, -> delivery_slip_header_id, delivery_slip_detail_large_classification_id {where(:piping_wiring_flag => 1).where(delivery_slip_header_id: delivery_slip_header_id ).
                                    where(delivery_slip_detail_large_classification_id: delivery_slip_detail_large_classification_id ).sum(:delivery_slip_price)}
  #(機器取付集計用)
  scope :sum_delivery_slip_price_equipment_mounting, -> delivery_slip_header_id, delivery_slip_detail_large_classification_id {where(:equipment_mounting_flag => 1).where(delivery_slip_header_id: delivery_slip_header_id ).
                                    where(delivery_slip_detail_large_classification_id: delivery_slip_detail_large_classification_id ).sum(:delivery_slip_price)}
  #(労務費集計用)
  scope :sum_delivery_slip_price_labor_cost, -> delivery_slip_header_id, delivery_slip_detail_large_classification_id {where(:labor_cost_flag => 1).where(delivery_slip_header_id: delivery_slip_header_id ).
                                    where(delivery_slip_detail_large_classification_id: delivery_slip_detail_large_classification_id ).sum(:delivery_slip_price)}
  
  #実行金額計
  
  #(配管配線集計用)
  scope :sum_execution_price_PipingWiring, -> delivery_slip_header_id, delivery_slip_detail_large_classification_id {where(:piping_wiring_flag => 1).where(delivery_slip_header_id: delivery_slip_header_id ).
                                    where(delivery_slip_detail_large_classification_id: delivery_slip_detail_large_classification_id ).sum(:execution_price)}
  #(機器取付集計用)
  scope :sum_execution_price_equipment_mounting, -> delivery_slip_header_id, delivery_slip_detail_large_classification_id {where(:equipment_mounting_flag => 1).where(delivery_slip_header_id: delivery_slip_header_id ).
                                    where(delivery_slip_detail_large_classification_id: delivery_slip_detail_large_classification_id ).sum(:execution_price)}
  #(労務費集計用)
  scope :sum_execution_price_labor_cost, -> delivery_slip_header_id, delivery_slip_detail_large_classification_id {where(:labor_cost_flag => 1).where(delivery_slip_header_id: delivery_slip_header_id ).
                                    where(delivery_slip_detail_large_classification_id: delivery_slip_detail_large_classification_id ).sum(:execution_price)}
  ######

  
  
  scope :with_header_id, -> (delivery_slip_detail_middle_classifications_delivery_slip_header_id=1) { joins(:DeliverySlipHeader).where("delivery_slip_headers.id = ?", delivery_slip_detail_middle_classifications_delivery_slip_header_id )}
  #scope :with_large_item, -> (delivery_slip_detail_middle_classifications_delivery_slip_detail_large_classification_id=1) { joins(:DeliverySlipDetailLargeClassification).where("delivery_slip_detail_large_classifications.working_large_item_name = ?", delivery_slip_detail_middle_classifications_delivery_slip_detail_large_classification_id )}
  #upd170308
  scope :with_large_item, -> (delivery_slip_detail_middle_classifications_delivery_slip_detail_large_classification_id=1, hoge) { joins(:DeliverySlipDetailLargeClassification)
         .where("delivery_slip_detail_large_classifications.working_large_item_name = ?", delivery_slip_detail_middle_classifications_delivery_slip_detail_large_classification_id )
         .where("delivery_slip_detail_large_classifications.working_large_specification = ?", hoge )}

  def self.ransackable_scopes(auth_object=nil)
     [:with_header_id, :with_large_item]
  end

end
