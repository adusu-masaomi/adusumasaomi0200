class ConstructionListPDF
    
  
  def self.create construction_list	
	#工事一覧表PDF発行
 
       # tlfファイルを読み込む
       report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/construction_list_pdf.tlf")
       
	  	# 1ページ目を開始
        report.start_new_page
     
        @flag = nil
		 
        #初期化
        #@purchase_order_code  = ""
        #@purchase_amount_subtotal = 0
        #@purchase_amount_total = 0

        #$purchase_data.joins(:purchase_order_datum).order("purchase_order_code, purchase_date, id").each do |purchase_datum|
        $construction_data.order("construction_code desc").each do |construction_datum| 
	  	 
		#---見出し---
        page_count = report.page_count.to_s + "頁"
		report.page.item(:page_no).value(page_count)

		 #if @flag.nil? 
		 #   @flag = "1"
		 #end
		
         if construction_datum.reception_date.present?
		    @reception_date = setGenGouDate(construction_datum.reception_date)
         #  @gengou = construction_datum.reception_date
		 #  @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		 end
		   
		    report.list(:default).add_row do |row|
			     billed_flag = false
				 if construction_datum.billed_flag != nil && construction_datum.billed_flag > 0
				   billed_flag = true
				 end
				 
				 
			     row.values construction_code: construction_datum.construction_code,
					        reception_date: @reception_date,
                            construction_name: construction_datum.construction_name,
							customer_code: construction_datum.CustomerMaster.id,
                            customer_name: construction_datum.CustomerMaster.customer_name
				 row.item(:frame).styles(:fill_color => '#F7BE81')  if billed_flag == true
				 
				 #縦線は再描画させないと描写されない
				 row.item(:line_1).styles(:fill_color => '#F7BE81')
			     row.item(:line_2).styles(:fill_color => '#F7BE81')
				 row.item(:line_3).styles(:fill_color => '#F7BE81')
				 row.item(:line_4).styles(:fill_color => '#F7BE81')

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
