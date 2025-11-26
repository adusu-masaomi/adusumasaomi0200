class MonthlyBalance < ActiveRecord::Base
  paginates_per 100 # 1ページあたり項目表示
end
