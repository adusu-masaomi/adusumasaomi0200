class DeliverySlipLandscapePDF
    
  
  #def self.create delivery_slip
  #upd170626
  def self.create delivery_slip_detail_large_classifications
	#納品書(横)PDF発行
       #新元号対応 190401
       require "date"
       d_heisei_limit = Date.parse("2019/5/1")
       
       # tlfファイルを読み込む
	   #変数reportはインスタンス変数に変更
       @report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/delivery_slip_landscape_pdf.tlf")

       @@labor_amount = 0
	   @@labor_amount_total = 0
         

		# 1ページ目を開始
        @report.start_new_page
        
	  @flag = nil
		 
		
      #$delivery_slip_detail_large_classifications.order(:line_number).each do |delivery_slip_detail_large_classification|
      #upd170626
      delivery_slip_detail_large_classifications.order(:line_number).each do |delivery_slip_detail_large_classification| 
	  	 
		   
		 #歩掛り合計
		 if delivery_slip_detail_large_classification.labor_productivity_unit.present?
           #合計へカウント
           @@labor_amount += delivery_slip_detail_large_classification.labor_productivity_unit
         end
		 
		 #歩掛り計合計
		 if delivery_slip_detail_large_classification.labor_productivity_unit_total.present?
           if delivery_slip_detail_large_classification.construction_type.to_i != $INDEX_SUBTOTAL  #add 170308
             #合計へカウント
             @@labor_amount_total += delivery_slip_detail_large_classification.labor_productivity_unit_total
           end
         end
		   
		 #---見出し---
		 
         #consumption_tax = $consumption_tax_only        #消費税率 
		 #consumption_tax_in = $consumption_tax_include  #消費税率(込)
		 
		 if @flag.nil? 
		 
		   @flag = "1"
		   
		   @delivery_slip_headers = DeliverySlipHeader.find(delivery_slip_detail_large_classification.delivery_slip_header_id)
           @construction_data = nil
           if ConstructionDatum.exists?(id: @delivery_slip_headers.construction_datum_id) 
             @construction_data = ConstructionDatum.find(@delivery_slip_headers.construction_datum_id)
           end
		   @customer_masters = CustomerMaster.find(@delivery_slip_headers.customer_id)
		   
		   #消費税
           date_per_ten_start = Date.parse("2019/10/01")   #消費税１０％開始日  add190824
           
		   if @delivery_slip_headers.delivery_amount.present?
             #if @delivery_slip_headers.delivery_slip_date < date_per_ten_start
             #upd190919
             if @delivery_slip_headers.delivery_slip_date.nil? || @delivery_slip_headers.delivery_slip_date < date_per_ten_start
             #消費税8%
		       @delivery_amount_tax_only = @delivery_slip_headers.delivery_amount * $consumption_tax_only  
		     else
             #消費税10%
		       @delivery_amount_tax_only = @delivery_slip_headers.delivery_amount * $consumption_tax_only_per_ten
             end
           end
		   
		   
		   #元号
		   if @delivery_slip_headers.delivery_slip_date.present?
		     #@gengou = @delivery_slip_headers.delivery_slip_date
             #upd191204 サブルーチン化
             @gengou = ApplicationController.new.WesternToJapaneseCalendar(@delivery_slip_headers.delivery_slip_date)
             
             #元号変わったらここも要変更
             #if @gengou >= d_heisei_limit
             ##令和
             #   if @gengou.year - $gengo_minus_ad_2 == 1
             #   #１年の場合は元年と表記
             #     @gengou = $gengo_name_2 + "元年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
             #   else
             #     @gengou = $gengo_name_2 + "#{@gengou.year - $gengo_minus_ad_2}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
             #   end
             #else
             ##平成
		     #   @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		     #end
           end
		   
		   #NET金額
		   #if @delivery_slip_headers.net_amount.present?
		   #  @net_amount = "(" + @delivery_slip_headers.net_amount.to_s(:delimited, delimiter: ',') + ")" 
		   #  @report.page.item(:message_net).value("NET")
		   #  @report.page.item(:net_amount).value(@net_amount)
		   #end
		   
		   #小計(見積金額) 
		   @report.page.item(:delivery_amount).value(@delivery_slip_headers.delivery_amount)
		   
	    ## 右側のヘッダ
		  
		   #納品No
		   if @delivery_slip_headers.delivery_slip_code.present?
		     @report.page.item(:delivery_slip_code2).value(@delivery_slip_headers.delivery_slip_code) 
           else
		   #納品Noが未入力の場合は、見積Noをそのまま出す。
		     @report.page.item(:delivery_slip_code2).value(@delivery_slip_headers.delivery_slip_code)
		   end
		   
		   
		   #工事CD
           if @construction_data.present?
		     @report.page.item(:construction_code).value(@construction_data.construction_code) 
		   end
           
		   #顧客CD
		   @report.page.item(:customer_code).value(@customer_masters.id)
		   
		   #納品日付
		   #@report.page.item(:delivery_slip_date2).value(@gengou)
           @report.page.item(:delivery_slip_date).value(@gengou) 
		   
		   #郵便番号(得意先)
		   #@report.page.item(:post2).value(@delivery_slip_headers.post) 
		   @report.page.item(:post).value(@delivery_slip_headers.post) 
		 
		   #住所(得意先)
		   #upd171012 分割された住所を一つにまとめる。
		   all_address = @delivery_slip_headers.address
		   if @delivery_slip_headers.house_number.present?
		     all_address += @delivery_slip_headers.house_number
		   end
		   if @delivery_slip_headers.address2.present?
		     all_address += "　" + @delivery_slip_headers.address2
		   end
		   #@report.page.item(:address2).value(@delivery_slip_headers.address) 
		   @report.page.item(:address).value(all_address) 
		   
		   
		   #TEL
		   @report.page.item(:tel).value(@delivery_slip_headers.tel) 
		   #FAX
		   @report.page.item(:fax).value(@delivery_slip_headers.fax) 
		   
		   #得意先名
		   #upd170809
		   @report.page.item(:customer_name2).value(@delivery_slip_headers.customer_master.customer_name) 
		 
		   #件名
		   @report.page.item(:construction_name2).value(@delivery_slip_headers.construction_name) 
		   
           #工事期間(開始〜終了日も追加)
           construction_period = @delivery_slip_headers.construction_period 
           
           if @delivery_slip_headers.construction_period.present?  #文字が入っていたらスペースを開ける
             construction_period += "　"
           end
           
           #開始日
           if @delivery_slip_headers.construction_period_date1.present?
             
             #一旦和暦に変換
             japaneseCalendar = ApplicationController.new.WesternToJapaneseCalendar(@delivery_slip_headers.construction_period_date1)
             
             construction_period += japaneseCalendar
           end
           
           if @delivery_slip_headers.construction_period_date1.present? &&
              @delivery_slip_headers.construction_period_date2.present?
             construction_period += " 〜 "
           end
           
           #終了日
           if @delivery_slip_headers.construction_period_date2.present?
             #一旦和暦に変換
             japaneseCalendar = ApplicationController.new.WesternToJapaneseCalendar(@delivery_slip_headers.construction_period_date2)
             construction_period += japaneseCalendar
           end
           #
           
           @report.page.item(:construction_period2).value(construction_period) 
           #@report.page.item(:construction_period2).value(@delivery_slip_headers.construction_period) 
		 
		   #住所（工事場所）
		   #分割された住所を一つにまとめる。
		   #all_address = @delivery_slip_headers.construction_place
		   #upd181011 郵便番号追加
           all_address = ""
           #del220430 郵便番号は抹消
           #if @delivery_slip_headers.construction_post.present?
           #  all_address = @delivery_slip_headers.construction_post + "　"
           #end
           all_address += @delivery_slip_headers.construction_place
		   #
                      
           if @delivery_slip_headers.construction_house_number.present?
		     all_address += @delivery_slip_headers.construction_house_number
		   end
		   if @delivery_slip_headers.construction_place2.present?
		     all_address += "　" + @delivery_slip_headers.construction_place2
		   end
		   #@report.page.item(:construction_place).value(@delivery_slip_headers.construction_place) 
		   @report.page.item(:construction_place).value(all_address) 
		   #
		   
		   #取引方法
		   #@report.page.item(:trading_method2).value(@delivery_slip_headers.trading_method) 
		 
		   #有効期間
		   #@report.page.item(:effective_period2).value(@delivery_slip_headers.effective_period) 
		   
		   #納品金額合計
		   @report.page.item(:delivery_amount2).value(@delivery_slip_headers.delivery_amount)
		   #消費税
		   if @qdelivery_amount_tax_only != ""
		     @report.page.item(:delivery_amount_tax_only).value(@delivery_amount_tax_only) 
		   end
		   #実行金額
		   @report.page.item(:execution_amount2).value(@delivery_slip_headers.execution_amount)
		   
		   @execution_amount_tax_only = 0
		   if @delivery_slip_headers.execution_amount != 0
              #if @delivery_slip_headers.delivery_slip_date < date_per_ten_start
              #upd190919
              #if @delivery_slip_headers.delivery_slip_date < date_per_ten_start
              if @delivery_slip_headers.delivery_slip_date.nil? || @delivery_slip_headers.delivery_slip_date < date_per_ten_start
              #消費税8%
                @execution_amount_tax_only = @delivery_slip_headers.execution_amount * $consumption_tax_only   
			  else
              #消費税10%
                @execution_amount_tax_only = @delivery_slip_headers.execution_amount * $consumption_tax_only_per_ten
              end
              @report.page.item(:execution_amount_tax_only).value(@execution_amount_tax_only)
		   end
		   
		   #利益
		   if @delivery_slip_headers.delivery_amount.present? && @delivery_slip_headers.execution_amount.present? 
		   profit = @delivery_slip_headers.delivery_amount + @delivery_amount_tax_only - @delivery_slip_headers.execution_amount - @execution_amount_tax_only
		     if profit > 0
		       @report.page.item(:profit).value(profit)
		     end
		   end
		 end
		 
		
		 
		   @report.list(:default).add_row do |row|
		  
                      #仕様の場合に数値・単位をnullにする
                      @quantity = delivery_slip_detail_large_classification.quantity
                      if @quantity == 0 
                        @quantity = ""
                      end  
                      #add190903
                      #小数点以下１位があれば表示、なければ非表示
                      if @quantity.present?
                        @quantity = "%.4g" %  @quantity
                      end
                      
                      @execution_quantity = delivery_slip_detail_large_classification.execution_quantity
                      if @execution_quantity == 0 
                        @execution_quantity = ""
                      end  
                      
                      #add190903
                      #小数点以下１位があれば表示、なければ非表示
                      if @execution_quantity.present?
                        @execution_quantity = "%.4g" %  @execution_quantity
                      end
                      #@unit_name = delivery_slip_detail_large_classification.DeliverySlipUnit.delivery_slip_unit_name
					  if delivery_slip_detail_large_classification.WorkingUnit.present?
                        @unit_name = delivery_slip_detail_large_classification.WorkingUnit.working_unit_name
                      else
					    @unit_name = delivery_slip_detail_large_classification.working_unit_name
					  end
					  
					  if @unit_name == "<手入力>"
                        #if delivery_slip_detail_large_classification.delivery_slip_unit_name != "<手入力>"
                        if delivery_slip_detail_large_classification.working_unit_name != "<手入力>"
                          @unit_name = delivery_slip_detail_large_classification.working_unit_name
                        else
						  @unit_name = ""
						end
					  end 
                      #  
                      #add170308
					  #小計、値引きの場合は項目を単価欄に表示させる為の分岐
					  case delivery_slip_detail_large_classification.construction_type.to_i
					    when $INDEX_SUBTOTAL, $INDEX_DISCOUNT
                          item_name = ""
						  unit_price_or_notices = delivery_slip_detail_large_classification.working_large_item_name
						  execution_unit_price_or_notices = delivery_slip_detail_large_classification.working_large_item_name
						  @quantity = ""
						  @execution_quantity = ""
						  @unit_name = ""
						else
                          item_name = delivery_slip_detail_large_classification.working_large_item_name
                          unit_price_or_notices = delivery_slip_detail_large_classification.working_unit_price
                          execution_unit_price_or_notices = delivery_slip_detail_large_classification.execution_unit_price
					  end
					  #
					  
                      row.values working_large_item_name: item_name,
                       working_large_specification: delivery_slip_detail_large_classification.working_large_specification,
                       quantity: @quantity,
		               working_unit_name: @unit_name,
                       working_unit_price: unit_price_or_notices,
					   execution_unit_price: execution_unit_price_or_notices,
					   delivery_slip_price: delivery_slip_detail_large_classification.delivery_slip_price,
                       execution_quantity: @execution_quantity,
                       working_unit_name2: @unit_name,
                       execution_price: delivery_slip_detail_large_classification.execution_price,
                       labor_productivity_unit: delivery_slip_detail_large_classification.labor_productivity_unit,
					   labor_productivity_unit_total: delivery_slip_detail_large_classification.labor_productivity_unit_total,
					   remarks: delivery_slip_detail_large_classification.remarks
           end 
		 #end
    end	
	   
	   #実行金額(計)
	   @report.page.item(:execution_amount).value(@delivery_slip_headers.execution_amount)
	   #歩掛(計)→不要？？
	   #@report.page.item(:labor_amount).value(@@labor_amount )
	   #歩掛計(計)
	   @report.page.item(:labor_amount_total).value(@@labor_amount_total )
