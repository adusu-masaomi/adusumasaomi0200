class BidComparisonListPDF
    
  @cheaper_flag_1 = false
  @cheaper_flag_2 = false
  
  def self.create bid_comparison_list
  #見積比較表PDF発行
 
      #@@page_number = 0
      #report = ThinReports::Report.create do |report|
	   
      # tlfファイルを読み込む
      report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/bid_comparison_list_pdf.tlf")
	   
	  # 1ページ目を開始
      report.start_new_page
      
	  @flag = nil
		 
	  #初期化
	  total_price_1 = 0
	  total_price_2 = 0
	  total_price_bid = 0
	  
    #add180925
    total_high_price = 0
    total_low_price = 0
    total_balance = 0
    #add end
    
	  quotation_material_header = $quotation_material_header
	  
		 #---見出し---
         page_count = report.page_count.to_s + "頁"

		 if @flag.nil? 
		 
		    @flag = "1"
		   
		   report.page.item(:quotation_code).value(quotation_material_header.quotation_code)
		   
#		   construction_code = "No."  #工事ナンバーに"No"をつける
		   if quotation_material_header.construction_datum.construction_code.present?
		     #construction_code = quotation_material_header.construction_datum.construction_code
         #upd180925 工事名にする
			   construction_name = quotation_material_header.construction_datum.construction_name
         report.page.item(:construction_name).value(construction_name)
		   end
		   
		   #発行日
		   @gengou = Date.today
		   @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		   report.page.item(:issue_date).value(@gengou)
		   
		   #仕入先１
		   if quotation_material_header.supplier_id_1.present?
		     supplier = SupplierMaster.find(quotation_material_header.supplier_id_1)
			 supplier_name = supplier.supplier_name
			 report.page.item(:supplier_name_1).value(supplier_name)
		   end
		   
		   #仕入先２
		   if quotation_material_header.supplier_id_2.present?
		     supplier = SupplierMaster.find(quotation_material_header.supplier_id_2)
			 supplier_name = supplier.supplier_name
			 report.page.item(:supplier_name_2).value(supplier_name)
		   end
		   

		 end
		
		   quotation_material_details = QuotationMaterialDetail.where(quotation_material_header_id: quotation_material_header.id)

           if quotation_material_details.present?
		   
             quotation_material_details.order("sequential_id desc").each do |quotation_material_detail| 
				report.list(:default).add_row do |row|

                     material_code = ""
                     material_name = ""
					 maker_name = ""
					 unit_name = ""
					 unit_price_1 = ""
					 unit_price_2 = ""
					 price_1 = ""
					 price_2 = ""
					 
					 if quotation_material_detail.material_code.present?
					   material_code = quotation_material_detail.material_code
					 end
					 if quotation_material_detail.material_name.present?
					   material_name = quotation_material_detail.material_name
					 end
					 #メーカー
					 if quotation_material_detail.maker_id.present?
					   maker_name = quotation_material_detail.maker_master.maker_name
					 end
					 #単位
					 if quotation_material_detail.unit_master_id.present?
					   unit_name = quotation_material_detail.unit_master.unit_name
					 end
					 
					 #単価
					 if quotation_material_detail.quotation_unit_price_1.present?
					   unit_price_1 = quotation_material_detail.quotation_unit_price_1
					   
             #del 180925
					   #落札分なら別途表示
					   #if quotation_material_detail.bid_flag_1 == 1
					   #  unit_price_bid = quotation_material_detail.quotation_unit_price_1
					   #end
					 end
					 if quotation_material_detail.quotation_unit_price_2.present?
					   unit_price_2 = quotation_material_detail.quotation_unit_price_2
					   
             #del 180925
					   #落札分なら別途表示
					   #if quotation_material_detail.bid_flag_2 == 1
					   #  unit_price_bid = quotation_material_detail.quotation_unit_price_2
					   #end
					 end
					 
           price_bid = 0
           
           #add180925
           #差額を求める
           if quotation_material_detail.quotation_unit_price_1.present? && 
              quotation_material_detail.quotation_unit_price_2.present? 
             
             #単価
             unit_price_bid = quotation_material_detail.quotation_unit_price_1 - 
                                 quotation_material_detail.quotation_unit_price_2
             #金額
             price_bid = quotation_material_detail.quotation_price_1 - 
                                 quotation_material_detail.quotation_price_2
                                 
             #金額合計
             
             #絶対値にする
             unit_price_bid = unit_price_bid.abs
             price_bid = price_bid.abs
             
             #
             
           end
           #
           
					 #del 180925
					 #単純に２社の価格を比較する(３社名は考慮していない) 
					 #(２社が同値なら、上記、落札フラグにより判定) 
					 #if quotation_material_detail.quotation_unit_price_1.to_i > 0 && 
					 #  quotation_material_detail.quotation_unit_price_1.to_i < quotation_material_detail.quotation_unit_price_2.to_i
					 #  unit_price_bid = quotation_material_detail.quotation_unit_price_1.to_i
					 #elsif quotation_material_detail.quotation_unit_price_2.to_i > 0 &&
					 #  quotation_material_detail.quotation_unit_price_2.to_i < quotation_material_detail.quotation_unit_price_1
					 #  unit_price_bid = quotation_material_detail.quotation_unit_price_2
					 #end
					 #
					 
					 #price_bid = 0
					 
           #金額
           if quotation_material_detail.quotation_price_1.present?
					   price_1 = quotation_material_detail.quotation_price_1
					 
           #del 180925
           #  #落札金額なら別途表示
					 #  if quotation_material_detail.bid_flag_1 == 1
					 #    price_bid = quotation_material_detail.quotation_price_1
					 #    #合計へもカウント
					 #    #total_price_bid += quotation_material_detail.quotation_price_1
					 #  end
					   #合計へもカウント
					   total_price_1 += quotation_material_detail.quotation_price_1
					 end
					 if quotation_material_detail.quotation_price_2.present?
					   price_2 = quotation_material_detail.quotation_price_2
					 
           #del 180925
           #   #落札金額なら別途表示
					 #  if quotation_material_detail.bid_flag_2 == 1
					 #    price_bid = quotation_material_detail.quotation_price_2
					 #  end
					   #合計へもカウント
					   total_price_2 += quotation_material_detail.quotation_price_2
					 end
					 
					 #単純に２社の価格を比較し、安い方をセットするる(３社名は考慮していない)
                     #(２社が同値なら、上記、落札フラグにより判定) 
					 if quotation_material_detail.quotation_price_1.to_i > 0 && 
					   quotation_material_detail.quotation_price_1.to_i < quotation_material_detail.quotation_price_2.to_i
					    
             #価格１ < 価格２
           #  price_bid = quotation_material_detail.quotation_price_1
             
             #add180925
             total_high_price += quotation_material_detail.quotation_price_2
             total_low_price += quotation_material_detail.quotation_price_1
           
					 elsif quotation_material_detail.quotation_price_2.to_i > 0 && 
					   quotation_material_detail.quotation_price_2.to_i < quotation_material_detail.quotation_price_1.to_i
					   
             #価格２ < 価格１
           #  price_bid = quotation_material_detail.quotation_price_2
             #add180925
             total_high_price += quotation_material_detail.quotation_price_1
             total_low_price += quotation_material_detail.quotation_price_2
           
           elsif quotation_material_detail.quotation_price_1.to_i > 0 &&  quotation_material_detail.quotation_price_2.to_i > 0 && 
             quotation_material_detail.quotation_price_2.to_i == quotation_material_detail.quotation_price_1.to_i
             #価格１と 価格２が同じ値→それぞれへカウント
             total_high_price += quotation_material_detail.quotation_price_1
             total_low_price += quotation_material_detail.quotation_price_2
             
					 end
           
					 if price_bid > 0
					   #合計へもカウント
					   total_price_bid += price_bid
					 end
					 #
					 
					 
                     row.values material_code: material_code, material_name: material_name, 
					            maker_name: maker_name, quantity: quotation_material_detail.quantity,
								unit_name: unit_name, list_price: quotation_material_detail.list_price,
								unit_price_1: unit_price_1,price_1: price_1, unit_price_2: unit_price_2,price_2: price_2,
                                unit_price_bid: unit_price_bid, price_bid: price_bid
                     
                     #価格比較し、安い方に色を塗る
                     comparePrice(unit_price_1 , unit_price_2)
                     if @cheaper_flag_1 == true
                       row.item(:unit_price_1).styles(:color => '#FE2E2E')
                       row.item(:price_1).styles(:color => '#FE2E2E')
                     end
                     if @cheaper_flag_2 == true
                       row.item(:unit_price_2).styles(:color => '#FE2E2E')
                       row.item(:price_2).styles(:color => '#FE2E2E')
                     end
			    end 
              end
			end

		
