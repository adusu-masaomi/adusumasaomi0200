class QuotationHeader < ActiveRecord::Base
   paginates_per 50  # 1ページあたり項目表示
   belongs_to :ConstructionDatum, :foreign_key => "construction_datum_id"
   
   scope :with_id, -> (quotation_headers_id=1) { where("quotation_headers.id = ?", quotation_headers_id )}

   def self.ransackable_scopes(auth_object=nil)
       [:with_id]
   end
     
end
