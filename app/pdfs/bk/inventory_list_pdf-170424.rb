class InventoryListPDF
    
  
  def self.create inventory_list
	#入出庫表PDF発行
 
       # tlfファイルを読み込む
       report = ThinReports::Report.new(layout: "#{Rails.root}/app/pdfs/inventory_list_pdf.tlf")
       
        # 1ページ目を開始
        report.start_new_page
        
        #初期化
        @flag = nil
		
		inventory_quantity_total = 0
		inventory_amount_total = 0
		
        #@purchase_order_code  = ""
        #@purchase_amount_subtotal = 0
        #@purchase_amount_total = 0

        #$purchase_data.joins(:purchase_order_datum).order("purchase_date, purchase_order_code, id").each do |purchase_datum| 
		#ソート順は仕入日、注文ナンバーの順とする。
		
		$inventories.joins(:material_master).order("material_code").each do |inventory| 
        
		
        #---見出し---
         page_count = report.page_count.to_s + "頁"
		 report.page.item(:pageno).value(page_count)

		 if @flag.nil? 
		 
		   @flag = "1"
		   
		   #if $material_search_flag == true
		   #品番検索が行われていた場合のみ、品番品名・在庫数を表示する
		   #  report.page.item(:material_code).value(inventory_history.material_master.material_code)
		   #  report.page.item(:material_name).value(inventory_history.material_master.material_name)
		   #   report.page.item(:inventory_quantity).value(inventory_history.inventories.pluck("inventory_quantity")[0])
		   #end
		 end
		
	  
		#小計出力（品番が変わった場合）
		#if material_code  != ""
		#  if material_code  != inventory_history.material_master.material_code
		#	@num = price_subtotal
		#	formatNum()
		#	price_subtotal_str = @num
		#	report.list(:default).add_row maker_name: "小計", 
        #                               quantity: quantity_subtotal,
		#							   price: price_subtotal_str
		#	quantity_subtotal = 0
		#	price_subtotal = 0
		#  end
		#end
		
		#数量・金額小計をセット
		if inventory.inventory_quantity.present?
		  inventory_quantity_total += inventory.inventory_quantity
		  inventory_amount_total += inventory.inventory_amount
		end
		
		
  	       report.list(:default).add_row do |row|
			 #品名(手入力は考慮しない）
			 material_name = inventory.material_master.material_name
			 #品番(手入力は考慮しない）
			 material_code = inventory.material_master.material_code
			   
			 #end
			 #数値の様式設定
			 #現在単価
             @num = inventory.current_unit_price
			 formatNum()
			 unit_price = @num
			 #金額
			 @num = inventory.inventory_amount
			 formatNum()
		     inventory_amount = @num
			 #定価
			 @num = inventory.material_master.list_price
			 formatNum()
		     list_price = @num
			 ###
					   
			 #数量は小数点の場合あり、その場合で表示を切り分ける。
             inventory_quantity = ""
             first, second = inventory.inventory_quantity.to_s.split('.')
             if second.to_i > 0
               inventory_quantity = sprintf("%.2f", inventory.inventory_quantity)
             else
               inventory_quantity = sprintf("%.0f", inventory.inventory_quantity)
             end
             #
			
			 if inventory.unit_master.present?
			   unit_name = inventory.unit_master.unit_name
			 else
			   unit_name = ""
			 end
			
			 row.values material_code: material_code,
                        material_name: material_name,
					    unit_name: unit_name,
						inventory_quantity: inventory_quantity,
						unit_price: unit_price,
						inventory_amount: inventory_amount,
                        list_price: list_price
              
			  
            end 


	    end	
#end   
        #add170302 最終ページの出力はここで定義する
        page_count = report.page_count.to_s + "頁"
        report.page.item(:pageno).value(page_count)
        
	
		#合計
		@num = inventory_amount_total
		formatNum()
		inventory_amount_total = @num
		
		
		report.list(:default).add_row  note: "合計", 
                                       inventory_quantity: inventory_quantity_total,
									   inventory_amount: inventory_amount_total
		
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
