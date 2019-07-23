class OutsourcingInvoicePDF
   
  def self.create outsourcing_invoice
     
     #新元号対応 190401
     require "date"
     d_heisei_limit = Date.parse("2019/5/1")
  
     #仕入表(仕入先別)PDF発行
     for num in 1..2 do
  
         if num == 1
  
          # tlfファイルを読み込む
          report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/outsourcing_invoice_pdf.tlf")
       
          # 1ページ目を開始
          report.start_new_page
        else
          report.start_new_page layout: "#{Rails.root}/app/pdfs/outsourcing_invoice_r_pdf.tlf"
        
        end
        
        
        #初期化
        #@flag = nil
        #@purchase_order_code  = ""
        #@purchase_amount_subtotal = 0
        #@purchase_amount_total = 0

        $purchase_data.joins(:purchase_order_datum).order("purchase_date, purchase_order_code, id").each do |purchase_datum| 
        #ソート順は仕入日、注文ナンバーの順とする。
		
        #---見出し---
        
        #あとで社員(仕入先？)マスターから拾えるようにする
        case $purchase_data_current.supplier_id
        when 37  #村山電気
          staff_id = 3
        when 31  #須戸
          staff_id = 6
        when 39  #小柳
          staff_id = 5
        else
        end
        # 
        #
        
        #仕入先(外注)の各種情報を取得
        set_supplier_info(staff_id)
        
        #外注費データを取得
        outsourcing_cost = OutsourcingCost.where(:construction_datum_id => $purchase_data_current.construction_datum_id).
                           where(:staff_id => staff_id).first
                           
        
        #請求書コード
        page_count = report.page_count.to_s + "頁"
		report.page.item(:invoice_code).value(outsourcing_cost.invoice_code)
		 
        #発行日(仕入日)
        #if $purchase_data_current.purchase_date.present?
		#     @gengou = $purchase_data_current.purchase_date
        #upd190205
        #発行日=作業完了日
        if outsourcing_cost.present? && outsourcing_cost.working_end_date.present?
		     @gengou = outsourcing_cost.working_end_date
		       
             #元号変わったらここも要変更
             if @gengou >= d_heisei_limit
             #令和
               if @gengou.year - $gengo_minus_ad_2 == 1
               #元号変わったらここも要変更
                 @gengou = $gengo_name_2 + "元年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
               else
                 @gengou = $gengo_name_2 + "#{@gengou.year - $gengo_minus_ad_2}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
               end
             else
             #平成
               @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
             end
             report.page.item(:purchase_date).value(@gengou)
        end
        
        #外注の住所等
        report.page.item(:supplier_post).value(@supplier_post)
        report.page.item(:supplier_address).value(@supplier_address)
        report.page.item(:supplier_name).value(@supplier_name)
        report.page.item(:supplier_position).value(@supplier_position)
        report.page.item(:supplier_responsible).value(@supplier_responsible)
        report.page.item(:supplier_tel).value(@supplier_tel)
        report.page.item(:supplier_fax_label).value(@supplier_fax_label)  #add190514
        report.page.item(:supplier_fax).value(@supplier_fax)              #add190514
        #
        
        #注文No
        report.page.item(:purchase_order_code).value($purchase_data_current.purchase_order_datum.purchase_order_code) 
        
        #工事コード
        report.page.item(:construction_code).value($purchase_data_current.construction_datum.construction_code) 
        
        #upd190722
        #件名には備考も加える
        if $purchase_data_current.notes.blank?
            construction_name = $purchase_data_current.construction_datum.construction_name
        else
            construction_name = $purchase_data_current.construction_datum.construction_name + "（" + $purchase_data_current.notes + "）"
        end
        
        #件名
        #report.page.item(:construction_name).value($purchase_data_current.construction_datum.construction_name)
        #up190722
        report.page.item(:construction_name).value(construction_name) 
        
        #得意先名
        report.page.item(:customer_name).value($purchase_data_current.construction_datum.CustomerMaster.customer_name) 
 
 
        #工事場所(住所)
		#分割された住所を一つにまとめる。
	    all_address = $purchase_data_current.construction_datum.address
		if $purchase_data_current.construction_datum.house_number.present?
		     all_address += $purchase_data_current.construction_datum.house_number
		end
		if $purchase_data_current.construction_datum.address2.present?
		     all_address += "　" + $purchase_data_current.construction_datum.address2
		end
		report.page.item(:construction_place).value(all_address) 
		#
        
        #着工日
        if outsourcing_cost.present? && outsourcing_cost.working_start_date.present?
		   @gengou = outsourcing_cost.working_start_date
		   #元号変わったらここも要変更
           if @gengou >= d_heisei_limit
           #令和
             if @gengou.year - $gengo_minus_ad_2 == 1
             #１年の場合は元年と表記
               @gengou = $gengo_name_2 + "元年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
             else
               @gengou = $gengo_name_2 + "#{@gengou.year - $gengo_minus_ad_2}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
             end
           else
           #平成
             @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
           end
           report.page.item(:working_start_date).value(@gengou)
        end
        #完了日
        if outsourcing_cost.present? && outsourcing_cost.working_end_date.present?
		   @gengou = outsourcing_cost.working_end_date
		   #元号変わったらここも要変更
           if @gengou >= d_heisei_limit
           #令和
             if @gengou.year - $gengo_minus_ad_2 == 1
             #１年の場合は元年と表記
               @gengou = $gengo_name_2 + "元年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
             else
               @gengou = $gengo_name_2 + "#{@gengou.year - $gengo_minus_ad_2}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
             end
           else
           #平成
             @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
           end
           report.page.item(:working_end_date).value(@gengou)
        end
        
        #締め日
        if outsourcing_cost.present? && outsourcing_cost.closing_date.present?
		   @gengou = outsourcing_cost.closing_date
           #元号変わったらここも要変更
           if @gengou >= d_heisei_limit
           #令和
             if @gengou.year - $gengo_minus_ad_2 == 1
             #１年の場合は元年と表記
               @gengou = $gengo_name_2 + "元年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
             else
               @gengou = $gengo_name_2 + "#{@gengou.year - $gengo_minus_ad_2}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
             end
           else
           #平成
		     @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
           end
           report.page.item(:closing_date).value(@gengou)
        end
        
        #支払予定日
        if outsourcing_cost.present? && outsourcing_cost.payment_due_date.present?
		   @gengou = outsourcing_cost.payment_due_date
		   #元号変わったらここも要変更
           if @gengou >= d_heisei_limit
           #令和
             if @gengou.year - $gengo_minus_ad_2 == 1
             #１年の場合は元年と表記
             #↑次回は１本化しておく！！！
               @gengou = $gengo_name_2 + "元年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
             else
               @gengou = $gengo_name_2 + "#{@gengou.year - $gengo_minus_ad_2}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
             end
           else
           #平成
             @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
           end
           report.page.item(:payment_due_date).value(@gengou)
        end
        
        ###
        #工事代金
        #外注費データの請求金額は使わない・・
        @num = $purchase_data_current.purchase_amount
        formatNum()
		purchase_amount = @num
        report.page.item(:purchase_amount).value(purchase_amount)
        
        purchase_amount_tax_only = 0
        purchase_amount_tax_in = 0
        
        if $purchase_data_current.purchase_amount > 0
          purchase_amount_tax_only = $purchase_data_current.purchase_amount * $consumption_tax_only
          purchase_amount_tax_in = $purchase_data_current.purchase_amount * $consumption_tax_include
        end
        
        #税額
        @num = purchase_amount_tax_only
        formatNum()
		purchase_amount_tax_only = @num
        report.page.item(:purchase_amount_tax_only).value(purchase_amount_tax_only)
        #税込合計
        @num = purchase_amount_tax_in
        formatNum()
		purchase_amount_tax_in = @num
        report.page.item(:purchase_amount_tax_in).value(purchase_amount_tax_in)
        ###
        
	    
        #支払先情報
        report.page.item(:supplier_bank_name).value(@supplier_bank_name)
        report.page.item(:supplier_bank_branch_name).value(@supplier_bank_branch_name)
        report.page.item(:supplier_account_type_name).value(@supplier_account_type_name)
        report.page.item(:supplier_account_number).value(@supplier_account_number)
        report.page.item(:supplier_account_name).value(@supplier_account_name)
       

	end	
