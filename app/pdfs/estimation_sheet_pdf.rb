class EstimationSheetPDF
    
  
  def self.create estimation_sheet	
	#見積書PDF発行
 
       # tlfファイルを読み込む
       #@report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/quotation_pdf.tlf")
	   @report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/estimation_sheet_pdf.tlf")
		
		# 1ページ目を開始
        @report.start_new_page
	    
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
		   @report.page.item(:post).value(@quotation_headers.post) 
		 
		   #住所
		   @report.page.item(:address).value(@quotation_headers.address) 
		 
		   #得意先名
		   @report.page.item(:customer_name).value(@quotation_headers.customer_name) 
           
		   ###add161227
		   #敬称
		   honorific_name = CustomerMaster.honorific[0].find{0}  #"様"
		   
		   if @quotation_headers.honorific_id == 1   #"御中?
		     id = @quotation_headers.honorific_id
			 honorific_name = CustomerMaster.honorific[id].find{id} #"御中"
		   end
		   @report.page.item(:honorific).value(honorific_name) 
		   
		   #担当1
		   if @quotation_headers.responsible1.present?
		     responsible = @quotation_headers.responsible1 + "  様"
		     @report.page.item(:responsible1).value(responsible)
		   end
		   #担当2
		   if @quotation_headers.responsible2.present?
		     responsible = @quotation_headers.responsible2 + "  様"
		     @report.page.item(:responsible2).value(responsible)
		   end
		   #####
		   
		   #件名
		   @report.page.item(:construction_name).value(@quotation_headers.construction_name) 
		 
		   #見積No
		   @report.page.item(:quotation_code).value(@quotation_headers.quotation_code) 
		 
           #税込見積合計金額	 
		   if @quotation_headers.quote_price.present?
             @quote_price_tax_in = @quotation_headers.quote_price * $consumption_tax_include
		     @report.page.item(:quote_price_tax_in).value(@quote_price_tax_in) 
		   end
		   
		   #消費税
		   if @quotation_headers.quote_price.present?
		     @quote_price_tax_only = @quotation_headers.quote_price * $consumption_tax_only
		     @report.page.item(:quote_price_tax_only).value(@quote_price_tax_only) 
		   end
		 
		   #工事期間
		   @report.page.item(:construction_period).value(@quotation_headers.construction_period) 
		 
		   #工事場所
		   @report.page.item(:construction_place).value(@quotation_headers.construction_place) 
		 
		   #取引方法
		   @report.page.item(:trading_method).value(@quotation_headers.trading_method) 
		 
		   #有効期間
		   @report.page.item(:effective_period).value(@quotation_headers.effective_period) 
		   
		   if @quotation_headers.quotation_date.present?
		     @gengou = @quotation_headers.quotation_date
		     #元号変わったらここも要変更
		     @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		     @report.page.item(:quotation_date).value(@gengou) 
		   end
		   
		   #NET金額
		   if @quotation_headers.net_amount.present?
		     @net_amount = "(" + @quotation_headers.net_amount.to_s(:delimited, delimiter: ',') + ")" 
			 
		     @report.page.item(:message_net).value("NET")
			 @report.page.item(:net_amount).value(@net_amount)
		   
		   end
		   
		   #小計(見積金額) 
		   #本来ならフッターに設定するべきだが、いまいちわからないため・・
		   @report.page.item(:quote_price).value(@quotation_headers.quote_price)
		   
		 end
		 
		 #for i in 0..29   #29行分(for test)
		   @report.list(:default).add_row do |row|
		  
                      #仕様の場合に数値・単位をnullにする
                      @quantity = quotation_detail_large_classification.quantity
                      if @quantity == 0 
                        @quantity = ""
                      end  
                      
					  if quotation_detail_large_classification.WorkingUnit.present?
					    @unit_name = quotation_detail_large_classification.WorkingUnit.working_unit_name
					  else 
					    @unit_name = quotation_detail_large_classification.working_unit_name
					  end
					  
					  if @unit_name == "<手入力>"
                        #if quotation_detail_large_classification.quotation_unit_name != "<手入力>"
						if quotation_detail_large_classification.working_unit_name != "<手入力>"
                          #@unit_name = quotation_detail_large_classification.quotation_unit_name
						  @unit_name = quotation_detail_large_classification.working_unit_name
					    else 
					      @unit_name = ""
					    end
                      end 
                      #  
                      #add170310
					  #小計、値引きの場合は項目を単価欄に表示させる為の分岐
					  case quotation_detail_large_classification.construction_type.to_i
					    when $INDEX_SUBTOTAL, $INDEX_DISCOUNT
                          item_name = ""
						  unit_price_or_notices = quotation_detail_large_classification.working_large_item_name
						  @quantity = ""
						  @unit_name = ""
						else
                          item_name = quotation_detail_large_classification.working_large_item_name
						  unit_price_or_notices = quotation_detail_large_classification.working_unit_price
					  end
					  #
					  
                      #明細欄出力
                      #upd170308
                      row.values working_large_item_name: item_name,
                       working_large_specification: quotation_detail_large_classification.working_large_specification,
                       quantity: @quantity,
		               working_unit_name: @unit_name,
					   working_unit_price: unit_price_or_notices,
                       quote_price: quotation_detail_large_classification.quote_price
					   
                      #row.values working_large_item_name: quotation_detail_large_classification.working_large_item_name,
                      # working_large_specification: quotation_detail_large_classification.working_large_specification,
                      # quantity: @quantity,
		              # working_unit_name: @unit_name,
					  # working_unit_price: quotation_detail_large_classification.working_unit_price,
                      # quote_price: quotation_detail_large_classification.quote_price
           end 
		 #end
    end	
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
	     self.detailed_statement
	   end
	 end
  end
  def self.detailed_statement
  #内訳書PDF発行(A4縦ver)
      
	  
      @@quote_price = 0
    
	  #(＊単独モジュールと違う箇所)
	  #変数@reportはインスタンス変数に変更
      # tlfファイルを読み込む
      #@report = Thin@reports::@report.new(layout: "#{Rails.root}/app/pdfs/detailed_statement_pdf.tlf")

	  #(＊単独モジュールと違う箇所)
	  # 1ページ目を開始
      #@@report.start_new_page
	  @report.start_new_page layout: "#{Rails.root}/app/pdfs/detailed_statement_pdf.tlf"
	   
	   
	  @flag = nil
	
	 
      $quotation_detail_middle_classifications.order(:line_number).each do |quotation_detail_middle_classification| 
      
      	 #---見出し---
		 
		 if @flag.nil? 
		   
		   @flag = "1"
		   
		   @quotation_headers = QuotationHeader.find(quotation_detail_middle_classification.quotation_header_id)
	       #得意先名
		   #@report.page.item(:customer_name).value(@quotation_headers.customer_name) 
		 
		   #件名
		   @report.page.item(:construction_name).value(@quotation_headers.construction_name) 
		 
		   #見積No
		   @report.page.item(:quotation_code).value(@quotation_headers.quotation_code) 
		   
		   if @quotation_headers.quotation_date.present?
             @gengou = @quotation_headers.quotation_date
		     @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		     @report.page.item(:quotation_date).value(@gengou) 
		   end
		 
		   #品目名
		   @report.page.item(:working_large_item_name).value(quotation_detail_middle_classification.QuotationDetailLargeClassification.working_large_item_name)
		   
		   #add170308
		   #仕様名
		   @report.page.item(:working_large_specification).value(quotation_detail_middle_classification.QuotationDetailLargeClassification.working_large_specification)
		   
		 end
		 
		
		 
		 @report.list(:default).add_row do |row|
		          
	       #170112start
		   if @page_number != (@report.page_count - @estimation_sheet_pages) then
		      #保持用
			  @quote_price_save = @@quote_price
			  
			  if @quote_price_save > 0
			    @report.page.item(:message_sum_header).value("前頁より")
			    @report.page.item(:blackets1_header).value("(")
		        @report.page.item(:blackets2_header).value(")")
			    @report.page.item(:subtotal_header).value(@quote_price_save)
			  end 
		   end 
		   @page_number = @report.page_count - @estimation_sheet_pages
		   #170112end
				  
				  
				  
				  #仕様の場合に数値・単位をnullにする
                  @quantity = quotation_detail_middle_classification.quantity
                  if @quantity == 0 
                    @quantity = ""
                  end  
                  #@unit_name = quotation_detail_middle_classification.QuotationUnit.quotation_unit_name
                  if quotation_detail_middle_classification.WorkingUnit.present?
                     @unit_name = quotation_detail_middle_classification.WorkingUnit.working_unit_name
                  end 
				  if @unit_name == "<手入力>"
                    #if quotation_detail_middle_classification.quotation_unit_name != "<手入力>"
                    if quotation_detail_middle_classification.working_unit_name != "<手入力>"
                      @unit_name = quotation_detail_middle_classification.working_unit_name
					else 
					  @unit_name = ""
					end
                  end
                  #  
                  #add170308
				  #小計、値引きの場合は項目を単価欄に表示させる為の分岐
				  case quotation_detail_middle_classification.construction_type.to_i
				  when $INDEX_SUBTOTAL, $INDEX_DISCOUNT
                    item_name = ""
					unit_price_or_notices = quotation_detail_middle_classification.working_middle_item_name
					@quantity = ""
					@unit_name = ""
				  else
                    item_name = quotation_detail_middle_classification.working_middle_item_name
					unit_price_or_notices = quotation_detail_middle_classification.working_unit_price
				  end
				  #
					  
                  if quotation_detail_middle_classification.quote_price.present?
                    if quotation_detail_middle_classification.construction_type.to_i != $INDEX_SUBTOTAL  #add 170308
                      #upd170220
                      tmp = quotation_detail_middle_classification.quote_price.delete("^0-9").to_i
                      if tmp > 0
                         num = quotation_detail_middle_classification.quote_price.to_i
                      else
                         num = tmp
                      end
                      #
                      @@quote_price += num
                    end
                  end
                  
                   #明細欄出力
                  #upd170308
                  row.values working_middle_item_name: item_name,
                   working_middle_specification: quotation_detail_middle_classification.working_middle_specification, 
                   quantity: @quantity,
                   working_unit_name: @unit_name,
                   working_unit_price: unit_price_or_notices,
                   quote_price: quotation_detail_middle_classification.quote_price
				   
                  #row.values working_middle_item_name: quotation_detail_middle_classification.working_middle_item_name,
                  # working_middle_specification: quotation_detail_middle_classification.working_middle_specification, 
                  # quantity: @quantity,
                  # working_unit_name: @unit_name,
                  # working_unit_price: quotation_detail_middle_classification.working_unit_price,
                  # quote_price: quotation_detail_middle_classification.quote_price
		    
    	  end
		  
          #頁番号
		  #頁番号
          #(＊単独モジュールと違う箇所)
		  page_number = @report.page_count - @estimation_sheet_pages
		  
          #デフォルトの頁番号をセット 
		  #if $default_page_number > 0 
          #  page_number = @report.page_count + ($default_page_number - 1 )
          #else
		  #  page_number = @report.page_count
		  #end  
		  
		  page_count = "(" +  page_number.to_s + ")"
		  @report.page.item(:page_number).value(page_count)
		  
		  #数値→漢字へ変換する場合
          #@kanji = num_to_k(@@page_number)
          #@page_number = "(" + @kanji.to_s + "頁)"
		  
		   
		   #本来ならフッターに設定するべきだが、いまいちわからないため・・
		   @report.page.item(:message_sum).value("次頁へ")
		   
		   #本来ならフッターに設定するべきだが、いまいちわからないため・・
		   @report.page.item(:subtotal).value(@@quote_price )
		   
		   #170112start
		   @report.page.item(:blackets1).value("(")
		   @report.page.item(:blackets2).value(")")
		   
		   #end
    end	
      
	   @report.page.item(:message_sum).value("計")
	   #カッコを消す
		@report.page.item(:blackets1).value(" ")
		@report.page.item(:blackets2).value(" ")
		
  end
  #漢数字を数字に変換(未使用だが今後使えそうなので温存)
  def self.num_to_k(n)
    number = 0..9
    kanji = ["","一","二","三","四","五","六","七","八","九"]
    num_kanji = Hash[number.zip(kanji)]
    digit = [1000,100,10]
    # digit = (1..3).map{ |i| 10 ** i }.reverse
    kanji_keta = ["千","百","十"]
    num_kanji_keta = Hash[digit.zip(kanji_keta)]
    num = n
    str = ""
    digit.each { |d|
      tmp = num / d
      str << (tmp == 0 ? "" : ((tmp == 1 ? "" : num_kanji[tmp]) + num_kanji_keta[d]))
      num %= d
    }
    str << num_kanji[num]
  
    return str
  end  
end


