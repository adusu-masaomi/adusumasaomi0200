class WorkingMiddleItem < ActiveRecord::Base
   paginates_per 200  # 1ページあたり項目表示

   belongs_to :WorkingUnit, :foreign_key => "working_unit_id"
   belongs_to :MaterialMaster, :foreign_key => "material_id"
   
   has_many :working_small_items
   accepts_nested_attributes_for :working_small_items, allow_destroy: true
   
   #add171113
   belongs_to :working_category, :foreign_key => "working_middle_item_category_id"
      
   #明細（小）フォームajax用
   attr_accessor :material_code_hide
   attr_accessor :material_name_hide
   attr_accessor :quantity_hide
   attr_accessor :unit_price_hide
   attr_accessor :labor_productivity_unit_hide
   
   #明細合計用
   attr_accessor :material_cost_total
   attr_accessor :labor_productivity_unit_sum
   #attr_accessor :labor_unit_price_standard
   attr_accessor :labor_cost
   
   #
   attr_accessor :master_insert_flag
   #活動フラグ判定用
   attr_accessor :action_flag
   #add171208モーダル画面で利用（上記と用途が異なる）
   #attr_accessor :action_flag_modal
   
   #マスター呼出用  add171109
   attr_accessor :working_middle_item_for_call
   attr_accessor :working_middle_item_category_for_call
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