#end 
	   
	   #add170626
       @delivery_slip_detail_large_classifications = delivery_slip_detail_large_classifications
	   
	   #内訳のデータも取得・出力
	   set_detail_data
	   
	  
        # Thin@reports::@reportを返す
        return @report
		
		
    
  end
  
  def self.set_detail_data
     
	 #納品書(表紙)のページ番号をマイナスさせるためのカウンター。
	 @estimation_sheet_pages = @report.page_count 
	 
	 #納品データでループ
	 #$delivery_slip_detail_large_classifications.order(:line_number).each do |delivery_slip_detail_large_classification|
     #upd170626
     @delivery_slip_detail_large_classifications.order(:line_number).each do |delivery_slip_detail_large_classification|
	   delivery_slip_header_id = delivery_slip_detail_large_classification.delivery_slip_header_id
	   delivery_slip_detail_large_classification_id =  delivery_slip_detail_large_classification.id
	    
       #$delivery_slip_detail_middle_classifications = DeliverySlipDetailMiddleClassification.where(:delivery_slip_header_id => delivery_slip_header_id).
       #                                          where(:delivery_slip_detail_large_classification_id => delivery_slip_detail_large_classification_id).where("id is NOT NULL")
       #upd170626
       @delivery_slip_detail_middle_classifications = DeliverySlipDetailMiddleClassification.where(:delivery_slip_header_id => delivery_slip_header_id).
                                                 where(:delivery_slip_detail_large_classification_id => delivery_slip_detail_large_classification_id).where("id is NOT NULL")
	   
	   #納品書PDF発行(A4横ver)
	   #if $delivery_slip_detail_middle_classifications.present?
       #upd170626
       if @delivery_slip_detail_middle_classifications.present?
	     self.delivery_slip_detailed_statement_landscape
	   end
	 end
	 
     
  end
  
  
  def self.delivery_slip_detailed_statement_landscape
	#内訳書PDF発行(A4横ver)
      


      #新元号対応 190401
       require "date"
       d_heisei_limit = Date.parse("2019/5/1")

      @@delivery_slip_price = 0
      @@execution_price = 0
      @@labor_productivity_unit = 0
      
	  
      #(＊単独モジュールと違う箇所)
	  # 1ページ目を開始
      #@report.start_new_page
	  @report.start_new_page layout: "#{Rails.root}/app/pdfs/delivery_slip_detailed_statement_landscape_pdf.tlf"
	   	   
	  @flag = nil
	  
	  #add171206
	  #ソートしている場合は、並び順を変える
	  if $sort_dm == "asc"
	    sort_string = "line_number desc"
	  else
	    sort_string = "line_number asc"
	  end
	  #
	  
	  #$delivery_slip_detail_middle_classifications.order(:line_number).each do |delivery_slip_detail_middle_classification|
      #upd170626 
	  #@delivery_slip_detail_middle_classifications.order(:line_number).each do |delivery_slip_detail_middle_classification|
      @delivery_slip_detail_middle_classifications.order(sort_string).each do |delivery_slip_detail_middle_classification| 
          
	  	 #---見出し---
		 
		 if @flag.nil? 
		   
		   @flag = "1"
		   
		   @delivery_slip_headers = DeliverySlipHeader.find(delivery_slip_detail_middle_classification.delivery_slip_header_id)
	      
		   #件名
		   @report.page.item(:construction_name).value(@delivery_slip_headers.construction_name) 
		 
		   #納品No
		   if @delivery_slip_headers.delivery_slip_code.present?
		     @report.page.item(:delivery_slip_code).value(@delivery_slip_headers.delivery_slip_code) 
		   else
		   #納品Noが未入力の場合は、見積Noをそのまま出す。
		     @report.page.item(:delivery_slip_code).value(@delivery_slip_headers.delivery_slip_code) 
		   end
		   
		   if @delivery_slip_headers.delivery_slip_date.present?
             #@gengou = @delivery_slip_headers.delivery_slip_date
             #upd191204 サブルーチン化
             @gengou = ApplicationController.new.WesternToJapaneseCalendar(@delivery_slip_headers.delivery_slip_date)
             
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
             
             @report.page.item(:delivery_slip_date).value(@gengou) 
		   end
		   
           #品目名
		   @report.page.item(:working_large_item_name).value(delivery_slip_detail_middle_classification.DeliverySlipDetailLargeClassification.working_large_item_name)
           #add170308
           #仕様名
           @report.page.item(:working_large_specification).value(delivery_slip_detail_middle_classification.DeliverySlipDetailLargeClassification.working_large_specification)

		 end
		 
		    
				
		 @report.list(:default).add_row do |row|
		 
		   if @page_number != (@report.page_count - @estimation_sheet_pages) then
		      #保持用
			  @delivery_slip_price_save = @@delivery_slip_price
			  @execution_price_save = @@execution_price
			  @labor_productivity_unit_save = @@labor_productivity_unit
			  
			  if @delivery_slip_price_save > 0
			    @report.page.item(:message_sum_header).value("前頁より")
			    @report.page.item(:blackets1_header).value("(")
		        @report.page.item(:blackets2_header).value(")")
			    @report.page.item(:subtotal_header).value(@delivery_slip_price_save)
			    @report.page.item(:blackets3_header).value("(")
		        @report.page.item(:blackets4_header).value(")")
			    @report.page.item(:subtotal_execution_header).value(@execution_price_save)
			    @report.page.item(:blackets5_header).value("(")
		        @report.page.item(:blackets6_header).value(")")
			    @report.page.item(:subtotal_labor_header).value(@labor_productivity_unit_save)
			  end 
		   end 
		   @page_number = @report.page_count - @estimation_sheet_pages
				
		          #仕様の場合に数値・単位をnullにする
                  @quantity = delivery_slip_detail_middle_classification.quantity
                  if @quantity == 0 
                    @quantity = ""
                  end  
                  #add190903
                  #小数点以下１位があれば表示、なければ非表示
                  if @quantity.present?
                    @quantity = "%.4g" %  @quantity
                  end
                  @execution_quantity = delivery_slip_detail_middle_classification.execution_quantity
                  if @execution_quantity == 0 
                    @execution_quantity = ""
                  end  
                  #add190903
                  #小数点以下１位があれば表示、なければ非表示
                  if @execution_quantity.present?
                    @execution_quantity = "%.4g" %  @execution_quantity
                  end
				  if delivery_slip_detail_middle_classification.WorkingUnit.present?
				    @unit_name = delivery_slip_detail_middle_classification.WorkingUnit.working_unit_name
                  else
				    @unit_name = delivery_slip_detail_middle_classification.working_unit_name
				  end
				 
                  if @unit_name == "<手入力>"
					if delivery_slip_detail_middle_classification.working_unit_name != "<手入力>"
                      @unit_name = delivery_slip_detail_middle_classification.working_unit_name
					else 
					  @unit_name = ""
					end
                  end 
                  
                  if delivery_slip_detail_middle_classification.delivery_slip_price.present?
				    if delivery_slip_detail_middle_classification.construction_type.to_i != $INDEX_SUBTOTAL  #add 170308
				      tmp = delivery_slip_detail_middle_classification.delivery_slip_price.delete("^0-9").to_i
					  if tmp > 0
                        num = delivery_slip_detail_middle_classification.delivery_slip_price.to_i
					  else
					    num = tmp
					  end
					  #
					  @@delivery_slip_price += num
				    end
				  end
                  #実行金額合計
                  if delivery_slip_detail_middle_classification.execution_price.present?
                    if delivery_slip_detail_middle_classification.construction_type.to_i != $INDEX_SUBTOTAL  #add 170308
				      #@@execution_price += delivery_slip_detail_middle_classification.execution_price
					  #upd170220
					  tmp = delivery_slip_detail_middle_classification.execution_price.delete("^0-9").to_i
					  if tmp > 0
                         num = delivery_slip_detail_middle_classification.execution_price.to_i
					  else
					     num = tmp
					  end
					  #
					  @@execution_price += num
                    end
                  end
                  
				  #del 170308
				  #@labor_amount = 0
                  #if delivery_slip_detail_middle_classification.execution_quantity.present?
				  #  if delivery_slip_detail_middle_classification.execution_quantity >= 0
                  #     if delivery_slip_detail_middle_classification.labor_productivity_unit.present?
				  #  	  @labor_amount = delivery_slip_detail_middle_classification.execution_quantity * delivery_slip_detail_middle_classification.labor_productivity_unit
                  #        #合計へカウント
				  #  	  @@labor_productivity_unit += @labor_amount
				#     end
                  #  end
				  #end
				  #  
				  
                  #add170308
				  #小計、値引きの場合は項目を単価欄に表示させる為の分岐
				  case delivery_slip_detail_middle_classification.construction_type.to_i
				  when $INDEX_SUBTOTAL, $INDEX_DISCOUNT
				    item_name = ""
					unit_price_or_notices = delivery_slip_detail_middle_classification.working_middle_item_name
					execution_unit_price_or_notices = delivery_slip_detail_middle_classification.working_middle_item_name
					@quantity = ""
					@unit_name = ""
					#歩掛りの計も表示させる
					if delivery_slip_detail_middle_classification.labor_productivity_unit_total != blank?
					  @labor_amount = delivery_slip_detail_middle_classification.labor_productivity_unit_total
                    end
					#
				  else
                    item_name = delivery_slip_detail_middle_classification.working_middle_item_name
					unit_price_or_notices = delivery_slip_detail_middle_classification.working_unit_price
					execution_unit_price_or_notices = delivery_slip_detail_middle_classification.execution_unit_price
					
					 #upd170308
					 if delivery_slip_detail_middle_classification.labor_productivity_unit_total != blank?
					    @labor_amount = delivery_slip_detail_middle_classification.labor_productivity_unit_total.to_f
						  
						#合計へカウント
						@@labor_productivity_unit += @labor_amount
					 end
				  end
				  #
				  
				  
				  if @labor_amount == 0
                     @labor_amount = ""
                  end
				  
                  row.values working_middle_item_name: item_name,
                   working_middle_specification: delivery_slip_detail_middle_classification.working_middle_specification, 
                   quantity: @quantity,
                   working_unit_name: @unit_name,
                   working_unit_price: unit_price_or_notices,
                   delivery_slip_price: delivery_slip_detail_middle_classification.delivery_slip_price,
                   quantity2: @execution_quantity,
                   working_unit_name2: @unit_name,
                   execution_unit_price: execution_unit_price_or_notices,
                   execution_price: delivery_slip_detail_middle_classification.execution_price,
                   labor_productivity_unit: delivery_slip_detail_middle_classification.labor_productivity_unit,
				   labor_amount: @labor_amount, remarks: delivery_slip_detail_middle_classification.remarks
				
		  end
		 
		  
		  #頁番号
          #(＊単独モジュールと違う箇所)
		  page_number = @report.page_count - @estimation_sheet_pages
         
		  page_count = "(" +  page_number.to_s + ")"
		  @report.page.item(:page_number).value(page_count)
		  
		   @report.page.item(:message_sum).value("次頁へ")
		   
		   @report.page.item(:blackets1).value("(")
		   @report.page.item(:blackets2).value(")")
		   
		   @report.page.item(:subtotal).value(@@delivery_slip_price)
		   
		   @report.page.item(:blackets3).value("(")
		   @report.page.item(:blackets4).value(")")
		   
		   @report.page.item(:subtotal_execution).value(@@execution_price )
		   
		   #歩掛り合計
		   @report.page.item(:blackets5).value("(")
		   @report.page.item(:blackets6).value(")")
		   
		   @report.page.item(:subtotal_labor).value(@@labor_productivity_unit )
		
    end	
     
	   @report.page.item(:message_sum).value("計")
		
		#@page_number2 = @report.page_count - @estimation_sheet_pages
		#if @page_number != @page_number2 then
		#end
		##
		
		#カッコを消す
		@report.page.item(:blackets1).value(" ")
		@report.page.item(:blackets2).value(" ")
		@report.page.item(:blackets3).value(" ")
		@report.page.item(:blackets4).value(" ")
		@report.page.item(:blackets5).value(" ")
		@report.page.item(:blackets6).value(" ")
		
		
  end

end


