class PostMailer < ApplicationMailer
   
   
   #def send_when_update(user)
   def send_when_update(user, responsible_name, email_responsible, email_responsible2)
     #layout "mailer"
     
     @user = "注文No:" + user.purchase_order_code
    
     if user.alias_name.present?
     #通称名をセット
       @construction = "工事名:" + user.alias_name
     else
     #工事名をセット
       @construction = "工事名:" + user.construction_datum.construction_name
     end
    
     #現場住所
     @construction_place = "現場住所:"
     if user.construction_datum.address.present?
       @construction_place += user.construction_datum.post + "　" +
       user.construction_datum.address + user.construction_datum.house_number + 
       user.construction_datum.address2
     else
       @construction_place += "※ご確認下さい"
     end
    
     @supplier_name = user.supplier_master.supplier_name
    
     #@responsible_name = $responsible_name + "様"
     @responsible_name = responsible_name + "様"
    
     #件名に日時を入れる（メール重なるのを防ぐため）
     require 'date'
     subject_time = "<" + Time.now.to_s + ">"
    
     #本番用
     ###
     #if user.supplier_master.id != 5
     #    mail to: email_responsible ,
     #    cc: ["adusu@coda.ocn.ne.jp", "adusu-info@eos.ocn.ne.jp" , email_responsible2 ] ,
     #    subject: '注文番号登録依頼' + subject_time
     #else
     ##ムサシで選んだ場合、テストメールとする
     #    mail to: "camille.saekiZZZ@gmail.com" ,
     #    cc: "ilovekyosukehimuro@yahoo.co.jp", 
     #    subject: '注文番号登録依頼' + subject_time
     #end
     
     #test用
     mail to: "camille0816@gmail.com" ,
     cc: "i_kyohim@yahoo.co.jp", 
        
     #以下は消さない事!
     #件名に日時を入れる（メール重なるのを防ぐため）
     subject: '注文番号登録依頼' + subject_time
  end
  
  #注文依頼
  #def send_purchase_order(user)
  def send_purchase_order(user, responsible, email_responsible, email_responsible2, attachment)
   
    @purchase_order_code = "注文No:" + user.purchase_order_datum.purchase_order_code
    
    if user.purchase_order_datum.alias_name.present?
    #通称名をセット
      @construction_name = "工事名:" + user.purchase_order_datum.alias_name
    else
    #工事名をセット
      @construction_name = "工事名:" + user.purchase_order_datum.construction_datum.construction_name
    end
    
    #納品先
    @delivery_place = nil
    if user.delivery_place_flag.present?
      @delivery_place = "納品先:" + PurchaseOrderHistory.delivery_place[user.delivery_place_flag][0]
    end
    
    #備考
    @notes = nil
    if user.notes.present?
      @notes = "※"+ user.notes
    end
    #
    
    @supplier_name = user.supplier_master.supplier_name + " 御中"
    
    #担当者
    #if $responsible.present?
    if responsible.present?
      #@responsible_name = $responsible + "様"
      @responsible_name = responsible + "様"
    else
      @responsible_name = "ご担当者様"
    end

    #件名に日時を入れる（メール重なるのを防ぐため）
    require 'date'
    subject_time = "<" + Time.now.to_s + ">"
	
    # 添付ファイル
    #attachments['sample.jpg'] = ..File.read(‘./tmp/sample.jpg')
    send_time = Time.now.strftime('%Y%m%d%H%M%S')
    #attachments['注文書_' + send_time + '.pdf'] = $attachment
    attachments['注文書_' + send_time + '.pdf'] = attachment
  
    #本番用
    #メアドは画面より反映(ccは固定)
    #mail to: email_responsible ,
    #cc: ["adusu@coda.ocn.ne.jp", "adusu-info@eos.ocn.ne.jp" , email_responsible2 ] ,

    #test時!!
    #メアドは画面より反映(ccは固定)
    mail to: "camille0816@gmail.com" ,
    cc: "i_kyohim@yahoo.co.jp", 

    #以下は消さない事!
    #件名に日時を入れる（メール重なるのを防ぐため）
    subject: '注文依頼' + subject_time 
  
  end
  
  #見積依頼メール
  #def send_quotation_material(user)
  def send_quotation_material(user, responsible, email_responsible, email_responsible2, notes,
                            attachment)
    
    @quotation_code = "見積No:" + user.quotation_code
    if user.construction_datum.alias_name.present?
    #通称名をセット
      @construction_name = "工事名:" + user.construction_datum.alias_name
    else
    #工事名をセット
      @construction_name = "工事名:" + user.construction_datum.construction_name
    end
    @supplier_name = user.supplier_master.supplier_name + " 御中"

    #担当者
    #if $responsible.present?
    if responsible.present?
      #@responsible_name = $responsible + "様"
      @responsible_name = responsible + "様"
    else
      @responsible_name = "ご担当者様"
    end
    
    #備考(全体)をセット
    #@notes = $notes
    @notes = notes
   
    #件名に日時を入れる（メール重なるのを防ぐため）
    require 'date'
    subject_time = "<" + Time.now.to_s + ">"
    
    # 添付ファイル
    send_time = Time.now.strftime('%Y%m%d%H%M%S')
    #attachments['見積依頼書_' + send_time + '.pdf'] = $attachment
    attachments['見積依頼書_' + send_time + '.pdf'] = attachment
    
    #メアド確認
    #binding.pry
    
    #本番用
    #メアドは画面より反映(ccは固定)
    #mail to: email_responsible ,
    #担当者２のメアドがあれば、CCに加える。
    #cc: ["adusu@coda.ocn.ne.jp", "adusu-info@eos.ocn.ne.jp" , email_responsible2 ] ,
    
    #test時!!
    #メアドは画面より反映(ccは固定)
    mail to: "camille0816@gmail.com" ,
    cc: "i_kyohim@yahoo.co.jp", 

    #以下は消さない事!
    #件名に日時を入れる（メール重なるのを防ぐため）
    subject: '見積依頼' + subject_time

  end
  
  #注文依頼メール(見積後)
  #def send_order_after_quotation(user)
  def send_order_after_quotation(user, responsible, email_responsible, email_responsible2, notes, 
                                 new_code_flag, purchase_order_code, supplier, attachment)
    
    #@purchase_order_code = "注文No:" + $purchase_order_code
    @purchase_order_code = "注文No:" + purchase_order_code
    
    if user.construction_datum.alias_name.present?
    #通称名をセット
      @construction_name = "工事名:" + user.construction_datum.alias_name
    else
    #工事名をセット
      @construction_name = "工事名:" + user.construction_datum.construction_name
    end
    
    #納品先
    @delivery_place = nil
    if user.delivery_place_flag.present?
      @delivery_place = "納品先:" + PurchaseOrderHistory.delivery_place[user.delivery_place_flag][0]
    end
    #現場住所(新規の注文コードで現場のみ)
    @construction_place = nil
    #if $new_code_flag && user.delivery_place_flag == 0
    if new_code_flag && user.delivery_place_flag == 0
      @construction_place = "現場住所:"
      if user.construction_datum.address.present?
        @construction_place += user.construction_datum.post + "　" +
        user.construction_datum.address + user.construction_datum.house_number + 
        user.construction_datum.address2
      else
        @construction_place += "※ご確認下さい"
      end
    end
    
    @supplier_name = user.supplier_master.supplier_name + " 御中"
  
    #担当者
    #if $responsible.present?
    if responsible.present?
      #@responsible_name = $responsible + "様"
      @responsible_name = responsible + "様"
    else
      @responsible_name = "ご担当者様"
    end
    
    #備考(全体)
    #@notes = $notes
    @notes = notes
    
    #見積金額合計
  
    tmp_header = "注文金額合計：￥"
    #case $supplier
    case supplier
    when 1
      @total_quotation_price = tmp_header + user.total_order_price_1.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
    when 2
      @total_quotation_price = tmp_header + user.total_order_price_2.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
    when 3
      @total_quotation_price = tmp_header + user.total_order_price_3.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
    end
  
    
    #件名に日時を入れる（メール重なるのを防ぐため）
    require 'date'
    subject_time = "<" + Time.now.to_s + ">"
    
    #メアド確認
    #binding.pry
    
    #添付ファイル
    send_time = Time.now.strftime('%Y%m%d%H%M%S')
    #attachments['注文書_' + send_time + '.pdf'] = $attachment
    attachments['注文書_' + send_time + '.pdf'] = attachment
    
    #本番用
    #メアドは画面より反映(ccは固定)
    #mail to: email_responsible ,
    #担当者２のメアドがあれば、CCに加える。
    #cc: ["adusu@coda.ocn.ne.jp", "adusu-info@eos.ocn.ne.jp" , email_responsible2 ] ,

    #メアドは画面より反映(ccは固定)
    mail to: "camille0816@gmail.com" ,
    cc: "i_kyohim@yahoo.co.jp", 

    #以下は消さない事!
    #件名に日時を入れる（メール重なるのを防ぐため）
    subject: '注文依頼' + subject_time 
    
  end
  
end
