class Inventory < ActiveRecord::Base
  paginates_per 200  # 1ページあたり項目表示
  
  belongs_to :material_master
  belongs_to :unit_master
  
  #add171026
  belongs_to :supplier_master
  
  #ファイルのアップローダー追加 add 171218
  mount_uploader :image, ImagesUploader
  
  #バリデーション追加
  #validates_numericality_of :inventory_quantity, :only_integer => true, :allow_nil => false
  validates_numericality_of :inventory_quantity, :only_float => true, :allow_nil => false    #upd180608 int to float
  validates_numericality_of :inventory_amount, :only_integer => true, :allow_nil => false
  #validates_numericality_of :current_quantity, :only_integer => true, :allow_nil => false   
  validates_numericality_of :current_quantity, :only_float => true, :allow_nil => false      #upd180608 int to float
  validates_numericality_of :current_unit_price, :allow_nil => false
  validates_numericality_of :last_unit_price, :allow_nil => false
  #
  
  #add171027
  #活動フラグ判定用追加
  attr_accessor :action_flag
  
  
  scope :with_material_name_include, -> inventory_material_name {
    if inventory_material_name.present? 
      joins(:material_master).where("material_masters.material_name like ?", '%' + inventory_material_name + '%' )
    end
  }
  scope :with_material_category_include, -> (inventory_material_category=1) {
    
    category_id = inventory_material_category.to_i 

    #220126抹消
    #idが１以上でないと呼び出されないため、viewで１をプラスしているので、ここでマイナスしてあげる。
    #category_id -= 1
	 
    joins(:material_master).where("material_masters.inventory_category_id = ?", category_id )
  }
  
  #del220126(マスター化)
  #在庫品目（品目を増やす場合はここで追記する。app.controllerにも定数追加(?不要?)。）
  #def self.category 
  #  [["エアコン部材", 0], ["配線器具", 1], ["ケーブル", 2], ["照明器具", 3], ["アンテナ", 4], ["分電盤", 5], ["ドアホン", 6], ["アース棒", 7], 
  #  ["開閉器", 8] ]
  #end
  
  def self.ransackable_scopes(auth_object=nil)
      [:with_material_name_include, :with_material_category_include]
      
  end
end
