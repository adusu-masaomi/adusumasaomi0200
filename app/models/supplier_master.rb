class SupplierMaster < ActiveRecord::Base
  paginates_per 200  # 1ページあたり項目表示　

	belongs_to :PurchaseDatum  #--> necessary??
  has_many :purchase_unit_prices	
  has_many :purchase_data, :foreign_key => "supplier_id"
  #add220108
  has_many :purchase_order_data
  
  #add210629
  has_many :supplier_responsibles, dependent: :destroy
  accepts_nested_attributes_for :supplier_responsibles, allow_destroy: true
  
	#バリデーション
	# validates :customer_id, presence: true, if: "customer_id.nil?"
  def self.to_csv(options = {})
      CSV.generate do |csv|
        # column_namesはカラム名を配列で返す
        # 例: ["id", "name", "price", "released_on", ...]
	    #csv << column_names
        #csv << ["id", "customer_name", "post"]
        
        #ヘッダ
        csv_column_names = ["id", "仕入先名", "電話番号", "FAX", "担当者"]
        csv << csv_column_names
        
        all.each do |supplier_master|
          
        
          # attributes はカラム名と値のハッシュを返す
          # 例: {"id"=>1, "name"=>"レコーダー", "price"=>3000, ... }
          # valudes_at はハッシュから引数で指定したキーに対応する値を取り出し、配列にして返す
          # 下の行は最終的に column_namesで指定したvalue値の配列を返す
    	    #if customer_master.card_not_flag != 1     #年賀状対象外は外す。
		        csv << supplier_master.csv_column_values
          #end
       end
    end
  end
  def csv_column_values
    [id, supplier_name, tel_main, fax_main, email_main, responsible1 ]
  end
end
