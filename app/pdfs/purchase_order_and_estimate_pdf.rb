class PurchaseOrderAndEstimatePDF
  
  MAX_LINE = 20  #最大行数
  
  FLAG_ESTIMATE = 1 #見積依頼時
  FLAG_ORDER = 2    #注文時
  
  #def self.create purchase_order_and_estimate
  def self.create purchase_order
  #注文書PDF発行
  
    #新元号対応
    require "date"
    @d_heisei_limit = Date.parse("2019/5/1")
  
    # tlfファイルを読み込む
    report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/purchase_order_and_estimate_pdf.tlf")
    

    # 総ページ数
    #page_total = 0
    
  
    # 1ページ目を開始
    report.start_new_page
    @flag = nil
    
    
    #初期化
    #
    exist_no_price = false  #一つでも単価が抜けていればtrue
    
    #まずはページ数の判定を行う
    cnt = 0
    cnt2 = 0
    
    pre_page_count = 1
    last_page_count = 1
    $detail_parameters.values.each do 
      cnt += 1
      cnt2 += 1
      
      #if cnt > 19  #maxの行数 - 1
      if cnt >= MAX_LINE  #maxの行数 - 1
        pre_page_count += 1
        cnt = 0
      end
      
    end
    last_page_count = pre_page_count
    #
    
    #タイトル
    if $request_type == FLAG_ESTIMATE
      title = "見積依頼書"
    else
      title = "注　文　書"
    end
    #
    report.page.item(:title).value(title)
    
    if $request_type == FLAG_ESTIMATE
      request = "下記の通り見積依頼いたします。"
    else
      request = "下記の通り注文いたします。"
    end
    #
    report.page.item(:request_message).value(request)
    #
    
    #見出し
    
    ##$quotation_material_header
    
    report.page.item(:supplier_name).value($quotation_material_header.supplier_master.supplier_name + "御中")
    
    #report.page.item(:supplier_responsible_name).value($quotation_material_header.supplier_master.responsible1 + "様")
    #担当は先頭を取ってくる---複数の場合に無理があるかも??
    report.page.item(:supplier_responsible_name).value($quotation_material_header.supplier_master.supplier_responsibles[0].responsible_name + "様")
    
    #見積依頼/注文日
    #注文日:
    issue = "注文日"
    if $request_type == FLAG_ESTIMATE
      issue = "依頼日:"
    else
      issue = "注文日:"
    end
    report.page.item(:lbl_issue_date).value(issue)
    
    #report.page.item(:order_date).value($quotation_material_header.requested_date)
    #upd220721 発行した日付をセット
    report.page.item(:order_date).value(Time.now.in_time_zone('Tokyo').to_date)
    
    #注文番号(注文時のみ)
    if $request_type == FLAG_ORDER
      report.page.item(:order_code).value($purchase_order_code)
    end
    #見積番号
    report.page.item(:quotation_code).value($quotation_material_header.quotation_code)
    
    #工事名
    report.page.item(:construction_name).value($quotation_material_header.construction_datum.construction_name)
    #納品先
    if $quotation_material_header.delivery_place_flag.present?
      report.page.item(:delivery_place).value(PurchaseOrderHistory.delivery_place[$quotation_material_header.delivery_place_flag][0])
    end
    
    #binding.pry
    
    #備考
    #要切り分け
    #report.page.item(:notes).value("※記載されている金額は、前回納品時の金額です。変更のある場合は、納品書にて修正して下さい。")
    @notes = ""
    get_notes_by_supplier
    
    #report.page.item(:notes).value("※" + $quotation_material_header[:notes])
    report.page.item(:notes).value(@notes)
    
    subtotal = 0
    #total = 0
    
    #明細
    #注文でループ
    $detail_parameters.values.each_with_index.reverse_each do |item, index|
      
      #出力判定
      check = false
      
      #if item[:_destroy] != "1" && @bid_flag == 1 && @mail_sent_flag != "1"
      @quotation_unit_price = 0 
      @quotation_price = 0 
      @bid_flag = false
      @quotation_email_sent_flag = false
      @order_email_sent_flag = false
      
      #仕入先１〜３の各判定
      if $request_type == FLAG_ESTIMATE
        get_supplier_when_quotation(item)
      elsif $request_type == FLAG_ORDER
        get_supplier_when_order(item)
      end
      
      #各アイテムの出力判定
      if !$mail_flag
      #帳票の場合
        if $request_type == FLAG_ESTIMATE
        #見積の場合
          if item[:_destroy] != "true"
            check = true
          end
        else
        #注文の場合
          #if item[:_destroy] != "true"
          if item[:_destroy] != "true" && @bid_flag == true
            check = true
          end
        end
        #注文の場合
      else
      #メール送信の場合
        if $request_type == FLAG_ESTIMATE
        #見積の場合
          if item[:_destroy] != "true" && !@quotation_email_sent_flag
            check = true
          end
        else
        #注文の場合
          if item[:_destroy] != "true" && !@order_email_sent_flag && @bid_flag
            check = true
          end
        end
      end
      ##
      
      if check
        
        report.list(:default).add_row do |row|
          
          
          #品名(備考有無により表示切り分け)
          material_name = ""
          #material_name2 = ""
          notes = ""
          
          material_name = item[:material_name]
          
          #備考(資材単位)
          if item[:notes].present?
            #material_name2 = item[:material_name]
            notes = "※" + item[:notes]
          end
          
          #定価
          @num = item[:list_price].to_i
          formatNum()
          list_price = @num
          #needed??
          str_list_price = ""
          if item[:list_price].to_i > 0
            str_list_price = "定価" + list_price
          end
          #
          
          #仕入先１〜３の判定
          #if $request_type == 2
          #  get_supplier_when_order(item)
          #end
          #注文単価
          @num = 0  
          
          if $request_type == 2
            @num = @quotation_unit_price
          end
          
          #単価が存在しない場合のフラグ
          #念の為、残しておく
          #if @num == 0
          #  exist_no_price = true
          #end
          #
          
          formatNum()
          unit_price = @num
          ##
          
          #@num = item[:list_price].to_i #定価
          #金額
          amount = 0  
          if $request_type == 2
            amount = item[:quantity].to_i * @quotation_unit_price
          end
          @num = amount
          formatNum()
          str_amount = @num
          
          #binding.pry
          
          subtotal += amount
          
          row.values material_code: item[:material_code],
		                 material_name: material_name,
                     material_note: notes,
                     list_price: str_list_price,
                     #maker_name: order.maker_master.maker_name,
                     maker_name: item[:maker_name],
                     quantity: item[:quantity],
                     #unit_name: order.unit_master.unit_name,
                     unit_name: UnitMaster.all_list_by_id(item[:unit_master_id].to_i),
                     unit_price: unit_price,
                     amount: str_amount
          
        end 
      
        
        #ページ番号
        #(２ページ以上の場合のみ表示)
        if last_page_count > 1
          page_count = report.page_count.to_s + "/" + last_page_count.to_s
          report.page.item(:page_no).value(page_count)
        end
        #
        
        #合計
        #(最終ページにのみ表示)
        if report.page_count >= last_page_count
        #  report.page.item(:page_no).value(page_count)
          
          
          ##小計〜合計
          
          #合計
          @num = subtotal
          formatNum()
          str_subtotal = @num
          
          
          #単価が抜けているものがあれば合計は非表示にする
          if !exist_no_price
            report.page.item(:subtotal).value(str_subtotal)
          else
            report.page.item(:subtotal).visible(false)
          end
          
          report.page.item(:lbl_tax).value("")
          report.page.item(:lbl_total).visible(false)
        else
          #最終ページ以外は非表示に
          report.page.item(:lbl_subtotal).visible(false)
          report.page.item(:lbl_tax).value("")
          report.page.item(:lbl_total).visible(false)
        end
      
      end  #check sent
        
    end	#do end
      
    
    # ThinReports::Reportを返す
    return report

  end  
   
