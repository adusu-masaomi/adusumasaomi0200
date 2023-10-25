class QuotationFaxPDF
    
  
  #def self.create quotation_fax
  def self.create(quotation_material_header, responsible)
	#見積fax用PDF発行
 
    # tlfファイルを読み込む
    report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/quotation_fax_pdf.tlf")
       
	# 1ページ目を開始
    report.start_new_page
	
	    
	#---見出し---
    #report.page.item(:construction_name).value($purchase_order_datum.alias_name)
      
    report.page.list(:default).header do |header|
      #$quotation_material_headerをとった(230509)
      
      header.item(:supplier_name).value(quotation_material_header.supplier_master.supplier_name)
      #header.item(:supplier_responsible_name).value(quotation_material_header.supplier_master.responsible1)
      header.item(:supplier_responsible_name).value(responsible)
      #注文番号
      header.item(:quotation_code).value(quotation_material_header.quotation_code)
	  #工事名
      header.item(:construction_name).value(quotation_material_header.construction_datum.construction_name)
    end
    
    #明細取得
    @quotation_material_details = QuotationMaterialDetail.
                   where(:quotation_material_header_id => quotation_material_header.id).where("id is NOT NULL")
    
    if @quotation_material_details.present?
      
      cnt = 0
      
      @quotation_material_details.each do |quotation_material_detail| 
      
        cnt += 1
        cnt_str = cnt.to_s + "."
        
        #見積フラグがあれば本来計上させないが、計上する。
        #２回以上(追伸)の見積もり送信を考慮しない...
        list_price = nil
        @num = nil
        
        if quotation_material_detail.list_price.present?
          list_price = quotation_material_detail.list_price
          @num = list_price
          formatNum
        end
        list_price = @num
        
        report.list(:default).add_row do |row|
	           row.values no: cnt_str, material_code: quotation_material_detail.material_code,
		              material_name: quotation_material_detail.material_name,
                      maker_name: quotation_material_detail.maker_name,
                      quantity: quotation_material_detail.quantity,
                      unit_name: quotation_material_detail.unit_master.unit_name,
                      list_price: list_price
        end 
      end
    end
    	
    # ThinReports::Reportを返す
    return report
		
  end  
  
  
end
   
def formatNum
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
    
    #return num
end  
 
