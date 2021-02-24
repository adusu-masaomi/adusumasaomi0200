class ConstructionCostFinalListPDF
    
  
  def self.create construction_final_list	
	#工事一覧表PDF発行
       #新元号対応 
       require "date"
       @d_heisei_limit = Date.parse("2019/5/1")
  
 
       # tlfファイルを読み込む
       report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/construction_cost_final_list_pdf.tlf")
       
	  	# 1ページ目を開始
        report.start_new_page
     
        @flag = nil
		 
        $construction_costs.joins(:construction_datum).order("construction_code").each do |construction_cost| 
	  	 
		#---見出し---
        page_count = report.page_count.to_s + "頁"
		report.page.item(:page_no).value(page_count)

		 #if @flag.nil? 
		 #   @flag = "1"
		 #end
		
         #確定申告区分がある場合のみ出力
         if construction_cost.final_return_division.present? 
		    report.list(:default).add_row do |row|
			     
                 #確定申告区分
                 final_return_division = ""
                 #if construction_cost.final_return_division.present? 
				     final_return_division = ConstructionCost.final_division[construction_cost.final_return_division][0]
			    #end
			     #
                 
			     row.values construction_code: construction_cost.construction_datum.construction_code,
					        construction_name: construction_cost.construction_datum.construction_name,
							final_return_division: final_return_division,
                            customer_name: construction_cost.construction_datum.CustomerMaster.customer_name
				 
                 #row.item(:frame).styles(:fill_color => '#F7BE81')  if billed_flag == true
				 
				 #縦線は再描画させないと描写されない
				 row.item(:line_1).styles(:fill_color => '#F7BE81')
			     row.item(:line_2).styles(:fill_color => '#F7BE81')
				 row.item(:line_3).styles(:fill_color => '#F7BE81')
				 row.item(:line_4).styles(:fill_color => '#F7BE81')

			end 
		 end
		 
		
    end	
		
        # ThinReports::Reportを返す
        return report
		
  end  
   
end
   
   
def setGenGouDate(inDate)
  gengouDate = inDate
  
  #元号変わったらここも要変更
  if gengouDate >= @d_heisei_limit
  #令和
    if gengouDate.year - $gengo_minus_ad_2 == 1
    #１年の場合は元年と表記
      gengouDate = $gengo_name_2 + "元年#{gengouDate.strftime('%-m')}月#{gengouDate.strftime('%-d')}日"
    else
      gengouDate = $gengo_name_2 + "#{gengouDate.year - $gengo_minus_ad_2}年#{gengouDate.strftime('%-m')}月#{gengouDate.strftime('%-d')}日"
    end
  else
  #平成
    gengouDate = $gengo_name + "#{gengouDate.year - $gengo_minus_ad}年#{gengouDate.strftime('%-m')}月#{gengouDate.strftime('%-d')}日"
  end
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
