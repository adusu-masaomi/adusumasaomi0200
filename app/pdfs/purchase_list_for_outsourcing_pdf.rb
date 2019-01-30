class PurchaseListForOutsourcingPDF 
  
  #include ApplicationHelper
  
  def self.create purchase_list_for_outsourcing
     #仕入表(仕入先別)PDF発行
      
       #
 
       # tlfファイルを読み込む
       report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/purchase_list_for_outsourcing_pdf.tlf")
       
        # 1ページ目を開始
        report.start_new_page
        
        #初期化
        @flag = nil
        @purchase_order_code  = ""
        @purchase_amount_subtotal = 0
        @purchase_amount_total = 0

        $purchase_data.joins(:purchase_order_datum).order("purchase_date, purchase_order_code, id").each do |purchase_datum| 
        #ソート順は仕入日、注文ナンバーの順とする。
		
        #---見出し---
         page_count = report.page_count.to_s + "頁"
		 report.page.item(:pageno).value(page_count)

		 if @flag.nil? 
		 
		   @flag = "1"
		   
		   if $construction_flag == true
		     report.page.item(:construction_code).value(purchase_datum.construction_datum.construction_code)
		     report.page.item(:construction_name).value(purchase_datum.construction_datum.construction_name)
		   end
		   if $customer_flag == true
		     report.page.item(:customer_name).value(purchase_datum.construction_datum.CustomerMaster.customer_name)
		   end
		   
		   if $supplier_flag == true
		     report.page.item(:supplier_name).value(purchase_datum.SupplierMaster.supplier_name)
		   end
		   
           #小計(見積金額) 
		   #本来ならフッターに設定するべきだが、いまいちわからないため・・
		   #report.page.item(:quote_price).value(@quotation_headers.quote_price)
		   
		 end
		
         #外注費データを取得
         payment_date = nil
         
         #binding.pry
         
         staff_id = ::ApplicationController.helpers.getSupplierToStaff(purchase_datum.supplier_id)
         outsourcing_cost = OutsourcingCost.where(:construction_datum_id => 
            purchase_datum.construction_datum_id).where(:staff_id => staff_id).first
         if outsourcing_cost.present?
           payment_date = outsourcing_cost.payment_date
           payment_amount = outsourcing_cost.payment_amount
           unpaid_amount = outsourcing_cost.unpaid_amount
         end
         #小計
		 #if @purchase_order_code  != ""
		 # if @purchase_order_code  != purchase_datum.purchase_order_datum.purchase_order_code
		 #   @num = @purchase_amount_subtotal
		#	formatNum()
		#	@purchase_amount_subtotal = @num
		#	report.list(:default).add_row purchase_order_code: @purchase_order_code, purchase_unit_price: "小計", 
        #                                  purchase_amount: @purchase_amount_subtotal
		#	@purchase_amount_subtotal = 0
		#  end
		#end
		
	    @purchase_order_code  = purchase_datum.purchase_order_datum.purchase_order_code
		#金額小計・合計をセット
		if purchase_datum.purchase_amount.present?
		  @purchase_amount_subtotal = @purchase_amount_subtotal + purchase_datum.purchase_amount
		  @purchase_amount_total = @purchase_amount_total + purchase_datum.purchase_amount
		end
        
        #add190124
        construction_code = ""
        construction_name = ""
        customer_name = ""
        if purchase_datum.construction_datum.present?
          construction_code = purchase_datum.construction_datum.construction_code
          construction_name = purchase_datum.construction_datum.construction_name
          customer_name = purchase_datum.construction_datum.CustomerMaster.customer_name
        end
        #
        
        #
		 #for i in 0..29   #29行分(for test)
		    report.list(:default).add_row do |row|
			           #品名のセット
					   #フリー入力とマスターからの取得を切り分ける
					   if purchase_datum.material_id == 1
					     material_name = purchase_datum.material_name
					   else
					     material_name = purchase_datum.MaterialMaster.material_name
					   end
					   #品番
					   if purchase_datum.material_code == "＜手入力用＞"
					     material_code = "-"
					   else 
					     material_code = purchase_datum.MaterialMaster.material_code
					   end
					   #
					   
					   ###数値の様式設定
					   #仕入単価
                       @num = purchase_datum.purchase_unit_price
					   formatNum()
					   unit_price = @num
					   #金額
					   @num = purchase_datum.purchase_amount
					   formatNum()
					   purchase_amount = @num
					   
                       purchase_amount_tax_in = 0
                       if purchase_datum.purchase_amount > 0
                       #税込価格にする
                         purchase_amount_tax_in = purchase_datum.purchase_amount * $consumption_tax_include
                         @num = purchase_amount_tax_in
                         formatNum()
					     purchase_amount_tax_in = @num
                       end
                       
                       #支払金額
                       @num = payment_amount
                       formatNum()
					   payment_amount = @num
                       #未払金額
                       @num = unpaid_amount
                       formatNum()
					   unpaid_amount = @num
					   
					   #add170307
                       #数量は小数点の場合あり、その場合で表示を切り分ける。
                       quantity = ""
                       first, second = purchase_datum.quantity.to_s.split('.')
                       if second.to_i > 0
                         quantity = sprintf("%.2f", purchase_datum.quantity)
                       else
                         quantity = sprintf("%.0f", purchase_datum.quantity)
                       end
                       #
					   
                       #締め日等を取得
                       @construction_datum_id = purchase_datum.construction_datum_id
					   @purchase_date = purchase_datum.purchase_date.to_date
					   @closing_date = nil
                       @payment_due_date = nil
                       get_customer_date_info
                       #
                       
			           row.values purchase_date: purchase_datum.purchase_date,
                                  construction_code: construction_code,
								  construction_name: construction_name,
								  customer_name: customer_name,
					              purchase_order_code: purchase_datum.purchase_order_datum.purchase_order_code,
					              purchase_amount: purchase_amount,
                                  purchase_amount_tax_in: purchase_amount_tax_in,
                                  closing_date: @closing_date,
                                  payment_due_date: @payment_due_date,
                                  payment_date: payment_date,
                                  payment_amount: payment_amount,
                                  unpaid_amount: unpaid_amount
	                    
            end 


	end	
