class QuotationDetailMiddleClassification < ActiveRecord::Base
  belongs_to :QuotationHeader, :foreign_key => "quotation_header_id"
  
  belongs_to :QuotationDetailLargeClassification, :foreign_key => "quotation_detail_large_classification_id"
  #accepts_nested_attributes_for :QuotationDetailLargeClassification, update_only: true
  #belongs_to :quotation_detail_large_classification, :foreign_key => "quotation_detail_large_classification_id"
 
  belongs_to :QuotationLargeItem, :foreign_key => "quotation_detail_large_classification_id"
  #belongs_to :QuotationUnit, :foreign_key => "quotation_unit_id"
  belongs_to :WorkingUnit, :foreign_key => "working_unit_id"
  
  #行挿入用
  attr_accessor :check_line_insert
  
  #マスターセット用
  #attr_accessor :check_update_master
  attr_accessor :check_update_item
  attr_accessor :check_update_all
  
  #attr_accessor :default_page_number
  
  def self.serial_number
    [[("<行選択>").to_s , (1..100).to_a ]]
  end 

  #金額合計(見積)
  def self.sumpriceQuote  
    sum(:quote_price)
  end
  #金額合計(実行)
  def self.sumpriceExecution  
    sum(:execution_price)
  end
  #合計(歩掛り)
  def self.sumLaborProductivityUnit 
    sum(:labor_productivity_unit).round(3)
  end 
   #合計(歩掛り計)
  def self.sumLaborProductivityUnitTotal 
    sum(:labor_productivity_unit_total).round(3)
  end 
  
  #scope
  scope :with_header_id, -> (quotation_detail_middle_classifications_quotation_header_id=1) { joins(:QuotationHeader).where("quotation_headers.id = ?", quotation_detail_middle_classifications_quotation_header_id )}

  #scope :with_large_item, -> (quotation_detail_middle_classifications_quotation_detail_large_classification_id=1) { joins(:QuotationDetailLargeClassification).where("quotation_detail_large_classifications.quotation_large_item_name = ?", quotation_detail_middle_classifications_quotation_detail_large_classification_id )}
  scope :with_large_item, -> (quotation_detail_middle_classifications_quotation_detail_large_classification_id=1) { joins(:QuotationDetailLargeClassification).where("quotation_detail_large_classifications.working_large_item_name = ?", quotation_detail_middle_classifications_quotation_detail_large_classification_id )}

  def self.ransackable_scopes(auth_object=nil)
     #[:with_header_id, :with_large_item_id]
     [:with_header_id, :with_large_item]
  end

end
