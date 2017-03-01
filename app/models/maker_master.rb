class MakerMaster < ActiveRecord::Base
    paginates_per 100  # 1ページあたり項目表示(index.html)
	has_many :PurchaseDatum
	validates :maker_name, uniqueness: true
end
