class UnitMaster < ActiveRecord::Base

   #scope :with_unit, -> (id=1){joins(:PurchaseUnitPrice).where("unit_masters.id = purchase_unit_prices.unit_id" )}
   #def self.ransackable_scopes(auth_object=nil)
   #    [:with_unit]
   #end

end
