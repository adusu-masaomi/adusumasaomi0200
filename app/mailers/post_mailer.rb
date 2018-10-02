class PostMailer < ApplicationMailer
   
   
   def send_when_update(user)
    #layout "mailer"
    
    @user = "注文No:" + user.purchase_order_code
    
    #if user.construction_datum.alias_name.present?
    if user.alias_name.present?
    #通称名をセット
      #@construction = "工事名:" + user.construction_datum.alias_name
      @construction = "工事名:" + user.alias_name
    else
    #工事名をセット
      @construction = "工事名:" + user.construction_datum.construction_name
    end
    
	#add170317
    @supplier_name = user.supplier_master.supplier_name
    @responsible_name = user.supplier_master.responsible1 + "様"
    
        #件名に日時を入れる（メール重なるのを防ぐため）
        require 'date'
        subject_time = "<" + Time.now.to_s + ">"


        #本番用
        #mail to: $email_responsible ,
        #upd180405 担当者２のメアドがあれば、CCに加える。
        #cc: ["adusu@coda.ocn.ne.jp", "adusu-takano@aroma.ocn.ne.jp" , $email_responsible2 ] ,

        #test用
        mail to: "kamille1973@live.jp" ,
        cc: "ilovekyosukehimuro@yahoo.co.jp", 
        
        #以下は消さない事!
        #add180403
        #件名に日時を入れる（メール重なるのを防ぐため）
        subject: '注文番号登録依頼' + subject_time
  end
  
  #注文依頼
  def send_purchase_order(user)
   
    @purchase_order_code = "注文No:" + user.purchase_order_datum.purchase_order_code
    #if user.purchase_order_datum.construction_datum.alias_name.present?
    if user.purchase_order_datum.alias_name.present?
    #通称名をセット
      #@construction_name = "工事名:" + user.purchase_order_datum.construction_datum.alias_name
      @construction_name = "工事名:" + user.purchase_order_datum.alias_name
    else
    #工事名をセット
      @construction_name = "工事名:" + user.purchase_order_datum.construction_datum.construction_name
    end
    
    #add181002
    #備考
    @notes = nil
    if user.notes.present?
      @notes = "※"+ user.notes
    end
    #
    
    @supplier_name = user.supplier_master.supplier_name + " 御中"
    
    #担当者
	#if user.supplier_master.present? && user.supplier_master.responsible1.present?
	if $responsible.present?
      @responsible_name = $responsible + "様"
    else
	  @responsible_name = "ご担当者様"
	end

    #件名に日時を入れる（メール重なるのを防ぐため）
    require 'date'
    subject_time = "<" + Time.now.to_s + ">"
	
    #本番用
    #メアドは画面より反映(ccは固定)
    #mail to: $email_responsible ,
    #upd180405 担当者２のメアドがあれば、CCに加える。
    #cc: ["adusu@coda.ocn.ne.jp", "adusu-takano@aroma.ocn.ne.jp" , $email_responsible2 ] ,

    #メアドは画面より反映(ccは固定)
    mail to: "kamille1973@live.jp" ,
    cc: "ilovekyosukehimuro@yahoo.co.jp", 

    #以下は消さない事!
    #add180403
    #件名に日時を入れる（メール重なるのを防ぐため）
    subject: '注文依頼' + subject_time 
  
  end
  
  #見積依頼メール
  def send_quotation_material(user)
   
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
	if user.responsible.present?
      @responsible_name = user.responsible + "様"
    else
	  @responsible_name = "ご担当者様"
	end
    
    #add181002
    #備考(全体)をセット
    @notes = $notes
   
    #件名に日時を入れる（メール重なるのを防ぐため）
    require 'date'
    subject_time = "<" + Time.now.to_s + ">"

    #本番用
    #メアドは画面より反映(ccは固定)
    #mail to: $email_responsible ,
    #upd180405 担当者２のメアドがあれば、CCに加える。
    #cc: ["adusu@coda.ocn.ne.jp", "adusu-takano@aroma.ocn.ne.jp" , $email_responsible2 ] ,

    #メアドは画面より反映(ccは固定)
    mail to: "kamille1973@live.jp" ,
    cc: "ilovekyosukehimuro@yahoo.co.jp", 

    #以下は消さない事!
    #add180403
    #件名に日時を入れる（メール重なるのを防ぐため）
    subject: '見積依頼' + subject_time

  end
  #注文依頼メール(見積後)
  def send_order_after_quotation(user)
   
    #@quotation_code = "見積No:" + user.quotation_code

    @purchase_order_code = "注文No:" + $purchase_order_code
    if user.construction_datum.alias_name.present?
    #通称名をセット
      @construction_name = "工事名:" + user.construction_datum.alias_name
    else
    #工事名をセット
      @construction_name = "工事名:" + user.construction_datum.construction_name
    end
    @supplier_name = user.supplier_master.supplier_name + " 御中"
	
	#担当者
	if user.responsible.present?
      @responsible_name = user.responsible + "様"
    else
	  @responsible_name = "ご担当者様"
	end
    
    #add181002
    #備考(全体)をセット
    @notes = $notes
	
	#見積金額合計
	
	#upd171019
	#tmp_header = "見積合計価格：￥"
	tmp_header = "注文金額合計：￥"
	case $supplier
      when 1
        #@total_quotation_price = tmp_header + user.total_quotation_price_1.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
		@total_quotation_price = tmp_header + user.total_order_price_1.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
      when 2
        #@total_quotation_price = tmp_header + user.total_quotation_price_2.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
		@total_quotation_price = tmp_header + user.total_order_price_2.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
      when 3
        #@total_quotation_price = tmp_header + user.total_quotation_price_3.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
		@total_quotation_price = tmp_header + user.total_order_price_3.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
	end
	
	
    #件名に日時を入れる（メール重なるのを防ぐため）
    require 'date'
    subject_time = "<" + Time.now.to_s + ">"
	
    #本番用
    #メアドは画面より反映(ccは固定)
    #mail to: $email_responsible ,
    #upd180405 担当者２のメアドがあれば、CCに加える。
    #cc: ["adusu@coda.ocn.ne.jp", "adusu-takano@aroma.ocn.ne.jp" , $email_responsible2 ] ,

    #メアドは画面より反映(ccは固定)
    mail to: "kamille1973@live.jp" ,
    cc: "ilovekyosukehimuro@yahoo.co.jp", 

    #以下は消さない事!
    #add180403
    #件名に日時を入れる（メール重なるのを防ぐため）
    subject: '注文依頼' + subject_time 
    
  end
  
end
