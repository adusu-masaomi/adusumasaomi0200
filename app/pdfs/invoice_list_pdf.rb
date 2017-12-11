class InvoiceListPDF
    
  
  def self.create invoice_list	
	#請求一覧PDF発行
 
       #@@page_number = 0
     
	 
     # tlfファイルを読み込む
     #report = ThinReports::Report.new(layout: "#{Rails.root}/app/pdfs/invoice_list_pdf.tlf")
	 report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/invoice_list_pdf.tlf")
       
	  	# 1ページ目を開始
     report.start_new_page
      
	 @flag = nil

     #初期化
     @biling_amount_subtotal = 0
	 @biling_amount_total = 0
	 @commission_subtotal = 0
	 @commission_total = 0
	 
     @month = ""
	 @last_month = ""
	 @year = ""
	 
	 #$purchase_data.joins(:purchase_order_datum).order("purchase_order_code, purchase_date, id").each do |invoice_header|
     #$invoice_headers.order("invoice_date, customer_id, construction_datum_id").each do |invoice_header|
     $invoice_headers.order("invoice_code").each do |invoice_header| 
        
         #---見出し---
		 #dt = Time.now.strftime('%Y/%m/%d %H:%M:%S')
		 dt = Time.now.strftime('%Y/%m/%d')
		 dt = dt + " 現在"
		 
		 report.page.item(:issue_date).value(dt)
		 
         page_count = report.page_count.to_s + "頁"
		 report.page.item(:page_no).value(page_count)

         report.page.item(:invoice_date_start).value($invoice_date_start)
         report.page.item(:invoice_date_end).value($invoice_date_end)
		 
		 if @flag.nil? 
		 
		   @flag = "1"
		  
		 end
		
          #binding.pry
		    
		    report.list(:default).add_row do |row|
			      
			  #請求金額をフォーマット
			  #@num = invoice_header.billing_amount
			  #formatNum()
			  #billing_amount = @num
			  #入金金額をフォーマット
			  @num = invoice_header.deposit_amount
			  formatNum()
			  deposit_amount = @num
			  #
			  #手数料をフォーマット
			  @num = invoice_header.commission
			  formatNum()
			  commission = @num
			  #入金予定日をフォーマット
			  payment_date_formatted = ""
			  if invoice_header.payment_date.present?
			    gengou = invoice_header.payment_date
		        payment_date_formatted = $GENGO_ALPHABET + "#{gengou.year - $gengo_minus_ad}.#{gengou.strftime('%-m')}.#{gengou.strftime('%-d')}"
		      end
			  #支払方法
			  payment_method = ""
			  
			  if invoice_header.payment_method_id.present?
			    payment_method = InvoiceHeader.payment_method[invoice_header.payment_method_id][0]
			  end
			  
			 #現金以外なら、手数料ない場合はスペースではなくゼロを明示する
			 #add170728
			 if invoice_header.payment_method_id.present? && invoice_header.payment_method_id > 0
                            if commission == ""
			      commission = "￥0"
				end
			  end
			  
			  
			  if invoice_header.invoice_date.present?
			    invoice_date = invoice_header.invoice_date
			  else
			  #請求日未入力の場合
			    invoice_date = Date.new(0001, 01, 01)
			  end
			  
			  if @month != "" && (invoice_date.year == @year && invoice_date.mon != @month) 
				#月ごとの小計
				
			    set_subtotal
				
				
			    report.list(:default).add_row  note: @note,
						     billing_amount: @biling_amount_subtotal_formatted,
							 commission: @commission_subtotal_formatted
				
							 
			    @biling_amount_subtotal = 0
				@commission_subtotal = 0
			    
			
              else
			    row.item(:line_upper).visible(false)
				row.item(:line_lower).visible(false)
			    #row.item(:rect).style(:border_width, 1)
			  
		        #同一月でも、最終ページ判定用に変数保存
				if invoice_date.present?
			      @last_month = invoice_date.mon
				else
				  @last_month = ""
				end
				
			  end
		  
		
				
			  #
		      if @year != "" && invoice_date.year != @year 
			  #年ごとの小計(年またがりを考慮)
			    set_total
				
				report.list(:default).add_row  note: @note,
			                 billing_amount: @biling_amount_total_formatted,
                             commission: @commission_total_formatted
				@biling_amount_subtotal = 0
				@biling_amount_total = 0
				@commission_subtotal = 0
				@commission_total = 0
				
			  end
			  #
			  if invoice_header.billing_amount.present?
			    #請求金額は「税込」を使用する
			    billing_amount_with_tax = invoice_header.billing_amount * $consumption_tax_include
			    #四捨五入する
			    billing_amount_with_tax = billing_amount_with_tax.round(0)
			  else
			  #請求金額未入力の場合
			    billing_amount_with_tax = 0
			  end
			  
			  #小計用にカウント
			  @biling_amount_subtotal += billing_amount_with_tax
			  #合計用にカウント
			  @biling_amount_total += billing_amount_with_tax
			  
			  #請求金額をフォーマット
			  @num = billing_amount_with_tax
			  formatNum()
			  billing_amount_with_tax = @num
			  
			  
			  if invoice_header.commission.present?
			    #小計用にカウント(手数料)
			  	@commission_subtotal += invoice_header.commission
			    #合計用にカウント(手数料)
			    @commission_total += invoice_header.commission
			  end
			  #
			  #row.item(:rect).style(:border_width, 1)
			  row.item(:line_upper).visible(false)
			  row.item(:line_lower).visible(false)
			  
			  #明細行出力
			  row.values invoice_code: invoice_header.invoice_code,
			             invoice_date: invoice_date,
					     customer_name: invoice_header.customer_name,
                         construction_name: invoice_header.construction_name,
                         billing_amount: billing_amount_with_tax,
						 deposit_amount: deposit_amount,
						 payment_method: payment_method,
						 commission: commission,
                         payment_date: payment_date_formatted,
						 remarks: invoice_header.remarks
			   
			  #小計判定用
			  if invoice_date.present?
			    @month = invoice_date.mon
			    @year = invoice_date.year
              end
				
            end 


	end	
