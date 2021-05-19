class InvoiceHeader < ActiveRecord::Base
  paginates_per 200  # 1ページあたり項目表示
  belongs_to :ConstructionDatum, :foreign_key => "construction_datum_id"
   
  belongs_to :customer_master, :foreign_key => "customer_id"
  accepts_nested_attributes_for :customer_master, update_only: true
   
  attr_accessor :customer_id_hide
  attr_accessor :billing_amount_with_tax  #add210419
  
  #バリデーション
  #validates :invoice_code, presence: true, uniqueness: true
  #請求書コードはユニークのチェックのみ。nullチェックはコピーに失敗するため除外。
  validates :invoice_code, presence:true, uniqueness: true

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
    if address.match(/[0-9０-９]+$/)
      errors.add :address, ADDRESS_ERROR_MESSAGE_4
    end
  end
    
  #入金日のチェック
  #＊備考に"繰越"が入っていたら、入金日もセットで入れてもらうようにする
  validate  :check_payment_date
  def check_payment_date
    if remarks.include?("繰越")
      if payment_date.nil?
        errors.add :payment_date, "を入力して下さい。"
      end
    end
  end

  scope :with_id, -> (invoice_headers_id=1) { where("invoice_headers.id = ?", invoice_headers_id )}
   
  #元請業者または保険適用外を除く
  scope :with_constractor, -> (extract_flag=true) { 
    if extract_flag.present?
      joins(:customer_master).where("invoice_headers.labor_insurance_not_flag is NULL or invoice_headers.labor_insurance_not_flag <> 1 ").
                  where("customer_masters.contractor_flag = ?" , 1 )
    end
  }
   
  #入金有無のチェック
  scope :with_deposit, -> deposit_flag { 
    if deposit_flag.present?
      if deposit_flag == "unpaid"
        #where("deposit_amount is NULL or deposit_amount = ?", 0)
        where("payment_date is NULL")
      elsif deposit_flag == "paid"
        #where("deposit_amount > ?", 0)
        where("payment_date is not NULL")
      end
    end
  }
   
   def self.ransackable_scopes(auth_object=nil)
       [:with_id, :with_constractor, :with_deposit]
   end
 	
  #入金フラグ
  #ex.値に0~1だとransack側のバグで認識できないため、文字にする
  def self.deposit_check_list 
      [["未", "unpaid"], ["済", "paid"]] 
  end
  
  #支払方法---増えたらここで変更する。
  def self.payment_method 
    #[["現金", 0], ["北越", 1], ["さんしん", 2]]
    [["", 0], ["現金", 1], ["北越", 2], ["さんしん", 3]] 
  end
  
end
