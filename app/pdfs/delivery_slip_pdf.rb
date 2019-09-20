class DeliverySlipPDF
    
  
  #def self.create delivery_slip	
  #upd170626
  def self.create delivery_slip_detail_large_classifications
	#納品書PDF発行
       #新元号対応 190401
       require "date"
       d_heisei_limit = Date.parse("2019/5/1")
       
       # tlfファイルを読み込む
       if $print_type == "1"
         @report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/delivery_slip_pdf.tlf")
       else
         @report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/delivery_slip_signed_pdf.tlf")
       end
	   
		# 1ページ目を開始
        @report.start_new_page
	    @flag = nil 
		
       #$delivery_slip_detail_large_classifications.order(:line_number).each do |delivery_slip_detail_large_classification|
       #upd170626
       delivery_slip_detail_large_classifications.order(:line_number).each do |delivery_slip_detail_large_classification| 
	  	 
		 #---見出し---
		 
		 if @flag.nil? 
		 
		    @flag = "1"
		   
		   @delivery_slip_headers = DeliverySlipHeader.find(delivery_slip_detail_large_classification.delivery_slip_header_id)
	     
		 
		   #郵便番号
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
		   #@report.page.item(:address).value(@delivery_slip_headers.address) 
		   @report.page.item(:address).value(all_address) 
		   #
		   
		   
		   #得意先名
		   #upd170809
		   @report.page.item(:customer_name).value(@delivery_slip_headers.customer_master.customer_name) 
           
		   #敬称
		   honorific_name = CustomerMaster.honorific[0].find{0}  #"様"
		   
		   if @delivery_slip_headers.honorific_id == 1   #"御中?
		     id = @delivery_slip_headers.honorific_id
			 honorific_name = CustomerMaster.honorific[id].find{id} #"御中"
		   end
		   @report.page.item(:honorific).value(honorific_name) 
		   
		   #担当1
		   #upd190131
           if @delivery_slip_headers.ConstructionDatum.present? && 
                !@delivery_slip_headers.ConstructionDatum.personnel.blank?
             responsible = @delivery_slip_headers.ConstructionDatum.personnel + "  様"
		     @report.page.item(:responsible1).value(responsible)
           end
           #if @delivery_slip_headers.responsible1.present?
		   #  responsible = @delivery_slip_headers.responsible1 + "  様"
		   #  @report.page.item(:responsible1).value(responsible)
		   #end
		   #担当2
		   if @delivery_slip_headers.responsible2.present?
		     responsible = @delivery_slip_headers.responsible2 + "  様"
		     @report.page.item(:responsible2).value(responsible)
		   end
		   #####
		   
		   #件名
		   @report.page.item(:construction_name).value(@delivery_slip_headers.construction_name) 
		 
		   #納品No
		   if @delivery_slip_headers.delivery_slip_code.present?
		     @report.page.item(:delivery_slip_code).value(@delivery_slip_headers.delivery_slip_code)
		   else
		     @report.page.item(:delivery_slip_code).value(@delivery_slip_headers.delivery_slip_code)
		   end
		   
           #消費税
           date_per_ten_start = Date.parse("2019/10/01")   #消費税１０％開始日  add190824
           
           #税込見積合計金額	 
		   if @delivery_slip_headers.delivery_amount.present?
             #if @delivery_slip_headers.delivery_slip_date < date_per_ten_start
             #upd190919
             if @delivery_slip_headers.delivery_slip_date.nil? || @delivery_slip_headers.delivery_slip_date < date_per_ten_start
             #消費税8%
               @delivery_amount_tax_in = @delivery_slip_headers.delivery_amount * $consumption_tax_include  
             else
             #消費税10%
               @delivery_amount_tax_in = @delivery_slip_headers.delivery_amount * $consumption_tax_include_per_ten
             end
             @report.page.item(:delivery_amount_tax_in).value(@delivery_amount_tax_in) 
		   end
		   
		   #消費税
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
             @report.page.item(:delivery_amount_tax_only).value(@delivery_amount_tax_only) 
		   end
		   
           
           #add 190723
           #工事期間
		   @report.page.item(:construction_period).value(@delivery_slip_headers.construction_period) 
		 
		   #住所（工事場所）
		   all_address = ""
           if @delivery_slip_headers.construction_post.present?
             all_address = @delivery_slip_headers.construction_post + "　"
           end
           #
           
           all_address += @delivery_slip_headers.construction_place
		   if @delivery_slip_headers.construction_house_number.present?
		     all_address += @delivery_slip_headers.construction_house_number
		   end
		   if @delivery_slip_headers.construction_place2.present?
		     all_address += "　" + @delivery_slip_headers.construction_place2
		   end
		   @report.page.item(:construction_place).value(all_address) 
		   #add end
           
           
           
           #納品日
		   if @delivery_slip_headers.delivery_slip_date.present?
		     @gengou = @delivery_slip_headers.delivery_slip_date
		    
             #元号変わったらここも要変更
             if @gengou >= d_heisei_limit
             #令和
               if @gengou.year - $gengo_minus_ad_2 == 1
               #１年の場合は元年と表記
                 @gengou = $gengo_name_2 + "元年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
               else
                 @gengou = $gengo_name_2 + "#{@gengou.year - $gengo_minus_ad_2}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
               end
             else
             #平成
               @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		     end
             @report.page.item(:delivery_slip_date).value(@gengou) 
		   else
            #空でも文字を出す 
             #empty_string =  $gengo_name + "　　" + "年" + "　　" + "月" + "　　" + "日"
             #upd190920
             empty_string =  $gengo_name_2 + "　　" + "年" + "　　" + "月" + "　　" + "日"
             @report.page.item(:delivery_slip_date).value(empty_string) 
           end
		   
		   #NET金額
		   #if @delivery_slip_headers.net_amount.present?
		   #  @net_amount = "(" + @delivery_slip_headers.net_amount.to_s(:delimited, delimiter: ',') + ")" 
		   #  @report.page.item(:message_net).value("NET")
		   #  @report.page.item(:net_amount).value(@net_amount)
		   #end
		   
		   #小計(見積金額) 
		   #本来ならフッターに設定するべきだが、いまいちわからないため・・
		   @report.page.item(:delivery_amount).value(@delivery_slip_headers.delivery_amount)
		   
		 end
		 
		   @report.list(:default).add_row do |row|
		  
                      #仕様の場合に数値・単位をnullにする
                      @quantity = delivery_slip_detail_large_classification.quantity
                      if @quantity == 0 
                        @quantity = ""
                      end  
                      
                      #add190903
                      if @quantity.present?
                        @quantity = "%.2g" %  @quantity
                      end
					  if delivery_slip_detail_large_classification.WorkingUnit.present?
					    @unit_name = delivery_slip_detail_large_classification.WorkingUnit.working_unit_name
					  else 
					    @unit_name = delivery_slip_detail_large_classification.working_unit_name
                      end
					  
					  #if @unit_name == "-"
                      if @unit_name == "<手入力>"
					    if delivery_slip_detail_large_classification.working_unit_name != "<手入力>"
                          @unit_name = delivery_slip_detail_large_classification.working_unit_name
						else
						  @unit_name = ""
						end
                      end 
                      #  
                      #add170310
					  #小計、値引きの場合は項目を単価欄に表示させる為の分岐
					  case delivery_slip_detail_large_classification.construction_type.to_i
					    when $INDEX_SUBTOTAL, $INDEX_DISCOUNT
                          item_name = ""
						  unit_price_or_notices = delivery_slip_detail_large_classification.working_large_item_name
						  @quantity = ""
						  @unit_name = ""
						else
                          item_name = delivery_slip_detail_large_classification.working_large_item_name
						  unit_price_or_notices = delivery_slip_detail_large_classification.working_unit_price
					  end
					  #
					  
					  #明細欄出力
                      #upd170308
                      row.values working_large_item_name: item_name,
                       working_large_specification: delivery_slip_detail_large_classification.working_large_specification,
                       quantity: @quantity,
		               working_unit_name: @unit_name,
					   working_unit_price: unit_price_or_notices,
                       delivery_slip_price: delivery_slip_detail_large_classification.delivery_slip_price
           end 
	end	
        
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
	 
	 #内訳データでループ
     #$delivery_slip_detail_large_classifications.order(:line_number).each do |delivery_slip_detail_large_classification|
     #upd 170626
     @delivery_slip_detail_large_classifications.order(:line_number).each do |delivery_slip_detail_large_classification|
	   delivery_slip_header_id = delivery_slip_detail_large_classification.delivery_slip_header_id
	   delivery_slip_detail_large_classification_id =  delivery_slip_detail_large_classification.id
	    
       #$delivery_slip_detail_middle_classifications = DeliverySlipDetailMiddleClassification.where(:delivery_slip_header_id => delivery_slip_header_id).
       #                                          where(:delivery_slip_detail_large_classification_id => delivery_slip_detail_large_classification_id).where("id is NOT NULL")
       #upd170626
       @delivery_slip_detail_middle_classifications = DeliverySlipDetailMiddleClassification.where(:delivery_slip_header_id => delivery_slip_header_id).
                                                 where(:delivery_slip_detail_large_classification_id => delivery_slip_detail_large_classification_id).where("id is NOT NULL")

	   #内訳書PDF発行(A4横ver)
	   #if $delivery_slip_detail_middle_classifications.present?
	   #upd170626
	   if @delivery_slip_detail_middle_classifications.present?
	     self.delivery_slip_detailed_statement
	   end
	 end
  end
  def self.delivery_slip_detailed_statement
  #内訳書PDF発行(A4縦ver)
      
	 #新元号対応 190401
       require "date"
       d_heisei_limit = Date.parse("2019/5/1")

      @@delivery_slip_price = 0
    
	  # 1ページ目を開始
      @report.start_new_page layout: "#{Rails.root}/app/pdfs/delivery_slip_detailed_statement_pdf.tlf"
	   
	   
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
      #upd171206 
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
             @gengou = @delivery_slip_headers.delivery_slip_date
		     
             #元号変わったらここも要変更
             if @gengou >= d_heisei_limit
             #令和
               if @gengou.year - $gengo_minus_ad_2 == 1
               #１年の場合は元年と表記
                 @gengou = $gengo_name_2 + "元年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
               else
                 @gengou = $gengo_name_2 + "#{@gengou.year - $gengo_minus_ad_2}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
               end
             else
             #平成
               @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		     end
             
             @report.page.item(:delivery_slip_date).value(@gengou) 
		   else
            #空でも文字を出す 
             #empty_string =  $gengo_name + "　　" + "年" + "　　" + "月" + "　　" + "日"
             #upd190920
             empty_string =  $gengo_name_2 + "　　" + "年" + "　　" + "月" + "　　" + "日"
             @report.page.item(:delivery_slip_date).value(empty_string) 
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
			  
			  if @delivery_slip_price_save > 0
			    @report.page.item(:message_sum_header).value("前頁より")
			    @report.page.item(:blackets1_header).value("(")
		        @report.page.item(:blackets2_header).value(")")
			    @report.page.item(:subtotal_header).value(@delivery_slip_price_save)
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
                    @quantity = "%.2g" %  @quantity
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
                  #  
                  #add170308
				  #小計、値引きの場合は項目を単価欄に表示させる為の分岐
				  case delivery_slip_detail_middle_classification.construction_type.to_i
				  when $INDEX_SUBTOTAL, $INDEX_DISCOUNT
                    item_name = ""
					unit_price_or_notices = delivery_slip_detail_middle_classification.working_middle_item_name
					@quantity = ""
					@unit_name = ""
				  else
                    item_name = delivery_slip_detail_middle_classification.working_middle_item_name
					unit_price_or_notices = delivery_slip_detail_middle_classification.working_unit_price
				  end
				  #
					  
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
                  
                  row.values working_middle_item_name: item_name,
                   working_middle_specification: delivery_slip_detail_middle_classification.working_middle_specification, 
                   quantity: @quantity,
                   working_unit_name: @unit_name,
                   working_unit_price: unit_price_or_notices,
                   delivery_slip_price: delivery_slip_detail_middle_classification.delivery_slip_price
		    
    	  end
		  
          #頁番号
		  page_number = @report.page_count - @estimation_sheet_pages
		  
          
		  page_count = "(" +  page_number.to_s + ")"
		  @report.page.item(:page_number).value(page_count)
		  
		   @report.page.item(:message_sum).value("次頁へ")
		   
		   @report.page.item(:subtotal).value(@@delivery_slip_price )
		   
		   @report.page.item(:blackets1).value("(")
		   @report.page.item(:blackets2).value(")")
		   
		  
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