#end   
        #add170302 最終ページの出力はここで定義する
        page_count = report.page_count.to_s + "頁"
        report.page.item(:page_no).value(page_count)
       
	    if @last_month ==  @month 
		#小計
		  
		  set_subtotal
		  
	      report.list(:default).add_row  note: @note,
						   billing_amount: @biling_amount_subtotal_formatted,
			               commission: @commission_subtotal_formatted
        end
		#合計
		set_total
		
        report.list(:default).add_row  note: @note,
						   billing_amount: @biling_amount_total_formatted,
						   commission: @commission_total_formatted
					   
	
		
        # ThinReports::Reportを返す
        return report
		
  end  
   
end
   
  def set_subtotal
    
    @note = @year.to_s + "年" + @month.to_s + "月" + "　計"
	#
	@num = @biling_amount_subtotal
	formatNum()
	@biling_amount_subtotal_formatted = @num
	#
	@num = @commission_subtotal
	formatNum()
	@commission_subtotal_formatted = @num
	#

  
  end
  
  def set_total
    
    @note = @year.to_s + "年" + "　合計"
	#
	@num = @biling_amount_total
	formatNum()
	@biling_amount_total_formatted = @num
    #
	@num = @commission_total
	formatNum()
	@commission_total_formatted = @num
	#
	
  end
   
    def formatNum()
	    
        if @num.present?
          #整数で四捨五入する
		  @num  = @num.round
		  
		  #桁区切りにする
		  @num  = @num.to_s(:delimited, delimiter: ',')
		else
		  @num  = "0"
        end
		# 円マークをつける
        if @num  == "0"
		  @num  = ""
		else
		  @num  = "￥" + @num 
		end
	end  
