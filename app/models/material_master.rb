class MaterialMaster < ActiveRecord::Base
	paginates_per 200  # 1ページあたり項目表示
	
	#has_many :PurchaseDatum
	belongs_to :PurchaseDatum
	belongs_to :MakerMaster, :foreign_key => "maker_id"
    
    has_many :PurchaseUnitPrice, :foreign_key => "material_id"  #add201208
    
    belongs_to :material_category
    belongs_to :inventory_category
    
    has_many :UnitMaster
	
	has_many :inventories
	
	#バリデーション
	#validates :maker_id, presence: true
	#validates :material_code, presence: true
	#validate :add_error_sample
    
	validates :material_code, presence: true, uniqueness: true
	
	#validates :maker_id, presence: true
	#validates :MakerMaster, presence: true, if: -> { maker_id.present? }
		
	
	#validates_presence_of :maker
    #field :maker_id
   #validates :maker_id, inclusion: { in: 	1..80 }
    
	#validates_presence_of  :maker_id
	#validates_associated :MakerMaster
	
	validates :maker_id, presence: true, if: "maker_id.nil?"
	
    def add_error_sample
      if maker_id.nil?
        errors[:maker_id] << "＊メーカーは必ず入力して下さい"
      end
    end
    
   validate :maker_existing
   
   #select2高速化のための処理
   #scope :search_faster, lambda { |query| where('material_name LIKE ?', "%#{query}%").limit(100) }
	 
   scope :with_maker, -> (id=1){joins(:MakerMaster).where("maker_masters.id = material_masters.maker_id" )}
   #在庫品目のみリストにあげたい場合に利用
   #scope :with_inventory_item, -> { where.not(:inventory_category_id => nil).where("inventory_category_id > ?", 0) }
   scope :with_inventory_item, -> { where.not(:inventory_category_id => nil) }
   
   scope :with_category, -> (id=1){joins(:material_category)}
   
   
   #add201208
   #scope :with_supplier_material_code, -> (dummy, supplier_material_id) { 
   #scope :with_supplier_material_code, -> (supplier_material_id=1) {
   scope :with_supplier_material_code, -> (supplier_material_id) {
      
      if supplier_material_id.present?
        strAry = supplier_material_id.split(",")  #仕入先id, 品番idで結合されたキーの為、分割させる
        joins(:PurchaseUnitPrice).where("purchase_unit_prices.material_id = ?", strAry[1] )
      end
   }
   
   
   def self.ransackable_scopes(auth_object=nil)
       [:with_maker, :with_category, :with_supplier_material_code]
       #[:with_maker, :with_category]
   end
   
   
   
   private
   def maker_existing
     errors.add(MakerMaster, :missing) if MakerMaster.blank?
   end
   
   
   #リスト表示用(CD/名称)
	def p_material_code_name
      if self.material_code.nil?
        material_code = "-"
      else 
        material_code = self.material_code
      end
      #add190206
      #社内コードがあれば優先
      if !self.internal_code.blank?
        material_code = self.internal_code
      end
      #
      if self.material_name.nil?
        material_name = "-"
      else 
        material_name = self.material_name
      end    
      #if self.MakerMaster.nil?
      #  maker_name = "-"
      #else 
      #  maker_name = self.MakerMaster.maker_name
      #end    	
      
	  #material_code + ':' + material_name + ':' + maker_name  
	  #上記だと著しく遅くなる・・・
	  
	  material_code + ':' + material_name 
    end
    
    #add190206
    #リスト表示用(CDのみ)
	def p_material_code
      material_code = "-"
      if !self.material_code.nil?
        material_code = self.material_code
      end
      #社内コードがあれば優先
      if !self.internal_code.blank?
        material_code = self.internal_code
      end
      #
      material_code
    end

end
