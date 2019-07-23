class ConstructionCostSummaryPDF
    
  
  def self.create construction_cost_summary	
	#仕入表PDF発行
      
      #新元号対応 190401
      require "date"
      d_heisei_limit = Date.parse("2019/5/1")
      
      #@@page_number = 0
      #report = ThinReports::Report.create do |report|
	  
	  #binding.pry
       
      # tlfファイルを読み込む
      if $print_type_costs != "1"
        report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/construction_cost_summary_pdf.tlf")
      else
	  #工事集計PDF用  add180118
	    report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/construction_cost_summary_black_pdf.tlf")
	   
	  end
       #report = ThinReports::Report.create do |r|
	  
	  # 1ページ目を開始
      report.start_new_page
      
	  @flag = nil
		 
	 #初期化
	 @purchase_order_code  = ""
	 @purchase_amount_subtotal = 0
	 @purchase_amount_total = 0
	
      #$purchase_data.joins(:purchase_order_datum).order("purchase_order_code, purchase_date, id").each do |purchase_datum| 
	  
	  #$construction_costs.each do |construction_costs| 
	  construction_costs = $construction_costs
	  
	
	   
		 #---見出し---
         page_count = report.page_count.to_s + "頁"

		 if @flag.nil? 
		 
		    @flag = "1"
		   
		   construction_code = "No."  #工事ナンバーに"No"をつける
		   if construction_costs.construction_datum.construction_code.present?
		     construction_code = construction_code + construction_costs.construction_datum.construction_code
		   end
		   
		   report.page.item(:construction_code).value(construction_code)
		   report.page.item(:construction_name).value(construction_costs.construction_datum.construction_name)
		   report.page.item(:customer_name).value(construction_costs.construction_datum.CustomerMaster.customer_name)
		 
		   #発行日
		   @gengou = Date.today
           
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
           
           report.page.item(:issue_date).value(@gengou)
		   
           
		   #最終作業日
		   null_date = Date.parse("2000/1/1")
           
           #if construction_costs.construction_datum.construction_end_date.present?
           if construction_costs.construction_datum.construction_end_date.present? && 
              construction_costs.construction_datum.construction_end_date != null_date
           
             @gengou = construction_costs.construction_datum.construction_end_date
		     
             if @gengou >= d_heisei_limit
             #令和
               if @gengou.year - $gengo_minus_ad_2 == 1
                 @gengou = $gengo_name_2 + "元年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
               else
                 @gengou = $gengo_name_2 + "#{@gengou.year - $gengo_minus_ad_2}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
               end
             else
             #平成
               @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		     end
             
             report.page.item(:construction_end_date).value(@gengou) 
		   
           else
             
             @gengou = "　　　　　　　"
             report.page.item(:construction_end_date).value(@gengou)
           
           end
		   
		 end
	
	    
		 #フッター
		 report.list(:default).on_footer_insert do |footer|
		 #list.on_page_footer_insert do |page_footer|  #ページフッターの場合。
           
		   #仕入金額計
		   if construction_costs.purchase_amount.present? && construction_costs.purchase_amount > 0
             footer.item(:purchase_amount).value(construction_costs.purchase_amount)
		   end
		   
		   #消耗品雑材料
		   if construction_costs.supplies_expense.present? && construction_costs.supplies_expense > 0
		     footer.item(:supplies_expense).value(construction_costs.supplies_expense)
		   end
		   
		   #小計2(仕入＋消耗品)
		   subtotal2 = 0
		   if construction_costs.purchase_amount.present?
		     subtotal2 = construction_costs.purchase_amount
		   end
		   if construction_costs.supplies_expense.present?
		     subtotal2 = subtotal2 + construction_costs.supplies_expense
		   end
		   if subtotal2 > 0
		     footer.item(:subtotal2).value(subtotal2)
		   end
		   #
		   
		   #労務費
		   if construction_costs.labor_cost.present? && construction_costs.labor_cost > 0
		     footer.item(:labor_cost).value(construction_costs.labor_cost)
		   end
		   
		   #小計3(小計2+労務費)
		   if construction_costs.labor_cost.present?
		     subtotal3 = subtotal2 + construction_costs.labor_cost
		   end 
		   if subtotal3.present? && subtotal3 > 0
		     footer.item(:subtotal3).value(subtotal3)
		   end
		   #
		   
		   #諸経費
		   if construction_costs.misellaneous_expense.present? && construction_costs.misellaneous_expense > 0
		     footer.item(:misellaneous_expense).value(construction_costs.misellaneous_expense)
		   end
         end
	
			#i = 0
		    purchase_order_detail = construction_costs.purchase_order_amount.split(",")
			
			cnt = (purchase_order_detail.length) -1 
		
            if cnt >= 0
			  (0..cnt).step(4) do |i|
			    
				report.list(:default).add_row do |row|
		             
					 #仕入名称-"出庫"のみ記載を変更する。
					 purchase_order_name = purchase_order_detail[i]
					 if purchase_order_detail[i] == "出庫"
					   purchase_order_name = "在庫分"
					 end
					 
					  row.values purchase_order_name: purchase_order_name,
					             supplier_name: purchase_order_detail[i+1],
								 purchase_order_code: purchase_order_detail[i+2],
								 purchase_price: purchase_order_detail[i+3]
		             #i =+ 4
			    end 
			  end
			end
		
		 #最下部の合計欄
		 if construction_costs.execution_amount.present?
		   report.page.item(:execution_amount).value(construction_costs.execution_amount)
		 end
		 if construction_costs.constructing_amount.present?
		   report.page.item(:constructing_amount).value(construction_costs.constructing_amount)
		 end
		 
		 #差額
		 difference = 0
		 if construction_costs.constructing_amount.present? && construction_costs.constructing_amount >= 0
           difference = construction_costs.constructing_amount
		   if construction_costs.execution_amount.present?
		     difference = difference - construction_costs.execution_amount
		   end
		   report.page.item(:difference).value(difference)
		 end
         
		 
    #end	
	
	#end
        # Thinrs::Reportを返す
        return report
	#end
  end  
   
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
