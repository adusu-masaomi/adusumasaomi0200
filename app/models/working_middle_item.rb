class WorkingMiddleItem < ActiveRecord::Base

   #require "browser"
   #browser = Browser.new("Some User Agent", accept_language: "en-us")
   #paginates_per 200  # 1ページあたり項目表示

   belongs_to :WorkingUnit, :foreign_key => "working_unit_id"
   belongs_to :MaterialMaster, :foreign_key => "material_id"
   
   has_many :working_small_items
   accepts_nested_attributes_for :working_small_items, allow_destroy: true
   
   belongs_to :working_category, :foreign_key => "working_middle_item_category_id"
   #add180202
   belongs_to :working_subcategory
  
   #明細（小）フォームajax用
   attr_accessor :material_id_hide     
   attr_accessor :material_code_hide
   attr_accessor :material_name_hide
   attr_accessor :quantity_hide
   attr_accessor :unit_price_hide
   attr_accessor :labor_productivity_unit_hide
   attr_accessor :material_price_hide  
   attr_accessor :maker_id_hide        
   attr_accessor :unit_master_id_hide  
   attr_accessor :working_subcategory_select_hide 
   attr_accessor :list_price_color_hide 
   attr_accessor :rate_hide   #add180726
   
   #明細合計用
   attr_accessor :material_cost_total
   attr_accessor :labor_productivity_unit_sum
   attr_accessor :labor_cost
   
   #
   attr_accessor :master_insert_flag
   #活動フラグ判定用
   attr_accessor :action_flag
   
   #マスター呼出用  
   attr_accessor :working_middle_item_for_call
   attr_accessor :working_middle_item_category_for_call
   attr_accessor :working_middle_item_subcategory_for_call
   #attr_accessor :working_subcategory_for_call  #add180202
   attr_accessor :working_middle_item_short_name_for_call
   attr_accessor :working_middle_item_id_select_hide
   attr_accessor :working_middle_item_short_name_select_hide
   ##
   
   #validation 
   validates :working_middle_item_name, presence: true
   
   scope :with_material, -> {joins(:MaterialMaster)}
   scope :with_unit, -> {joins(:WorkingUnit)}
   scope :with_category, -> {joins(:working_category)}
   scope :with_id, -> (working_middle_item_id=1) { where("working_middle_items.id = ?", working_middle_item_id )}
   
   #カテゴリー項目
   def self.categories 
     #[["-", 0], ["幹線", 1], ["接地", 2], ["配管配線", 3], ["配線器具(ワイド２１)", 4], ["配線器具(フルカラー)", 5], ["器具取付", 6], ["ボックス", 7],["換気ダクト", 8],["テレビ", 9]] 
	 [["-", 0], ["配線器具(ワイド２１)", 1], ["配線器具(フルカラー)", 2], ["配管配線", 3], ["換気ダクト", 4], ["器具取付", 5], ["幹線", 6], ["接地", 7],["ボックス", 8],["テレビ", 9]] 
   end
   
   def self.ransackable_scopes(auth_object=nil)
      [:with_unit, :with_id]
   end
   
   
   #acts_as_list
 
end
