class Contact < ActiveRecord::Base
  
  paginates_per 200  # 1ページあたり項目表示
  
  def self.partner_division 
    [["未選択", 0], ["得意先", 1], ["仕入先", 2]] 
  end
end
