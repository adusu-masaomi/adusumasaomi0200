class Stocktake < ActiveRecord::Base
  paginates_per 200  # 1ページあたり項目表示
  
  belongs_to :material_master
  belongs_to :inventory
  
  #ajax用
  attr_accessor :unit_price_hide
  attr_accessor :quantity_hide
  attr_accessor :amount_hide
  attr_accessor :difference
  attr_accessor :different_amount
  
  #attr_accessor :inventory_id_hide  #add171128
  
  #棚卸日＆アイテムの重複登録防止。
  validates :stocktake_date,  presence: true, uniqueness: { scope: [:material_master_id] }
  
 scope :with_material_category_include, -> (inventory_material_category=1) {
    
    category_id = inventory_material_category.to_i 
	
    #del220126
    #idが１以上でないと呼び出されないため、viewで１をプラスしているので、ここでマイナスしてあげる。
    #category_id -= 1
	 
    joins(:inventory).joins(:material_master).where("material_masters.inventory_category_id = ?", category_id )
	
  }
  
  def self.ransackable_scopes(auth_object=nil)
      [ :with_material_category_include]
  end
end
