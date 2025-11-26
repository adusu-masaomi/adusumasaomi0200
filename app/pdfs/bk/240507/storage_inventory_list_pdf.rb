class StorageInventoryListPDF
    
  
  #def self.create inventory_list
  def self.create(storage_inventories, warehouse_name, category_name)
  #預かり在庫表PDF発行
      
    # tlfファイルを読み込む
    #case $print_flag 
    #when "1", "5"
    #  #在庫一覧表(画像付)
    #  report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/inventory_list_with_pic_pdf.tlf")
    #end
    report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/storage_inventory_list_pdf.tlf")
    
    #ソート順
    sort_str = "material_code"
    if $print_flag == "5"   #在庫一覧(数量順の場合)
      sort_str = "inventory_quantity desc"
    end
       
    # 1ページ目を開始
    report.start_new_page
        
    #初期化
    @flag = nil
    
    inventory_quantity_total = 0
    inventory_amount_total = 0
    
    #事務所・倉庫
    if warehouse_name.present?
      tmp_name = "(" + warehouse_name + ")"
      report.page.item(:warehouse).value(tmp_name)
    end
    
    #カテゴリー
    if category_name.present?
      report.page.item(:category_name).value(category_name)
    else 
      report.page.item(:lbl_category_name).visible(false)
    end
    #
    
    #ソート順は仕入日、注文ナンバーの順とする。
    
    #$inventories.joins(:material_master).order("material_code").each do |inventory| 
    #$inventories.joins(:material_master).order(sort_str).each do |inventory|
    storage_inventories.joins(:material_master).order(sort_str).each do |storage_inventory| 
      #---見出し---
      #report.page.item(:issue_date).value(Date.today)
      
      #dt = Time.now.strftime('%Y/%m/%d %H:%M:%S')
      dt = Time.now.strftime('%Y/%m/%d')
      report.page.item(:issue_date).value(dt)
      #DateTime.now.strftime('%m/%d/%Y')
  
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
      #if inventory.inventory_quantity.present?
      #  inventory_quantity_total += inventory.inventory_quantity
      #  inventory_amount_total += inventory.inventory_amount
      #end
      if storage_inventory.quantity.present?
        inventory_quantity_total += storage_inventory.quantity
        #inventory_amount_total += storage_inventory.inventory_amount
      end
      
      #ここまで修正....
      
      report.list(:default).add_row do |row|
        #品名(手入力は考慮しない）
        material_name = storage_inventory.material_master.material_name
        #品番(手入力は考慮しない）
        material_code = storage_inventory.material_master.material_code
        
        #end
        
        #数値の様式設定
        #現在単価
        #@num = inventory.current_unit_price
        @num = storage_inventory.unit_price
        formatNum()
        unit_price = @num
        #金額
        #@num = inventory.inventory_amount
        #formatNum()
        #inventory_amount = @num
        inventory_amount = nil  #test
        #定価
        @num = storage_inventory.material_master.list_price
        formatNum()
        list_price = @num
        #
          
        #数量は小数点の場合あり、その場合で表示を切り分ける。
        inventory_quantity = ""
        first, second = storage_inventory.quantity.to_s.split('.')
        if second.to_i > 0
          inventory_quantity = sprintf("%.2f", storage_inventory.quantity)
        else
          inventory_quantity = sprintf("%.0f", storage_inventory.quantity)
        end
        #
        
        #単位...必要か
        if storage_inventory.unit_master.present?
          unit_name = storage_inventory.unit_master.unit_name
        else
          unit_name = ""
        end
        
        #画像をセット(カット)
        image_pic = nil
        #if inventory.image.present?
        #  image_pic = "#{Rails.root}/public" + inventory.image_url(:thumb)
        #else
        #  image_pic = nil
        #end
        ##
    
        row.values image: image_pic, material_code: material_code,
                          material_name: material_name, unit_name: unit_name,
                          quantity: inventory_quantity,
                          unit_price: unit_price
                          #inventory_amount: inventory_amount,
                          #list_price: list_price
        #除外の線--カット
        #if $print_flag == "3"
        #  if inventory.no_stocktake_flag == 1
        #    row.item(:exclude_line).visible(true)
        #  else
        #    row.item(:exclude_line).visible(false)
        #  end
        #end
        #
    
    
      end 


	    end	
#end   
        #合計
		@num = inventory_amount_total
		formatNum()
		inventory_amount_total = @num
		
		
		report.list(:default).add_row  note: "合計", 
                                       quantity: inventory_quantity_total
									   #inventory_amount: inventory_amount_total
		
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
