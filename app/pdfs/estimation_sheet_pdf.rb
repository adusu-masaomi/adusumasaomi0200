class EstimationSheetPDF
    
  
  def self.create estimation_sheet	
	#見積書PDF発行
 
       # tlfファイルを読み込む
       report = ThinReports::Report.new(layout: "#{Rails.root}/app/pdfs/quotation_pdf.tlf")

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
		
		# 1ページ目を開始
        report.start_new_page
        #r.start_new_page
		
	    
		# テーブルの値を設定
        # list に表のIDを設定する(デフォルトのID値: default)
        # add_row で列を追加できる
        # ブロック内のrow.valuesで値を設定する
	  
	  @flag = nil
		 
		
      $quotation_detail_large_classifications.order(:line_number).each do |quotation_detail_large_classification| 
	  	 
		 #---見出し---
		 
		 if @flag.nil? 
		 
		    @flag = "1"
		   
		   @quotation_headers = QuotationHeader.find(quotation_detail_large_classification.quotation_header_id)
	     
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
             @quote_price_tax_in = @quotation_headers.quote_price * 1.08  #増税時は変更すること。
		     report.page.item(:quote_price_tax_in).value(@quote_price_tax_in) 
		   end
		   
		   #消費税
		   if @quotation_headers.quote_price.present?
		     @quote_price_tax_only = @quotation_headers.quote_price * 0.08  #増税時は変更すること。
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
		   
		 end
		 
		 #for i in 0..29   #29行分(for test)
		   report.list(:default).add_row do |row|
		  
                      #仕様の場合に数値・単位をnullにする
                      @quantity = quotation_detail_large_classification.quantity
                      if @quantity == 0 
                        @quantity = ""
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
                       quote_price: quotation_detail_large_classification.quote_price
           end 
		 #end
    end	
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


