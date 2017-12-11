class InvoiceLandscapePDF
    
  
  #def self.create invoice
  #upd170626
  def self.create invoice_detail_large_classifications
	#請求書(横)PDF発行
 
       # tlfファイルを読み込む
	   #変数reportはインスタンス変数に変更
       @report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/invoice_landscape_pdf.tlf")

     @@labor_amount = 0
	 @@labor_amount_total = 0
         

		# 1ページ目を開始
        @report.start_new_page
       
	  @flag = nil
		 
		
      #$invoice_detail_large_classifications.order(:line_number).each do |invoice_detail_large_classification|
	  #upd170626
      invoice_detail_large_classifications.order(:line_number).each do |invoice_detail_large_classification| 
	  	 
		   
         #歩掛り合計
         if invoice_detail_large_classification.labor_productivity_unit.present?
           #合計へカウント
           @@labor_amount += invoice_detail_large_classification.labor_productivity_unit
         end
		 
		 #歩掛り計合計
		 if invoice_detail_large_classification.labor_productivity_unit_total.present?
           if invoice_detail_large_classification.construction_type.to_i != $INDEX_SUBTOTAL  #add 170308
             #合計へカウント
             @@labor_amount_total += invoice_detail_large_classification.labor_productivity_unit_total
           end
         end
		   
		 #---見出し---
		 
		 #消費税率
         consumption_tax = $consumption_tax_only
		 #消費税率(込)
		 consumption_tax_in = $consumption_tax_include
		 
		 if @flag.nil? 
		 
		   @flag = "1"
		   
		   @invoice_headers = InvoiceHeader.find(invoice_detail_large_classification.invoice_header_id)
		   @construction_data = ConstructionDatum.find(@invoice_headers.construction_datum_id)
		   @customer_masters = CustomerMaster.find(@invoice_headers.customer_id)
		   #add170119
		   @construction_costs = ConstructionCost.find_by(construction_datum_id: @invoice_headers.construction_datum_id)
		       
		   #消費税
		   if @invoice_headers.billing_amount.present?
		     #消費税のみの金額
		     @billing_amount_tax_only = @invoice_headers.billing_amount * consumption_tax 
             #消費税込み金額(add170725)
             @billing_amount_tax_in = @invoice_headers.billing_amount * consumption_tax_in
		   end
		 
		 
		   if @invoice_headers.invoice_date.present?
		     @gengou = @invoice_headers.invoice_date
		     @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		   end
           
		   #NET金額
		   #if @invoice_headers.net_amount.present?
		   #  @net_amount = "(" + @invoice_headers.net_amount.to_s(:delimited, delimiter: ',') + ")" 
		   #  @report.page.item(:message_net).value("NET")
		   #  @report.page.item(:net_amount).value(@net_amount)
		   #end
		   
		   #小計(見積金額) 
		   @report.page.item(:billing_amount).value(@invoice_headers.billing_amount)
		   
	    ## 右側のヘッダ
		  
           #請求No
           if @invoice_headers.invoice_code.present?
             @report.page.item(:invoice_code2).value(@invoice_headers.invoice_code) 
           else
             #請求Noが未入力の場合は、見積Noをそのまま出す。
		     @report.page.item(:invoice_code2).value(@invoice_headers.invoice_code)
		   end
		   
		   #工事CD
		   @report.page.item(:construction_code).value(@construction_data.construction_code) 
		   
		   #顧客CD
		   @report.page.item(:customer_code).value(@customer_masters.id)
		   
		   #見積日付
		   @report.page.item(:invoice_date).value(@gengou) 
		   
		   #郵便番号(得意先)
		   #@report.page.item(:post2).value(@invoice_headers.post)
           @report.page.item(:post).value(@invoice_headers.post) 
		 
		   #住所(得意先)
		   #upd171012 分割された住所を一つにまとめる。
		   all_address = @invoice_headers.address
		   if @invoice_headers.house_number.present?
		     all_address += @invoice_headers.house_number
		   end
		   if @invoice_headers.address2.present?
		     all_address += "　" + @invoice_headers.address2
		   end
		   #@report.page.item(:address2).value(@invoice_headers.address) 
		   @report.page.item(:address).value(all_address) 
		   #
		   
		   
		   #TEL
		   @report.page.item(:tel).value(@invoice_headers.tel) 
		   #FAX
		   @report.page.item(:fax).value(@invoice_headers.fax) 
		   
		   #得意先名
		   @report.page.item(:customer_name2).value(@invoice_headers.customer_master.customer_name) 
		 
		   #件名
		   @report.page.item(:construction_name2).value(@invoice_headers.construction_name) 
		   
		   #工事期間
		   #@report.page.item(:construction_period2).value(@invoice_headers.construction_period) 
		 
		   #工事場所
		   #@report.page.item(:construction_place2).value(@invoice_headers.construction_place) 
		 
		   #対象期間
		   @report.page.item(:invoice_period_start_date).value(@invoice_headers.invoice_period_start_date)
		   @report.page.item(:invoice_period_end_date).value(@invoice_headers.invoice_period_end_date)
		 
		   #支払期限
		   #@report.page.item(:trading_method2).value(@invoice_headers.trading_method) 
		   @report.page.item(:payment_period).value(@invoice_headers.payment_period) 
		   
		   #有効期間
		   #@report.page.item(:effective_period2).value(@invoice_headers.effective_period) 
		   
		   #見積金額合計
		   @report.page.item(:billing_amount2).value(@invoice_headers.billing_amount)
		   #消費税
		   if @billing_amount_tax_only != ""
		     @report.page.item(:billing_amount_tax_only).value(@billing_amount_tax_only) 
		   end
		   
		   #税込金額(合計)
		   if @invoice_headers.billing_amount.present?
		     @report.page.item(:billing_amount_tax_in).value(@billing_amount_tax_in)
		   end
		   
		   ####170725 以下抹消(復活する可能性もあるので一応残しておく)
		   ##実行金額
		   #execution_amount = 0
		   # if @invoice_headers.execution_amount.present? && @invoice_headers.execution_amount.to_i > 0 then
		   #    #まずは直接実行金額を参照。
		   #    execution_amount = @invoice_headers.execution_amount
           # else
		   #   #なければ工事集計の費用を出す
		   #   if @construction_costs.present?
		   #    #@report.page.item(:execution_amount2).value(@invoice_headers.execution_amount)
           #      if @construction_costs.execution_amount.present?
		   #         execution_amount = @construction_costs.execution_amount
		   #      end
           #   end   
		   # end
		   #@report.page.item(:execution_amount2).value(execution_amount)
		   #@execution_amount_tax_only = 0
		   #if execution_amount != 0
           #   @execution_amount_tax_only = execution_amount * consumption_tax   
		   #   @report.page.item(:execution_amount_tax_only).value(@execution_amount_tax_only)
		   #end
		   ##利益
		   #profit = @invoice_headers.billing_amount + @billing_amount_tax_only - @invoice_headers.execution_amount - @execution_amount_tax_only
		   #if profit > 0
		   #  @report.page.item(:profit).value(profit)
		   #end
		   ###
		 end
		 
		
		 
		 #for i in 0..29   #29行分(for test)
		   @report.list(:default).add_row do |row|
		  
                      #仕様の場合に数値・単位をnullにする
                      @quantity = invoice_detail_large_classification.quantity
                      if @quantity == 0 
                        @quantity = ""
                      end  
                      @execution_quantity = invoice_detail_large_classification.execution_quantity
                      if @execution_quantity == 0 
                        @execution_quantity = ""
                      end  
                      
					  if invoice_detail_large_classification.WorkingUnit.present?
                        @unit_name = invoice_detail_large_classification.WorkingUnit.working_unit_name
				      else
					    @unit_name = invoice_detail_large_classification.working_unit_name
					  end 
					  
                      if @unit_name == "<手入力>"
					    if invoice_detail_large_classification.working_unit_name != "<手入力>"
                          @unit_name = invoice_detail_large_classification.working_unit_name
                        else
						  @unit_name = ""
						end
					  end 
                      #  
                      #add170308
					  #小計、値引きの場合は項目を単価欄に表示させる為の分岐
					  case invoice_detail_large_classification.construction_type.to_i
					    when $INDEX_SUBTOTAL, $INDEX_DISCOUNT
                          item_name = ""
						  unit_price_or_notices = invoice_detail_large_classification.working_large_item_name
						  execution_unit_price_or_notices = invoice_detail_large_classification.working_large_item_name
						  @quantity = ""
						  @execution_quantity = ""
						  @unit_name = ""
						else
                          item_name = invoice_detail_large_classification.working_large_item_name
                          unit_price_or_notices = invoice_detail_large_classification.working_unit_price
                          execution_unit_price_or_notices = invoice_detail_large_classification.execution_unit_price
					  end
					  #
					  row.values working_large_item_name: item_name,
                       working_large_specification: invoice_detail_large_classification.working_large_specification,
                       quantity: @quantity,
		               working_unit_name: @unit_name,
                       working_unit_price: unit_price_or_notices,
					   invoice_price: invoice_detail_large_classification.invoice_price
					   
                      #row.values working_large_item_name: invoice_detail_large_classification.working_large_item_name,
                      # working_large_specification: invoice_detail_large_classification.working_large_specification,
                      # quantity: @quantity,
		              # working_unit_name: @unit_name,
                      # working_unit_price: invoice_detail_large_classification.working_unit_price,
					  # invoice_price: invoice_detail_large_classification.invoice_price
                      
           end 
		 #end
    end	
	   
		 
	   #add170626
	   @invoice_detail_large_classifications = invoice_detail_large_classifications
		 
	   #内訳のデータも取得・出力
	   set_detail_data
	   
	  
        # Thin@reports::@reportを返す
        return @report
		
		
    
  end
  
  def self.set_detail_data
     
	 #見積書(表紙)のページ番号をマイナスさせるためのカウンター。
	 @estimation_sheet_pages = @report.page_count 
	 
	 #内訳データでループ
	 #$invoice_detail_large_classifications.order(:line_number).each do |invoice_detail_large_classification|
	 #upd170626
	 @invoice_detail_large_classifications.order(:line_number).each do |invoice_detail_large_classification|
	 
	   invoice_header_id = invoice_detail_large_classification.invoice_header_id
	   invoice_detail_large_classification_id =  invoice_detail_large_classification.id
	    
       #$invoice_detail_middle_classifications = InvoiceDetailMiddleClassification.where(:invoice_header_id => invoice_header_id).
       #                                          where(:invoice_detail_large_classification_id => invoice_detail_large_classification_id).where("id is NOT NULL")
       #170626
       @invoice_detail_middle_classifications = InvoiceDetailMiddleClassification.where(:invoice_header_id => invoice_header_id).
                                                 where(:invoice_detail_large_classification_id => invoice_detail_large_classification_id).where("id is NOT NULL")
												 
	   #内訳書PDF発行(A4横ver)
	   #if $invoice_detail_middle_classifications.present?
	   #upd170626
	   if @invoice_detail_middle_classifications.present?
	     self.invoice_detailed_statement_landscape
	   end
	 end
	 
     
  end
  
  
  def self.invoice_detailed_statement_landscape
	#内訳書PDF発行(A4横ver)
      
      @@invoice_price = 0
      @@execution_price = 0
      @@labor_productivity_unit = 0
      
	  
      #(＊単独モジュールと違う箇所)
	  # 1ページ目を開始
      #@report.start_new_page
	  @report.start_new_page layout: "#{Rails.root}/app/pdfs/invoice_detailed_statement_landscape_pdf.tlf"
	   

	   
	  @flag = nil
	  
	  #$invoice_detail_middle_classifications.order(:line_number).each do |invoice_detail_middle_classification|
      #upd170626
      @invoice_detail_middle_classifications.order(:line_number).each do |invoice_detail_middle_classification| 
          
	  	 #---見出し---
		 
		 if @flag.nil? 
		   
		   @flag = "1"
		   
		   @invoice_headers = InvoiceHeader.find(invoice_detail_middle_classification.invoice_header_id)
	      
		   #件名
		   @report.page.item(:construction_name).value(@invoice_headers.construction_name) 
		 
		   #請求No
		   if @invoice_headers.invoice_code.present?
		     @report.page.item(:invoice_code).value(@invoice_headers.invoice_code) 
           else
             #請求Noが未入力の場合は、見積Noをそのまま出す。
             @report.page.item(:invoice_code).value(@invoice_headers.invoice_code) 
           end
           
		   if @invoice_headers.invoice_date.present?
             @gengou = @invoice_headers.invoice_date
		     @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		     @report.page.item(:invoice_date).value(@gengou) 
		   end
		   
           #品目名
		   @report.page.item(:working_large_item_name).value(invoice_detail_middle_classification.InvoiceDetailLargeClassification.working_large_item_name)
		   
		    #add170308
           #仕様名
           @report.page.item(:working_large_specification).value(invoice_detail_middle_classification.InvoiceDetailLargeClassification.working_large_specification)

		 end
				
		 @report.list(:default).add_row do |row|
		 
		   if @page_number != (@report.page_count - @estimation_sheet_pages) then
		      #保持用
			  @invoice_price_save = @@invoice_price
			  @execution_price_save = @@execution_price
			  @labor_productivity_unit_save = @@labor_productivity_unit
			  
			  if @invoice_price_save > 0
			    @report.page.item(:message_sum_header).value("前頁より")
			    @report.page.item(:blackets1_header).value("(")
		        @report.page.item(:blackets2_header).value(")")
			    @report.page.item(:subtotal_header).value(@invoice_price_save)
			
			  end 
		   end 
		   @page_number = @report.page_count - @estimation_sheet_pages
		   	
				
		          #仕様の場合に数値・単位をnullにする
                  @quantity = invoice_detail_middle_classification.quantity
                  if @quantity == 0 
                    @quantity = ""
                  end  
                  @execution_quantity = invoice_detail_middle_classification.execution_quantity
                  if @execution_quantity == 0 
                    @execution_quantity = ""
                  end  
                  
				  if invoice_detail_middle_classification.WorkingUnit.present?
				    @unit_name = invoice_detail_middle_classification.WorkingUnit.working_unit_name
                  else
				    #@unit_name = ""
				    @unit_name = invoice_detail_middle_classification.working_unit_name
				  end
				  
				  if @unit_name == "<手入力>"
					if invoice_detail_middle_classification.working_unit_name != "<手入力>"
                      @unit_name = invoice_detail_middle_classification.working_unit_name
					else 
					  @unit_name = ""
					end
                  end 
                  
                  if invoice_detail_middle_classification.invoice_price.present?
				    if invoice_detail_middle_classification.construction_type.to_i != $INDEX_SUBTOTAL  #add 170308
                      #upd170220
					  tmp = invoice_detail_middle_classification.invoice_price.delete("^0-9").to_i
					  if tmp > 0
                         num = invoice_detail_middle_classification.invoice_price.to_i
					  else
					     num = tmp
					  end
					  #
					  @@invoice_price += num
				    end
				  end
                  #実行金額合計
                  if invoice_detail_middle_classification.execution_price.present?
                    if invoice_detail_middle_classification.construction_type.to_i != $INDEX_SUBTOTAL  #add 170308
                      #upd170220
					  tmp = invoice_detail_middle_classification.execution_price.delete("^0-9").to_i
					  if tmp > 0
                         num = invoice_detail_middle_classification.execution_price.to_i
					  else
					     num = tmp
					  end
					  #
					  @@execution_price += num
                    end
                  end
                  
				  #@labor_amount = 0
                  #if invoice_detail_middle_classification.execution_quantity.present?
				  #  if invoice_detail_middle_classification.execution_quantity >= 0
                  #     if invoice_detail_middle_classification.labor_productivity_unit.present?
				  #      @labor_amount = invoice_detail_middle_classification.execution_quantity * invoice_detail_middle_classification.labor_productivity_unit
                  #        #合計へカウント
				  # 	  @@labor_productivity_unit += @labor_amount
				  #     end
                  #  end
				  #end
				  
				  #  
                  #add170308
				  #小計、値引きの場合は項目を単価欄に表示させる為の分岐
				  case invoice_detail_middle_classification.construction_type.to_i
				  when $INDEX_SUBTOTAL, $INDEX_DISCOUNT
				    item_name = ""
					unit_price_or_notices = invoice_detail_middle_classification.working_middle_item_name
					execution_unit_price_or_notices = invoice_detail_middle_classification.working_middle_item_name
					@quantity = ""
					@unit_name = ""
					#歩掛りの計も表示させる
					if invoice_detail_middle_classification.labor_productivity_unit_total != blank?
					  @labor_amount = invoice_detail_middle_classification.labor_productivity_unit_total
                    end
					#
				  else
                    item_name = invoice_detail_middle_classification.working_middle_item_name
					unit_price_or_notices = invoice_detail_middle_classification.working_unit_price
					execution_unit_price_or_notices = invoice_detail_middle_classification.execution_unit_price
					
					 #upd170308
					 if invoice_detail_middle_classification.labor_productivity_unit_total != blank?
					    @labor_amount = invoice_detail_middle_classification.labor_productivity_unit_total.to_f
						  
						#合計へカウント
						@@labor_productivity_unit += @labor_amount
					 end
				  end
				  #
				  
				  if @labor_amount == 0
                     @labor_amount = ""
                  end
				  
                  row.values working_middle_item_name: item_name,
                   working_middle_specification: invoice_detail_middle_classification.working_middle_specification, 
                   quantity: @quantity,
                   working_unit_name: @unit_name,
                   working_unit_price: unit_price_or_notices,
                   invoice_price: invoice_detail_middle_classification.invoice_price
                  
				   
				
		  end
		#end 
		  
		 
		  
		  #頁番号
          #(＊単独モジュールと違う箇所)
		  page_number = @report.page_count - @estimation_sheet_pages
         
	  
		  page_count = "(" +  page_number.to_s + ")"
		  @report.page.item(:page_number).value(page_count)
		   
		   @report.page.item(:message_sum).value("次頁へ")
		   
		   @report.page.item(:blackets1).value("(")
		   @report.page.item(:blackets2).value(")")
		   
		   @report.page.item(:subtotal).value(@@invoice_price)
		   
		   #@report.page.item(:blackets3).value("(")
		   #@report.page.item(:blackets4).value(")")
		   #@report.page.item(:subtotal_execution).value(@@execution_price )
		   
		   #歩掛り合計
		   #@report.page.item(:blackets5).value("(")
		   #@report.page.item(:blackets6).value(")")
		   #@report.page.item(:subtotal_labor).value(@@labor_productivity_unit )
		   
		  
    end	
     
	   @report.page.item(:message_sum).value("計")
		
		#改ページの最中はヘッダにも表示
		#@page_number2 = @report.page_count - @estimation_sheet_pages
		
		#カッコを消す
		@report.page.item(:blackets1).value(" ")
		@report.page.item(:blackets2).value(" ")
		#@report.page.item(:blackets3).value(" ")
		#@report.page.item(:blackets4).value(" ")
		#@report.page.item(:blackets5).value(" ")
		#@report.page.item(:blackets6).value(" ")
	

  end

end


