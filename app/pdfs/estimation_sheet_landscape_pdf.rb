class EstimationSheetLandscapePDF
    
  
  def self.create estimation_sheet	
	#見積書PDF発行
 
       # tlfファイルを読み込む
	   #変数reportはインスタンス変数に変更
       @report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/quotation_landscape_pdf.tlf")

      # Thin @reportsでPDFを作成
      #@report = Thin@reports::@report.create do |r|

       # Thin@reports Editorで作成したファイルを読み込む
      #r.use_layout "#{Rails.root}/app/pdfs/quotation_pdf.tlf" do |config|
      #  config.list(:default) do
      #    events.on :footer_insert do |e|
      #      e.section.item(:footer_message).value("test")
      #    end
      #  end
      #end

     @@labor_amount = 0
         

		# 1ページ目を開始
        @report.start_new_page
        #r.start_new_page
		
	    
		# テーブルの値を設定
        # list に表のIDを設定する(デフォルトのID値: default)
        # add_row で列を追加できる
        # ブロック内のrow.valuesで値を設定する
	  
	  @flag = nil
		 
		
      $quotation_detail_large_classifications.order(:line_number).each do |quotation_detail_large_classification| 
	  	 
		   
		 #歩掛り合計
		 if quotation_detail_large_classification.labor_productivity_unit.present?
           #合計へカウント
           @@labor_amount += quotation_detail_large_classification.labor_productivity_unit
         end
		   
		 #---見出し---
		 
         consumption_tax = 0.08   #消費税率 →→→→→ 増税時は注意する！！
		 consumption_tax_in = 1.08   #消費税率 →→→→→ 増税時は注意する！！
		 
		 if @flag.nil? 
		 
		    @flag = "1"
		   
		   @quotation_headers = QuotationHeader.find(quotation_detail_large_classification.quotation_header_id)
		   @construction_data = ConstructionDatum.find(@quotation_headers.construction_datum_id)
		   @customer_masters = CustomerMaster.find(@quotation_headers.customer_id)
		   
		   #郵便番号
           #@report.page.item(:post).value(@quotation_headers.post) 
		 
		   #住所
           #@report.page.item(:address).value(@quotation_headers.address) 
		 
		   #得意先名
		   #@report.page.item(:customer_name).value(@quotation_headers.customer_name) 
		   
		   #敬称
		   #honorific_name = CustomerMaster.honorific[0].find{0}  #"様"
		   
		   #if @quotation_headers.honorific_id == 1   #"御中?
		   #  id = @quotation_headers.honorific_id
           #  honorific_name = CustomerMaster.honorific[id].find{id} #"御中"
		   #end
		   #@report.page.item(:honorific).value(honorific_name) 
		   
		   #担当1
           #if @quotation_headers.responsible1.present?
		   #  responsible = @quotation_headers.responsible1 + "  様"
		   #  @report.page.item(:responsible1).value(responsible)
		   #end
		   #担当2
		   #if @quotation_headers.responsible2.present?
		   #  responsible = @quotation_headers.responsible2 + "  様"
		   #  @report.page.item(:responsible2).value(responsible)
		   #end
		   
		   #件名
		   #@report.page.item(:construction_name).value(@quotation_headers.construction_name) 
		 
		   #見積No
		   #@report.page.item(:quotation_code).value(@quotation_headers.quotation_code) 
		 
           #税込見積合計金額	 
		   #if @quotation_headers.quote_price.present?
           #  @quote_price_tax_in = @quotation_headers.quote_price * consumption_tax_in  #増税時は変更すること。
		   #  @report.page.item(:quote_price_tax_in).value(@quote_price_tax_in) 
		   #end
		   
		   #消費税
		   if @quotation_headers.quote_price.present?
		     @quote_price_tax_only = @quotation_headers.quote_price * consumption_tax  
		   #  @report.page.item(:quote_price_tax_only).value(@quote_price_tax_only) 
		   end
		 
		   #工事期間
		   #@report.page.item(:construction_period).value(@quotation_headers.construction_period) 
		 
		   #工事場所
		   #@report.page.item(:construction_place).value(@quotation_headers.construction_place) 
		   #取引方法
		   #@report.page.item(:trading_method).value(@quotation_headers.trading_method) 
		   #有効期間
		   #@report.page.item(:effective_period).value(@quotation_headers.effective_period) 
		   
		   #元号変わったらここも要変更
		   @gengou = @quotation_headers.quotation_date
		   @gengou = "平成#{@gengou.year - 1988}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		  
           #@report.page.item(:quotation_date).value(@gengou) 
		   
		   #NET金額
		   #本来ならフッターに設定するべきだが、いまいちわからないため・・
		   if @quotation_headers.net_amount.present?
		     @net_amount = "(" + @quotation_headers.net_amount.to_s(:delimited, delimiter: ',') + ")" 
			 
		     @report.page.item(:message_net).value("NET")
			 @report.page.item(:net_amount).value(@net_amount)
		   
		   end
		   
		   #小計(見積金額) 
		   #本来ならフッターに設定するべきだが、いまいちわからないため・・
		   @report.page.item(:quote_price).value(@quotation_headers.quote_price)
		   
	    ## 右側のヘッダ
		  
		   #見積No
		   @report.page.item(:quotation_code2).value(@quotation_headers.quotation_code) 
		   #工事CD
		   @report.page.item(:construction_code).value(@construction_data.construction_code) 
		   
		   #顧客CD
		   @report.page.item(:customer_code).value(@customer_masters.id)
		   
		   #見積日付
		   @report.page.item(:quotation_date2).value(@gengou) 
		   
		   #郵便番号
		   @report.page.item(:post2).value(@quotation_headers.post) 
		 
		   #住所
		   @report.page.item(:address2).value(@quotation_headers.address) 
		   #TEL
		   @report.page.item(:tel).value(@quotation_headers.tel) 
		   #FAX
		   @report.page.item(:fax).value(@quotation_headers.fax) 
		   
		   #得意先名
		   @report.page.item(:customer_name2).value(@quotation_headers.customer_name) 
		 
		   #件名
		   @report.page.item(:construction_name2).value(@quotation_headers.construction_name) 
		   #工事期間
		   @report.page.item(:construction_period2).value(@quotation_headers.construction_period) 
		 
		   #工事場所
		   @report.page.item(:construction_place2).value(@quotation_headers.construction_place) 
		 
		   #取引方法
		   @report.page.item(:trading_method2).value(@quotation_headers.trading_method) 
		 
		   #有効期間
		   @report.page.item(:effective_period2).value(@quotation_headers.effective_period) 
		   
		   #見積金額合計
		   @report.page.item(:quote_price2).value(@quotation_headers.quote_price)
		   #消費税
		   if @quote_price_tax_only != ""
		     @report.page.item(:quote_price_tax_only2).value(@quote_price_tax_only) 
		   end
		   #実行金額
		   @report.page.item(:execution_amount2).value(@quotation_headers.execution_amount)
		   
		   @execution_amount_tax_only = 0
		   if @quotation_headers.execution_amount != 0
              @execution_amount_tax_only = @quotation_headers.execution_amount * consumption_tax   #増税時注意！！
			  @report.page.item(:execution_amount_tax_only).value(@execution_amount_tax_only)
		   end
		   
		   #利益
		   profit = @quotation_headers.quote_price + @quote_price_tax_only - @quotation_headers.execution_amount - @execution_amount_tax_only
		   if profit > 0
		     @report.page.item(:profit).value(profit)
		   end
		 end
		 
		
		 
		 #for i in 0..29   #29行分(for test)
		   @report.list(:default).add_row do |row|
		  
                      #仕様の場合に数値・単位をnullにする
                      @quantity = quotation_detail_large_classification.quantity
                      if @quantity == 0 
                        @quantity = ""
                      end  
                      @execution_quantity = quotation_detail_large_classification.execution_quantity
                      if @execution_quantity == 0 
                        @execution_quantity = ""
                      end  
                      
                      @unit_name = quotation_detail_large_classification.QuotationUnit.quotation_unit_name
                      if @unit_name == "<手入力>"
                        @unit_name = ""
                      end 
                      #  
                      
                      row.values quotation_large_item_name: quotation_detail_large_classification.quotation_large_item_name,
                       quotation_large_specification: quotation_detail_large_classification.quotation_large_specification,
                       quantity: @quantity,
		               quotation_unit_name: @unit_name,
                       quote_price: quotation_detail_large_classification.quote_price,
                       execution_quantity: @execution_quantity,
                       quotation_unit_name2: @unit_name,
                       execution_price: quotation_detail_large_classification.execution_price,
                       labor_productivity_unit: quotation_detail_large_classification.labor_productivity_unit
           end 
		 #end
    end	
	   
	   #実行金額(計)
	   @report.page.item(:execution_amount).value(@quotation_headers.execution_amount)
	   #歩掛(計)
	   @report.page.item(:labor_amount).value(@@labor_amount )
