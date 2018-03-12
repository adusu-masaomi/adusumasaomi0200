class WorkingSpecificMiddleItem < ActiveRecord::Base
    paginates_per 200  # 1ページあたり項目表示

   belongs_to :WorkingUnit, :foreign_key => "working_unit_id"
   belongs_to :MaterialMaster, :foreign_key => "material_id"
   
   has_many :working_specific_small_items
   accepts_nested_attributes_for :working_specific_small_items, allow_destroy: true
   
   #ok????
   #def working_specific_small_items_attributes=(attributes)
   # binding.pry
#	if attributes["0"]["id"].present?
 #     self.working_specific_small_items = WorkingSpecificSmallItem.find(attributes["0"]["id"])
 #   end
 #   super
 #  end
 
   #def avatar
   #def working_specific_small_items_attributes=(attributes)
   #  super || working_specific_small_items
   #end
  
   
   #明細（小）フォームajax用
   attr_accessor :material_id_hide     #add180310
   attr_accessor :material_code_hide
   attr_accessor :material_name_hide
   attr_accessor :quantity_hide
   attr_accessor :unit_price_hide
   attr_accessor :labor_productivity_unit_hide
   attr_accessor :material_price_hide  #add180310
   attr_accessor :maker_id_hide        #add180310
   attr_accessor :unit_master_id_hide  #add180310
   attr_accessor :working_subcategory_select_hide #add180310
   
   #明細合計用
   attr_accessor :material_cost_total
   attr_accessor :labor_productivity_unit_sum
   #attr_accessor :labor_unit_price_standard
   attr_accessor :labor_cost
   
   #add171114
   #活動フラグ判定用追加
   attr_accessor :action_flag
   
   attr_accessor :master_insert_flag
   
   #マスター呼出用  add171109
   attr_accessor :working_specific_middle_item_for_call
   
   attr_accessor :working_middle_item_id_select_hide
   attr_accessor :working_middle_item_short_name_select_hide
   
   #validation 
   #add171117
   validates :working_middle_item_name, presence: true
   
   scope :with_material, -> {joins(:MaterialMaster)}
   scope :with_unit, -> {joins(:WorkingUnit)}
   
   #add171104
   #カテゴリー項目
   def self.categories 
     #[["-", 0], ["幹線", 1], ["接地", 2], ["配管配線", 3], ["配線器具(ワイド２１)", 4], ["配線器具(フルカラー)", 5], ["器具取付", 6], ["ボックス", 7],["換気ダクト", 8],["テレビ", 9]] 
	 [["-", 0], ["配線器具(ワイド２１)", 1], ["配線器具(フルカラー)", 2], ["配管配線", 3], ["換気ダクト", 4], ["器具取付", 5], ["幹線", 6], ["接地", 7],["ボックス", 8],["テレビ", 9]]
   end
   
   def self.ransackable_scopes(auth_object=nil)
      [:with_unit]
   end
   
end
