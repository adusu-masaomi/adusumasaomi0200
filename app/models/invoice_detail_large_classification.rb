class InvoiceDetailLargeClassification < ActiveRecord::Base
  belongs_to :InvoiceHeader, :foreign_key => "invoice_header_id"
  belongs_to :WorkingUnit, :foreign_key => "working_unit_id"
  
  has_many :invoice_detail_middle_classifications

  def self.choices 
    [["項目", 1], ["備考", 2]] 
  end
  
  #del170308
  #def self.types 
  #  [["通常", 0], ["配管配線工事", 1], ["機器取付工事", 2], ["労務費", 3]] 
  #end
  
  def self.serial_number
    [[("<行選択>").to_s , (1..999).to_a ]]
  end 
  
  #行挿入用
  attr_accessor :check_line_insert
  #マスターセット用
  attr_accessor :check_update_item
  attr_accessor :check_update_all
  
  #短縮名手入力用(add170822)
  attr_accessor :working_large_item_short_name_manual
  
  #金額合計(請求)
  def self.sumpriceInvoice  
    #sum(:invoice_price)
	#upd170308
    #工事種別が通常かまたは値引の場合のみ合算。
    where("construction_type = ? or construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:invoice_price)

  end
  #金額合計(実行)
  def self.sumpriceExecution  
    sum(:execution_price)
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
    #sum(:labor_productivity_unit_total)
    #upd170306
    #where(:construction_type => "0").sum(:labor_productivity_unit_total)
    #upd170308
    #工事種別が通常かまたは値引の場合のみ合算。
    where("construction_type = ? or construction_type = ? ", "0", $INDEX_DISCOUNT.to_s ).sum(:labor_productivity_unit_total)
  end
  
  #add170223
  #合計(歩掛り-配管配線集計用)
  scope :sum_LPU_PipingWiring, -> invoice_header_id {where(:piping_wiring_flag => 1).where(invoice_header_id: invoice_header_id ).
                                   sum(:labor_productivity_unit)}
  #合計(歩掛り計-配管配線集計用)
  scope :sum_LPUT_PipingWiring, -> invoice_header_id {where(:piping_wiring_flag => 1).where(invoice_header_id: invoice_header_id ).
                                   sum(:labor_productivity_unit_total)}
  #合計(歩掛り-機器取付集計用)
  scope :sum_LPU_equipment_mounting, -> invoice_header_id {where(:equipment_mounting_flag => 1).where(invoice_header_id: invoice_header_id ).
                                   sum(:labor_productivity_unit)}
  #合計(歩掛り-機器取付集計用)
  scope :sum_LPUT_equipment_mounting, -> invoice_header_id {where(:equipment_mounting_flag => 1).where(invoice_header_id: invoice_header_id ).
                                   sum(:labor_productivity_unit_total)}
  #合計(歩掛り-労務費集計用)
  scope :sum_LPU_labor_cost, -> invoice_header_id {where(:labor_cost_flag => 1).where(invoice_header_id: invoice_header_id ).
                                   sum(:labor_productivity_unit)}
  #合計(歩掛り-労務費集計用)
  scope :sum_LPUT_labor_cost, -> invoice_header_id {where(:labor_cost_flag => 1).where(invoice_header_id: invoice_header_id ).
                                   sum(:labor_productivity_unit_total)}
  #add end
  
  scope :with_header_id, -> (invoice_detail_large_classifications_invoice_header_id=1) { joins(:InvoiceHeader).where("invoice_headers.id = ?", invoice_detail_large_classifications_invoice_header_id )}
  
  def self.ransackable_scopes(auth_object=nil)
     [:with_header_id]
  end
  
end
