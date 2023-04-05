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
	 
     #binding.pry
     
     
	 #$purchase_data.joins(:purchase_order_datum).order("purchase_order_code, purchase_date, id").each do |invoice_header|
     #$invoice_headers.order("invoice_date, customer_id, construction_datum_id").each do |invoice_header|
     
     #モデルのページングの制限があるので、ここで(limit)解除させる--年２００件として２０年間くらいを最大とする
     $invoice_headers.order("invoice_code").limit(5000).each do |invoice_header| 
        
         
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
			  
              
              #備考欄の背景色(非表示)
              row.item(:fmeSituation).visible(false)
              
              #add180719
              #得意先の背景色(非表示)
              row.item(:fmeCustomer).visible(false)
              row.item(:lineDelete).visible(false)
              
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
		        
                #新元号対応 190401
                require "date"
                d_heisei_limit = Date.parse("2019/5/1");
                
                if gengou >= d_heisei_limit
                #新元号
                    payment_date_formatted = $GENGO_ALPHABET_2 + "#{gengou.year - $gengo_minus_ad_2}.#{gengou.strftime('%-m')}.#{gengou.strftime('%-d')}"
                
                else
                #平成
                    payment_date_formatted = $GENGO_ALPHABET + "#{gengou.year - $gengo_minus_ad}.#{gengou.strftime('%-m')}.#{gengou.strftime('%-d')}"
		        end
                #
                
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
			  
              #月ごとの小計
              
              #同じ年で月が異なるor
              #12月で年月が異なる
              
              ###
              is_subtotal = false
              if @month != "" && (invoice_date.year == @year && invoice_date.mon != @month)
                is_subtotal = true
              end
              if @year != "" 
                if @year == 2022  #法人なりした月
                  if @month == 10 && invoice_date.mon != @month
                    is_subtotal = true
                  end
                elsif @year > 2022 #法人後の粘度は、９月決算となる
                  if @month == 9 && invoice_date.mon != @month
                    is_subtotal = true
                  end
                elsif @year < 2022
                  if @month == 12 && (invoice_date.year > @year && invoice_date.mon != @month)
                    is_subtotal = true
                  end
                end
              end
              ##
              
              #12月の計が出ないバグ修正(upd180417)
              if (@month != "" && (invoice_date.year == @year && invoice_date.mon != @month)) ||
                 (@month == 12 && (invoice_date.year > @year && invoice_date.mon != @month))
				        
                #binding.pry
				
			          set_subtotal
				
				#report.list(:default).add_row  note: @note,
				#		     billing_amount: @biling_amount_subtotal_formatted,
				#			 commission: @commission_subtotal_formatted
                
                #upd180331
                report.list(:default).add_row do |row2|
                       row2.values  note: @note,
						            billing_amount: @biling_amount_subtotal_formatted,
							        commission: @commission_subtotal_formatted
				       #add180331
                       row2.item(:fmeSituation).visible(false)
                       row2.item(:fmeCustomer).visible(false)
                       row2.item(:lineDelete).visible(false)
				      end
             
			    @biling_amount_subtotal = 0
				@commission_subtotal = 0
			    
			
              else
			    row.item(:line_upper).visible(false)
				row.item(:line_lower).visible(false)
                row.item(:lineDelete).visible(false)
			    #row.item(:rect).style(:border_width, 1)
			  
		        #同一月でも、最終ページ判定用に変数保存
				if invoice_date.present?
			      @last_month = invoice_date.mon
				else
				  @last_month = ""
				end
				
			  end
		     
        #upd230217
        #法人成りのため集計区分変更
		    is_total = false
        
        if @year != "" 
          if @year == 2022  #法人なりした月
            if invoice_date.month != @month && @month == 10
              is_total = true
            end
          elsif @year > 2022 #法人後の粘度は、９月決算となる
            if invoice_date.month != @month && @month == 9
              is_total = true
            end
          elsif @year < 2022
            
            if invoice_date.year != @year
              is_total = true
            end
          end
        end
        #
        
			  #
        #if @year != "" && invoice_date.year != @year 
        if is_total
        #年ごとの小計(年またがりを考慮)
              
          set_total
				
				#report.list(:default).add_row  
                #             row.values note: @note,
			    #             billing_amount: @biling_amount_total_formatted,
                #             commission: @commission_total_formatted
                
          report.list(:default).add_row do |row2| 
                       row2.values note: @note,
			                 billing_amount: @biling_amount_total_formatted,
                             commission: @commission_total_formatted
                        #add180331
                       row2.item(:fmeSituation).visible(false)
                       row2.item(:fmeCustomer).visible(false)
                       row2.item(:lineDelete).visible(false)
          end
                
          @biling_amount_subtotal = 0
				  @biling_amount_total = 0
				  @commission_subtotal = 0
				  @commission_total = 0
				
			  end
              
              date_per_ten_start = Date.parse("2019/10/01")
              
			  #
			  if invoice_header.billing_amount.present?
			    
                #請求金額は「税込」を使用する
                #請求日によって税率を切り分ける
                if !(invoice_header.invoice_date.nil?) && invoice_header.invoice_date < date_per_ten_start
                  #8%の場合
                  billing_amount_with_tax = invoice_header.billing_amount * $consumption_tax_include
                elsif invoice_header.invoice_date.nil?
                  #日付ブランクなら現在日付で判定(add191031)
                  if Date.today < date_per_ten_start
                  #8%の場合
                    billing_amount_with_tax = invoice_header.billing_amount * $consumption_tax_include
                  else
                  #10%の場合。変更時はさらに分岐させる
                    billing_amount_with_tax = invoice_header.billing_amount * $consumption_tax_include_per_ten
                  end
                else
                #10%の場合
                  billing_amount_with_tax = invoice_header.billing_amount * $consumption_tax_include_per_ten
                end
                
                
                #請求金額は「税込」を使用する
			    #billing_amount_with_tax = invoice_header.billing_amount * $consumption_tax_include
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
              row.item(:lineDelete).visible(false)
			  
              
              #未入金のものに背景色をつける
              if invoice_header.invoice_code.present? && invoice_header.payment_date.blank?
                row.item(:fmeSituation).visible(true)
              end
              
              final_return_division = ""
              
              #add180719
              #元請業者の色つけ（印刷フラグがある場合のみ）
              if $print_flag_invoice == "1"
                  #元請業者には赤系の色をつける
                  if invoice_header.customer_master.present?
                    if invoice_header.customer_master.contractor_flag == 1
                        row.item(:fmeCustomer).visible(true)
                    end
                  end
                  #労働保険対象外は取り消し線入れる
                  if invoice_header.labor_insurance_not_flag == 1
                    row.item(:lineDelete).visible(true)
                  end
              elsif $print_flag_invoice == "2"
                #確定申告用
                if invoice_header.final_return_division.present? && invoice_header.final_return_division > 0
                  final_return_division = ConstructionCost.final_division[invoice_header.final_return_division][0]
                end
              end
              
              #sample .....
              # 入庫の場合は入庫と表示
		      #if purchase_datum.inventory_division_id.present? && InventoryHistory.inventory_division[purchase_datum.inventory_division_id.to_i][1] == 0
			  #  division_name = InventoryHistory.inventory_division[purchase_datum.inventory_division_id.to_i][0]
			  #else
		      #  division_name = purchase_datum.PurchaseDivision.purchase_division_name
			  #end
			  #
              
              
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
						 remarks: invoice_header.remarks,
                         final_return_division: final_return_division
			   
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
       
	    if @last_month ==  @month  #単月で検索した場合
		    #小計
		    set_subtotal
		  
	      #report.list(:default).add_row  note: @note,
		  #       billing_amount: @biling_amount_subtotal_formatted,
		  #                 commission: @commission_subtotal_formatted
          
          report.list(:default).add_row  do |row2|
                   row2.values note: @note,
						   billing_amount: @biling_amount_subtotal_formatted,
			               commission: @commission_subtotal_formatted
                   row2.item(:fmeSituation).visible(false)
                   row2.item(:fmeCustomer).visible(false)
                   row2.item(:lineDelete).visible(false)
          end
      end
		  
      #合計
		  set_total
		
        #report.list(:default).add_row  note: @note,
		#				   billing_amount: @biling_amount_total_formatted,
		#				   commission: @commission_total_formatted
        #upd180331
        report.list(:default).add_row do |row2|
                row2.values note: @note,
						    billing_amount: @biling_amount_total_formatted,
						    commission: @commission_total_formatted
                row2.item(:fmeSituation).visible(false)
                row2.item(:fmeCustomer).visible(false)
                row2.item(:lineDelete).visible(false)
	    end
	
		
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
    
    #
    @term = @year
    if @year == 2022
    #11月以降、次年度となる
      if @month > 10
        @term = @year + 1
      end
    elsif @year > 2022
    #10月以降、次年度となる
      if @month > 9
        @term = @year + 1
      end
    else
    #そのまま
      @term = @year
    end
    #
    
    #@note = @year.to_s + "年" + "　合計"
    #@note = @term.to_s + "年度" + "　合計"
    @note = @term.to_s + "年度" + "  合計"
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
