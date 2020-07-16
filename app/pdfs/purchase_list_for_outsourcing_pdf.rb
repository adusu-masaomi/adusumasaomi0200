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
        @purchase_amount_tax_in_total = 0  #add191101
        
        @payment_amount_total = 0
        @unpaid_amount_total = 0

        sort_key = ""
        if !$no_color
        #ADUSU用の場合、仕入日・注番でソート
            sort_key = "purchase_date, purchase_order_code, id"
        else
        #会計士用の場合、支払日・仕入日・注番でソート
            sort_key = "payment_date, purchase_date, purchase_order_code, id"
        end

        #$purchase_data.joins(:purchase_order_datum).order("purchase_date, purchase_order_code, id").each do |purchase_datum|
        #upd200215
        $purchase_data.joins(:purchase_order_datum).order(sort_key).each do |purchase_datum|
 
        
        #---見出し---
         #発行日
         dt = Time.now.strftime('%Y/%m/%d')
         dt += " 現在"
		 report.page.item(:issue_date).value(dt)
        
         page_count = report.page_count.to_s + "頁"
		 report.page.item(:pageno).value(page_count)

		 if @flag.nil? 
		 
		   @flag = "1"
		   
		   if $construction_flag == true
              #del190930
              # report.page.item(:construction_code).value(purchase_datum.construction_datum.construction_code)
		      # report.page.item(:construction_name).value(purchase_datum.construction_datum.construction_name)
		   end
		   if $customer_flag == true
             #if purchase_datum.construction_datum.CustomerMaster.customer_name.present?
		      # report.page.item(:customer_name).value(purchase_datum.construction_datum.CustomerMaster.customer_name)
		     #end
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
         unpaid_payment_date = nil
         
         staff_id = ::ApplicationController.helpers.getSupplierToStaff(purchase_datum.supplier_id)
         
         #outsourcing_cost = OutsourcingCost.where(:construction_datum_id => 
         #       purchase_datum.construction_datum_id).where(:staff_id => staff_id).first
                
         
         if purchase_datum.purchase_order_datum_id.present?
         #upd190930
         #注番があればそっちを優先する
             outsourcing_cost = OutsourcingCost.where(:purchase_order_datum_id => 
                purchase_datum.purchase_order_datum_id).where(:staff_id => staff_id).first
             
             #注番のないデータなら、工事IDで引っ張る(将来的にはなくなる予定)
             if outsourcing_cost.nil?
                   outsourcing_cost = OutsourcingCost.where(:construction_datum_id => 
                      purchase_datum.construction_datum_id).where(:staff_id => staff_id).first
             end
         end
         
         if outsourcing_cost.present?
           payment_date = outsourcing_cost.payment_date
           unpaid_payment_date = outsourcing_cost.unpaid_payment_date
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
        purchse_amount_tax_in = 0   #add191101
        
		#金額小計・合計をセット
		if purchase_datum.purchase_amount.present?
		  @purchase_amount_subtotal = @purchase_amount_subtotal + purchase_datum.purchase_amount
		  @purchase_amount_total = @purchase_amount_total + purchase_datum.purchase_amount
          
          #add191101
          #異なる消費税が混在するケースがあるので、消費税は一括計算せずに明細を加算させる
          #@purchase_amount_tax_in_total
          date_per_ten_start = Date.parse("2019/10/01")   #消費税１０％開始日
          #upd191101
          #消費税率により分岐
          if purchase_datum.purchase_date < date_per_ten_start
          #8%の場合
            purchase_amount_tax_in = purchase_datum.purchase_amount * $consumption_tax_include
          else
            #10%の場合(変更があれば更に分岐させる)
            purchase_amount_tax_in = purchase_datum.purchase_amount * $consumption_tax_include_per_ten
          end
          
          @purchase_amount_tax_in_total += purchase_amount_tax_in
          #
		end
        
        if outsourcing_cost.present?
          #支払金額計
          if !outsourcing_cost.payment_amount.blank?
            @payment_amount_total += outsourcing_cost.payment_amount
          end
          #未払金額計
          if !outsourcing_cost.unpaid_amount.blank?
            @unpaid_amount_total += outsourcing_cost.unpaid_amount
          end
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
					   
                       #purchase_amount_tax_in = 0  #del191101
                       if purchase_datum.purchase_amount > 0
                       #税込価格にする
                         
                         #フォーマット変更させる
                         @num = purchase_amount_tax_in
                         formatNum()
					     purchase_amount_tax_in_str = @num
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
					   
                       #add20215
                       #振込元銀行を表記
                       #税理士向けレイアウトの場合のみ
                       source_bank_str = ""
                       if $no_color
                         if outsourcing_cost.source_bank_id == 1
                           source_bank_str = "北"
                         else
                           source_bank_str = "さ"
                         end
                       end
                       ##
                       
                       
                       #締め日等を取得
                       @construction_datum_id = purchase_datum.construction_datum_id
					   @purchase_date = purchase_datum.purchase_date.to_date
					   @closing_date = nil
                       @payment_due_date = nil
                       get_customer_date_info
                       #
                       
			           row.values purchase_date: purchase_datum.purchase_date,
                                  purchase_order_code: purchase_datum.purchase_order_datum.purchase_order_code,
                                  construction_code: construction_code,
								  construction_name: construction_name,
								  customer_name: customer_name,
					              purchase_amount: purchase_amount,
                                  purchase_amount_tax_in: purchase_amount_tax_in_str,
                                  closing_date: @closing_date,
                                  payment_due_date: @payment_due_date,
                                  payment_date: payment_date,
                                  payment_amount: payment_amount,
                                  unpaid_amount: unpaid_amount,
                                  unpaid_payment_date: unpaid_payment_date,
                                  source_bank: source_bank_str
                       
                       if purchase_datum.outsourcing_payment_flag == 1
                       #支払済みの場合の色
                         #row.item(:fmeDetail).styles(:fill_color => '#BF00FF')
                         #画面のままの色だと濃すぎるので、印刷用に薄くする
                         if !$no_color 
                            row.item(:fmeDetail).styles(:fill_color => '#CD70EC')  
                            #線が隠れるので色を戻す
                            row.item(:detail_line_1).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_2).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_3).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_4).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_5).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_6).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_7).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_8).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_9).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_10).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_11).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_12).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                         end
                       elsif purchase_datum.outsourcing_invoice_flag == 1
	                   #請求済みの場合の色
                         if !$no_color 
                            row.item(:fmeDetail).styles(:fill_color => '#E3CEF6')  
                            #線が隠れるので色を戻す
                            row.item(:detail_line_1).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_2).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_3).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_4).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_5).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_6).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_7).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_8).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_9).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_10).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_11).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                            row.item(:detail_line_12).styles(:fill_color => '#F2EAEF')  if purchase_datum.outsourcing_invoice_flag == 1
                         end
                       end
                       
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
        #@num = tmp_purchase_amount_total * $consumption_tax_include
        @num = @purchase_amount_tax_in_total   #upd191101
        
        formatNum()
		@purchase_amount_total_tax_in = @num
        
        #支払金額計
        @num = @payment_amount_total
        formatNum()
		@payment_amount_total = @num
        
        #未払金額計
        @num = @unpaid_amount_total
        formatNum()
		@unpaid_amount_total = @num
        
        
        #合計表示
        report.list(:default).add_row  memo: "合計", 
                                          purchase_amount: @purchase_amount_total,
                                          purchase_amount_tax_in: @purchase_amount_total_tax_in,
                                          payment_amount: @payment_amount_total, 
                                          unpaid_amount: @unpaid_amount_total
		
        # ThinReports::Reportを返す
        return report
		
  end  
   
