class InvoicePDF
    
  
  #def self.create invoice
  #upd170626
  def self.create invoice_detail_large_classifications
	#請求書PDF発行
 
       #新元号対応 190401
       require "date"
       d_heisei_limit = Date.parse("2019/5/1")
 
       # tlfファイルを読み込む
	   #if $print_type == "1"
     case $print_type
     when "1"
     #請求書(印鑑なし)
         @report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/invoice_pdf.tlf")
	   #else
     when "3"
     #請求書（印鑑有）
	     @report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/invoice_signed_pdf.tlf")
     when "4"
     #旧様式
	     @report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/invoice_signed_simple_pdf.tlf")
	   end
	   
		# 1ページ目を開始
        @report.start_new_page
	    
        @flag = nil
		
    invoice_detail_large_classifications.order(:line_number).each do |invoice_detail_large_classification| 
	  	 
		 #---見出し---
		 
		 if @flag.nil? 
		 
		   @flag = "1"
		   
		   @invoice_header = InvoiceHeader.find(invoice_detail_large_classification.invoice_header_id)
	     
		   #郵便番号(得意先)
		   @report.page.item(:post).value(@invoice_header.post) 
		 
		   #住所(得意先)
		   #分割された住所を一つにまとめる。
		   all_address = @invoice_header.address
		   if @invoice_header.house_number.present?
		     all_address += @invoice_header.house_number
		   end
		   if @invoice_header.address2.present?
		     all_address += "　" + @invoice_header.address2
		   end
		   @report.page.item(:address).value(all_address) 
		   #
		   
		   #得意先名
		   @report.page.item(:customer_name).value(@invoice_header.customer_master.customer_name) 
           
		   #敬称
		   honorific_name = CustomerMaster.honorific[0].find{0}  #"様"
		   
		   if @invoice_header.honorific_id == 1   #"御中?
		     id = @invoice_header.honorific_id
			   honorific_name = CustomerMaster.honorific[id].find{id} #"御中"
		   end
		   @report.page.item(:honorific).value(honorific_name) 
		   
		   #件名
		   @report.page.item(:construction_name).value(@invoice_header.construction_name) 
		 
		   #請求No
		   if @invoice_header.invoice_code.present?
		     @report.page.item(:invoice_code).value(@invoice_header.invoice_code) 
       else
		   #請求Noが未入力の場合は、見積Noをそのまま出す。
		   #  @report.page.item(:invoice_code).value(@invoice_header.invoice_code) 
       end
		   
       #add210419
       #税抜見積金額
       @report.page.item(:billing_amount_no_tax).value(@invoice_header.billing_amount)
       
       #税込見積合計金額	 
       date_per_ten_start = Date.parse("2019/10/01")   #消費税１０％開始日  add190824
       
       @billing_amount_tax_in = 0
 
		   if @invoice_header.billing_amount.present?
         if !(@invoice_header.invoice_date.nil?) && @invoice_header.invoice_date < date_per_ten_start
         #消費税8%の場合 
           @billing_amount_tax_in = @invoice_header.billing_amount * $consumption_tax_include
		     elsif @invoice_header.invoice_date.nil?
         #日付ブランクなら現在日付で判定(add191031)
           if Date.today < date_per_ten_start
           #8%の場合
             @billing_amount_tax_in = @invoice_header.billing_amount * $consumption_tax_include
           else
             #10%の場合。変更時はさらに分岐させる
             @billing_amount_tax_in = @invoice_header.billing_amount * $consumption_tax_include_per_ten
           end
         else
         #消費税10%の場合 
           @billing_amount_tax_in = @invoice_header.billing_amount * $consumption_tax_include_per_ten
         end
             
         @report.page.item(:billing_amount_tax_in).value(@billing_amount_tax_in) 
		   end
		   
		   #消費税のみ金額
		   if @invoice_header.billing_amount.present?
		     
         if !(@invoice_header.invoice_date.nil?) && @invoice_header.invoice_date < date_per_ten_start
           #消費税8%の場合
           @billing_amount_tax_only = @invoice_header.billing_amount * $consumption_tax_only
         elsif @invoice_header.invoice_date.nil?
           #日付ブランクなら現在日付で判定(add191031)
           if Date.today < date_per_ten_start
           #8%の場合
             @billing_amount_tax_only = @invoice_header.billing_amount * $consumption_tax_only
           else
           #10%の場合。変更時はさらに分岐させる
             @billing_amount_tax_only = @invoice_header.billing_amount * $consumption_tax_only_per_ten
           end
         else
           #消費税10%の場合
           @billing_amount_tax_only = @invoice_header.billing_amount * $consumption_tax_only_per_ten
         end  
             
		     @report.page.item(:billing_amount_tax_only).value(@billing_amount_tax_only) 
		   end
		   
       #add210420
       #前回請求額等を取得する
       get_before_amount
       
       transffered_amount = 0
       
       #前回請求額をセット
       if !@deposit_complete_flag
         #前回繰越額
         transffered_amount = @before_billing_amount - @before_deposit_amount
         
         if transffered_amount > 0  #前回繰越がある場合のみ出力
           #前回請求額
           @report.page.item(:before_billing_amount).value(@before_billing_amount) 
           #前回入金額
           if @before_deposit_amount.present? && @before_deposit_amount > 0
             @report.page.item(:before_deposit_amount).value(@before_deposit_amount) 
           end
           #前回繰越額(カラムなし)
           @report.page.item(:transffered_amount).value(transffered_amount) 
         end
       end
       
       #今回請求額(カラムなし) --> 税込請求額 + 前回繰越額
       billing_amount_lately = @billing_amount_tax_in + transffered_amount
       @report.page.item(:billing_amount_lately).value(billing_amount_lately) 
       #
       
		   #対象期間(開始)
		   if @invoice_header.invoice_period_start_date.present?
		     @gengou = @invoice_header.invoice_period_start_date
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
             
         @report.page.item(:invoice_period_start_date).value(@gengou)
       end
		   
		   #対象期間(終了)
		   if @invoice_header.invoice_period_end_date.present?
		     @gengou = @invoice_header.invoice_period_end_date
		     
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
             
         @report.page.item(:invoice_period_end_date).value(@gengou)
		   end
	
		   #支払期限
		   @report.page.item(:payment_period).value(@invoice_header.payment_period) 
		 
		   if @invoice_header.invoice_date.present?
		     @gengou = @invoice_header.invoice_date
             
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
             
         @report.page.item(:invoice_date).value(@gengou) 
		   else
         #空でも文字を出す 
         empty_string =  $gengo_name_2 + "　　" + "年" + "　　" + "月" + "　　" + "日"
         @report.page.item(:invoice_date).value(empty_string) 
       end
		   
		   #小計(請求金額) 
		   @report.page.item(:billing_amount).value(@invoice_header.billing_amount)
		   
		 end
		 
     #---end 見出し---
     
		 @report.list(:default).add_row do |row|
		  
        #仕様の場合に数値・単位をnullにする
        @quantity = invoice_detail_large_classification.quantity
        if @quantity == 0 
          @quantity = ""
        end  
			  #add190903
                      #小数点以下１位があれば表示、なければ非表示
                      if @quantity.present? 
                      	@quantity = "%.2g" %  @quantity
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
                      #add170310
                      #小計、値引きの場合は項目を単価欄に表示させる為の分岐
                      case invoice_detail_large_classification.construction_type.to_i
                      when $INDEX_SUBTOTAL, $INDEX_DISCOUNT
                          item_name = ""
                          unit_price_or_notices = invoice_detail_large_classification.working_large_item_name
                          @quantity = ""
                          @unit_name = ""
                      else
                          item_name = invoice_detail_large_classification.working_large_item_name
						  unit_price_or_notices = invoice_detail_large_classification.working_unit_price
					  end
					  #

                      #明細欄出力
                      #upd170308
                      row.values working_large_item_name: item_name,
                       working_large_specification: invoice_detail_large_classification.working_large_specification,
                       quantity: @quantity,
		               working_unit_name: @unit_name,
					   working_unit_price: unit_price_or_notices,
                       invoice_price: invoice_detail_large_classification.invoice_price
           end 
	end	
        
		#add170626
		@invoice_detail_large_classifications = invoice_detail_large_classifications
		
        #内訳のデータも取得・出力
        set_detail_data
       
        # Thin@reports::@reportを返す
        return @report
		
		
    
  end
  def self.set_detail_data
     
	 #請求書(表紙)のページ番号をマイナスさせるためのカウンター。
	 @estimation_sheet_pages = @report.page_count 
	 
	 #内訳データでループ
	 #$invoice_detail_large_classifications.order(:line_number).each do |invoice_detail_large_classification|
	 #upd170626
	 @invoice_detail_large_classifications.order(:line_number).each do |invoice_detail_large_classification|
	   invoice_header_id = invoice_detail_large_classification.invoice_header_id
	   invoice_detail_large_classification_id =  invoice_detail_large_classification.id
	    
       #$invoice_detail_middle_classifications = InvoiceDetailMiddleClassification.where(:invoice_header_id => invoice_header_id).
       #                                          where(:invoice_detail_large_classification_id => invoice_detail_large_classification_id).where("id is NOT NULL")
       #upd170626
	   @invoice_detail_middle_classifications = InvoiceDetailMiddleClassification.where(:invoice_header_id => invoice_header_id).
                                                 where(:invoice_detail_large_classification_id => invoice_detail_large_classification_id).where("id is NOT NULL")
												 
	   
	   #内訳書PDF発行(A4横ver)
	   #if $invoice_detail_middle_classifications.present?
	   #upd170626
	   if @invoice_detail_middle_classifications.present?
	     self.invoice_detailed_statement
	   end
	 end
  end
  def self.invoice_detailed_statement
  #内訳書PDF発行(A4縦ver)
      
      #新元号対応 190401
      require "date"
      d_heisei_limit = Date.parse("2019/5/1")
	  
      @@invoice_price = 0
    
	  # 1ページ目を開始
      @report.start_new_page layout: "#{Rails.root}/app/pdfs/invoice_detailed_statement_pdf.tlf"
	   
	   
	  @flag = nil

      #$invoice_detail_middle_classifications.order(:line_number).each do |invoice_detail_middle_classification|
      #upd170626
      @invoice_detail_middle_classifications.order(:line_number).each do |invoice_detail_middle_classification| 
      
      	 #---見出し---
		 
		 if @flag.nil? 
		   
		   @flag = "1"
		   
		   @invoice_header = InvoiceHeader.find(invoice_detail_middle_classification.invoice_header_id)
	       
		   #件名
		   @report.page.item(:construction_name).value(@invoice_header.construction_name) 
		 
		   #請求No
		   if @invoice_header.invoice_code.present?
		     @report.page.item(:invoice_code).value(@invoice_header.invoice_code) 
           else
		   #請求Noが未入力の場合は、見積Noをそのまま出す。
		     @report.page.item(:invoice_code).value(@invoice_header.invoice_code)
           end
		   
		   if @invoice_header.invoice_date.present?
             @gengou = @invoice_header.invoice_date
		     
             #元号変わったらここも要変更
             if @gengou >= d_heisei_limit
             #令和
               if @gengou.year - $gengo_minus_ad_2 == 1
               #１年の場合は元年と表記
                 @gengou_2 = $gengo_name + "元年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
               else
                 @gengou_2 = $gengo_name + "#{@gengou.year - $gengo_minus_ad_2}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		       end
             else
             #平成
               @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
             end
             
             @report.page.item(:invoice_date).value(@gengou) 
		   else
             #空でも文字を出す 
             #empty_string =  $gengo_name + "　　" + "年" + "　　" + "月" + "　　" + "日"
             empty_string =  $gengou_2 + "　　" + "年" + "　　" + "月" + "　　" + "日"
             @report.page.item(:invoice_date).value(empty_string) 
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
				  #add190903
                  #小数点以下１位があれば表示、なければ非表示
                  if @quantity.present?
                    @quantity = "%.2g" %  @quantity
                  end
                  
				  if invoice_detail_middle_classification.WorkingUnit.present?
                    @unit_name = invoice_detail_middle_classification.WorkingUnit.working_unit_name
                  else
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
                  	  
                  row.values working_middle_item_name: invoice_detail_middle_classification.working_middle_item_name,
                   working_middle_specification: invoice_detail_middle_classification.working_middle_specification, 
                   quantity: @quantity,
                   working_unit_name: @unit_name,
                   working_unit_price: invoice_detail_middle_classification.working_unit_price,
                   invoice_price: invoice_detail_middle_classification.invoice_price
		    
    	  end
		  
          #頁番号
		  page_number = @report.page_count - @estimation_sheet_pages
		  
		  page_count = "(" +  page_number.to_s + ")"
		  @report.page.item(:page_number).value(page_count)
		  
		  @report.page.item(:message_sum).value("次頁へ")
		   
		  @report.page.item(:subtotal).value(@@invoice_price )
		   
		  @report.page.item(:blackets1).value("(")
		  @report.page.item(:blackets2).value(")")
		   
    end	
      
	   @report.page.item(:message_sum).value("計")
	   #カッコを消す
		@report.page.item(:blackets1).value(" ")
		@report.page.item(:blackets2).value(" ")
		
  end
  
  #前回請求額等を取得する
  def self.get_before_amount
    @invoice_header_extract = InvoiceHeader.where(["customer_id = ?", @invoice_header.customer_id]).where.not( id: @invoice_header.id)
    
    cnt = 0
    max_count = 3  #前回３回まで見ることとする
    
    @deposit_complete_flag = true  #入金完了フラグ
    @before_billing_amount = 0     #前回請求額
    @before_deposit_amount = 0     #前回入金額
    
    @invoice_header_extract.order('invoice_code desc').each do |invoice_header|
      cnt += 1
      if cnt > max_count
        break
      end
      
      #入金フラグなし？
      if invoice_header.deposit_complete_flag.nil? || invoice_header.deposit_complete_flag == 0
        if invoice_header.invoice_code < @invoice_header.invoice_code #あくまでも前回までの請求コードで照合する
          @deposit_complete_flag = false
        
          #請求金額を税込みでカウント
          if invoice_header.billing_amount.present?
            billing_amount = invoice_header.billing_amount * $consumption_tax_include_per_ten
            @before_billing_amount += billing_amount
          end
          #入金額を手数料込みでカウント
          commission = 0
          if invoice_header.commission.present?
            commission += invoice_header.commission
          end
          if invoice_header.deposit_amount.present?
            @before_deposit_amount += invoice_header.deposit_amount + commission
          end
        
        end
      end
    end
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


