class QuotationOrderFaxPDF
    
  
  #def self.create quotation_order_fax
  def self.create(quotation_material_header, purchase_order_code, supplier, responsible)
	#見積fax用PDF発行
 
    # tlfファイルを読み込む
    report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/quotation_order_fax_pdf.tlf")
       
	# 1ページ目を開始
    report.start_new_page
	
	#---見出し---
    #report.page.item(:construction_name).value($purchase_order_datum.alias_name)
      
    report.page.list(:default).header do |header|
      
      #担当者
      header.item(:supplier_name).value(quotation_material_header.supplier_master.supplier_name)
      #header.item(:supplier_responsible_name).value(quotation_material_header.supplier_master.responsible1)
      header.item(:supplier_responsible_name).value(responsible)
      
      #注文番号
      header.item(:purchase_order_code).value(purchase_order_code)
      #工事名
      header.item(:construction_name).value(quotation_material_header.construction_datum.construction_name)
      ##注文金額
      #header.item(:total_order_price).value(total_order_price)
    end
    
    #明細取得
    @quotation_material_details = QuotationMaterialDetail.
                   where(:quotation_material_header_id => quotation_material_header.id).where("id is NOT NULL")
                   #where(:quotation_material_header_id => $quotation_material_header.id).where("id is NOT NULL")
    
    if @quotation_material_details.present?
      
      cnt = 0
      
      @total_order_price = 0
      @unit_price = 0
      @price = 0
      
      @quotation_material_details.each do |quotation_material_detail| 
      
        #if isBidSupplier(quotation_material_detail) == true
        if isBidSupplier(quotation_material_detail, supplier) == true
          cnt += 1
          cnt_str = cnt.to_s + "."
        
          #見積フラグがあれば本来計上させないが、計上する。
          #２回以上(追伸)の見積もり送信を考慮しない...
        
          #定価
          #list_price = 0
          #@num = quotation_material_detail.list_price
          #formatNum
          #list_price = @num
          #
          
          #単価
          @num = @unit_price
          formatNum
          @unit_price = @num
          
          #金額
          @num = @price
          formatNum
          @price = @num
          
          report.list(:default).add_row do |row|
	           row.values no: cnt_str, material_code: quotation_material_detail.material_code,
		              material_name: quotation_material_detail.material_name,
                      maker_name: quotation_material_detail.maker_name,
                      quantity: quotation_material_detail.quantity,
                      unit_name: quotation_material_detail.unit_master.unit_name,
                      unit_price: @unit_price,
                      price: @price
          end 
        
        end
      end
    end
    
    #注文金額合計
    @num = @total_order_price
    formatNum
    @total_order_price = @num
    
    report.page.list(:default).header do |header|
      header.item(:total_order_price).value(@total_order_price)  
    end
    # ThinReports::Reportを返す
    return report
		
  end  
  
  
end

#落札した業者の判定、単価もセット
def isBidSupplier(quotation_material_detail, supplier)
  
  isBid = false
  
  #case $supplier
  case supplier
    when 1
      if quotation_material_detail.bid_flag_1 == 1
        isBid = true
        @unit_price = quotation_material_detail.quotation_unit_price_1
        @price = quotation_material_detail.quotation_price_1
        #合計金額
        @total_order_price += @price
      end
    when 2
      if quotation_material_detail.bid_flag_2 == 1
        isBid = true
        @unit_price = quotation_material_detail.quotation_unit_price_2
        @price = quotation_material_detail.quotation_price_2
        @total_order_price += @price
      end
    when 3
      if quotation_material_detail.bid_flag_3 == 1
        isBid = true
        @unit_price = quotation_material_detail.quotation_unit_price_3
        @price = quotation_material_detail.quotation_price_3
        @total_order_price += @price
      end
  end
  
  
  
  return isBid
end

#数値を符号付きの文字に変換
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
end  
 
