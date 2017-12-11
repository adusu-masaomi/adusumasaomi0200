class DeliverySlipHeader < ActiveRecord::Base

   paginates_per 200  # 1ページあたり項目表示
   belongs_to :ConstructionDatum, :foreign_key => "construction_datum_id"
   
   belongs_to :customer_master, :foreign_key => "customer_id"
   accepts_nested_attributes_for :customer_master, update_only: true
	
   attr_accessor :customer_id_hide	
	
   #バリデーション
   #validates :delivery_slip_code, presence: true, uniqueness: true	
   #納品書コードはユニークのチェックのみ。nullチェックはコピーに失敗するため除外。
   validates :delivery_slip_code, presence:true, uniqueness: true

	
   scope :with_id, -> (delivery_slip_headers_id=1) { where("delivery_slip_headers.id = ?", delivery_slip_headers_id )}
   
   def self.ransackable_scopes(auth_object=nil)
       [:with_id]
   end
   
   
   #リスト表示用(CD/件名)
	def p_delv_cd_name
	
	    #binding.pry
	
        if self.delivery_slip_code.nil?
           delivery_slip_code = "-"
        else 
           delivery_slip_code = self.delivery_slip_code
        end
        if self.construction_name.nil?
           construction_name = "-"
        else 
           construction_name = self.construction_name
        end        

        delivery_slip_code + ':' + construction_name 
    end
   
end
