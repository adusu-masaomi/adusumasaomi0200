class WorkingLargeItem < ActiveRecord::Base
    paginates_per 200  # 1ページあたり項目表示
	
	belongs_to :WorkingUnit, :foreign_key => "working_unit_id"
	scope :with_unit, -> {joins(:WorkingUnit)}
	
    def self.ransackable_scopes(auth_object=nil)
      [:with_unit]
    end
	
end
