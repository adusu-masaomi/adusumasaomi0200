#class PurchaseOrderAndEstimatePDF
class PurchaseOrderPDF
  
  MAX_LINE = 20  #最大行数
  
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
    $order_parameters.values.each do 
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
    #ここは見積・注文の場合に変動する
    title = "注　文　書"
    #title = "見積依頼書"
    report.page.item(:title).value(title)
    
    request = "下記の通り注文いたします。"
    #request = "下記の通り見積依頼いたします。"
    report.page.item(:request_message).value(request)
    #
    
    #見出し
    
    report.page.item(:supplier_name).value($purchase_order_history.supplier_master.supplier_name + "御中")
    
    #report.page.item(:supplier_responsible_name).value($purchase_order_history.supplier_master.responsible1 + "様")
    #担当は先頭を取ってくる---複数の場合に無理があるかも??
    report.page.item(:supplier_responsible_name).value($purchase_order_history.supplier_master.supplier_responsibles[0].responsible_name + "様")
    
    #注文日
    report.page.item(:order_date).value($purchase_order_history.purchase_order_date)
  
    #注文番号
    report.page.item(:order_code).value($purchase_order_history.purchase_order_datum.purchase_order_code)
    #工事名
    report.page.item(:construction_name).value($purchase_order_history.purchase_order_datum.construction_datum.construction_name)
    #納品先
    report.page.item(:delivery_place).value(PurchaseOrderHistory.delivery_place[$purchase_order_history.delivery_place_flag][0])
    
    #備考
    #要切り分け
    report.page.item(:notes).value("※記載されている金額は、前回納品時の金額です。変更のある場合は、納品書にて修正して下さい。")
    if !$purchase_order_history[:notes].blank?
      #report.page.item(:notes).value("※" + $purchase_order_history[:notes])
      report.page.item(:notes2).value($purchase_order_history[:notes])
    end
    
    subtotal = 0
    #total = 0
    
    #明細
    #注文でループ
    $order_parameters.values.each_with_index.reverse_each do |item, index|
      
      #出力判定
      check = false
      if $mail_flag == 0
      #帳票の場合
        if item[:_destroy] != "true"
          check = true
        end
      else
      #メール送信の場合
        if item[:_destroy] != "true" && item[:mail_sent_flag] != 1 && item[:mail_sent_flag] != "1"
          check = true
        end
      end
      ##
      
      if check
      #if item[:_destroy] != "true" && item[:mail_sent_flag] != 1 && item[:mail_sent_flag] != "1"  
        
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
          #注文単価
          @num = item[:order_unit_price].to_i
          
          #単価が存在しない場合のフラグ
          if @num == 0
            exist_no_price = true
          end
          #
          
          formatNum()
          unit_price = @num
          
          
          #@num = item[:list_price].to_i #定価
          #金額
          amount = item[:quantity] * item[:order_unit_price].to_i
          @num = amount
          formatNum()
          str_amount = @num
          
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
          
          #復活もありえるので残しておく
          report.page.item(:lbl_subtotal).visible(true)
          #消費税(増税時要対応)
          #taxlabel = "消費税" + ($consumption_tax_only_per_ten * 100).to_i.to_s + "%"
          #report.page.item(:lbl_tax).value(taxlabel)
          #report.page.item(:lbl_total).visible(true)
          #
          
          ##小計〜合計
          
          #合計
          @num = subtotal
          formatNum()
          str_subtotal = @num
          
          #復活もありえるので残しておく
          #消費税
          #tax = subtotal * $consumption_tax_only_per_ten
          #@num = tax
          #formatNum()
          #str_tax = @num
          #合計(小数点四捨五入--仕入業者に合わせている)
          #total = subtotal * $consumption_tax_include_per_ten
          #@num = total
          #formatNum()
          #str_total = @num
          ##
          
          #単価が抜けているものがあれば合計は非表示にする
          if !exist_no_price
            report.page.item(:subtotal).value(str_subtotal)
          else
            report.page.item(:subtotal).visible(false)
          end
          
          #復活もありえるので残しておく
          #report.page.item(:tax).value(str_tax)
          #report.page.item(:total).value(str_total)
          #
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
