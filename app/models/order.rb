class Order < ActiveRecord::Base
  
  paginates_per 10  # 1ページあたり項目表示
  
  #has_many :purchase_order_data
  #belongs_to :purchase_order_datum
  
  belongs_to :material_master,  :foreign_key => "material_id"
  belongs_to :unit_master
  belongs_to :purchase_order_history
  
  #this is not work well.
  #validates :quantity, numericality: {
  #          only_integer: true, greater_than: 0
  #        }
  
  #メーカーID用
  attr_accessor :maker_id_hide
  
  #単位
  #add170804
  attr_accessor :unit_id_hide
  
  # sequential(gem)用 '1707xx
  acts_as_sequenced scope: :purchase_order_history_id
  
   validate :check_link_count
   def check_link_count
      if self.quantity.nil?
   	    self.errors.add :base, "No more than 5 links allowed."
   		$quantity_nothing = true
   	  end
   end
   
   def self.mail_flag 
    [["送信済", 1]] 
   end
   
end
