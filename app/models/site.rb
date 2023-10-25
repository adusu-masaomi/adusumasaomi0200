class Site < ActiveRecord::Base
  paginates_per 200  # 1ページあたり項目表示
end