#		 #最下部の合計欄

     #高値計
     if total_high_price > 0
		   report.page.item(:total_high_price).value(total_high_price)
		 end
     #安値計
     if total_low_price > 0
		   report.page.item(:total_low_price).value(total_low_price)
		 end
     
     #差額計
     if total_high_price > 0 && total_low_price > 0
     #if total_balance > 0
       total_balance = total_high_price - total_low_price
		   report.page.item(:total_balance).value(total_balance)
		 end
     
     #金額１計
		 if total_price_1 > 0
		   report.page.item(:total_price_1).value(total_price_1)
		 end
     #金額２計
		 if total_price_2 > 0
		   report.page.item(:total_price_2).value(total_price_2)
		 end
		 #差額計
		 if total_price_bid > 0
		   report.page.item(:total_price_bid).value(total_price_bid)
		 end

        # Thinrs::Reportを返す
        return report
  end  
   
end
   
  
def comparePrice(price1, price2)
  @cheaper_flag_1 = false
  @cheaper_flag_2 = false
  
  if price1.present? && price2.present?
    if price1 < price2
      @cheaper_flag_1 = true
    elsif price2 < price1
      @cheaper_flag_2 = true
    elsif price1 ==  price2
    #同値の場合は、どちらも赤にする
      @cheaper_flag_1 = true
      @cheaper_flag_2 = true
    end
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
