class Stocktake < ActiveRecord::Base
  paginates_per 200  # 1ページあたり項目表示
  
  belongs_to :material_master
  belongs_to :inventory
  
  #ajax用
  attr_accessor :unit_price_hide
  attr_accessor :quantity_hide
  attr_accessor :amount_hide
  attr_accessor :difference
  attr_accessor :different_amount
  
  #attr_accessor :inventory_id_hide  #add171128
  
  #棚卸日＆アイテムの重複登録防止。
  validates :stocktake_date,  presence: true, uniqueness: { scope: [:material_master_id] }

end
