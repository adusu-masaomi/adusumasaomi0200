class EstimationSheetLandscapePDF
    
  
  #def self.create estimation_sheet
  def self.create quotation_detail_large_classifications
	#見積書PDF発行
       
       # tlfファイルを読み込む
	   @report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/estimation_sheet_landscape_pdf.tlf")

       @@labor_amount = 0
	   @@labor_amount_total = 0
       
	   #履歴データの判定
	   @history =false
	   if $print_type == "53"
         @history = true
	   end 

		# 1ページ目を開始
        @report.start_new_page
		
	    
		# テーブルの値を設定
        # list に表のIDを設定する(デフォルトのID値: default)
        # add_row で列を追加できる
        # ブロック内のrow.valuesで値を設定する
	  
	  @flag = nil
		 
		
      #$quotation_detail_large_classifications.order(:line_number).each do |quotation_detail_large_classification|
      quotation_detail_large_classifications.order(:line_number).each do |quotation_detail_large_classification| 
	  	 
		   
		 #歩掛り合計
		 if quotation_detail_large_classification.labor_productivity_unit.present?
           #合計へカウント
           @@labor_amount += quotation_detail_large_classification.labor_productivity_unit
         end
		 
		 #歩掛り計合計
		 if quotation_detail_large_classification.labor_productivity_unit_total.present?
           if quotation_detail_large_classification.construction_type.to_i != $INDEX_SUBTOTAL  #add 170308
             #合計へカウント
             @@labor_amount_total += quotation_detail_large_classification.labor_productivity_unit_total
           end
         end
		   
		 #---見出し---
		 
         consumption_tax = $consumption_tax_only         #消費税率 
		 consumption_tax_in = $consumption_tax_include   #消費税率(込) 
		 
		 if @flag.nil? 
		 
		    @flag = "1"
		   
		   #@quotation_headers = QuotationHeader.find(quotation_detail_large_classification.quotation_header_id)
		   
		   #upd170626
		   if @history == false
			 @quotation_headers = QuotationHeader.find(quotation_detail_large_classification.quotation_header_id)
	       else
		   #履歴用
		     @quotation_headers = QuotationHeaderHistory.find(quotation_detail_large_classification.quotation_header_history_id)
		   end
		   
           @construction_data = nil
           if ConstructionDatum.where(:id => @quotation_headers.construction_datum_id).exists?
		     @construction_data = ConstructionDatum.find(@quotation_headers.construction_datum_id)
		   end
           
           @customer_masters = CustomerMaster.find(@quotation_headers.customer_id)
		   
		   #郵便番号
           #@report.page.item(:post).value(@quotation_headers.post) 
		   
		   #消費税
		   if @quotation_headers.quote_price.present?
		     @quote_price_tax_only = @quotation_headers.quote_price * consumption_tax  
		   end
		   
		   #元号変わったらここも要変更
		   if @quotation_headers.quotation_date.present?
		     @gengou = @quotation_headers.quotation_date
		     @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		   end
		  
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
           if !(@construction_data.blank?)
		     @report.page.item(:construction_code).value(@construction_data.construction_code) 
		   else
             #データ存在しない場合
             @report.page.item(:construction_code).value("-")
           end
           
		   #顧客CD
		   @report.page.item(:customer_code).value(@customer_masters.id)
		   
		   #見積日付
		   @report.page.item(:quotation_date2).value(@gengou) 
		   
		   #郵便番号(得意先)
		   #@report.page.item(:pos2).value(@quotation_headers.post) 
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
		   
		   #TEL
		   @report.page.item(:tel).value(@quotation_headers.tel) 
		   #FAX
		   @report.page.item(:fax).value(@quotation_headers.fax) 
		   
		   #得意先名
		   #@report.page.item(:customer_name2).value(@quotation_headers.customer_name)
		   #update 170809
           @report.page.item(:customer_name2).value(@quotation_headers.customer_master.customer_name) 
		 
		   #件名
		   @report.page.item(:construction_name2).value(@quotation_headers.construction_name) 
		   #工事期間
		   @report.page.item(:construction_period2).value(@quotation_headers.construction_period) 
		 
		   #住所（工事場所）
		   #upd171012 分割された住所を一つにまとめる。
		   all_address = @quotation_headers.construction_place
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
                      #小計、値引きの場合は項目を単価欄に表示させる為の分岐
					  case quotation_detail_large_classification.construction_type.to_i
					    when $INDEX_SUBTOTAL, $INDEX_DISCOUNT
                          item_name = ""
						  unit_price_or_notices = quotation_detail_large_classification.working_large_item_name
						  execution_unit_price_or_notices = quotation_detail_large_classification.working_large_item_name
						  @quantity = ""
						  @execution_quantity = ""
						  @unit_name = ""
						else
                          item_name = quotation_detail_large_classification.working_large_item_name
                          unit_price_or_notices = quotation_detail_large_classification.working_unit_price
                          execution_unit_price_or_notices = quotation_detail_large_classification.execution_unit_price
					  end
					  #
					  
					  #明細欄出力
                      #upd170308
					  row.values working_large_item_name: item_name,
                       working_large_specification: quotation_detail_large_classification.working_large_specification,
                       quantity: @quantity,
		               working_unit_name: @unit_name,
                       working_unit_price: unit_price_or_notices,
					   execution_unit_price: execution_unit_price_or_notices,
					   quote_price: quotation_detail_large_classification.quote_price,
                       execution_quantity: @execution_quantity,
                       working_unit_name2: @unit_name,
                       execution_price: quotation_detail_large_classification.execution_price,
                       labor_productivity_unit: quotation_detail_large_classification.labor_productivity_unit,
					   labor_productivity_unit_total: quotation_detail_large_classification.labor_productivity_unit_total,
					   remarks: quotation_detail_large_classification.remarks
					  
          
           end 
		 #end
    end	
	   
	   #実行金額(計)
	   @report.page.item(:execution_amount).value(@quotation_headers.execution_amount)
	   #歩掛(計)→不要？？
	   #@report.page.item(:labor_amount).value(@@labor_amount )
	   #歩掛計(計)
	   @report.page.item(:labor_amount_total).value(@@labor_amount_total )
