class CustomerListCardPDF
    
  
  def self.create customer_list_card	
    #工事一覧表PDF発行
 
    # tlfファイルを読み込む
    report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/customer_list_card_pdf.tlf")
    
    
	# 1ページ目を開始
    report.start_new_page
     
    @flag = nil
		 
        #初期化
        #@purchase_order_code  = ""
        #@purchase_amount_subtotal = 0
        #@purchase_amount_total = 0
        #$purchase_data.joins(:purchase_order_datum).order("purchase_order_code, purchase_date, id").each do |purchase_datum|
        #$customer.order("construction_code desc").each do |construction_datum|

    $customers.each do |customer| 
	  	 
		#---見出し---
        page_count = report.page_count.to_s + "頁"
		report.page.item(:page_no).value(page_count)

		 #if @flag.nil? 
		 #   @flag = "1"
		 #end
		
         #if customer.reception_date.present?
		 #   @reception_date = setGenGouDate(customer.reception_date)
         #end
		   
		    report.list(:default).add_row do |row|
			     #billed_flag = false
				 #if customer.billed_flag != nil && customer.billed_flag > 0
				 #  billed_flag = true
				 #end
				 
				 
			     row.values ID: customer.id, customer_name: customer.customer_name,
                            post: customer.post, address: customer.address,
                            house_number: customer.house_number, tel: customer.tel_main,
                            fax: customer.fax_main, responsible: customer.responsible1
					        #reception_date: @reception_date,
                            #construction_name: customer.construction_name,
							#customer_code: customer.CustomerMaster.id,
                            #customer_name: customer.CustomerMaster.customer_name
				 
                 #row.item(:frame).styles(:fill_color => '#F7BE81')  if billed_flag == true
				 
                 if $print_flag_customer == "2"
                 #年賀状確認用
                    if customer.card_not_flag == 1
                        row.item(:line_through).visible(true)
                    end
                 end
                 
				 #縦線は再描画させないと描写されない
				 #row.item(:line_1).styles(:fill_color => '#F7BE81')
			     #row.item(:line_2).styles(:fill_color => '#F7BE81')
				 #row.item(:line_3).styles(:fill_color => '#F7BE81')
				 #row.item(:line_4).styles(:fill_color => '#F7BE81')

			end 
			
		 
		
    end	
		
        # ThinReports::Reportを返す
        return report
		
  end  
   
end
   
def setGenGouDate(inDate)
  gengouDate = inDate
  gengouDate = $gengo_name + "#{gengouDate.year - $gengo_minus_ad}年#{gengouDate.strftime('%-m')}月#{gengouDate.strftime('%-d')}日"

  return gengouDate
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
