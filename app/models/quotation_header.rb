class QuotationHeader < ActiveRecord::Base
   paginates_per 200  # 1ページあたり項目表示
   belongs_to :ConstructionDatum, :foreign_key => "construction_datum_id"
   
   belongs_to :customer_master, :foreign_key => "customer_id"
   accepts_nested_attributes_for :customer_master, update_only: true
   
   attr_accessor :customer_id_hide
   
   #add171002
   attr_accessor :invoice_period_start_date_hide
   attr_accessor :invoice_period_end_date_hide
   
   #見積書コードはユニークのチェックのみ。
   validates :quotation_code, presence:true, uniqueness: true
   
   ##add180123
   #住所に番地等を入れないようにするためのバリデーション(冗長だが他に方法が見当たらない)
   ADDRESS_ERROR_MESSAGE = "番地（番地）は入力できません。"
   ADDRESS_ERROR_MESSAGE_2 = "番地（丁目）は入力できません。"
   ADDRESS_ERROR_MESSAGE_3 = "番地（ハイフン）は入力できません。"
   ADDRESS_ERROR_MESSAGE_4 = "番地（数字）は入力できません。"
   
   validates :address, format: {without: /丁目/ , :message => ADDRESS_ERROR_MESSAGE_2 }
   validates :address, format: {without: /番地/ , :message => ADDRESS_ERROR_MESSAGE }
   #「流通センター」などの地名も有るため、許可する。
   #validates :address, format: {without: /ー/ , :message => ADDRESS_ERROR_MESSAGE_3 }
   #validates :address, format: {without: /−/ , :message => ADDRESS_ERROR_MESSAGE_3 }
   validates :address, format: {without: /-/ , :message => ADDRESS_ERROR_MESSAGE_3 }
   
   #住所に数値が混じっていた場合も禁止する
   validate  :address_regex
   def address_regex
     if address.match(/[0-9０-９]+$/)
       errors.add :address, ADDRESS_ERROR_MESSAGE_4
     end
   end
   
   #見積書用（工事場所）
   validates :construction_place, format: {without: /丁目/ , :message => ADDRESS_ERROR_MESSAGE_2 }
   validates :construction_place, format: {without: /番地/ , :message => ADDRESS_ERROR_MESSAGE }
   #「流通センター」などの地名も有るため、許可する。
   #validates :construction_place, format: {without: /ー/ , :message => ADDRESS_ERROR_MESSAGE_3 }
   #validates :construction_place, format: {without: /−/ , :message => ADDRESS_ERROR_MESSAGE_3 }
   validates :construction_place, format: {without: /-/ , :message => ADDRESS_ERROR_MESSAGE_3 }
   
   #住所に数値が混じっていた場合も禁止する
   validate  :construction_place_regex
   def construction_place_regex
     if construction_place.match(/[0-9０-９]+$/)
       errors.add :construction_place, ADDRESS_ERROR_MESSAGE_4
     end
   end
   
   ##add end 
   
   scope :with_id, -> (quotation_headers_id=1) { where("quotation_headers.id = ?", quotation_headers_id )}
   
   def self.ransackable_scopes(auth_object=nil)
       [:with_id]
   end
     
end