end

#仕入先毎の落札とメール送信フラグを取得
def get_bid_and_sent_flag
  
end

#仕入先毎の備考を取得
def get_notes_by_supplier
  
  case $supplier
    when 1
      @notes = $quotation_material_header[:notes_1]
    when 2
      @notes = $quotation_material_header[:notes_2]
    when 3
      @notes = $quotation_material_header[:notes_3]
  end
  
end

def get_supplier_when_quotation(item)
  
  #仕入先１〜３の判定
  case $supplier
    when 1
      @quotation_email_sent_flag = !item[:quotation_email_flag_1].to_i.zero?  
    when 2
      @quotation_email_sent_flag = !item[:quotation_email_flag_2].to_i.zero?
	  when 3
	    @quotation_email_sent_flag = !item[:quotation_email_flag_3].to_i.zero?
	  else #0
      @quotation_email_sent_flag = false
  end

end

def get_supplier_when_order(item)
  
  #仕入先１〜３の判定
  case $supplier
    when 1
      @quotation_price = item[:quotation_price_1].to_i 
      @quotation_unit_price = item[:quotation_unit_price_1].to_i 
      @bid_flag = !item[:bid_flag_1].to_i.zero? 
      @order_email_sent_flag = !item[:order_email_flag_1].to_i.zero?  
    when 2
      @quotation_price = item[:quotation_price_2].to_i 
      @quotation_unit_price = item[:quotation_unit_price_2].to_i 
      @bid_flag = !item[:bid_flag_2].to_i.zero? 
      @order_email_sent_flag = !item[:order_email_flag_2].to_i.zero? 
	  when 3
	    @quotation_price = item[:quotation_price_3].to_i
      @quotation_unit_price = item[:quotation_unit_price_3].to_i
	    @bid_flag = !item[:bid_flag_3].to_i.zero?
      @order_email_sent_flag = !item[:order_email_flag_3].to_i.zero? 
	end

end
   
def setGenGouDate(inDate)
  gengouDate = inDate
  
  #元号変わったらここも要変更
  if gengouDate >= @d_heisei_limit
  #令和
    if gengouDate.year - $gengo_minus_ad_2 == 1
    #１年の場合は元年と表記
      gengouDate = $gengo_name_2 + "元年#{gengouDate.strftime('%-m')}月#{gengouDate.strftime('%-d')}日"
    else
      gengouDate = $gengo_name_2 + "#{gengouDate.year - $gengo_minus_ad_2}年#{gengouDate.strftime('%-m')}月#{gengouDate.strftime('%-d')}日"
    end
  else
  #平成
    gengouDate = $gengo_name + "#{gengouDate.year - $gengo_minus_ad}年#{gengouDate.strftime('%-m')}月#{gengouDate.strftime('%-d')}日"
  end
  return gengouDate
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
