class QuotationHeader < ActiveRecord::Base
   paginates_per 50  # 1ページあたり項目表示
   belongs_to :ConstructionDatum, :foreign_key => "construction_datum_id"
   
   belongs_to :customer_master, :foreign_key => "customer_id"
   accepts_nested_attributes_for :customer_master, update_only: true
	
   scope :with_id, -> (quotation_headers_id=1) { where("quotation_headers.id = ?", quotation_headers_id )}
   
   def self.ransackable_scopes(auth_object=nil)
       [:with_id]
   end
     
end
