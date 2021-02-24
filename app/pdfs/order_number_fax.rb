class OrderNumberFaxPDF
    
  
  def self.create order_number_fax
	#注文番号fax用PDF発行
 
       
       # tlfファイルを読み込む
       report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/order_number_fax_pdf.tlf")
       
		# 1ページ目を開始
       report.start_new_page
	
	   #$purchase_order_data
	   
	   
       $purchase_order_data.each do |purchase_order_data| 
	  	 
		#---見出し---
          
	    report.page.item(:order_no).value(purchase_order_data.purchase_order_code)
		   
           
		   #report.page.item(:working_safety_matter_name).value(construction_datum.working_safety_matter_name)
		 
		   #作業日・作業者
		   #report.page.item(:working_date).value($working_date)
		   #report.page.item(:staff_name).value($staff_name)
		 
            #report.list(:default).add_row do |row|
			#           row.values purchase_order_code: purchase_datum.purchase_order_datum.purchase_order_code,
			#	              material_code: purchase_datum.material_code
        	#end 
        end	
		
        # ThinReports::Reportを返す
        return report
		
  end  
  
 
end
   
  
 
