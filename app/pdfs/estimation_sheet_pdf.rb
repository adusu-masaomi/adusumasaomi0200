class EstimationSheetPDF
    
  
  #def self.create estimation_sheet	
  #upd170626
  def self.create quotation_detail_large_classifications
	#見積書PDF発行
        
		#新元号対応 190401
        require "date"
        
		#履歴データの判定
		@history =false
	    if $print_type == "51" || $print_type == "52"
          @history = true
		end 
		
        # tlfファイルを読み込む
        ##if $print_type == "1"
		#upd170626
		if $print_type == "1" || $print_type == "51"
          @report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/estimation_sheet_pdf.tlf")
        else
        #押印付バージョン
          @report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/estimation_sheet_signed_pdf.tlf")
        end
	   
		# 1ページ目を開始
        @report.start_new_page
	    
		# テーブルの値を設定
        # list に表のIDを設定する(デフォルトのID値: default)
        # add_row で列を追加できる
        # ブロック内のrow.valuesで値を設定する
	  
       @flag = nil
	   
	   #add171206
	   #ソートしている場合は、並び順を変える
	   #if $sort_ql == "asc" 
	   #  sort_string = "line_number ASC"
	   #else
	   #  sort_string = "line_number ASC"
	   #end
	   #
	   
       #add200127
       @notSumFlag = false
       @existsDetail = false
       #事前に明細データの有無を確認
       
       #@quotation_headers = QuotationHeader.find(quotation_detail_large_classification.quotation_header_id)
       #if @quotation_headers.not_sum_flag.present? && @quotation_headers.not_sum_flag == 1
       #  @notSumFlag = true
       #  quotation_detail_middle_classifications = QuotationDetailMiddleClassification.where(:quotation_header_id => @quotation_headers.id).
       #                                          where("id is NOT NULL")
           
       #  quotation_detail_middle_classifications.order(:line_number).each do |quotation_detail_middle_classification|
       #    if quotation_detail_middle_classification.quote_price.present? && 
       #      quotation_detail_middle_classification.quote_price.to_i > 0
       #      @existsDetail = true
       #    end
       #  end #loop end     
       #end
       
       
         quotation_detail_large_classifications.order(:line_number).each do |quotation_detail_large_classification|
         @quotation_headers = QuotationHeader.find(quotation_detail_large_classification.quotation_header_id)
           if @quotation_headers.not_sum_flag.present? && @quotation_headers.not_sum_flag == 1
             @notSumFlag = true
             if @quotation_headers.present?
               quotation_detail_middle_classifications = QuotationDetailMiddleClassification.where(:quotation_header_id => @quotation_headers.id).
                                                 where(:quotation_detail_large_classification_id => quotation_detail_large_classification.id).where("id is NOT NULL")
               quotation_detail_middle_classifications.order(:line_number).each do |quotation_detail_middle_classification|
                 
                 if quotation_detail_middle_classification.quote_price.present? && 
                   quotation_detail_middle_classification.quote_price.to_i > 0
                     @existsDetail = true
                 end
               end  #loop end
             end
           end  
        end #loop end
       
       
       if $print_type == "4"
         @notSumFlag = true
       end
       
       #$quotation_detail_large_classifications.order(:line_number).each do |quotation_detail_large_classification| 
	   #upd170626
	   quotation_detail_large_classifications.order(:line_number).each do |quotation_detail_large_classification|
        
		 #---見出し---
		 
		 if @flag.nil? 
		 
		    @flag = "1"
		   
		   if @history == false
			 @quotation_headers = QuotationHeader.find(quotation_detail_large_classification.quotation_header_id)
	       else
		   #履歴用
		     #add170626
		     @quotation_headers = QuotationHeaderHistory.find(quotation_detail_large_classification.quotation_header_history_id)
		   end
		 
		   #郵便番号(得意先)
		   @report.page.item(:post).value(@quotation_headers.post) 
		 
		   #住所(得意先)
		   #upd171012 分割された住所を一つにまとめる。
		   all_address = @quotation_headers.address
		   if @quotation_headers.house_number.present?
		     all_address += @quotation_headers.house_number
		   end
		   if @quotation_headers.address2.present?
		     all_address += "　" + @quotation_headers.address2
		   end
		   #@report.page.item(:address).value(@quotation_headers.address)
           @report.page.item(:address).value(all_address) 
		   #
		   
		   #得意先名
		   #@report.page.item(:customer_name).value(@quotation_headers.customer_name) 
		   #update 170809
		   @report.page.item(:customer_name).value(@quotation_headers.customer_master.customer_name) 
           
		   ###add161227
		   #敬称
		   honorific_name = CustomerMaster.honorific[0].find{0}  #"様"
		   
		   if @quotation_headers.honorific_id == 1   #"御中?
		     id = @quotation_headers.honorific_id
			 honorific_name = CustomerMaster.honorific[id].find{id} #"御中"
		   end
		   @report.page.item(:honorific).value(honorific_name) 
		   
		   #担当1
		   #upd190131
           if @quotation_headers.ConstructionDatum.present? && 
                !@quotation_headers.ConstructionDatum.personnel.blank?
             responsible = @quotation_headers.ConstructionDatum.personnel + "  様"
		     @report.page.item(:responsible1).value(responsible)
           end
           #if @quotation_headers.responsible1.present?
		   #  responsible = @quotation_headers.responsible1 + "  様"
		   #  @report.page.item(:responsible1).value(responsible)
		   #end
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
		 
           date_per_ten_start = Date.parse("2019/10/01")   #消費税１０％開始日  add190824
         
           if @notSumFlag == false   #add200127
           
             #税込見積合計金額	 
		     if @quotation_headers.quote_price.present?
               #if @quotation_headers.quotation_date < date_per_ten_start
               #upd190919
               if @quotation_headers.quotation_date.nil? || @quotation_headers.quotation_date < date_per_ten_start
               #消費税8%の場合 
                 @quote_price_tax_in = @quotation_headers.quote_price * $consumption_tax_include
		       else
               #消費税10%の場合 
                 @quote_price_tax_in = @quotation_headers.quote_price * $consumption_tax_include_per_ten
               end
               @report.page.item(:quote_price_tax_in).value(@quote_price_tax_in) 
		     end
		   
		     #消費税
		     if @quotation_headers.quote_price.present?
		       #if @quotation_headers.quotation_date < date_per_ten_start
               #upd190919
               if @quotation_headers.quotation_date.nil? || @quotation_headers.quotation_date < date_per_ten_start
               #消費税8%の場合  
                 @quote_price_tax_only = @quotation_headers.quote_price * $consumption_tax_only
               else
               #消費税10%の場合
                 @quote_price_tax_only = @quotation_headers.quote_price * $consumption_tax_only_per_ten
               end
               @report.page.item(:quote_price_tax_only).value(@quote_price_tax_only) 
		     end
		   end
		   #工事期間
		   
           #add191204
           #工事期間(開始〜終了日も追加)
           construction_period = @quotation_headers.construction_period 
           
           if @quotation_headers.construction_period.present?  #文字が入っていたらスペースを開ける
             construction_period += "　"
           end
           
           #開始日
           if @quotation_headers.construction_period_date1.present?
             
             #一旦和暦に変換
             japaneseCalendar = ApplicationController.new.WesternToJapaneseCalendar(@quotation_headers.construction_period_date1)
             
             construction_period += japaneseCalendar
           end
           
           if @quotation_headers.construction_period_date1.present? &&
              @quotation_headers.construction_period_date2.present?
             construction_period += " 〜 "
           end
           
           #終了日
           if @quotation_headers.construction_period_date2.present?
             #一旦和暦に変換
             japaneseCalendar = ApplicationController.new.WesternToJapaneseCalendar(@quotation_headers.construction_period_date2)
             
             construction_period += japaneseCalendar
           end
           #
           
           @report.page.item(:construction_period).value(construction_period)
           #@report.page.item(:construction_period).value(@quotation_headers.construction_period) 
		 
           
         
		   #住所（工事場所）
		   #upd171012 分割された住所を一つにまとめる。
           
           #upd181015 郵便番号追加
           all_address = ""
           if @quotation_headers.construction_post.present?
             all_address = @quotation_headers.construction_post + "　"
           end
           #
           
           all_address += @quotation_headers.construction_place
		   #all_address = @quotation_headers.construction_place
		   if @quotation_headers.construction_house_number.present?
		     all_address += @quotation_headers.construction_house_number
		   end
		   if @quotation_headers.construction_place2.present?
		     all_address += "　" + @quotation_headers.construction_place2
		   end
		   #@report.page.item(:construction_place).value(@quotation_headers.construction_place) 
		   @report.page.item(:construction_place).value(all_address) 
		   #
		   
		   #取引方法
		   @report.page.item(:trading_method).value(@quotation_headers.trading_method) 
		 
		   #有効期間
		   @report.page.item(:effective_period).value(@quotation_headers.effective_period) 
		   
           #binding.pry
           
		   if @quotation_headers.quotation_date.present?
		     
             #@gengou = @quotation_headers.quotation_date
             
             #upd191204 サブルーチン化
             @gengou = ApplicationController.new.WesternToJapaneseCalendar(@quotation_headers.quotation_date)
             
             ##新元号対応 
             #d_heisei_limit = Date.parse("2019/5/1");
             ##元号変わったらここも要変更
             #if @gengou >= d_heisei_limit
             #   #令和
             #   if @gengou.year - $gengo_minus_ad_2 == 1
             #   #１年の場合は元年と表記
             #     @gengou = $gengo_name_2 + "元年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
             #   else
             #     @gengou = $gengo_name_2 + "#{@gengou.year - $gengo_minus_ad_2}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
             #   end
             #else
             #   #平成
		     #   @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		     #end
             
             
             @report.page.item(:quotation_date).value(@gengou) 
		   else
           #空でも文字を出す add180515
             #empty_string =  $gengo_name + "　　" + "年" + "　　" + "月" + "　　" + "日"
             #upd190919
             empty_string =  $gengo_name_2 + "　　" + "年" + "　　" + "月" + "　　" + "日"
             @report.page.item(:quotation_date).value(empty_string) 
           end
		   
		   #NET金額
		   if @quotation_headers.net_amount.present?
		     @net_amount = "(" + @quotation_headers.net_amount.to_s(:delimited, delimiter: ',') + ")" 
			 
		     @report.page.item(:message_net).value("NET")
			 @report.page.item(:net_amount).value(@net_amount)
		   
		   end
		   
		   #小計(見積金額) 
		   #本来ならフッターに設定するべきだが、いまいちわからないため・・
           if @notSumFlag == false  #add200127
		     @report.page.item(:quote_price).value(@quotation_headers.quote_price)
		   end
		 end
		 
         #add200127
         #見積だけの単価としたい場合は、合計を出さない
         #binding.pry
         #if @quotation_headers.not_sum_flag.present? && @quotation_headers.not_sum_flag == 1
         #明細データの有無を事前に確認しておく
             #quotation_detail_middle_classifications = QuotationDetailMiddleClassification.where(:quotation_header_id => @quotation_headers.id).
             #                                    where(:quotation_detail_large_classification_id => quotation_detail_large_classification_id).where("id is NOT NULL")
         #end
         #
         
		   @report.list(:default).add_row do |row|
		  
                      #仕様の場合に数値・単位をnullにする
                      @quantity = quotation_detail_large_classification.quantity
                      if @quantity == 0 
                        @quantity = ""
                      end  
                      #add190903
                      #小数点以下１位があれば表示、なければ非表示
                      if @quantity.present? 
                      	@quantity = "%.4g" %  @quantity
                      end
					  if quotation_detail_large_classification.WorkingUnit.present?
					    @unit_name = quotation_detail_large_classification.WorkingUnit.working_unit_name
					  else 
					    @unit_name = quotation_detail_large_classification.working_unit_name
					  end
					  
					  if @unit_name == "<手入力>"
                        if quotation_detail_large_classification.working_unit_name != "<手入力>"
                          @unit_name = quotation_detail_large_classification.working_unit_name
					    else 
					      @unit_name = ""
					    end
                      end 
                      #  
                      
                      unit_price_or_notices = nil
                      item_name = quotation_detail_large_classification.working_large_item_name
                      
                      if $print_type != "4"  #add200219
                      #小計、値引きの場合は項目を単価欄に表示させる為の分岐
					    case quotation_detail_large_classification.construction_type.to_i
					        when $INDEX_SUBTOTAL, $INDEX_DISCOUNT
                                item_name = ""
						        unit_price_or_notices = quotation_detail_large_classification.working_large_item_name
						        @quantity = ""
						        @unit_name = ""
						    else
                                #item_name = quotation_detail_large_classification.working_large_item_name
						        unit_price_or_notices = quotation_detail_large_classification.working_unit_price
					    end
                      end
					  #
					  
                      #add200127
                      quote_price = nil
                      if $print_type != "4"  #add200219
                       if @existsDetail == false #明細データがない場合
                         quote_price = quotation_detail_large_classification.quote_price
                       end
                      end
                      #明細欄出力
                      row.values working_large_item_name: item_name,
                       working_large_specification: quotation_detail_large_classification.working_large_specification,
                       quantity: @quantity,
		               working_unit_name: @unit_name,
					   working_unit_price: unit_price_or_notices,
                       quote_price: quote_price
					   
            end 
	end	
 

        #内訳のデータも取得・出力
        
        #add170626
        @quotation_detail_large_classifications = quotation_detail_large_classifications  
        
		set_detail_data
       
        # Thin@reports::@reportを返す
        return @report
		
		
    
  end
  
  
  
  def self.set_detail_data
     
	 #見積書(表紙)のページ番号をマイナスさせるためのカウンター。
	 @estimation_sheet_pages = @report.page_count 
	 
	 #内訳データでループ
	 #$quotation_detail_large_classifications.order(:line_number).each do |quotation_detail_large_classification|
	 #$construction_data.order("construction_code desc").each do |construction_datum| 
	 
     #binding.pry
     
	 #upd170626
	 @quotation_detail_large_classifications.order(:line_number).each do |quotation_detail_large_classification|
	   #upd170626
	   if @history == false
         quotation_header_id = quotation_detail_large_classification.quotation_header_id
	   else
	     quotation_header_id = quotation_detail_large_classification.quotation_header_history_id
	   end 
	   quotation_detail_large_classification_id =  quotation_detail_large_classification.id
	    
       #$quotation_detail_middle_classifications = QuotationDetailMiddleClassification.where(:quotation_header_id => quotation_header_id).
       #                                          where(:quotation_detail_large_classification_id => quotation_detail_large_classification_id).where("id is NOT NULL")
	   #upd170626
	   if @history == false
	      @quotation_detail_middle_classifications = QuotationDetailMiddleClassification.where(:quotation_header_id => quotation_header_id).
                                                 where(:quotation_detail_large_classification_id => quotation_detail_large_classification_id).where("id is NOT NULL")
       else
	     @quotation_detail_middle_classifications = QuotationDetailsHistory.where(:quotation_header_history_id => quotation_header_id).
                                                 where(:quotation_breakdown_history_id => quotation_detail_large_classification_id).where("id is NOT NULL")
	   end
		
	   #内訳書PDF発行
	   #if $quotation_detail_middle_classifications.present?
	   #upd170626
	   if @quotation_detail_middle_classifications.present?
	     self.detailed_statement
	   end
	 end
  end
  def self.detailed_statement
  #内訳書PDF発行(A4縦ver)
      
	  
      @@quote_price = 0
    
	  #(＊単独モジュールと違う箇所)
	  # 1ページ目を開始
      @report.start_new_page layout: "#{Rails.root}/app/pdfs/detailed_statement_pdf.tlf"
	   
	   
	  @flag = nil
	  
	  #add171206
	  #ソートしている場合は、並び順を変える
	  if $sort_qm == "asc"
	    sort_string = "line_number desc"
	  else
	    sort_string = "line_number asc"
	  end
	  #
	  
	 
      #$quotation_detail_middle_classifications.order(:line_number).each do |quotation_detail_middle_classification|
      #upd170626
	  #@quotation_detail_middle_classifications.order(:line_number).each do |quotation_detail_middle_classification| 
	  #upd171206
	  @quotation_detail_middle_classifications.order(sort_string).each do |quotation_detail_middle_classification| 
      
      	 #---見出し---
		 
		 if @flag.nil? 
		   
		   @flag = "1"
		   
		   #upd170626
	       if @history == false
		     @quotation_headers = QuotationHeader.find(quotation_detail_middle_classification.quotation_header_id)
	       else
		     @quotation_headers = QuotationHeaderHistory.find(quotation_detail_middle_classification.quotation_header_history_id)
		   end
		   
		   #得意先名
		   #@report.page.item(:customer_name).value(@quotation_headers.customer_name) 
		 
		   #件名
		   @report.page.item(:construction_name).value(@quotation_headers.construction_name) 
		 
		   #見積No
		   @report.page.item(:quotation_code).value(@quotation_headers.quotation_code) 
		   
           #見積日
		   if @quotation_headers.quotation_date.present?
             
             #@gengou = @quotation_headers.quotation_date
             #upd191204 サブルーチン化
		     @gengou = ApplicationController.new.WesternToJapaneseCalendar(@quotation_headers.quotation_date)
             
             ##新元号対応 
             #d_heisei_limit = Date.parse("2019/5/1");
             ##元号変わったらここも要変更
             #if @gengou >= d_heisei_limit
             #   #令和
             #   if @gengou.year - $gengo_minus_ad_2 == 1
             #   #１年の場合は元年と表記
             #     @gengou = $gengo_name_2 + "元年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
             #   else
             #     @gengou = $gengo_name_2 + "#{@gengou.year - $gengo_minus_ad_2}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
             #   end
             #else
             #   #平成
             #   @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
             #end
                          
		     @report.page.item(:quotation_date).value(@gengou) 
		   else
           #空でも文字を出す add180515
             #empty_string =  $gengo_name + "　　" + "年" + "　　" + "月" + "　　" + "日"
             #upd190919 空白はなら令和に
             empty_string =  $gengo_name_2 + "　　" + "年" + "　　" + "月" + "　　" + "日"
             @report.page.item(:quotation_date).value(empty_string) 
           end
		   
		   if @history == false
		     #品目名
		     @report.page.item(:working_large_item_name).value(quotation_detail_middle_classification.QuotationDetailLargeClassification.working_large_item_name)
		     #仕様名
		     @report.page.item(:working_large_specification).value(quotation_detail_middle_classification.QuotationDetailLargeClassification.working_large_specification)
		   else
		   #履歴の場合
		     #品目名
		     @report.page.item(:working_large_item_name).value(quotation_detail_middle_classification.QuotationBreakdownHistory.working_large_item_name)
		     #仕様名
		     @report.page.item(:working_large_specification).value(quotation_detail_middle_classification.QuotationBreakdownHistory.working_large_specification)
		   end
		 end
		 
		
		 
		 @report.list(:default).add_row do |row|
		          
	       if @page_number != (@report.page_count - @estimation_sheet_pages) then
		      #保持用
			  @quote_price_save = @@quote_price
			  
			  if @quote_price_save > 0
			    @report.page.item(:message_sum_header).value("前頁より")
                
                if @notSumFlag == false  #add200127
			      @report.page.item(:blackets1_header).value("(")
		          @report.page.item(:blackets2_header).value(")")
			      @report.page.item(:subtotal_header).value(@quote_price_save)
                end
			  end 
		   end 
		   @page_number = @report.page_count - @estimation_sheet_pages
		   	  
				  
				  #仕様の場合に数値・単位をnullにする
                  @quantity = quotation_detail_middle_classification.quantity
                  if @quantity == 0 
                    @quantity = ""
                  end  
                  #add190903
                  #小数点以下１位があれば表示、なければ非表示
                  if @quantity.present? 
                    @quantity = "%.4g" %  @quantity
                  end    
                  if quotation_detail_middle_classification.WorkingUnit.present?
                     @unit_name = quotation_detail_middle_classification.WorkingUnit.working_unit_name
                  end 
				  if @unit_name == "<手入力>"
                    if quotation_detail_middle_classification.working_unit_name != "<手入力>"
                      @unit_name = quotation_detail_middle_classification.working_unit_name
					else 
					  @unit_name = ""
					end
                  end
                  #  
                  unit_price_or_notices = nil 
                  item_name = quotation_detail_middle_classification.working_middle_item_name
                  
                  if $print_type != "4"   #upd200218
                    #小計、値引きの場合は項目を単価欄に表示させる為の分岐
				    case quotation_detail_middle_classification.construction_type.to_i
				    when $INDEX_SUBTOTAL, $INDEX_DISCOUNT
                    
					    item_name = ""
					    unit_price_or_notices = quotation_detail_middle_classification.working_middle_item_name
					    @quantity = ""
					    @unit_name = ""
				    else
                        #item_name = quotation_detail_middle_classification.working_middle_item_name
					    unit_price_or_notices = quotation_detail_middle_classification.working_unit_price
				    end
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
                  
                  quote_price = nil
                  if $print_type != "4"   #upd200218
                    quote_price = quotation_detail_middle_classification.quote_price
                  end
                  
                   #明細欄出力
                  row.values working_middle_item_name: item_name,
                   working_middle_specification: quotation_detail_middle_classification.working_middle_specification, 
                   quantity: @quantity,
                   working_unit_name: @unit_name,
                   working_unit_price: unit_price_or_notices,
                   #quote_price: quotation_detail_middle_classification.quote_price
                   quote_price: quote_price
				   
         		  
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
           if @notSumFlag == false  #add200127
		     @report.page.item(:subtotal).value(@@quote_price )
		   end
           
		   @report.page.item(:blackets1).value("(")
		   @report.page.item(:blackets2).value(")")
		   
		   #end
    end	
      
	   #add170609 小計の前は１行空行を入れる
	   #@report.list(:default).add_row working_middle_item_name: ""
		   
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


