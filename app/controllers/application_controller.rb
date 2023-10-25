class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  ### ここから追加(ログイン) ###
  #before_action :user_logged_in? #ログインチェックの事前認証

  def reset_user_session
    session[:user] = nil
    @current_user = nil
  end

  def user_logged_in?
    user_id = session[:user]
    if user_id then
      begin
        @current_user = User.find(user_id)
      rescue ActiveRecord::RecordNotFound
        reset_user_session
      end
    end

    # current_userが取れなかった場合はログイン画面にリダイレクト
    unless @current_user
      flash[:referer] = request.fullpath
      redirect_to "/rails/login"
    end
  end
  ### ここまで追加(ログイン) ###
  
  #add191204
  #西暦から和暦に変換するメソッド(in=Date , out=String)
  def WesternToJapaneseCalendar(westernYear)
  
    japaneseCalendar = westernYear
    japaneseCalendarChar = westernYear.to_s
    
    d_heisei_limit = Date.parse("2019/5/1");
    
    #元号変わったらここも要変更
    if japaneseCalendar >= d_heisei_limit
      #令和
      if japaneseCalendar.year - $gengo_minus_ad_2 == 1
      #１年の場合は元年と表記
        japaneseCalendarChar = $gengo_name_2 + "元年#{japaneseCalendar.strftime('%-m')}月#{japaneseCalendar.strftime('%-d')}日"
      else
        japaneseCalendarChar = $gengo_name_2 + "#{japaneseCalendar.year - $gengo_minus_ad_2}年#{japaneseCalendar.strftime('%-m')}月#{japaneseCalendar.strftime('%-d')}日"
      end
    else
      #平成
      japaneseCalendarChar = $gengo_name + "#{japaneseCalendar.year - $gengo_minus_ad}年#{japaneseCalendar.strftime('%-m')}月#{japaneseCalendar.strftime('%-d')}日" 
    end
    
    return japaneseCalendarChar
  end
  
  #仕入担当者の名前、Email取得
  def app_set_responsible(param_responsible, param_email, param_supplier)
    
    #supplier_update_flag = nil
    supplier_responsible = nil
    
    @supplier_responsible_id = 0
    
    #$responsible = nil
    #$email_responsible = nil
    
    @responsible = nil
    @email_responsible = nil
        
    if param_responsible.to_i > 0
      #担当者選択した場合
      supplier_responsible = SupplierResponsible.where(id: param_responsible).first
      #if supplier_responsible.present?
      if supplier_responsible.present? && (supplier_responsible.supplier_master_id == param_supplier.to_i)
        #担当者をセット
        #$responsible = supplier_responsible.responsible_name
        @responsible = supplier_responsible.responsible_name
        #担当Emailをセット
        #$email_responsible = supplier_responsible.responsible_email
        @email_responsible = supplier_responsible.responsible_email
       
        #必ず更新とする  
        @supplier_update_flag = 2
            
        #メアドのみ新規の場合
        if param_email.to_i == 0
          #$email_responsible = param_email
          @email_responsible = param_email
        else
          #メアドが別IDのものの場合(あり得る？？)
          #param_email
          supplier_responsible_other = SupplierResponsible.
                  where(id: param_email).first
          if supplier_responsible_other.present?
            #$email_responsible = supplier_responsible_other.responsible_email
            @email_responsible = supplier_responsible_other.responsible_email
          end
        end
        #end
      end
    else
      #担当者手入力の場合
        
      @supplier_update_flag = 1
        
      #担当者をセット
      #$responsible = param_responsible
      #$email_responsible = param_email
      @responsible = param_responsible
      @email_responsible = param_email
        
      #メアドがIDの場合(違う名前で同一Emailの場合)
      if param_email.to_i > 0
        supplier_responsible = SupplierResponsible.where(id: 
                                        param_email).first
        if supplier_responsible.present?
          #$email_responsible = supplier_responsible.responsible_email
          @email_responsible = supplier_responsible.responsible_email
        end
      end
    end
    
    #処理遅延で担当者が空になっている場合、最初の担当とする
    #if $responsible.nil? && $email_responsible.nil?
    if @responsible.nil? && @email_responsible.nil?
      
      supplier_id = param_supplier.to_i
      supplier_responsible = SupplierResponsible.where(supplier_master_id: supplier_id).first
      
      if supplier_responsible.present?
        #担当者をセット
        #$responsible = supplier_responsible.responsible_name
        @responsible = supplier_responsible.responsible_name
        #担当Emailをセット
        #$email_responsible = supplier_responsible.responsible_email
        @email_responsible = supplier_responsible.responsible_email
      end
    
    end
    
    #add230502
    return @responsible, @email_responsible
    
    #return supplier_update_flag
  end
  
  #仕入担当者の追加・更新
  def app_update_responsible(param_supplier_master_id, param_responsible, param_purchase_order_datum_id,
                             purchase_order_update_flag, responsible, email_responsible)
  #def app_update_responsible(param_supplier_master_id, param_responsible, param_purchase_order_datum_id,
  #                           purchase_order_update_flag)
    
    supplier_responsible_params = { supplier_master_id: param_supplier_master_id,
                                    responsible_name: responsible,
                                    responsible_email: email_responsible }
    
    #supplier_responsible_params = { supplier_master_id: param_supplier_master_id,
    #                                responsible_name: $responsible,
    #                                responsible_email: $email_responsible }
    
    
    case @supplier_update_flag
    when 1  #新規
      supplier_responsible = SupplierResponsible.new(supplier_responsible_params)
      supplier_responsible.save!(:validate => false)
        
      #パラメーターへ再び戻す
      #params[:purchase_order_datum][:@supplier_responsible_id] = supplier_responsible.id
      @supplier_responsible_id = supplier_responsible.id
    when 2  #更新
      supplier_responsible = SupplierResponsible.where(:id => param_responsible).first
        
      if supplier_responsible.present?
        @supplier_responsible_id = supplier_responsible.id
        supplier_responsible.update(supplier_responsible_params)
      end
    end
    
    #注文データの担当者もアプデしておく
    if purchase_order_update_flag == 0  #注文履歴画面から呼んだ場合
      if @supplier_update_flag > 0
        purchase_order_data = PurchaseOrderDatum.where(:id => param_purchase_order_datum_id).first
        if purchase_order_data.present?
          purchase_order_data_params = { supplier_responsible_id: @supplier_responsible_id }
          purchase_order_data.update(purchase_order_data_params)
        end
      end
    end
  end
  
  #add220123
  #請求日から入金予定日の計算
  #(last_day_flag == true 締日未設定の場合でも予定日を月末か翌月末にする)
  def app_get_income_due_date(customer_master_id, billing_date, last_day_flag)
    
    @customer = nil
    if customer_master_id.present?
      @customer = CustomerMaster.find(customer_master_id)
    end
    
    #binding.pry
    
    if @customer.present?
      
      #@purchase_date = Date.parse(billing_date)
      @purchase_date = billing_date
 
      @closing_date = nil
      @payment_due_date = nil
      addMonth = 0
      
    
      #締め日算出
      if @customer.closing_date_division == 1
      #月末の場合
        d = @purchase_date
        @closing_date = Date.new(d.year, d.month, -1)
      else
      #日付指定の場合
        d = @purchase_date
        
        if @customer.closing_date != 0
          
          if d.day <= @customer.closing_date  #bugfix 200127
            if Date.valid_date?(d.year, d.month, @customer.closing_date)
              @closing_date = Date.new(d.year, d.month, @customer.closing_date)
            else
            #日付指定で31日などを指定した場合(31日がない場合ここに来る)は、月末とみなす
            #add230715
              @closing_date = Date.new(d.year, d.month, -1)
            end
          else
            #締め日を過ぎていた場合、月＋１
            addMonth += 1
            
            d = d >> addMonth
            
            if Date.valid_date?(d.year, d.month, @customer.closing_date)
              @closing_date = Date.new(d.year, d.month, @customer.closing_date) 
            end
          end
        else
          #日付指定有で指定日未入力なら、月末とみなす
          #add200110
          d = @purchase_date
          @closing_date = Date.new(d.year, d.month, -1)
        end
          
      end
        
      #支払日算出
      d = @closing_date   
      if @customer.due_date.present?  && @customer.due_date > 0
          
        if @customer.due_date >= 28   #月末とみなす
          d2 = Date.new(d.year, d.month, 28)  #一旦、エラーの出ない２８日を月末とさせる
            
          addMonth = @customer.due_date_division 
            
          d2 = d2 >> addMonth
          d2 = Date.new(d2.year, d2.month, -1)
            
          @payment_due_date = d2
          
        else
        ##月末の扱いでなければ、そのまま
          #binding.pry
          
          if Date.valid_date?(d.year, d.month, @customer.due_date)
            d2 = Date.new(d.year, d.month, @customer.due_date)
            
            addMonth = @customer.due_date_division
              
            @payment_due_date = d2 >> addMonth
            
          end
        end
        
      end
    
      #
      #締日設定がない場合、月末を支払い日にする
      if last_day_flag
        if @payment_due_date.blank?
          d = @purchase_date
          addMonth = 0
          
          if d.day > 15
            addMonth += 1
          end
          
          d = d >> addMonth
          @payment_due_date = Date.new(d.year, d.month, -1)
        end
      end
      #
    
    end
  end
  ##
  
  #日次入出金マスターへの書き込み
  #@differ_amount, @differ_date, @payment_due_dateが事前取得されていること
  def app_upsert_daily_cash_flow
  
    daily_cash_flow = DailyCashFlow.find_by(cash_flow_date: @payment_due_date)
    if daily_cash_flow.nil?
    #データ無しの場合
          
      #前日までの残高を取得(保留)
      #get_pre_balance
      #前日残をセット(保留)
      #pre_balance = 0
      #if @pre_balance.present?
      #  pre_balance += @pre_balance
      #end
      #残高をセット(保留)
      #balance = pre_balance + @differ_amount
      #
      #daily_cash_flow_params = { cash_flow_date: @payment_due_date, income: @differ_amount,
      #                          previous_balance: pre_balance, balance: balance }
      
      daily_cash_flow_params = { cash_flow_date: @payment_due_date, income: @differ_amount }
      
          
      @check = DailyCashFlow.create(daily_cash_flow_params)
    else
    #データ存在している場合
          
      if @differ_amount.abs > 0
        #残高をセット
        income = daily_cash_flow.income.to_i + @differ_amount
        #balance = daily_cash_flow.previous_balance.to_i + income - daily_cash_flow.expence.to_i
        daily_cash_flow_params = { income: income, income_completed_flag: 0}  #追加を考慮し、完了フラグは0にする
        daily_cash_flow.update(daily_cash_flow_params)
      end
    end
        
    #日付変わった場合、差異をマイナスする
    if @differ_date.present?
      app_delete_daily_cash_flow
    end
    #
    
    #同月内の、前日残高へ加算(保留)
    #add_pre_balance_to_end_month
  end
  
  #入出金データからマイナスする
  #@differ_date, @differ_amountが取得されている事
  def app_delete_daily_cash_flow
    daily_cash_flow = DailyCashFlow.find_by(cash_flow_date: @differ_date)
    
    if daily_cash_flow.present?
      daily_cash_flow.income -= @differ_amount
      
      #残高も要計算(保留)
      #daily_cash_flow.balance = daily_cash_flow.previous_balance - daily_cash_flow.income - daily_cash_flow.expence.to_i
      
      daily_cash_flow.save!(:validate => false)
    end
    
  end
  ##
  
  
  #元号の設定(改定時はここを変更する)
  $gengo_name = "平成"      #平成の場合
  $gengo_name_2 = "令和"    #令和 〃
  $GENGO_ALPHABET = "H"    #平成の場合
  $GENGO_ALPHABET_2 = "R"  #令和 〃
  #$ad = 1988
  $gengo_minus_ad = 1988   #平成の場合
  $gengo_minus_ad_2 = 2018
  
  #消費税の設定(改定時はここを変更する→xx)
  $consumption_tax_only = 0.08
  $consumption_tax_include = 1.08
  
  #消費税１０％の対応(切り替えのタイミングがあるので、こうやって定数追加した方がよい)
  $consumption_tax_only_per_ten = 0.10
  $consumption_tax_include_per_ten = 1.10
  
  #add170308
  #見積等での工事種別の定数
  #(変更時はapplication.html.erbも要変更)
  $INDEX_SUBTOTAL = 1                    #小計
  $INDEX_DISCOUNT = 2                    #値引き
  $INDEX_PIPING_WIRING_CONSTRUCTION = 3  #配管配線工事
  $INDEX_EUIPMENT_MOUNTING = 4          #機器取付工事
  $INDEX_LABOR_COST = 5                  #労務費
  
  #add170310
  #見積書などの、見出しコードの仮番
  $HEADER_CODE_MAX = "9999999999"
  #確定申告区分のZ(明細有)のコード
  $FINAL_RETURN_DIVISION_Z = 9
  
  #仕入区分
  $INDEX_DIVISION_PURCHASE = 1    #仕入 add180324
  $INDEX_DIVISION_SHIPPING = 5    #出庫 
  
  #在庫の区分
  $INDEX_INVENTORY_STOCK = 0       #入庫
  $INDEX_INVENTORY_SHIPPING = 1    #出庫
  $INDEX_INVENTORY_STOCKTAKE = 2   #棚卸
  
  #仕入先業者
  $SUPPLIER_MASER_ID_OKADA_DENKI_SANGYO = 2
  $SUPPLIER_MASER_ID_OST = 4   #add200715
  $SUPPLIER_MASER_ID_OWN_COMPANY = 10 
  $SUPPLIER_MASER_ID_MURAYAMA_DENKI = 37
  $SUPPLIER_MASER_ID_SUDO_DENKI = 31
  $SUPPLIER_MASER_ID_OYANAGI_DENKI = 39
  
  #社員ID
  $STAFF_ID_MURAYAMA = 3   #add200201
  $STAFF_ID_SUDO = 6       #add200201
  $STAFF_ID_OYANAGI = 5    #add200201
  
  #工事ID(170915~未使用？)
  $CUNSTRUCTION_ID_AIR_CONDITIONING_ELEMENT = 976 #エアコン部材
  $CUNSTRUCTION_ID_PIPE_AND_WIRING = 977          #配管配線
  $CUNSTRUCTION_ID_CABLE = 978                    #ケーブル
  #$CONSTRUCTION_ID_LIGHTING_EQUIPMENT = 1083      #照明器具 add170915
  
  #在庫品目(170915~未使用？)
  $INVENTORY_CATEGORY_AIR_CONDITIONING_ELEMENT = 0
  $INVENTORY_CATEGORY_PIPE_AND_WIRING = 1
  $INVENTORY_CATEGORY_ID_CABLE = 2
  #$INVENTORY_LIGHTING_EQUIPMENT = 3               #照明器具 add170915
  
  $CONSTRUCTION_NULL_DATE = "2021/01/01"         #工事開始日などの、NULL値として扱う日付(add180113)
  $CONSTRUCTION_QUERY_NULL_DATE = "//"           #(add180113)
  
  #労務単価定数
  $LABOR_COST = 11000
  #$LABOR_COST = 12100   #upd200108
  
  #$INDEX_SUPPLIER_OKADA = 2     #仕入先ID(岡田電気)   #del200715
  
  $STRING_COPY = "(コピー)"      #明細をコピーした場合にアイテム名につける文字  (add180912)
  
  #ADUSU側銀行マスターID
  #$BANK_ID_SANSHIN_HOKUETSU = 1
  $BANK_ID_DAISHI_HOKUETSU = 1    #upd 230306
  $BANK_ID_SANSHIN_TSUKANOME = 3
  $BANK_ID_SANSHIN_MAIN = 4 #さんしん本店(*本来、支店IDで分けるべき?)
  $BANK_ID_CASH = 9 #現金(*本来、支店IDで分けるべき?)  #add200201
  
  #add230405
  #支払方法ID(請求書ヘッダにて使用)
  $PAYMENT_METHOD_ID_CASH = 1
  $PAYMENT_METHOD_ID_DAISHI_HOKUETSU = 2
  $PAYMENT_METHOD_ID_SANSHIN = 3
  
  #会計システム用の定数
  #勘定科目
  $A_ACCOUNT_TITLE_ID_OUTSOURCING = 2
  #支払方法
  $A_PAYMENT_METHOD_ID_TRANSFER = 1    #add200201
  $A_PAYMENT_METHOD_ID_CASH = 4        #add200201
  #取引先
  $A_PARTNER_ID_MURAYAMA_DENKI = 73
  $A_PARTNER_ID_SUDO_DENKI = 50
  #銀行支店
  $A_BANK_BRANSH_ID_SANSHIN_MAIN = 19
  $A_BANK_BRANSH_ID_SANSHIN_TSUKANOME = 21
end
