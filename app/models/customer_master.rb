class CustomerMaster < ActiveRecord::Base
    paginates_per 200  # 1ページあたり項目表示

    has_many :construction_datum  # <== 関係を追記
    
    validates :closing_date, presence: true, numericality: :integer
    validates :due_date, presence: true, numericality: :integer
	
	#見積書・請求書等での敬称として使用
	def self.honorific 
      [["様", 0], ["御中", 1]] 
    end
end
