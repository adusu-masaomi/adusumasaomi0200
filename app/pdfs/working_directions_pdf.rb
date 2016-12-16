class WorkingDirectionsPDF
    
  
  def self.create working_directions
	#作業指示書PDF発行
 
       # tlfファイルを読み込む
       report = ThinReports::Report.new(layout: "#{Rails.root}/app/pdfs/working_directions_pdf.tlf")
       
		# 1ページ目を開始
        report.start_new_page
    
		# テーブルの値を設定
        # list に表のIDを設定する(デフォルトのID値: default)
        # add_row で列を追加できる
        # ブロック内のrow.valuesで値を設定する
	  
	   #@flag = nil
	   #初期化
	   #@purchase_order_code  = ""
	   #@purchase_amount_subtotal = 0
	   #@purchase_amount_total = 0
	
	
	   construction_datum = $construction_datum
	   
	   
       #$construction_datum.order(:construction_code).each do |construction_datum| 
	  	 
		 #---見出し---
          
		  #着工・完了日未入力の場合の非表示処理。
          period_start = "" 
          if construction_datum.construction_period_start != nil && construction_datum.construction_period_start.strftime("%Y/%m/%d") != "2021/01/01" then
            period_start = construction_datum.construction_period_start.strftime("%Y/%m/%d")
          end
          period_end = "" 
          if construction_datum.construction_period_end != nil && construction_datum.construction_period_end.strftime("%Y/%m/%d") != "2021/01/01" then
            period_end = construction_datum.construction_period_end.strftime("%Y/%m/%d")
          end
		 
		 #if @flag.nil? 
		   #@flag = "1"
		   report.page.item(:issue_date).value(Date.today)
		   report.page.item(:construction_code).value(construction_datum.construction_code)
		   report.page.item(:construction_name).value(construction_datum.construction_name)
		   report.page.item(:customer_name).value(construction_datum.CustomerMaster.customer_name)
           report.page.item(:construction_period_start).value(period_start)
           report.page.item(:construction_period_end).value(period_end)
           report.page.item(:construction_place).value(construction_datum.construction_place)
           report.page.item(:construction_detail).value(construction_datum.construction_detail)
           report.page.item(:attention_matter).value(construction_datum.attention_matter)
		   report.page.item(:working_safety_matter_name).value(construction_datum.working_safety_matter_name)
		 
            #report.list(:default).add_row do |row|
			#           row.values purchase_order_code: purchase_datum.purchase_order_datum.purchase_order_code,
			#	              material_code: purchase_datum.material_code
        	#end 
    #end	
		
        # ThinReports::Reportを返す
        return report
		
  end  
   
end
   
  
 
