class CustomerMaster < ActiveRecord::Base
    paginates_per 50  # 1ページあたり項目表示

    has_many :construction_datum  # <== 関係を追記
    
    validates :closing_date, presence: true, numericality: :integer
    validates :due_date, presence: true, numericality: :integer
end
