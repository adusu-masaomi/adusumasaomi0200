class DetailedStatementPDF
    
  def self.create detailed_statement
	#内訳書PDF発行(A4縦ver)
      
	  
      @@quote_price = 0
    
	  # tlfファイルを読み込む
      report = ThinReports::Report.new(layout: "#{Rails.root}/app/pdfs/detailed_statement_pdf.tlf")


	  # 1ページ目を開始
      report.start_new_page
	   

	   
	  @flag = nil
	
	 
      $quotation_detail_middle_classifications.order(:line_number).each do |quotation_detail_middle_classification| 
      
      	 #---見出し---
		 
		 if @flag.nil? 
		   
		   @flag = "1"
		   
		   @quotation_headers = QuotationHeader.find(quotation_detail_middle_classification.quotation_header_id)
	       #得意先名
		   #report.page.item(:customer_name).value(@quotation_headers.customer_name) 
		 
		   #件名
		   report.page.item(:construction_name).value(@quotation_headers.construction_name) 
		 
		   #見積No
		   report.page.item(:quotation_code).value(@quotation_headers.quotation_code) 
		 
           @gengou = @quotation_headers.quotation_date
		   #元号変わったらここも要変更
		   @gengou = "平成#{@gengou.year - 1988}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		   report.page.item(:quotation_date).value(@gengou) 
		 
		   #品目名
		   report.page.item(:quotation_large_item_name).value(quotation_detail_middle_classification.QuotationDetailLargeClassification.quotation_large_item_name)
		   
		 end
		 
		
		 
		 report.list(:default).add_row do |row|
		          #仕様の場合に数値・単位をnullにする
                  @quantity = quotation_detail_middle_classification.quantity
                  if @quantity == 0 
                    @quantity = ""
                  end  
                  #@unit_name = quotation_detail_middle_classification.QuotationUnit.quotation_unit_name
				  @unit_name = quotation_detail_middle_classification.WorkingUnit.working_unit_name
                  
				  if @unit_name == "<手入力>"
                    @unit_name = ""
                  end 
					  
                  if quotation_detail_middle_classification.quote_price.present?
                    @@quote_price += quotation_detail_middle_classification.quote_price
                  end
                  	  
                  row.values quotation_middle_item_name: quotation_detail_middle_classification.quotation_middle_item_name,
                   quotation_middle_specification: quotation_detail_middle_classification.quotation_middle_specification, 
                   quantity: @quantity,
                   quotation_unit_name: @unit_name,
                   quotation_unit_price: quotation_detail_middle_classification.quotation_unit_price,
                   quote_price: quotation_detail_middle_classification.quote_price
		    
    	  end
		  
          #頁番号
          #デフォルトの頁番号をセット 
		  if $default_page_number > 0 
            page_number = report.page_count + ($default_page_number - 1 )
          else
		    page_number = report.page_count
		  end  
		  #page_count = "(" +  report.page_count.to_s + ")"
		  page_count = "(" +  page_number.to_s + ")"
		  report.page.item(:page_number).value(page_count)
		  
		  #数値→漢字へ変換する場合
          #@kanji = num_to_k(@@page_number)
          #@page_number = "(" + @kanji.to_s + "頁)"
		  
		   
		   #本来ならフッターに設定するべきだが、いまいちわからないため・・
		   report.page.item(:message_sum).value("次頁へ")
		   
		   #本来ならフッターに設定するべきだが、いまいちわからないため・・
		   report.page.item(:subtotal).value(@@quote_price )
		   
		   #end
    end	
     
    
  # フッタ作成時の処理
     #x.list(:table2) do 
     #  #binding.pry
     #  #events.on :page_footer_insert do |e|
     # on_page_footer_insert do |e|
     #    e.values subtotal: @@quote_price
	 # end
    #end 

      
	   report.page.item(:message_sum).value("計")
		   
        # ThinReports::Reportを返す
        return report


  end


  #漢数字を数字に変換  
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