#end 
		 
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
	 @quotation_detail_large_classifications.order(:line_number).each do |quotation_detail_large_classification|
	   
	   #upd170626
	   if @history == false
	     quotation_header_id = quotation_detail_large_classification.quotation_header_id
	   else
	     quotation_header_id = quotation_detail_large_classification.quotation_header_history_id
	   end
	   
	   quotation_detail_large_classification_id =  quotation_detail_large_classification.id
	    
	   #upd170626
	   if @history == false
         @quotation_detail_middle_classifications = QuotationDetailMiddleClassification.where(:quotation_header_id => quotation_header_id).
                                                 where(:quotation_detail_large_classification_id => quotation_detail_large_classification_id).where("id is NOT NULL")
       else
	     @quotation_detail_middle_classifications = QuotationDetailsHistory.where(:quotation_header_history_id => quotation_header_id).
                                                 where(:quotation_breakdown_history_id => quotation_detail_large_classification_id).where("id is NOT NULL")
	   end
		
	   #内訳書PDF発行(A4横ver)
	   if @quotation_detail_middle_classifications.present?
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
	  
	  #170112
	   
	  
	  #@page_number = @report.page_count - @estimation_sheet_pages
	   #add171206
	  #ソートしている場合は、並び順を変える
	  if $sort_qm == "asc"
	    sort_string = "line_number desc"
	  else
	    sort_string = "line_number asc"
	  end
	  #
	  
      #@quotation_detail_middle_classifications.order(:line_number).each do |quotation_detail_middle_classification|
	  @quotation_detail_middle_classifications.order(sort_string).each do |quotation_detail_middle_classification|
	  	 
				
      	 #---見出し---
		 
		  #@@page_number = @@page_number + 1
		 
		 if @flag.nil? 
		   
		   @flag = "1"
		   
		   #upd170626
		   if @history == false
		     @quotation_headers = QuotationHeader.find(quotation_detail_middle_classification.quotation_header_id)
	       else
		     @quotation_headers = QuotationHeaderHistory.find(quotation_detail_middle_classification.quotation_header_history_id)
		   end
		   
		   #件名
		   @report.page.item(:construction_name).value(@quotation_headers.construction_name) 
		 
		   #見積No
		   @report.page.item(:quotation_code).value(@quotation_headers.quotation_code) 
		 
		   if @quotation_headers.quotation_date.present?
             @gengou = @quotation_headers.quotation_date
		     #元号変わったらここも要変更
		     @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		     @report.page.item(:quotation_date).value(@gengou) 
		  end
		 
		  #upd170626
		  if @history == false
            #品目名
            @report.page.item(:working_large_item_name).value(quotation_detail_middle_classification.QuotationDetailLargeClassification.working_large_item_name)
            #仕様名
            @report.page.item(:working_large_specification).value(quotation_detail_middle_classification.QuotationDetailLargeClassification.working_large_specification)
		  else
		    #品目名
            @report.page.item(:working_large_item_name).value(quotation_detail_middle_classification.QuotationBreakdownHistory.working_large_item_name)
            #仕様名
            @report.page.item(:working_large_specification).value(quotation_detail_middle_classification.QuotationBreakdownHistory.working_large_specification)
		  
		  end
		   
		 end
		 
		    
				
		 @report.list(:default).add_row do |row|
		 
		   #170112start
		   if @page_number != (@report.page_count - @estimation_sheet_pages) then
		      #保持用
			  @quote_price_save = @@quote_price
			  @execution_price_save = @@execution_price
			  @labor_productivity_unit_save = @@labor_productivity_unit
			  
			  if @quote_price_save > 0
			    @report.page.item(:message_sum_header).value("前頁より")
			    @report.page.item(:blackets1_header).value("(")
		        @report.page.item(:blackets2_header).value(")")
			    @report.page.item(:subtotal_header).value(@quote_price_save)
			    @report.page.item(:blackets3_header).value("(")
		        @report.page.item(:blackets4_header).value(")")
			    @report.page.item(:subtotal_execution_header).value(@execution_price_save)
			    @report.page.item(:blackets5_header).value("(")
		        @report.page.item(:blackets6_header).value(")")
			    @report.page.item(:subtotal_labor_header).value(@labor_productivity_unit_save)
			  end 
		   end 
		   @page_number = @report.page_count - @estimation_sheet_pages
		   #170112end
	       
				
				
		          #仕様の場合に数値・単位をnullにする
                  @quantity = quotation_detail_middle_classification.quantity
                  if @quantity == 0 
                    @quantity = ""
                  end  
                  @execution_quantity = quotation_detail_middle_classification.execution_quantity
                  if @execution_quantity == 0 
                    @execution_quantity = ""
                  end  
                  #@unit_name = quotation_detail_middle_classification.QuotationUnit.quotation_unit_name
				  if quotation_detail_middle_classification.WorkingUnit.present?
                    @unit_name = quotation_detail_middle_classification.WorkingUnit.working_unit_name
                  else
				    @unit_name = quotation_detail_middle_classification.working_unit_name
				  end                                       

				  if @unit_name == "<手入力>"
				    if quotation_detail_middle_classification.working_unit_name != "<手入力>"
                        
                        @unit_name = quotation_detail_middle_classification.working_unit_name
					else 
					  @unit_name = ""
					end
                  end 
                  
                  if quotation_detail_middle_classification.quote_price.present?
                    if quotation_detail_middle_classification.construction_type.to_i != $INDEX_SUBTOTAL  #add 170308
                      #@@quote_price += quotation_detail_middle_classification.quote_price
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
				  
                  #実行金額合計
                  if quotation_detail_middle_classification.execution_price.present?
                    if quotation_detail_middle_classification.construction_type.to_i != $INDEX_SUBTOTAL  #add 170308
                      #@@execution_price += quotation_detail_middle_classification.execution_price
                      #upd170220
                      tmp = quotation_detail_middle_classification.execution_price.delete("^0-9").to_i
                      if tmp > 0
                         num = quotation_detail_middle_classification.execution_price.to_i
                      else
                         num = tmp
                      end
                      #
                      @@execution_price += num
                    end
                  end
                  
				  #del 170308
				  #@labor_amount = 0
                  #if quotation_detail_middle_classification.execution_quantity.present?
				  #upd170311
				  #
				  #歩掛り計は直接フィールドから取得。
				  #if quotation_detail_middle_classification.execution_quantity.present? 
				  #  if quotation_detail_middle_classification.execution_quantity >= 0
                       #if quotation_detail_middle_classification.labor_productivity_unit.present?
					   #upd170308
					  # if quotation_detail_middle_classification.labor_productivity_unit_total != blank?
					      #@labor_amount = quotation_detail_middle_classification.execution_quantity * quotation_detail_middle_classification.labor_productivity_unit
                      #    @labor_amount = quotation_detail_middle_classification.labor_productivity_unit_total.to_f
						  
						  #合計へカウント
					#	  @@labor_productivity_unit += @labor_amount
					#   end
                  #  end
				  #end
				  
				  #  
                  #add170308
				  #小計、値引きの場合は項目を単価欄に表示させる為の分岐
				  case quotation_detail_middle_classification.construction_type.to_i
				  when $INDEX_SUBTOTAL, $INDEX_DISCOUNT
				    item_name = ""
					unit_price_or_notices = quotation_detail_middle_classification.working_middle_item_name
					execution_unit_price_or_notices = quotation_detail_middle_classification.working_middle_item_name
					@quantity = ""
					@unit_name = ""
					#歩掛りの計も表示させる
					if quotation_detail_middle_classification.labor_productivity_unit_total != blank?
					  @labor_amount = quotation_detail_middle_classification.labor_productivity_unit_total
                    end
					#
				  else
                    item_name = quotation_detail_middle_classification.working_middle_item_name
					unit_price_or_notices = quotation_detail_middle_classification.working_unit_price
					execution_unit_price_or_notices = quotation_detail_middle_classification.execution_unit_price
					
					 #upd170308
					 if quotation_detail_middle_classification.labor_productivity_unit_total != blank?
					    @labor_amount = quotation_detail_middle_classification.labor_productivity_unit_total.to_f
						  
						#合計へカウント
						@@labor_productivity_unit += @labor_amount
					 end
				  end
				  #
				  
				  if @labor_amount == 0
                     @labor_amount = ""
                  end
				  
				  #明細欄出力
                  #upd170308
				  row.values working_middle_item_name: item_name,
                   working_middle_specification: quotation_detail_middle_classification.working_middle_specification, 
                   quantity: @quantity,
                   working_unit_name: @unit_name,
                   working_unit_price: unit_price_or_notices,
                   quote_price: quotation_detail_middle_classification.quote_price,
                   quantity2: @execution_quantity,
                   working_unit_name2: @unit_name,
                   execution_unit_price: execution_unit_price_or_notices,
                   execution_price: quotation_detail_middle_classification.execution_price,
                   labor_productivity_unit: quotation_detail_middle_classification.labor_productivity_unit,
				   labor_amount: @labor_amount,
				   remarks: quotation_detail_middle_classification.remarks
				   
                  #row.values working_middle_item_name: quotation_detail_middle_classification.working_middle_item_name,
                  # working_middle_specification: quotation_detail_middle_classification.working_middle_specification, 
                  # quantity: @quantity,
                  # working_unit_name: @unit_name,
                  # working_unit_price: quotation_detail_middle_classification.working_unit_price,
                  # quote_price: quotation_detail_middle_classification.quote_price,
                  # quantity2: @execution_quantity,
                  # working_unit_name2: @unit_name,
                  # execution_unit_price: quotation_detail_middle_classification.execution_unit_price,
                  # execution_price: quotation_detail_middle_classification.execution_price,
                  # labor_productivity_unit: quotation_detail_middle_classification.labor_productivity_unit,
				  # labor_amount: @labor_amount,
				  # remarks: quotation_detail_middle_classification.remarks
				
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
		   
		   #170112start
		   @report.page.item(:blackets1).value("(")
		   @report.page.item(:blackets2).value(")")
		   
		   @report.page.item(:subtotal).value(@@quote_price)
		   
		   #170112start
		   @report.page.item(:blackets3).value("(")
		   @report.page.item(:blackets4).value(")")
		   
		   @report.page.item(:subtotal_execution).value(@@execution_price )
		   
		   #歩掛り合計
		   #170112start
		   @report.page.item(:blackets5).value("(")
		   @report.page.item(:blackets6).value(")")
		   
		   @report.page.item(:subtotal_labor).value(@@labor_productivity_unit )
		   
		   
		  
		   
		   #end
    end	
     
	   @report.page.item(:message_sum).value("計")
		
		#170112start
		##
		#改ページの最中はヘッダにも表示
		@page_number2 = @report.page_count - @estimation_sheet_pages
		if @page_number != @page_number2 then
		  # 保留！
		  
         	#@report.page.item(:message_sum_header).value("前頁より")
			#@report.page.item(:blackets1_header).value("(")
		   #@report.page.item(:blackets2_header).value(")")
		#	@report.page.item(:subtotal_header).value(@@quote_price_save)
		#	@report.page.item(:blackets3_header).value("(")
		 #  @report.page.item(:blackets4_header).value(")")
		#	@report.page.item(:subtotal_execution_header).value(@@execution_price_save)
		#	@report.page.item(:blackets5_header).value("(")
		 #   @report.page.item(:blackets6_header).value(")")
		#	@report.page.item(:subtotal_labor_header).value(@@labor_productivity_unit_save)
			
		end
		##
		
		#カッコを消す
		@report.page.item(:blackets1).value(" ")
		@report.page.item(:blackets2).value(" ")
		@report.page.item(:blackets3).value(" ")
		@report.page.item(:blackets4).value(" ")
		@report.page.item(:blackets5).value(" ")
		@report.page.item(:blackets6).value(" ")
		
		#170112end
		
		#(＊単独モジュールと違う箇所)
        # Thin@reports::@reportを返す
        #return @report

  end

end


