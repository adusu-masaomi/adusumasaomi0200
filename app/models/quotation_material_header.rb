class QuotationMaterialHeader < ActiveRecord::Base

  belongs_to :construction_datum
  belongs_to :supplier_master
  
  has_many :quotation_material_details
  accepts_nested_attributes_for :quotation_material_details, :allow_destroy => true
  
  #ボタン切り分け用
  attr_accessor :sent_flag
  
  #見積依頼メール判定フラグ（済or未）
  attr_accessor :quotation_email_flag
  
  #全チェック(落札)フラグ
  attr_accessor :all_bid_flag
  
  #資材ID自動セット用
  attr_accessor :material_id_hide
  
  #注文No
  #add171023
  attr_accessor :purchase_order_code
  
  #バリデーション
  validates :quotation_code, presence: true
  
  #参照見積コード
  #attr_accessor :quotation_header_origin_id
   
end