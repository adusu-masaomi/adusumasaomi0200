class PurchaseListPDF
    
  
  def self.create purchase_list	
	#仕入表PDF発行
 
       #@@page_number = 0
 
       # tlfファイルを読み込む
       report = ThinReports::Report.new(layout: "#{Rails.root}/app/pdfs/purchase_list_pdf.tlf")
       
	
	
      # Thin ReportsでPDFを作成
 #report = ThinReports::Report.create do |r|

       # ThinReports Editorで作成したファイルを読み込む
      #r.use_layout "#{Rails.root}/app/pdfs/quotation_pdf.tlf" do |config|
      #  config.list(:default) do
      #    events.on :footer_insert do |e|
      #      e.section.item(:footer_message).value("test")
      #    end
      #  end
      #end
	  
	  #report.use_layout "#{Rails.root}/app/pdfs/purchase_list_pdf.tlf" do |config|
      #	 events.on :page_create do |e|
	        
      #  end	
	  #end
	  
	  	# 1ページ目を開始
        report.start_new_page
        #r.start_new_page
		
	 
   
		# テーブルの値を設定
        # list に表のIDを設定する(デフォルトのID値: default)
        # add_row で列を追加できる
        # ブロック内のrow.valuesで値を設定する
	  
	  @flag = nil
	   
      	# maxLine = 30
        # lineCount = 0
		 
	 #初期化
	 @purchase_order_code  = ""
	 @purchase_amount_subtotal = 0
	 @purchase_amount_total = 0
	
      $purchase_data.joins(:purchase_order_datum).order("purchase_order_code, purchase_date, id").each do |purchase_datum| 
	  	 
		 #---見出し---
                 page_count = report.page_count.to_s + "頁"
		 report.page.item(:pageno).value(page_count)

		 if @flag.nil? 
		 
		    @flag = "1"
		   
		   #@construction_data = ConstructionDatum.find(purchase_datum.construction_datum_id)
		  
		   #binding.pry
		   report.page.item(:construction_code).value(purchase_datum.construction_datum.construction_code)
		   report.page.item(:construction_name).value(purchase_datum.construction_datum.construction_name)
		   report.page.item(:customer_name).value(purchase_datum.construction_datum.CustomerMaster.customer_name)
		 
           #小計(見積金額) 
		   #本来ならフッターに設定するべきだが、いまいちわからないため・・
		   #report.page.item(:quote_price).value(@quotation_headers.quote_price)
		   
		 end
		
         #小計
		 if @purchase_order_code  != ""
		  if @purchase_order_code  != purchase_datum.purchase_order_datum.purchase_order_code
		    
			@num = @purchase_amount_subtotal
			formatNum()
			@purchase_amount_subtotal = @num
			report.list(:default).add_row purchase_order_code: @purchase_order_code, purchase_unit_price: "小計", 
                                          purchase_amount: @purchase_amount_subtotal
			@purchase_amount_subtotal = 0
		  end
		end
		
	    @purchase_order_code  = purchase_datum.purchase_order_datum.purchase_order_code
		#金額小計・合計をセット
		if purchase_datum.purchase_amount.present?
		  @purchase_amount_subtotal = @purchase_amount_subtotal + purchase_datum.purchase_amount
		  @purchase_amount_total = @purchase_amount_total + purchase_datum.purchase_amount
		end
		 #for i in 0..29   #29行分(for test)
		    report.list(:default).add_row do |row|
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
					   
			           row.values purchase_order_code: purchase_datum.purchase_order_datum.purchase_order_code,
					              material_code: purchase_datum.material_code,
                                  material_name: purchase_datum.material_name,
								  maker_name: purchase_datum.maker_name,
                                  quantity: purchase_datum.quantity,
                                  unit_name: purchase_datum.unit_master.unit_name,
								  purchase_unit_price: unit_price,
								  purchase_amount: purchase_amount,
                                  list_price: list_price,
                                  supplier_name: purchase_datum.SupplierMaster.supplier_name,
								  purchase_division_name: purchase_datum.PurchaseDivision.purchase_division_name
	                    
						#lineCount = lineCount +  1
						
						#binding.pry
						
                        #if lineCount > maxLine then
			            #  @@page_number = @@page_number + 1
				        #  lineCount = 0
			            #end
			end 
			
		   #if @@page_number == 0
		    #  @@page_number = 1
		    #end
		   
		    #頁番号
            #@page_number = @@page_number.to_s + "頁"
		    #report.page.item(:page_number).value(@page_number)
		
    end	
#end 
		#小計(ラスト分)
		@num = @purchase_amount_subtotal
		formatNum()
		@purchase_amount_subtotal = @num
		report.list(:default).add_row purchase_order_code: @purchase_order_code, purchase_unit_price: "小計", 
                                          purchase_amount: @purchase_amount_subtotal
		#@purchase_amount_subtotal = 0
		
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