end
   

  #得意先から締め日・支払日を算出
  #本来、コントローラと共通化させなければならない・・・・
  def get_customer_date_info
    
    require "date"
    
    #construction = ConstructionDatum.find(params[:purchase_datum][:construction_datum_id])
    construction = ConstructionDatum.where(:id => @construction_datum_id).first
    
    customer = nil
    if construction.present?
      customer = CustomerMaster.find(construction.customer_id)
    end
    
    if customer.present?
        
        addMonth = 0
        
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
          
          #if d.day < customer.closing_date
          if d.day <= customer.closing_date  #bugfix 200127
            if Date.valid_date?(d.year, d.month, customer.closing_date)
              @closing_date = Date.new(d.year, d.month, customer.closing_date)
            end
            
          else
          #締め日を過ぎていた場合、月＋１
            addMonth += 1
            d = d >> addMonth
            if Date.valid_date?(d.year, d.month, customer.closing_date)
              @closing_date = Date.new(d.year, d.month, customer.closing_date)
            end
          end
          
        end
        
        #支払日算出
        #d = @purchase_date
        d = @closing_date    #upd191112
        
        if d.nil?
          d = @purchase_date  #add191120
        end
 
        if customer.due_date.present?
          
          if customer.due_date >= 28   #月末とみなす
            d2 = Date.new(d.year, d.month, 28)  #一旦、エラーの出ない２８日を月末とさせる
            addMonth = customer.due_date_division 
            d2 = d2 >> addMonth
            d2 = Date.new(d2.year, d2.month, -1)
            @payment_due_date = d2
          else
          ##月末の扱いでなければ、そのまま
            if Date.valid_date?(d.year, d.month, customer.due_date)
                d2 = Date.new(d.year, d.month, customer.due_date)
                #addMonth = customer.due_date_division + addMonth
                addMonth = customer.due_date_division
                @payment_due_date = d2 >> addMonth
            end
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
