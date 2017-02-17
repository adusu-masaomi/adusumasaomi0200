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
    

        #本番用
        #mail to: $email_responsible ,
        #cc: "adusu@coda.ocn.ne.jp",
        
        #test用
        mail to: "kamille1973@live.jp" ,
        cc: "ilovekyosukehimuro@yahoo.co.jp", 
        
        #以下は消さない事!
        subject: '注文番号登録依頼'
  end
  
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
    @supplier_name = user.supplier_master.supplier_name + " 御中"
    

    #本番用
    #メアドは画面より反映(ccは固定)
    #mail to: $email_responsible ,
    #cc: "adusu@coda.ocn.ne.jp",
 
    #メアドは画面より反映(ccは固定)
    mail to: "kamille1973@live.jp" ,
    cc: "ilovekyosukehimuro@yahoo.co.jp", 

    #以下は消さない事!
    subject: '注文依頼'
  
  end
  
end
