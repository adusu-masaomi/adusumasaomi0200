class InvoiceHeader < ActiveRecord::Base
   paginates_per 200  # 1ページあたり項目表示
   belongs_to :ConstructionDatum, :foreign_key => "construction_datum_id"
   
   belongs_to :customer_master, :foreign_key => "customer_id"
   accepts_nested_attributes_for :customer_master, update_only: true
   
   attr_accessor :customer_id_hide
   
   #バリデーション
   #validates :invoice_code, presence: true, uniqueness: true
   #請求書コードはユニークのチェックのみ。nullチェックはコピーに失敗するため除外。
   validates :invoice_code, presence:true, uniqueness: true
	
   scope :with_id, -> (invoice_headers_id=1) { where("invoice_headers.id = ?", invoice_headers_id )}
   
   def self.ransackable_scopes(auth_object=nil)
       [:with_id]
   end
 	
  
  #支払方法---増えたらここで変更する。
  def self.payment_method 
    #[["現金", 0], ["北越", 1], ["さんしん", 2]]
    [["", 0], ["現金", 1], ["北越", 2], ["さんしん", 3]] 
  end
  
end
