class InventoryActionListPDF
    
  
  def self.create inventory_action_list
    #棚卸表PDF発行
      
       # tlfファイルを読み込む
	   #棚卸表
	   report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/inventory_action_list_pdf.tlf")
	   
        # 1ページ目を開始
        report.start_new_page
        
        #初期化
        @flag = nil

        #inventory_quantity_total = 0
        #inventory_amount_total = 0
        
        stocktake_amount_total = 0
		
        #$purchase_data.joins(:purchase_order_datum).order("purchase_date, purchase_order_code, id").each do |purchase_datum| 
		#ソート順は仕入日、注文ナンバーの順とする。
		
		$stocktakes.joins(:material_master).order("material_code").each do |stocktake| 
        
		
        #---見出し---
		 
		 #棚卸日
		 if $stocktake_date.present?
		 #画面指定した日付を出力
		   stocktake_date = Time.parse($stocktake_date)
		   dt = "#{stocktake_date.strftime('%-Y')}年#{stocktake_date.strftime('%-m')}月#{stocktake_date.strftime('%-d')}日" + "現在"
		   
		 else
		 #画面からの指定がなければ、当日の日付をそのまま出力。
		   stocktake_date = Date.today
		   dt = "#{stocktake_date.strftime('%-Y')}年#{stocktake_date.strftime('%-m')}月#{stocktake_date.strftime('%-d')}日" + "現在"
		 end
		 
		 report.page.item(:stocktake_date).value(dt)
		 
		 #dt = Time.now.strftime('%Y/%m/%d %H:%M:%S')
		 #report.page.item(:issue_date).value(dt)
		 
         page_count = report.page_count.to_s + "頁"
		 report.page.item(:pageno).value(page_count)

		 #if @flag.nil? 
		 #  @flag = "1"
		 #end
	
	  	
		 #金額小計をセット
		 if stocktake.physical_amount.present?
		   stocktake_amount_total += stocktake.physical_amount
		 end
		 
		 #if inventory.inventory_quantity.present?
		 #  inventory_quantity_total += inventory.inventory_quantity
		 #  inventory_amount_total += inventory.inventory_amount
		 #end
		
		
  	       report.list(:default).add_row do |row|
			 #品名
			 material_name = stocktake.material_master.material_name
			 #品番
			 material_code = stocktake.material_master.material_code
			 
             #単位
             unit_name = ""
			 #if stocktake.inventory.unit_master.present?
                         if stocktake.inventory.present? && stocktake.inventory.unit_master.present?
               unit_name = stocktake.inventory.unit_master.unit_name
             end

             #差異数
             difference = 0
             if stocktake.physical_quantity.present? && stocktake.book_quantity.present?
			   difference = stocktake.physical_quantity - stocktake.book_quantity
			 end
  
			 #end
			 #数値の様式設定
			 #単価(最終)
             @num = stocktake.unit_price
			 formatNum()
			 unit_price = @num
			 #金額
			 @num = stocktake.physical_amount
			 formatNum()
		     physical_amount = @num
			 ###
					   
			 #数量は小数点の場合あり、その場合で表示を切り分ける。
             #inventory_quantity = ""
             #first, second = inventory.inventory_quantity.to_s.split('.')
             #if second.to_i > 0
             #  inventory_quantity = sprintf("%.2f", inventory.inventory_quantity)
             #else
             #  inventory_quantity = sprintf("%.0f", inventory.inventory_quantity)
             #end
             #
			
			 row.values material_code: material_code,
                        material_name: material_name,
					    unit_name: unit_name,
                        book_quantity: stocktake.book_quantity,
                        physical_quantity: stocktake.physical_quantity,
						difference: difference, 
						unit_price: unit_price,
						physical_amount: physical_amount
            end 


	    end	
#end   
        #合計
		@num = stocktake_amount_total
		formatNum()
		stocktake_amount_total = @num
		
		
		report.list(:default).add_row  note: "合計", 
                                 physical_amount: stocktake_amount_total
		
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
