class EstimationSheetLandscapePDF
    
  
  def self.create estimation_sheet	
	#見積書PDF発行
 
       # tlfファイルを読み込む
       report = ThinReports::Report.new(layout: "#{Rails.root}/app/pdfs/quotation_landscape_pdf.tlf")

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

     @@labor_amount = 0
         

		# 1ページ目を開始
        report.start_new_page
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
		   
		   #binding.pry
		   
		   #QuotationHeader.find(quotation_detail_large_classification.quotation_header_id).joins(:ConstructionDatum)
		   #binding.pry
		 
		   #郵便番号
		   report.page.item(:post).value(@quotation_headers.post) 
		 
		   #住所
		   report.page.item(:address).value(@quotation_headers.address) 
		 
		   #得意先名
		   report.page.item(:customer_name).value(@quotation_headers.customer_name) 
		 
		   #件名
		   report.page.item(:construction_name).value(@quotation_headers.construction_name) 
		 
		   #見積No
		   report.page.item(:quotation_code).value(@quotation_headers.quotation_code) 
		 
           #税込見積合計金額	 
		   if @quotation_headers.quote_price.present?
             @quote_price_tax_in = @quotation_headers.quote_price * consumption_tax_in  #増税時は変更すること。
		     report.page.item(:quote_price_tax_in).value(@quote_price_tax_in) 
		   end
		   
		   #消費税
		   if @quotation_headers.quote_price.present?
		     @quote_price_tax_only = @quotation_headers.quote_price * consumption_tax  #増税時は変更すること。
		     report.page.item(:quote_price_tax_only).value(@quote_price_tax_only) 
		   end
		 
		   #工事期間
		   report.page.item(:construction_period).value(@quotation_headers.construction_period) 
		 
		   #工事場所
		   report.page.item(:construction_place).value(@quotation_headers.construction_place) 
		 
		   #取引方法
		   report.page.item(:trading_method).value(@quotation_headers.trading_method) 
		 
		   #有効期間
		   report.page.item(:effective_period).value(@quotation_headers.effective_period) 
		 
		   @gengou = @quotation_headers.quotation_date
		   #元号変わったらここも要変更
		   @gengou = "平成#{@gengou.year - 1988}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		   report.page.item(:quotation_date).value(@gengou) 
		   
		   
		   #NET金額
		   if @quotation_headers.net_amount.present?
		     @net_amount = "(" + @quotation_headers.net_amount.to_s(:delimited, delimiter: ',') + ")" 
			 
		     report.page.item(:message_net).value("NET")
			 report.page.item(:net_amount).value(@net_amount)
		   
		   end
		   
		   #小計(見積金額) 
		   #本来ならフッターに設定するべきだが、いまいちわからないため・・
		   report.page.item(:quote_price).value(@quotation_headers.quote_price)
		   
	    ## 右側のヘッダ
		    #実行金額
		   report.page.item(:execution_amount).value(@quotation_headers.execution_amount)
		   
		   #見積No
		   report.page.item(:quotation_code2).value(@quotation_headers.quotation_code) 
		   #工事CD
		   report.page.item(:construction_code).value(@construction_data.construction_code) 
		   
		   #顧客CD
		   report.page.item(:customer_code).value(@customer_masters.id)
		   
		   #見積日付
		   report.page.item(:quotation_date2).value(@gengou) 
		   
		   #郵便番号
		   report.page.item(:post2).value(@quotation_headers.post) 
		 
		   #住所
		   report.page.item(:address2).value(@quotation_headers.address) 
		   #TEL
		   report.page.item(:tel).value(@quotation_headers.tel) 
		   #FAX
		   report.page.item(:fax).value(@quotation_headers.fax) 
		   
		   #得意先名
		   report.page.item(:customer_name2).value(@quotation_headers.customer_name) 
		 
		   #件名
		   report.page.item(:construction_name2).value(@quotation_headers.construction_name) 
		   #工事期間
		   report.page.item(:construction_period2).value(@quotation_headers.construction_period) 
		 
		   #工事場所
		   report.page.item(:construction_place2).value(@quotation_headers.construction_place) 
		 
		   #取引方法
		   report.page.item(:trading_method2).value(@quotation_headers.trading_method) 
		 
		   #有効期間
		   report.page.item(:effective_period2).value(@quotation_headers.effective_period) 
		   
		   #見積金額合計
		   report.page.item(:quote_price2).value(@quotation_headers.quote_price)
		   #消費税
		   if @quote_price_tax_only != ""
		     report.page.item(:quote_price_tax_only2).value(@quote_price_tax_only) 
		   end
		   #実行金額
		   report.page.item(:execution_amount2).value(@quotation_headers.execution_amount)
		   
		   @execution_amount_tax_only = 0
		   if @quotation_headers.execution_amount != 0
              @execution_amount_tax_only = @quotation_headers.execution_amount * consumption_tax   #増税時注意！！
			  report.page.item(:execution_amount_tax_only).value(@execution_amount_tax_only)
		   end
		   
		   #利益
		   profit = @quotation_headers.quote_price + @quote_price_tax_only - @quotation_headers.execution_amount - @execution_amount_tax_only
		   if profit > 0
		     report.page.item(:profit).value(profit)
		   end
		 end
		 
		
		 
		 #for i in 0..29   #29行分(for test)
		   report.list(:default).add_row do |row|
		  
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
                      if @unit_name == "-"
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
	 
	   report.page.item(:labor_amount).value(@@labor_amount )
#end 
		 
	    #$quotation_detail_large_classifications.each do |quotation_detail_large_classification|
		#    report.list(:default).add_row do |row|
		#    row.values quotation_large_item_name: quotation_detail_large_classification.quotation_large_item_name,
        #               quantity: quotation_detail_large_classification.quantity
        #  end
        #end
    
        # ThinReports::Reportを返す
        return report
		
		
    
  end
end


