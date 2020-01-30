class QuotationMaterialDetail < ActiveRecord::Base

  belongs_to :quotation_material_header
  
  belongs_to :maker_master, :foreign_key => "maker_id"
  belongs_to :unit_master
  
  #add200129
  belongs_to :material_master,  :foreign_key => "material_id"
  
  #メーカーID用
  attr_accessor :maker_id_hide
  
  #add200129
  #分類 
  attr_accessor :material_category_id_hide
  
  #単位
  attr_accessor :unit_id_hide
  
  #明細の連番配置用
  attr_accessor :sequential_id_hide
  #ソート順判別用（新規＝降順、編集＝昇順）
  attr_accessor :sort_order
  #add180508
  #備考
  attr_accessor :notes
  
  # sequential(gem)用 '1707xx
  acts_as_sequenced scope: :quotation_material_header_id
  
end
