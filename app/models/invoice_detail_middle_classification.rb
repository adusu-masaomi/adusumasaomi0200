class InvoiceDetailMiddleClassification < ActiveRecord::Base
  belongs_to :InvoiceHeader, :foreign_key => "invoice_header_id"
  
  belongs_to :InvoiceDetailLargeClassification, :foreign_key => "invoice_detail_large_classification_id"
  #belongs_to :InvoiceLargeItem, :foreign_key => "invoice_detail_large_classification_id"
  belongs_to :WorkingUnit, :foreign_key => "working_unit_id"
  
  #行挿入用
  attr_accessor :check_line_insert
  
  #マスターセット用
  attr_accessor :check_update_item
  attr_accessor :check_update_all
  
  #短縮名手入力用(add170822)
  attr_accessor :working_middle_item_short_name_manual
  
  def self.serial_number
    [[("<行選択>").to_s , (1..999).to_a ]]
  end 
  
  #add170223
  #del170308
  #def self.types 
  #  [["通常", 0], ["配管配線工事", 1], ["機器取付工事", 2], ["労務費", 3]] 
  #end
  
  #金額合計(請求)
  def self.sumpriceInvoice  
    #sum(:invoice_price)
	#工事種別が通常かまたは値引の場合のみ合算。
    where("invoice_detail_middle_classifications.construction_type = ? or 
      invoice_detail_middle_classifications.construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:invoice_price)
  end
  #金額合計(実行)
  def self.sumpriceExecution  
    #sum(:execution_price)
    #upd170308
    #工事種別が通常かまたは値引の場合のみ合算。
    where("invoice_detail_middle_classifications.construction_type = ? or 
      invoice_detail_middle_classifications.construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:execution_price)

  end
  #合計(歩掛り)
  def self.sumLaborProductivityUnit 
    sum(:labor_productivity_unit).round(3)
  end 
   #合計(歩掛り計)
  def self.sumLaborProductivityUnitTotal 
    #sum(:labor_productivity_unit_total).round(3)
    #upd170306
    #where(:construction_type => "0").sum(:labor_productivity_unit_total).round(3)
	#upd170308
    #工事種別が通常かまたは値引の場合のみ合算。
    where("invoice_detail_middle_classifications.construction_type = ? or 
	invoice_detail_middle_classifications.construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:labor_productivity_unit_total).round(3)
	
  end 
  
  #scope
  
  #add170223
  #合計(歩掛り-配管配線集計用)
  scope :sum_LPU_PipingWiring, -> invoice_header_id, invoice_detail_large_classification_id {where(:piping_wiring_flag => 1).where(invoice_header_id: invoice_header_id ).
                                   where(invoice_detail_large_classification_id: invoice_detail_large_classification_id ).sum(:labor_productivity_unit)}
  #合計(歩掛り計-配管配線集計用)
  scope :sum_LPUT_PipingWiring, -> invoice_header_id, invoice_detail_large_classification_id {where(:piping_wiring_flag => 1).where(invoice_header_id: invoice_header_id ).
                                    where(invoice_detail_large_classification_id: invoice_detail_large_classification_id ).sum(:labor_productivity_unit_total)}
  #合計(歩掛り-機器取付集計用)
  scope :sum_LPU_equipment_mounting, -> invoice_header_id, invoice_detail_large_classification_id {where(:equipment_mounting_flag => 1).where(invoice_header_id: invoice_header_id ).
                                    where(invoice_detail_large_classification_id: invoice_detail_large_classification_id ).sum(:labor_productivity_unit)}
  #合計(歩掛り-機器取付集計用)
  scope :sum_LPUT_equipment_mounting, -> invoice_header_id, invoice_detail_large_classification_id {where(:equipment_mounting_flag => 1).where(invoice_header_id: invoice_header_id ).
                                    where(invoice_detail_large_classification_id: invoice_detail_large_classification_id ).sum(:labor_productivity_unit_total)}
  #合計(歩掛り-労務費集計用)
  scope :sum_LPU_labor_cost, -> invoice_header_id, invoice_detail_large_classification_id {where(:labor_cost_flag => 1).where(invoice_header_id: invoice_header_id ).
                                    where(invoice_detail_large_classification_id: invoice_detail_large_classification_id ).sum(:labor_productivity_unit)}
  #合計(歩掛り-労務費集計用)
  scope :sum_LPUT_labor_cost, -> invoice_header_id, invoice_detail_large_classification_id {where(:labor_cost_flag => 1).where(invoice_header_id: invoice_header_id ).
                                    where(invoice_detail_large_classification_id: invoice_detail_large_classification_id ).sum(:labor_productivity_unit_total)}
  #add end
  
  scope :with_header_id, -> (invoice_detail_middle_classifications_invoice_header_id=1) { joins(:InvoiceHeader).where("invoice_headers.id = ?", invoice_detail_middle_classifications_invoice_header_id )}
  #scope :with_large_item, -> (invoice_detail_middle_classifications_invoice_detail_large_classification_id=1) { joins(:InvoiceDetailLargeClassification).where("invoice_detail_large_classifications.working_large_item_name = ?", invoice_detail_middle_classifications_invoice_detail_large_classification_id )}
  
  #upd170308
  scope :with_large_item, -> (invoice_detail_middle_classifications_invoice_detail_large_classification_id=1, hoge ) { joins(:InvoiceDetailLargeClassification)
        .where("invoice_detail_large_classifications.working_large_item_name = ?", invoice_detail_middle_classifications_invoice_detail_large_classification_id )
        .where("invoice_detail_large_classifications.working_large_specification = ?", hoge ) }
  
  scope :with_large_item_name, -> (invoice_detail_middle_classifications_invoice_detail_large_classification_id=1, item_name ) { joins(:InvoiceDetailLargeClassification)
        .where("invoice_detail_large_classifications.working_large_item_name = ?", item_name) }

  def self.ransackable_scopes(auth_object=nil)
     [:with_header_id, :with_large_item, :with_large_item_name]
  end
end
