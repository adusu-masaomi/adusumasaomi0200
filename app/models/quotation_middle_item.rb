class QuotationMiddleItem < ActiveRecord::Base
   paginates_per 50  # 1ページあたり項目表示

   belongs_to :QuotationUnit, :foreign_key => "quotation_unit_id"
   belongs_to :MaterialMaster, :foreign_key => "material_id"

   scope :with_material, -> {joins(:MaterialMaster)}
   
   
end
