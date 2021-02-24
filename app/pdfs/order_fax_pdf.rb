class OrderFaxPDF
    
  
  def self.create order_fax
	#注文fax用PDF発行
 
    # tlfファイルを読み込む
    report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/order_fax_pdf.tlf")
       
	# 1ページ目を開始
    report.start_new_page
	
	#purchase_order_data = $purchase_order_data
	    
	#---見出し---
          
	#report.page.item(:construction_name).value($purchase_order_datum.alias_name)
    
      
    report.page.list(:default).header do |header|
    
      header.item(:supplier_name).value($purchase_order_history.supplier_master.supplier_name)
      header.item(:supplier_responsible_name).value($purchase_order_history.supplier_master.responsible1)
      #注文番号
      header.item(:order_no).value($purchase_order_history.purchase_order_datum.purchase_order_code)
	  #工事名
      header.item(:construction_name).value($purchase_order_history.purchase_order_datum.construction_datum.construction_name)
    end
    
    #注文でループ
    @orders = Order.where(:purchase_order_history_id => $purchase_order_history.id).where("id is NOT NULL")
   
    if @orders.present?
      
      cnt = 0
      
      @orders.each do |order| 
      
        cnt += 1
        cnt_str = cnt.to_s + "."
        
        report.list(:default).add_row do |row|
	           row.values no: cnt_str, material_code: order.material_code,
		              material_name: order.material_name,
                      maker_name: order.maker_master.maker_name,
                      quantity: order.quantity,
                      unit_name: order.unit_master.unit_name
        end 
      end
    end
    	
    # ThinReports::Reportを返す
    return report
		
  end  
  
 
end
   
  
 
