class WarehouseAndDeliveryListPDF
    
  
  def self.create warehouse_and_delivery_list
	#入出庫表PDF発行
 
       # tlfファイルを読み込む
       #report = ThinReports::Report.new(layout: "#{Rails.root}/app/pdfs/warehouse_and_delivery_list_pdf.tlf")
       #upd240127
       report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/warehouse_and_delivery_list_pdf.tlf")
       
        # 1ページ目を開始
        report.start_new_page
        
        #初期化
        @flag = nil
		
		material_code = ""
		quantity_subtotal = 0
		quantity_total = 0
		price_subtotal = 0
		price_subtotal_str = ""
		price_total = 0
		
        #@purchase_order_code  = ""
        #@purchase_amount_subtotal = 0
        #@purchase_amount_total = 0

        #$purchase_data.joins(:purchase_order_datum).order("purchase_date, purchase_order_code, id").each do |purchase_datum| 
		#ソート順は仕入日、注文ナンバーの順とする。
		
		$inventory_histories.joins(:material_master).order("material_code, inventory_date").each do |inventory_history| 
        
		
        #---見出し---
		 report.page.item(:issue_date).value(Date.today)
		 
		 dt = Time.now.strftime('%Y/%m/%d %H:%M:%S')
		 report.page.item(:issue_date).value(dt)
		 
		
         page_count = report.page_count.to_s + "頁"
		 report.page.item(:pageno).value(page_count)

		 if @flag.nil? 
		 
		   @flag = "1"
		   
		   if $material_search_flag == true
		   #品番検索が行われていた場合のみ、品番品名・在庫数を表示する
		     report.page.item(:material_code).value(inventory_history.material_master.material_code)
		     report.page.item(:material_name).value(inventory_history.material_master.material_name)
			 report.page.item(:inventory_quantity).value(inventory_history.inventories.pluck("inventory_quantity")[0])
			 report.page.item(:unit_name).value(inventory_history.unit_master.unit_name)
		   end
		 end
		
	    #@purchase_order_code  = purchase_datum.purchase_order_datum.purchase_order_code
		#金額小計・合計をセット
		#if purchase_datum.purchase_amount.present?
		#  @purchase_amount_subtotal = @purchase_amount_subtotal + purchase_datum.purchase_amount
		#  @purchase_amount_total = @purchase_amount_total + purchase_datum.purchase_amount
		#end
	    
		
		#小計出力（品番が変わった場合）
		if material_code  != ""
		  if material_code  != inventory_history.material_master.material_code
			@num = price_subtotal
			formatNum()
			price_subtotal_str = @num
			report.list(:default).add_row maker_name: "小計", 
                                       quantity: quantity_subtotal,
									   price: price_subtotal_str
			quantity_subtotal = 0
			price_subtotal = 0
		  end
		end
		
		#数量・金額小計をセット
        if inventory_history.quantity.present?
          if (inventory_history.inventory_division_id == $INDEX_INVENTORY_STOCK) || 
             (inventory_history.inventory_division_id == $INDEX_INVENTORY_STOCKTAKE)
		    quantity_subtotal += inventory_history.quantity
		    quantity_total += inventory_history.quantity
			
			price_subtotal += inventory_history.price
			price_total += inventory_history.price
		  elsif inventory_history.inventory_division_id == $INDEX_INVENTORY_SHIPPING
		  #出庫はマイナスする
            quantity_subtotal -= inventory_history.quantity
		    quantity_total -= inventory_history.quantity
			
			price_subtotal -= inventory_history.price
			price_total -= inventory_history.price
		  end
		end
		
			  
			
		
		
  	       report.list(:default).add_row do |row|
			 #品名(手入力は考慮しない）
			 material_name = inventory_history.material_master.material_name
			 #品番(手入力は考慮しない）
			 material_code = inventory_history.material_master.material_code
			   
			 #end
			 #数値の様式設定
			 #仕入単価
             @num = inventory_history.unit_price
			 formatNum()
			 unit_price = @num
			 #金額
			 @num = inventory_history.price
			 formatNum()
		     price = @num
			 #定価
			 @num = inventory_history.material_master.list_price
			 formatNum()
		     list_price = @num
			 ###
					   
			 #数量は小数点の場合あり、その場合で表示を切り分ける。
             quantity = ""
             first, second = inventory_history.quantity.to_s.split('.')
             if second.to_i > 0
               quantity = sprintf("%.2f", inventory_history.quantity)
             else
               quantity = sprintf("%.0f", inventory_history.quantity)
             end
             #
			
       #add240127
       construction_code = nil
       if inventory_history.construction_datum.present? && inventory_history.construction_datum.construction_code.present?
         construction_code = inventory_history.construction_datum.construction_code
       end
       construction_name = nil
       if inventory_history.construction_datum.present? && inventory_history.construction_datum.construction_name.present?
         construction_name = inventory_history.construction_datum.construction_name
       end
       customer_name = nil
       if inventory_history.construction_datum.present? && inventory_history.construction_datum.CustomerMaster.present? &&
          inventory_history.construction_datum.CustomerMaster.customer_name.present?
         customer_name = inventory_history.construction_datum.CustomerMaster.customer_name
       end
       #
      
			 row.values inventory_date: inventory_history.inventory_date,
			            inventory_division_name: InventoryHistory.inventory_division[inventory_history.inventory_division_id][0],
                  #construction_code: inventory_history.construction_datum.construction_code,
                  construction_code: construction_code,
                  #construction_name: inventory_history.construction_datum.construction_name,
                  construction_name: construction_name,
                  #customer_name: inventory_history.construction_datum.CustomerMaster.customer_name,
                  customer_name: customer_name, 
                  #purchase_order_code: purchase_datum.purchase_order_datum.purchase_order_code,
					    material_code: material_code,
                        material_name: material_name,
					    maker_name: inventory_history.material_master.MakerMaster.maker_name,
                        quantity: quantity,
                        unit_name: inventory_history.unit_master.unit_name,
						unit_price: unit_price,
						price: price,
                        list_price: list_price,
                        supplier_name: inventory_history.supplier_master.supplier_name
						
	          
			  
            end 


	    end	
#end   
       
		#小計(ラスト)
        @num = price_subtotal
		formatNum()
		price_subtotal = @num
		report.list(:default).add_row maker_name: "小計", 
                                       quantity: quantity_subtotal,
									   price: price_subtotal
		
		#合計
		@num = price_total
		formatNum()
		price_total = @num
		
		
		report.list(:default).add_row  maker_name: "合計", 
                                       quantity: quantity_total,
									   price: price_total
		
		#最終ページの出力はここで定義する
        page_count = report.page_count.to_s + "頁"
        report.page.item(:pageno).value(page_count)
		
		
        # ThinReports::Reportを返す
        return report
		
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
