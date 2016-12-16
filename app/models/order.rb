class Order < ActiveRecord::Base
  #has_many :entries
  #has_many :purchase_order_data
  ##belongs_to :purchase_order_datum
  belongs_to :material_master,  :foreign_key => "material_id"
  belongs_to :unit_master
  belongs_to :purchase_order_history
  
  #this is not work well.
  #validates :quantity, numericality: {
  #          only_integer: true, greater_than: 0
  #        }
		  
		  
   validate :check_link_count
   def check_link_count
      if self.quantity.nil?
   	    self.errors.add :base, "No more than 5 links allowed."
   		$quantity_nothing = true
   	  end
   end
   
end