#end   
        #add170302 最終ページの出力はここで定義する
        page_count = report.page_count.to_s + "頁"
        report.page.item(:pageno).value(page_count)

		#小計(ラスト分)
		#@num = @purchase_amount_subtotal
		#formatNum()
		#@purchase_amount_subtotal = @num
		#report.list(:default).add_row purchase_order_code: @purchase_order_code, purchase_unit_price: "小計", 
        #                                  purchase_amount: @purchase_amount_subtotal
		
		#合計
		tmp_purchase_amount_total = @purchase_amount_total  #保持用
        
        @num = @purchase_amount_total
        formatNum()
		@purchase_amount_total = @num
		
        #税込
        @num = tmp_purchase_amount_total * $consumption_tax_include
        formatNum()
		@purchase_amount_total_tax_in = @num
        
        #合計表示
        report.list(:default).add_row  memo: "合計", 
                                          purchase_amount: @purchase_amount_total,
                                          purchase_amount_tax_in: @purchase_amount_total_tax_in
		
        # ThinReports::Reportを返す
        return report
		
  end  
   
end
   

  #得意先から締め日・支払日を算出
  def get_customer_date_info
    
    require "date"
    
    #construction = ConstructionDatum.find(params[:purchase_datum][:construction_datum_id])
    construction = ConstructionDatum.where(:id => @construction_datum_id).first
    
    customer = nil
    if construction.present?
      customer = CustomerMaster.find(construction.customer_id)
    end
    
    if customer.present?
        
        #締め日算出
        if customer.closing_date_division == 1
        #月末の場合
          #d = params[:purchase_datum][:purchase_date]
          d = @purchase_date
          @closing_date = Date.new(d.year, d.month, -1)
        else
        #日付指定の場合
          #d = params[:purchase_datum][:purchase_date].to_date
          d = @purchase_date
          if Date.valid_date?(d.year, d.month, customer.closing_date)
            @closing_date = Date.new(d.year, d.month, customer.closing_date)
          end
        end
        
        #支払日算出
        #d = params[:purchase_datum][:purchase_date].to_date
        d = @purchase_date
        if customer.due_date.present?
          if Date.valid_date?(d.year, d.month, customer.due_date)
            d2 = Date.new(d.year, d.month, customer.due_date)
            addMonth = customer.due_date_division
            @payment_due_date = d2 >> addMonth
          end
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