class OutsourcingToPayment < ApplicationController

  #外注データを支払データ(django)、入出金データ(expence,daily_cash_flow)へセットする
  def set_oursourcing_to_payment(purchase_data)
    
    require "date"
    #
    now_date = DateTime.now.to_date
    #
    date_tommorow = now_date + 1
    #
    payment_due_date = nil
    
    @amount_murayama = {}
    @amount_sudo = {}
    
    #発生月
    @occur_month_murayama = {}
    @occur_month_sudo = {}
    
    
    purchase_data.each do |pd|
      
      #須戸・村山電気以外ならスルー
      if pd.supplier_id != $SUPPLIER_MASER_ID_MURAYAMA_DENKI && 
         pd.supplier_id != $SUPPLIER_MASER_ID_SUDO_DENKI
        next
      end
      
      #外注支払データ呼出? -> purchase_dataのみでOKのようだ
      #outsourcingcost = OutsourcingCost.
      #       where(purchase_order_datum_id: pd.purchase_order_datum_id).first
            
      if pd.payment_date.present?
        next
      end
      
      
      if pd.payment_due_date.nil? || pd.payment_due_date <= now_date
        
        #日付は翌日にセット
        payment_due_date = date_tommorow.to_date
        
      else
        payment_due_date = pd.payment_due_date
        
      end
      
      #該当日へ加算
      set_occur_date(pd, payment_due_date)
      
      #該当の支払予定日へ加算する
      set_amount(pd, payment_due_date)
      
    end  #do end
    
    #先月のデータも削除する為、Hashへ追加
    add_last_month
    
    #該当月で未払の支払データを一旦抹消
    delete_payment(1)
    delete_payment(2)
  
    #支払データへ書込
    save_to_payment(1)
    save_to_payment(2)
    
  end
  
  #先月の情報も(あれば削除する為)配列へ追加
  def add_last_month
  
    #先月の１日を求める
    tmp_date = Date.today.last_month
    last_month = tmp_date.beginning_of_month.to_date
    
    if !(@occur_month_murayama.empty?)
      #村山電気
      #データ(Hash)存在、かつ該当月(先月)のキー無し？
      if !(@occur_month_murayama.has_key?(last_month))
        @occur_month_murayama[last_month] = "1"
      end
    elsif !(@occur_month_sudo.empty?)
      #須戸デンキ
      #データ(Hash)存在、かつ該当月(先月)のキー無し？
      if !(@occur_month_sudo.has_key?(last_month))
        @occur_month_sudo[last_month] = "1"
      end
    end
    
  end
  
  #該当月で未払いのデータを一旦抹消
  def delete_payment(flag)
    
    if flag == 1
      occur_months = @occur_month_murayama
      partner_id = $PARTNER_ID_MURAYAMA
    else
      occur_months = @occur_month_sudo
      partner_id = $PARTNER_ID_SUDO
    end
    
    #occur_month... ex. 04/01, "1"(データあれば)
    
    occur_months.each do |key, val|
      if val == "1"
        month = key
        
        #expence, daily_cash_flowからも引く必要あり!!
        payments = Payment.where(billing_year_month: month, partner_id: partner_id)
        
        if payments.present?
        
          payments.each do |payment|
            
            if payment.payment_date.nil?
              
              #ここでexpenceを削除
              delete_expence(payment)
              
              #ここでdaily_cash_flowを削除(マイナス)
              delete_daily_cash_flow(payment)
              
            end
            
          end
          
        end
        #
        
        #
        #該当する支払データを一旦抹消(支払いが未払いの場合)
        payments = Payment.where(billing_year_month: month, partner_id: partner_id).
                           where(payment_date: nil).destroy_all
        
      end
    end
    
    
  end
  
  #Expenceの削除
  def delete_expence(payment)
    
    expence = Expence.where(table_type_id: 1, table_id: payment.id).first
    
    if expence.present?
      
      @amount = payment.payment_amount
      
      expence.destroy
      
      #delete_daily_cash_flow(payment)
      
    end
    
  end
  
  def delete_daily_cash_flow(payment)
    
    if payment.payment_due_date_changed.present?
      #upd240510
      #支払予定変更日があれば優先
      daily_cash_flow = DailyCashFlow.where(cash_flow_date: payment.payment_due_date_changed).first
    else
      daily_cash_flow = DailyCashFlow.where(cash_flow_date: payment.payment_due_date).first
    end
    
    if daily_cash_flow.present?
      #データ有?
      amount = payment.billing_amount
      
      if amount.present?
        if daily_cash_flow.expence.present?
          daily_cash_flow.expence -= amount
          
          is_delete = false
          #incomeもexpenceも空なら削除対象とする
          if (daily_cash_flow.income.nil? || daily_cash_flow.income == 0) && 
             (daily_cash_flow.expence.nil? || daily_cash_flow.expence == 0)
            is_delete = true
          end
          
          if !(is_delete)
            daily_cash_flow.save!
          else
            #incomeもexpenceもゼロなら、削除
            daily_cash_flow.destroy
          end
        end
      end
    
    end
    
  end
  
  #支払データへ書込み
  def save_to_payment(flag)
    
    if flag == 1
      amounts = @amount_murayama
      partner_id = $PARTNER_ID_MURAYAMA
      @partner_name = "村山電気"
    else
      amounts = @amount_sudo
      partner_id = $PARTNER_ID_SUDO
      @partner_name = "須戸デンキ"
    end
    
    amounts.each do |key, val|
      
      #キーから年月を生成
      tmp_month = key.beginning_of_month
      @billing_year_month = tmp_month.to_date
      
      #支払予定日
      @occur_date = key
      
      #支払金額
      @amount = val
      
      account_title_id = $ACCOUNT_TITLE_ID_OUTSOURCING
      
      @payment_method_id = 1  #振込
      
      #支払済のデータ存在している場合、上書き??
      #基本、ないはず....
      
      payment_params = { billing_year_month: @billing_year_month, order: 0,
                         trade_division_id: 0, note: "", completed_flag: 0,
                         partner_id: partner_id, 
                         billing_amount: @amount, rough_estimate: @amount, 
                         payment_due_date: @occur_date, 
                         payment_method_id: @payment_method_id, 
                         account_title_id: account_title_id}
      payment = Payment.new(payment_params)
      payment.save!
      
      #id取得
      @payment_id = payment.id
      
      #支出データへ書込み
      set_expence
      
      #入出金データへ書込み
      set_daily_cash_flow
      ##
              
    end
  end
  
  #支出(expence)データを更新
  def set_expence()
    
    expence_params = { table_type_id: 1, table_id: @payment_id, 
                       payment_method_id: @payment_method_id,
                       payment_on: @occur_date,
                       name: @partner_name, 
                       payment_amount: @amount,
                       billing_year_month: @billing_year_month,
                       payment_source_id: 1,
                       is_estimate: 0, is_completed: 0 }
    expence = Expence.where(table_type_id: 1, table_id: @payment_id).first
    
    if expence.nil?
      expence = Expence.new(expence_params)
      expence.save!
    else
      expence.update(expence_params)
    end
  end
  
  def set_daily_cash_flow
    
    daily_cash_flow = DailyCashFlow.where(cash_flow_date: @occur_date).first
    
    if daily_cash_flow.blank?
      #新規
      daily_params = {cash_flow_date: @occur_date, 
                      expence: @amount,
                      income_completed_flag: 0,
                      expence_completed_flag: 0}
      
      daily_cash_flow = DailyCashFlow.new(daily_params)
      
      daily_cash_flow.save!
    else
      
      #追加
      if daily_cash_flow.expence.present?
        daily_cash_flow.expence += @amount
      else
        daily_cash_flow.expence = @amount
      end
      
      daily_cash_flow.save!
    end
     
  end
  
  
  def set_occur_date(pd, occur_date)
  
    #occur_month = occur_date.strftime("%Y%m")
    #↑NG 該当月の1日にする必要がある!!
    tmp_month = occur_date.beginning_of_month
    occur_month = tmp_month.to_date
    
    if pd.supplier_id == $SUPPLIER_MASER_ID_MURAYAMA_DENKI
      if @occur_month_murayama[occur_month].nil?
        @occur_month_murayama[occur_month] = "1"
      end
    elsif pd.supplier_id == $SUPPLIER_MASER_ID_SUDO_DENKI
      if @occur_month_sudo[occur_month].nil?
        @occur_month_sudo[occur_month] = "1"
      end
    end
    
  end
  
  #該当の支払予定日へ加算
  def set_amount(pd, occur_date)
    
    amount  = 0
      
    if pd.supplier_id == $SUPPLIER_MASER_ID_MURAYAMA_DENKI
      amount = @amount_murayama[occur_date]
    elsif pd.supplier_id == $SUPPLIER_MASER_ID_SUDO_DENKI
      amount = @amount_sudo[occur_date]
    end
    
    #ここで消費税の計算をする
    purchase_amount_tax_inc = pd.purchase_amount * $consumption_tax_include_per_ten
    #
    
    if pd.supplier_id == $SUPPLIER_MASER_ID_MURAYAMA_DENKI
      if amount.present?
        @amount_murayama[occur_date] = amount.to_i + purchase_amount_tax_inc
      else
        #初回は初期値をセット
        @amount_murayama[occur_date] = purchase_amount_tax_inc
      end
    elsif pd.supplier_id == $SUPPLIER_MASER_ID_SUDO_DENKI
      if amount.present?
        @amount_sudo[occur_date] = amount.to_i + purchase_amount_tax_inc
      else
        #初回は初期値をセット
        @amount_sudo[occur_date] = purchase_amount_tax_inc
      end
    end
    
  end
    
end