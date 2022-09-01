class ConstructionDatum < ActiveRecord::Base
	#kaminari用設定
    paginates_per 200  # 1ページあたり項目表示
    #paginates_per 100   # 1ページあたり項目表示   #upd210707 読み込み遅いので100件にした

    belongs_to :CustomerMaster, :foreign_key => "customer_id"
    accepts_nested_attributes_for :CustomerMaster 
    belongs_to :PurchaseDivisionMaster
    belongs_to :site    #add190124
    has_many :purchase_order_datum
	has_many :construction_daily_reports
	#Del190930
    #has_many :construction_costs, :foreign_key => "construction_datum_id"
	has_many :construction_attachments, dependent: :destroy
    accepts_nested_attributes_for :construction_attachments, allow_destroy: true
    #
    #dd190131
    #has_one :quotation_header
   
	#発行日用
    attr_accessor :issue_date
	#作業日・作業者（指示書発行一時用）
	attr_accessor :working_date
	attr_accessor :staff_id
	
    #add200114
    attr_accessor :deposit_due_date_hide
    
	#バリデーション
	validates :customer_id, presence: true
    validates :construction_code, presence: true, uniqueness: true
	validates :alias_name, presence: true
    
	#住所に番地等を入れないようにするためのバリデーション(冗長だが他に方法が見当たらない)
    ADDRESS_ERROR_MESSAGE = "番地（番地）は入力できません。"
    ADDRESS_ERROR_MESSAGE_2 = "番地（丁目）は入力できません。"
	ADDRESS_ERROR_MESSAGE_3 = "番地（ハイフン）は入力できません。"
	ADDRESS_ERROR_MESSAGE_4 = "番地（数字）は入力できません。"
   
    validates :address, format: {without: /丁目/ , :message => ADDRESS_ERROR_MESSAGE_2 }
    validates :address, format: {without: /番地/ , :message => ADDRESS_ERROR_MESSAGE }
    #「流通センター」などの地名も有るため、許可する。
    #validates :address, format: {without: /ー/ , :message => ADDRESS_ERROR_MESSAGE_3 }
    #validates :address, format: {without: /−/ , :message => ADDRESS_ERROR_MESSAGE_3 }
    validates :address, format: {without: /-/ , :message => ADDRESS_ERROR_MESSAGE_3 }
   
    #住所に数値が混じっていた場合も禁止する
    validate  :address_regex
    def address_regex
      #if address.match(/[0-9０-９]+$/)
      if address.present? && address.match(/[0-9０-９]+$/)  #upd211005
        errors.add :address, ADDRESS_ERROR_MESSAGE_4
      end
    end
    
    #緯度経度の自動登録
    geocoded_by :address_with_house_number
    after_validation :geocode, if: lambda {|obj| obj.address_changed?}
	
    #scope :with_id,  -> { joins(:purchase_order_datum) }
    #upd220618
    scope :with_id, -> (construction_id=1) { 
	  if construction_id.present?
	    joins(:purchase_order_datum).where("purchase_order_data.construction_datum_id = ?", construction_id )
	  end
    }
    
    scope :with_customer, -> { joins(:CustomerMaster) }  
    
	def self.ransackable_scopes(auth_object=nil)
  		[:with_id, :with_customer]
	end
	
	#緯度経度保存用アドレス
	def address_with_house_number
	  if self.house_number.nil?
	    address_with_house_number = self.address
	  else
        address_with_house_number = self.address + self.house_number
      end
	end
	
	#リスト表示用(CD/名称)
	def p_cd_name
        if self.construction_code.nil?
           construction_code = "-"
        else 
           construction_code = self.construction_code
        end
        if self.construction_name.nil?
           construction_name = "-"
        else 
           construction_name = self.construction_name
        end        

        construction_code + ':' + construction_name 
    end
	
	#リスト表示用(CD/短縮名称)
	def p_cd_alias_name
        if self.construction_code.nil?
           construction_code = "-"
        else 
           construction_code = self.construction_code
        end
        if self.alias_name.nil?
           alias_name = "-"
        else 
           alias_name = self.alias_name
        end        

        construction_code + ':' + alias_name 
    end
	
    def self.order_check_list 
      [["未", 0], ["済", 1]] 
    end
    
    def self.bills_check_list 
      [["未", 0], ["済", 1]] 
    end
    
    def self.calculated_check_list 
      [["未", 0], ["済", 1]] 
    end
    
    #在庫品目によって、工事IDを自動取得する
    def self.get_construction_on_inventory_category(inventory_category_id)
      ret_id = 1
	  
	  case inventory_category_id
      when $INVENTORY_CATEGORY_AIR_CONDITIONING_ELEMENT
      #エアコン部材
        ret_id = $CUNSTRUCTION_ID_AIR_CONDITIONING_ELEMENT
      when $INVENTORY_CATEGORY_PIPE_AND_WIRING
      #配線器具
        ret_id = $CUNSTRUCTION_ID_PIPE_AND_WIRING
      when $INVENTORY_CATEGORY_ID_CABLE
      #ケーブル
        ret_id =  $CUNSTRUCTION_ID_CABLE
	  else
	    ret_id = 1
      end
	  
	  return ret_id
	end

end
