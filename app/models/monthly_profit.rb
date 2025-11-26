class MonthlyProfit < ActiveRecord::Base
  paginates_per 60  # 1ページあたり項目表示
  
  attr_accessor :calculate_date  #集計用集計日
end
