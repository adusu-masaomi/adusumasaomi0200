class PurchaseOrderDatum < ActiveRecord::Base
    paginates_per 200  # 1ページあたり項目表示

    #has_many :construction_data , :foreign_key => "construction_datum_id"
    belongs_to :construction_datum 
    accepts_nested_attributes_for :construction_datum, update_only: true
    
    belongs_to :supplier_master
    accepts_nested_attributes_for :supplier_master, update_only: true

    belongs_to :purchase_datum
    
	#has_many :entries
    #has_many :orders, through: :entries
	#has_many :orders, dependent: :destroy, inverse_of: :purchase_order_datum
	has_many :purchase_order_history
	
	
    has_many :orders
    accepts_nested_attributes_for :orders, :allow_destroy => true
	
    #def self.header_numbers 
    #  [["B", 1], ["M", 2]] 
    #end
	
	 #最終番号取得
     attr_accessor :last_header_number
  
	
    #validation
    validates :purchase_order_code, presence: true, uniqueness: true
	#validates :purchase_order_code, uniqueness: {message: ",工事IDが同じ組み合わせのレコードが既に存在します。", scope: [:construction_datum_id]} 
 
    
    #scope
    scope :with_id,  -> { joins(:construction_datum) }
	
    def p_num_cd
      if self.purchase_order_code.present?
	    self.purchase_order_code + '<' + self.construction_datum.id.to_s + '>'
      end
    end
    
    def self.header_numbers 
      [*('A'..'Z')]
	  #[["A", "A"], ["B", "B"], ["C", "C"], ["D", "D"], ["E", "E"], ["F", "F"], ["G", "G"], 
    end
	
end