#end 
		 
	   #内訳のデータも取得・出力
	   set_detail_data
	   
	  
        # Thin@reports::@reportを返す
        return @report
		
		
    
  end
  
  def self.set_detail_data
     
	 #見積書(表紙)のページ番号をマイナスさせるためのカウンター。
	 @estimation_sheet_pages = @report.page_count 
	 
	 #内訳データでループ
	 $quotation_detail_large_classifications.order(:line_number).each do |quotation_detail_large_classification|
	   quotation_header_id = quotation_detail_large_classification.quotation_header_id
	   quotation_detail_large_classification_id =  quotation_detail_large_classification.id
	    
       $quotation_detail_middle_classifications = QuotationDetailMiddleClassification.where(:quotation_header_id => quotation_header_id).
                                                 where(:quotation_detail_large_classification_id => quotation_detail_large_classification_id).where("id is NOT NULL")
        
	   #内訳書PDF発行(A4横ver)
	   if $quotation_detail_middle_classifications.present?
	     self.detailed_statement_landscape
	   end
	 end
	 
     
  end
  
  
  def self.detailed_statement_landscape
	#内訳書PDF発行(A4横ver)
      
      @@quote_price = 0
      @@execution_price = 0
      @@labor_productivity_unit = 0
      
	   
	  
	  #(＊単独モジュールと違う箇所)
	  #変数reportはインスタンス変数に変更
      # tlfファイルを読み込む
      #@report = Thin@reports::@report.new(layout: "#{Rails.root}/app/pdfs/detailed_statement_landscape_pdf.tlf")

      #(＊単独モジュールと違う箇所)
	  # 1ページ目を開始
      #@report.start_new_page
	  @report.start_new_page layout: "#{Rails.root}/app/pdfs/detailed_statement_landscape_pdf.tlf"
	   

	   
	  @flag = nil
		
      $quotation_detail_middle_classifications.order(:line_number).each do |quotation_detail_middle_classification| 
      
      	 #---見出し---
		 
		  #@@page_number = @@page_number + 1
		 
		 if @flag.nil? 
		   
		   @flag = "1"
		   
		   @quotation_headers = QuotationHeader.find(quotation_detail_middle_classification.quotation_header_id)
	       #得意先名
		   #@report.page.item(:customer_name).value(@quotation_headers.customer_name) 
		  
		   #件名
		   @report.page.item(:construction_name).value(@quotation_headers.construction_name) 
		 
		   #見積No
		   @report.page.item(:quotation_code).value(@quotation_headers.quotation_code) 
		 
           @gengou = @quotation_headers.quotation_date
		   #元号変わったらここも要変更
		   @gengou = "平成#{@gengou.year - 1988}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		   @report.page.item(:quotation_date).value(@gengou) 
		 
           #品目名
           @report.page.item(:quotation_large_item_name).value(quotation_detail_middle_classification.QuotationDetailLargeClassification.quotation_large_item_name)
		   
		 end
		 
		 
		 @report.list(:default).add_row do |row|
		          #仕様の場合に数値・単位をnullにする
                  @quantity = quotation_detail_middle_classification.quantity
                  if @quantity == 0 
                    @quantity = ""
                  end  
                  @execution_quantity = quotation_detail_middle_classification.execution_quantity
                  if @execution_quantity == 0 
                    @execution_quantity = ""
                  end  
                  @unit_name = quotation_detail_middle_classification.QuotationUnit.quotation_unit_name
                  #if @unit_name == "-"
                  if @unit_name == "<手入力>"
                    @unit_name = ""
                  end 
                  
                  if quotation_detail_middle_classification.quote_price.present?
                    @@quote_price += quotation_detail_middle_classification.quote_price
                  end
                  #実行金額合計
                  if quotation_detail_middle_classification.execution_price.present?
                    @@execution_price += quotation_detail_middle_classification.execution_price
                  end
                  
				  @labor_amount = 0
                  if quotation_detail_middle_classification.quantity.present?
				    if quotation_detail_middle_classification.quantity >= 0
                       if quotation_detail_middle_classification.labor_productivity_unit.present?
					      @labor_amount = quotation_detail_middle_classification.quantity * quotation_detail_middle_classification.labor_productivity_unit
                          #合計へカウント
						  @@labor_productivity_unit += @labor_amount
					   end
                    end
				  end
				  
				  # binding.pry
                  if @labor_amount == 0
                     @labor_amount = ""
                  end
				  
                  row.values quotation_middle_item_name: quotation_detail_middle_classification.quotation_middle_item_name,
                   quotation_middle_specification: quotation_detail_middle_classification.quotation_middle_specification, 
                   quantity: @quantity,
                   quotation_unit_name: @unit_name,
                   quotation_unit_price: quotation_detail_middle_classification.quotation_unit_price,
                   quote_price: quotation_detail_middle_classification.quote_price,
                   quantity2: @execution_quantity,
                   quotation_unit_name2: @unit_name,
                   execution_unit_price: quotation_detail_middle_classification.execution_unit_price,
                   execution_price: quotation_detail_middle_classification.execution_price,
                   labor_productivity_unit: quotation_detail_middle_classification.labor_productivity_unit,
                   labor_amount: @labor_amount
		  end
		#end 
		  
		 
		  
		  #頁番号
          #(＊単独モジュールと違う箇所)
		  page_number = @report.page_count - @estimation_sheet_pages
         
		  #if $default_page_number > 0 
		     #デフォルトの頁番号をセット 
		    #page_number = @report.page_count + ($default_page_number - 1 )
          #  page_number = @report.page_count + ($default_page_number - 1 )
		  #else
		  #  page_number = @report.page_count
		  #end  
		
		  
		  #page_count = "(" +  @report.page_count.to_s + ")"
		  page_count = "(" +  page_number.to_s + ")"
		  @report.page.item(:page_number).value(page_count)
		  
		  #数字→漢字へ変換(せっかく作ったが没・・)
          #@kanji = num_to_k(@@page_number)
          ##@page_number = "(" + @kanji.to_s + "頁)"
           
		   #本来ならフッターに設定するべきだが、いまいちわからないため・・
		   @report.page.item(:message_sum).value("次頁へ")
		   
		   @report.page.item(:subtotal).value(@@quote_price )
		   @report.page.item(:subtotal_execution).value(@@execution_price )
		   #歩掛り合計
		   @report.page.item(:subtotal_labor).value(@@labor_productivity_unit )
		   
		   #end
    end	
     
	   @report.page.item(:message_sum).value("計")
		
		#(＊単独モジュールと違う箇所)
        # Thin@reports::@reportを返す
        #return @report

  end

end


