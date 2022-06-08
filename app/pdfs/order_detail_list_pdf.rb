class OrderDetailListPDF
    
  
  def self.create order_detail_list	
    #注文明細表PDF発行
 
    # tlfファイルを読み込む
    report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/order_detail_list_pdf.tlf")
       
    # 1ページ目を開始
    report.start_new_page
   
    # テーブルの値を設定
    # list に表のIDを設定する(デフォルトのID値: default)
    # add_row で列を追加できる
    # ブロック内のrow.valuesで値を設定する
 
    @flag = nil
    
    #初期化
    @purchase_order_code  = ""
    @order_price_subtotal = 0
    @order_price_total = 0
    
    $orders.joins({:purchase_order_history => :purchase_order_datum}).order("purchase_order_histories.purchase_order_datum_id,
                                                     purchase_order_histories.purchase_order_date, id").each do |orders|  
    #---見出し---
      page_count = report.page_count.to_s + "頁"
      report.page.item(:pageno).value(page_count)

      #これだと時間がかかりすぎる...
      #他で使えそうなので消さないこと
      #report.page.item(:construction_code).value(orders.purchase_order_history.purchase_order_datum.construction_datum.construction_code)
      #report.page.item(:construction_name).value(orders.purchase_order_history.purchase_order_datum.construction_datum.construction_name)
      #report.page.item(:customer_name).value(orders.purchase_order_history.purchase_order_datum.construction_datum.CustomerMaster.customer_name)
      #
      report.page.item(:construction_code).value($construction_code_for_detail_pdf)
      report.page.item(:construction_name).value($construction_name_for_detail_pdf)
      report.page.item(:customer_name).value($customer_name_for_detail_pdf)
      
      #小計
      if @purchase_order_code  != ""
        if @purchase_order_code  != orders.purchase_order_history.purchase_order_datum.purchase_order_code
          @num = @order_price_subtotal
          formatNum()
          @order_price_subtotal = @num
          report.list(:default).add_row do |row2|
                              row2.values purchase_order_code: @purchase_order_code, order_unit_price: "小計", 
                                          order_price: @order_price_subtotal
                                          #row2.item(:lbl_unit_price_multi).visible(false)  
          end
			    @order_price_subtotal = 0
        end
      end
		
      @purchase_order_code  = orders.purchase_order_history.purchase_order_datum.purchase_order_code
      #金額小計・合計をセット
      if orders.order_price.present?
        @order_price_subtotal = @order_price_subtotal + orders.order_price
        @order_price_total = @order_price_total + orders.order_price
      end
		  #for i in 0..29   #29行分(for test)
      report.list(:default).add_row do |row|
        #品名のセット
        material_name = orders.material_name
        #品番
        if orders.material_code == "＜手入力用＞" || orders.material_code == "-"
          material_code = "-"
        else
          material_code = orders.material_code
        end
        #
					   
				#数値の様式設定
        #注文単価
        @num = orders.order_unit_price
        formatNum()
        unit_price = @num
        #金額
        @num = orders.order_price
        formatNum()
        order_price = @num
        #定価
        @num = orders.list_price
        formatNum()
        list_price = @num
        #
        #数量は小数点の場合あり、その場合で表示を切り分ける。
        quantity = ""
        first, second = orders.quantity.to_s.split('.')
        if second.to_i > 0
          quantity = sprintf("%.2f", orders.quantity)
        else
          quantity = sprintf("%.0f", orders.quantity)
        end
        #
			
        #納品済みフラグ
        delivery_complete_flag = ""
        if orders.delivery_complete_flag.present? && Order.delivery_complete_check_list[orders.delivery_complete_flag][1] == 1
          delivery_complete_flag = Order.delivery_complete_check_list[orders.delivery_complete_flag][0]
        end 
                       
        row.values purchase_order_date: orders.purchase_order_history.purchase_order_date,
                                  purchase_order_code: orders.purchase_order_history.purchase_order_datum.purchase_order_code,
                                  material_code: material_code,
                                  material_name: material_name,
                                  maker_name: orders.material_master.MakerMaster.maker_name,
                                  quantity: quantity,
                                  unit_name: orders.unit_master.unit_name,
                                  order_unit_price: unit_price,
                                  order_price: order_price,
                                  list_price: list_price,
                                  supplier_name: orders.purchase_order_history.supplier_master.supplier_name,
                                  delivery_complete_flag: delivery_complete_flag
	                    
      end  #enddo(row)
    end  #enddo(orders)
    #end   
    #最終ページの出力はここで定義する
    page_count = report.page_count.to_s + "頁"
    report.page.item(:pageno).value(page_count)

    #小計(ラスト分)
    @num = @order_price_subtotal
    formatNum()
    @order_price_subtotal = @num
        
    report.list(:default).add_row do |row2| 
           row2.values purchase_order_code: @purchase_order_code, order_unit_price: "小計", 
                       order_price: @order_price_subtotal
           #row2.item(:lbl_unit_price_multi).visible(false)  
    end
		
		#合計
		@num = @order_price_total
		formatNum()
    @order_price_total = @num
    report.list(:default).add_row do |row2|
      row2.values order_unit_price: "合計", 
                            order_price: @order_price_total
      #row2.item(:lbl_unit_price_multi).visible(false)  
    end

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
