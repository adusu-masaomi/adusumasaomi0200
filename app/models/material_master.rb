class MaterialMaster < ActiveRecord::Base
	#has_many :PurchaseDatum
	belongs_to :PurchaseDatum
	belongs_to :MakerMaster, :foreign_key => "maker_id"
	has_many :UnitMaster
	
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
   
   scope :with_maker, -> (id=1){joins(:MakerMaster).where("maker_masters.id = material_masters.maker_id" )}
   
   def self.ransackable_scopes(auth_object=nil)
       [:with_maker]
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
      if self.material_name.nil?
        material_name = "-"
      else 
        material_name = self.material_name
      end    
      if self.MakerMaster.nil?
        maker_name = "-"
      else 
        maker_name = self.MakerMaster.maker_name
      end    	
      
	  #self.construction_code + ':' + self.construction_name
      material_code + ':' + material_name + ':' + maker_name  
    end

end
