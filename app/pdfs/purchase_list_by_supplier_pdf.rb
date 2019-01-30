class PurchaseListBySupplierPDF
    
  
  def self.create purchase_list_by_supplier
	#仕入表(仕入先別)PDF発行
 
       # tlfファイルを読み込む
       report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/purchase_list_by_supplier_pdf.tlf")
       
        # 1ページ目を開始
        report.start_new_page
        
        #初期化
        @flag = nil
        @purchase_order_code  = ""
        @purchase_amount_subtotal = 0
        @purchase_amount_total = 0

        #$purchase_data.joins(:purchase_order_datum).order("purchase_order_code, purchase_date, id").each do |purchase_datum| 
        
        $purchase_data.joins(:purchase_order_datum).order("purchase_date, purchase_order_code, id").each do |purchase_datum| 
        #ソート順は仕入日、注文ナンバーの順とする。
		
        #---見出し---
         page_count = report.page_count.to_s + "頁"
		 report.page.item(:pageno).value(page_count)

		 if @flag.nil? 
		 
		   @flag = "1"
		   
		   if $construction_flag == true
		     report.page.item(:construction_code).value(purchase_datum.construction_datum.construction_code)
		     report.page.item(:construction_name).value(purchase_datum.construction_datum.construction_name)
		   end
		   if $customer_flag == true
		     report.page.item(:customer_name).value(purchase_datum.construction_datum.CustomerMaster.customer_name)
		   end
		   
		   if $supplier_flag == true
		     report.page.item(:supplier_name).value(purchase_datum.SupplierMaster.supplier_name)
		   end
		   
           #小計(見積金額) 
		   #本来ならフッターに設定するべきだが、いまいちわからないため・・
		   #report.page.item(:quote_price).value(@quotation_headers.quote_price)
		   
		 end
		
         #小計
		 #if @purchase_order_code  != ""
		 # if @purchase_order_code  != purchase_datum.purchase_order_datum.purchase_order_code
		 #   @num = @purchase_amount_subtotal
		#	formatNum()
		#	@purchase_amount_subtotal = @num
		#	report.list(:default).add_row purchase_order_code: @purchase_order_code, purchase_unit_price: "小計", 
        #                                  purchase_amount: @purchase_amount_subtotal
		#	@purchase_amount_subtotal = 0
		#  end
		#end
		
	    @purchase_order_code  = purchase_datum.purchase_order_datum.purchase_order_code
		#金額小計・合計をセット
		if purchase_datum.purchase_amount.present?
		  @purchase_amount_subtotal = @purchase_amount_subtotal + purchase_datum.purchase_amount
		  @purchase_amount_total = @purchase_amount_total + purchase_datum.purchase_amount
		end
        
        #add190124
        construction_code = ""
        construction_name = ""
        customer_name = ""
        if purchase_datum.construction_datum.present?
          construction_code = purchase_datum.construction_datum.construction_code
          construction_name = purchase_datum.construction_datum.construction_name
          customer_name = purchase_datum.construction_datum.CustomerMaster.customer_name
        end
        #
        
        #
		 #for i in 0..29   #29行分(for test)
		    report.list(:default).add_row do |row|
			           #品名のセット
					   #フリー入力とマスターからの取得を切り分ける
					   if purchase_datum.material_id == 1
					     material_name = purchase_datum.material_name
					   else
					     material_name = purchase_datum.MaterialMaster.material_name
					   end
					   #品番
					   if purchase_datum.material_code == "＜手入力用＞"
					     material_code = "-"
					   else 
					     material_code = purchase_datum.MaterialMaster.material_code
					   end
					   #
					   
					   ###数値の様式設定
					   #仕入単価
                       @num = purchase_datum.purchase_unit_price
					   formatNum()
					   unit_price = @num
					   #金額
					   @num = purchase_datum.purchase_amount
					   formatNum()
					   purchase_amount = @num
					   #定価
					   @num = purchase_datum.list_price
					   formatNum()
					   list_price = @num
					   ###
					   
					   #add170307
                       #数量は小数点の場合あり、その場合で表示を切り分ける。
                       quantity = ""
                       first, second = purchase_datum.quantity.to_s.split('.')
                       if second.to_i > 0
                         quantity = sprintf("%.2f", purchase_datum.quantity)
                       else
                         quantity = sprintf("%.0f", purchase_datum.quantity)
                       end
                       #
					   
					   #upd171227 入庫の場合は入庫と表示
					   if purchase_datum.inventory_division_id.present? && InventoryHistory.inventory_division[purchase_datum.inventory_division_id.to_i][1] == 0
					     division_name = InventoryHistory.inventory_division[purchase_datum.inventory_division_id.to_i][0]
					   else
					     division_name = purchase_datum.PurchaseDivision.purchase_division_name
					   end
					   #
					   
                       
			           row.values purchase_date: purchase_datum.purchase_date,
                                  construction_code: construction_code,
								  construction_name: construction_name,
								  customer_name: customer_name,
					              purchase_order_code: purchase_datum.purchase_order_datum.purchase_order_code,
					              material_code: material_code,
                                  material_name: material_name,
								  maker_name: purchase_datum.maker_name,
                                  quantity: quantity,
                                  unit_name: purchase_datum.unit_master.unit_name,
								  purchase_unit_price: unit_price,
								  purchase_amount: purchase_amount,
                                  list_price: list_price,
                                  supplier_name: purchase_datum.SupplierMaster.supplier_name,
								  purchase_division_name: division_name
	                    
            end 


	end	
#end   
        #add170302 最終ページの出力はここで定義する
        page_count = report.page_count.to_s + "頁"
        report.page.item(:pageno).value(page_count)

		#小計(ラスト分)
		#@num = @purchase_amount_subtotal
		#formatNum()
		#@purchase_amount_subtotal = @num
		#report.list(:default).add_row purchase_order_code: @purchase_order_code, purchase_unit_price: "小計", 
        #                                  purchase_amount: @purchase_amount_subtotal
		
		#合計
		@num = @purchase_amount_total
		formatNum()
		@purchase_amount_total = @num
		report.list(:default).add_row  purchase_unit_price: "合計", 
                                          purchase_amount: @purchase_amount_total
		
        # ThinReports::Reportを返す
        return report
		
  end  
   
end
   
  
   
    def formatNum()
	    
        if @num.present?
          #整数で四捨五入する
		  @num  = @num.round
		  
		  #桁区切りにする
		  @num  = @num.to_s(:delimited, delimiter: ',')
		else
		  @num  = "0"
        end
		# 円マークをつける
        if @num  == "0"
		  @num  = ""
		else
		  @num  = "￥" + @num 
		end
	end  
