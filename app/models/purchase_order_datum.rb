class PurchaseOrderDatum < ActiveRecord::Base
    paginates_per 200  # 1ページあたり項目表示

    belongs_to :construction_datum 
    accepts_nested_attributes_for :construction_datum, update_only: true
    
    belongs_to :supplier_master
    accepts_nested_attributes_for :supplier_master, update_only: true

    #add210703
    belongs_to :supplier_responsible
    accepts_nested_attributes_for :supplier_responsible, update_only: true

    belongs_to :purchase_datum
    
    #has_many :purchase_order_history
    
	  has_many :construction_costs, :foreign_key => "purchase_order_datum_id"
    has_many :orders
    accepts_nested_attributes_for :orders, :allow_destroy => true
    
    has_many :purchase_order_histories, through: :orders   #upd220108
    
    #def self.header_numbers 
    #  [["B", 1], ["M", 2]] 
    #end
	
    #最終番号取得
    attr_accessor :last_header_number
    attr_accessor :search_character
    
    #現場住所
    attr_accessor :post
    attr_accessor :address
    attr_accessor :house_number
    attr_accessor :address2
    #
    
    #add210703
    #attr_accessor :supplier_responsible_email
    
    #validation
    validates :purchase_order_code, presence: true, uniqueness: true
    validate :check_supplier   #add210727
    
    #validates :purchase_order_code, uniqueness: {message: ",工事IDが同じ組み合わせのレコードが既に存在します。", scope: [:construction_datum_id]} 
    
    #add210727
    def check_supplier
      if supplier_master_id == 1
        errors.add(:supplier_master_id, ": 選択してください。")
      end
    end
        
    #scope
    scope :with_id,  -> { joins(:construction_datum) }
	
    def p_num_cd
      if self.purchase_order_code.present?  && self.construction_datum.present?
        self.purchase_order_code + '<' + self.construction_datum.id.to_s + '>'
      end
    end
    
    def self.header_numbers 
      [*('A'..'Z')]
	  #[["A", "A"], ["B", "B"], ["C", "C"], ["D", "D"], ["E", "E"], ["F", "F"], ["G", "G"], 
    end
	
end
