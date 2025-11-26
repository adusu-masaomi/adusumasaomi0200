class StorageInventory < ActiveRecord::Base
  paginates_per 200  # 1ページあたり項目表示
  
  belongs_to :material_master
  belongs_to :unit_master
  
  #validates :warehouse_id, presence: true
  
  #倉庫
  def self.warehouse
    [["事務所", 0], ["倉庫", 1]] 
  end
  
  scope :with_material_category_include, -> (material_category=1) {
    category_id = material_category.to_i 
    joins(:material_master).where("material_masters.inventory_category_id = ?", category_id )
  }
  def self.ransackable_scopes(auth_object=nil)
    [:with_material_category_include]
  end
end