#end   
        #最終ページの出力はここで定義する
        #page_count = report.page_count.to_s + "頁"
        #report.page.item(:pageno).value(page_count)
    #for文の最終
    end
    
        # ThinReports::Reportを返す
        return report
		
  end  
   
end
   
  #仕入先(外注)の各種情報を拾う
  #とりあえず固定・・・あとでマスターにする！
  def set_supplier_info(staff_id)
    #初期化
    @supplier_post = ""
    @supplier_address = ""
    @supplier_name = ""
    @supplier_position = ""
    @supplier_responsible = ""
    @supplier_tel = ""
    @supplier_fax_label = ""  #add190514
    @supplier_fax = ""        #add190514
    #
    @supplier_bank_name = ""
    @supplier_bank_branch_name = ""
    @supplier_account_type_name = ""
    @supplier_account_number = ""
    @supplier_account_name = ""
    #
    
    case staff_id
    when 3  #村山電気
      @supplier_post = "955-0851"
      @supplier_address = "新潟県三条市西四日町2-5-1"
      @supplier_name = "村　山　電　気"
      @supplier_position = "代表"
      @supplier_responsible = "村山　敏弘"
      @supplier_tel = "0256-32-5550"
      #
      @supplier_bank_name = "第四銀行"
      @supplier_bank_branch_name = "三条南支店"
      @supplier_account_type_name = "普通"
      @supplier_account_number = "1108748"
      @supplier_account_name = "ムラヤマ　トシヒロ"
    when 6  #須戸
      @supplier_post = "959-1156"
      @supplier_address = "新潟県三条市大字福島新田乙943"
      @supplier_name = "  須 戸 デ ン キ"
      @supplier_position = "代表"
      @supplier_responsible = "須戸　剛"
      @supplier_tel = "0256-45-3205"
      @supplier_fax_label = "FAX"     #add190514
      @supplier_fax = "0256-45-3064"  #add190514
      #
      @supplier_bank_name = "三條信用組合"
      @supplier_bank_branch_name = "栄支店"
      @supplier_account_type_name = "普通"
      @supplier_account_number = "0004492"
      @supplier_account_name = "スド　ツヨシ"
    when 5  #小柳
      @supplier_post = "959-1263"
      @supplier_address = "新潟県燕市大曲3571-1"
      @supplier_name = "小　柳　電　気"
      @supplier_position = "代表"
      @supplier_responsible = "小柳　哲英"
      @supplier_tel = "0256-64-3548"
      #
      @supplier_bank_name = "第四銀行"
      @supplier_bank_branch_name = "燕支店"
      @supplier_account_type_name = "普通"
      @supplier_account_number = "1294461"
      @supplier_account_name = "オヤナギ　テツエイ"
      
    else
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
