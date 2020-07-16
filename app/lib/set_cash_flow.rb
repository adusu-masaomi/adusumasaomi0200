class SetCashFlow
#資金繰表明細データ(会計)への保存用クラス

  #@invoice_header = nil
  
  
  #資金繰り表用のデータ作成する
  #djangoのカラムのため、SQL操作
  #
  #〜工事の画面からcallされるもの
  def set_cash_flow_detail_expected_for_construction(params, construction_datum)
    deposit_due_date = nil
    
    if params[:construction_datum][:deposit_due_date].present? 
      deposit_due_date = params[:construction_datum][:deposit_due_date]
    end
    
      args = ["select * from account_cash_flow_detail_expected where construction_id = ?", construction_datum.id]
      sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
      result_params = ActiveRecord::Base.connection.select_all(sql)

      #予定金額<>決定金額なら決定金額を優先する
      expected_income = 0
      if params[:construction_datum][:final_amount].present? && 
        params[:construction_datum][:final_amount].to_i > 0
        
        #決定金額をセット
        expected_income = params[:construction_datum][:final_amount]
      else
        #予定金額をそのままセット
        if params[:construction_datum][:estimated_amount].present?
          expected_income = params[:construction_datum][:estimated_amount]
        end
      end
      #
      
      #登録時に消費税をかける
      if expected_income.present? && expected_income.to_i > 0
        tmp_amount = expected_income.to_i * $consumption_tax_include_per_ten
        expected_income = tmp_amount.to_s
      end
      
      #支払先の銀行ID取得
      payment_bank_id = 1  #デフォルトは北越にする
      payment_bank_branch_id = 1 #支店もデフォルトは１に
      customer = nil
      
      if params[:construction_datum][:customer_id].present?
        customer = CustomerMaster.find(params[:construction_datum][:customer_id].to_i)
      end
      
      #銀行によって支店を振り分ける(rails側では支店マスターがないため）
      #現金予定のパターン有り？？
      
      if customer.present?
        if customer.payment_bank_id.present? && customer.payment_bank_id > 0
          case customer.payment_bank_id 
          when $BANK_ID_SANSHIN_HOKUETSU
            payment_bank_id = customer.payment_bank_id
          when $BANK_ID_SANSHIN_TSUKANOME
            payment_bank_id = customer.payment_bank_id
            payment_bank_branch_id = $A_BANK_BRANSH_ID_SANSHIN_TSUKANOME
          when $BANK_ID_SANSHIN_MAIN
            payment_bank_id = $BANK_ID_SANSHIN_TSUKANOME  #会計sysでは塚野目と同じIDになっている
            payment_bank_branch_id = $A_BANK_BRANSH_ID_SANSHIN_MAIN
          end
        end
      end
      #
      
      
      #新規・更新処理
      if result_params.rows.blank?
        #新規追加
        
        #if deposit_due_date.present?  #入金予定日が入ってなければ登録しない
        if deposit_due_date.present? && expected_income.to_i > 0 #入金予定日・金額が入ってなければ登録しない
            args = ["INSERT INTO account_cash_flow_detail_expected(expected_date, construction_id, expected_expense, 
                                            expected_income, payment_bank_id, payment_bank_branch_id, account_title_id, billing_year_month) VALUES(? ,? , ? ,? ,? , ? ,? ,?)", 
                                        deposit_due_date, construction_datum.id, 0, expected_income, payment_bank_id, payment_bank_branch_id, 1, "2020-01-01"]
             
            #account_title_idとbilling_year_monthは未使用だが適当な初期値を入れておく
            #args = ["INSERT INTO account_cash_flow_detail_expected(expected_date, construction_id, expected_expense, 
             #                               expected_income, payment_bank_id, payment_bank_branch_id, account_title_id, billing_year_month) VALUES(? ,? , ? ,? ,? , ? ,?, ?)", 
             #                           deposit_due_date, @construction_datum.id, 0, expected_income, payment_bank_id, 1, 1, "2020-01-01"]
            sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
            result_params = ActiveRecord::Base.connection.execute(sql)
        end
      else
      
        #binding.pry
      
        #if deposit_due_date.present?
        if deposit_due_date.present? && expected_income.to_i > 0
            #更新
            args = ["UPDATE account_cash_flow_detail_expected SET expected_date=?, expected_income=?, payment_bank_id=?, 
                            payment_bank_branch_id=? where construction_id = ?" , 
                                        deposit_due_date, expected_income, payment_bank_id, payment_bank_branch_id, construction_datum.id]
            sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
            result_params = ActiveRecord::Base.connection.execute(sql)
        else
           #すでにデータ存在していて、予定日が入ってなければ削除とする
           args = ["DELETE FROM account_cash_flow_detail_expected where construction_id = ?" , 
                                        construction_datum.id]
           sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
           result_params = ActiveRecord::Base.connection.execute(sql)
            
        end
      end
  end
  
  #〜以下は外注請求書の入力画面からcallされるもの〜
  def set_cash_flow_detail_actual_for_outsourcing(params, payment_date, outsourcing_amount)
  #実際データへの保存
    #
    
    purchase_id = params[:outsourcing_cost][:purchase_order_datum_id]
    #outsourcing_amount = params[:outsourcing_cost][:payment_amount].to_i
    
    #支払先銀行
    get_payment_bank_and_cash_id_for_outsourcing(params[:outsourcing_cost][:source_bank_id].to_i)
    
    
    #payment_bank_id = @payment_bank_id
    
    #支払方法
    payment_method_id = $A_PAYMENT_METHOD_ID_TRANSFER
    if @cash_id == 1
      payment_method_id = $A_PAYMENT_METHOD_ID_CASH #現金払のケースも考慮
    end
    
    #取引先
    partner_id = nil
    if params[:outsourcing_cost][:staff_id].present?
    
      case params[:outsourcing_cost][:staff_id].to_i
      when $STAFF_ID_MURAYAMA  #村山電気
        partner_id = $A_PARTNER_ID_MURAYAMA_DENKI
      when $STAFF_ID_SUDO      #須戸デンキ
        partner_id = $A_PARTNER_ID_SUDO_DENKI
      end
    end
    
    account_title_id = $A_ACCOUNT_TITLE_ID_OUTSOURCING   #科目を外注にする
    
    #注文ID(工事IDはユニークではない為)で検索
    args = ["select * from account_cash_flow_detail_actual where purchase_id = ?", purchase_id]
    sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
    result_params = ActiveRecord::Base.connection.select_all(sql)
    
    if result_params.rows.blank?
    #新規追加
      #支払予定日・支払金額がある場合のみ登録
      if payment_date.present? && outsourcing_amount > 0
        args = ["INSERT INTO account_cash_flow_detail_actual(actual_date, purchase_id, actual_expense, 
                                         actual_income, payment_bank_id, payment_bank_branch_id, cash_id, 
                                         billing_year_month, payment_method_id, account_title_id, partner_id,
                                         cash_book_id, invoice_header_id)
                                            VALUES(? ,? , ? ,? ,? ,?, ?, ?, ?, ?, ?, ?, ?)", 
                                    payment_date, purchase_id, outsourcing_amount, 
                                    0, @payment_bank_id, @payment_bank_branch_id, @cash_id, nil, payment_method_id, account_title_id, partner_id, nil, nil]
        sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
        result_params = ActiveRecord::Base.connection.execute(sql)
      end
    else
    #更新
      #支払予定日・支払金額がある場合のみ登録
      #account_title_id, partner_idはあとで消してOK(PG入れ替えつなぎ用)
      if payment_date.present? && outsourcing_amount > 0
        args = ["UPDATE account_cash_flow_detail_actual SET actual_date=?, actual_expense=?, payment_bank_id=? ,
                        payment_bank_branch_id=? , cash_id=?, payment_method_id=? , account_title_id=?, partner_id=? where purchase_id = ?" , 
                        payment_date, outsourcing_amount, @payment_bank_id, @payment_bank_branch_id ,
                        @cash_id, payment_method_id, account_title_id, partner_id, purchase_id]
        sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
        result_params = ActiveRecord::Base.connection.execute(sql)
            
      else
      #すでにデータ存在していて、予定日or金額が入ってなければ削除とする
        args = ["DELETE FROM account_cash_flow_detail_actual where purchase_id = ?" , 
                                    purchase_id]
        sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
        result_params = ActiveRecord::Base.connection.execute(sql)
      end
    end
    
  end
  
  def set_cash_flow_detail_expected_for_outsourcing(params, payment_due_date)
    
    #
    purchase_id = params[:purchase_datum][:purchase_order_datum_id]
    outsourcing_amount = params[:purchase_datum][:purchase_amount].to_i
    outsourcing_amount *= $consumption_tax_include_per_ten  #消費税をかける(8%時期は考慮していない)
    
    #purchase_date = params[:purchase_datum][:purchase_date]
    #construction_id = params[:purchase_datum][:construction_datum_id]
    #supplier_id = params[:purchase_datum][:supplier_id]
    #
    
    #支払先銀行
    #北越で固定とする。将来的に仕入先マスターにカラム追加して取得(?)
    payment_bank_id = $BANK_ID_SANSHIN_HOKUETSU #RAILS's ID=DJANGO's ID
    
    #add200130
    #支払方法->振込で固定
    payment_method_id = $A_PAYMENT_METHOD_ID_TRANSFER
    
    #注文ID(工事IDはユニークではない為)で検索
    args = ["select * from account_cash_flow_detail_expected where purchase_id = ?", purchase_id]
    sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
    result_params = ActiveRecord::Base.connection.select_all(sql)
    
    #取引先をセット
    partner_id = nil
    if params[:purchase_datum][:supplier_id].present?
      case params[:purchase_datum][:supplier_id].to_i
      when $SUPPLIER_MASER_ID_MURAYAMA_DENKI  #村山電気
        partner_id = $A_PARTNER_ID_MURAYAMA_DENKI
      when $SUPPLIER_MASER_ID_SUDO_DENKI      #須戸デンキ
        partner_id = $A_PARTNER_ID_SUDO_DENKI
      end
    end
    
    account_title_id = $A_ACCOUNT_TITLE_ID_OUTSOURCING   #科目を外注にする
    
    if result_params.rows.blank?
    #新規追加
      #支払予定日・支払金額がある場合のみ登録
      if payment_due_date.present? && outsourcing_amount > 0
        args = ["INSERT INTO account_cash_flow_detail_expected(expected_date, purchase_id, expected_expense, 
                                         expected_income, payment_bank_id, payment_bank_branch_id, cash_id, 
                                         billing_year_month, payment_method_id, account_title_id, partner_id,
                                         construction_id)
                                            VALUES(? ,? ,? ,? , ? ,?, ?, ?, ?, ?, ?, ?)", 
                                    payment_due_date, purchase_id, outsourcing_amount, 
                                    0, payment_bank_id, nil, nil, nil, payment_method_id, account_title_id, partner_id, nil]
        sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
        result_params = ActiveRecord::Base.connection.execute(sql)
      end
    else
    #更新
      #支払予定日・支払金額がある場合のみ登録
      #account_title_id, partner_idはあとで消してOK(PG入れ替えつなぎ用)
      if payment_due_date.present? && outsourcing_amount > 0
        args = ["UPDATE account_cash_flow_detail_expected SET expected_date=?, expected_expense=?, payment_bank_id=? ,
                        payment_method_id=? , account_title_id=?, partner_id=? where purchase_id = ?" , 
                        payment_due_date, outsourcing_amount, payment_bank_id, payment_method_id,  
                        account_title_id, partner_id, purchase_id]
        sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
        result_params = ActiveRecord::Base.connection.execute(sql)
            
      else
      #すでにデータ存在していて、予定日or金額が入ってなければ削除とする
        args = ["DELETE FROM account_cash_flow_detail_expected where purchase_id = ?" , 
                                    purchase_id]
        sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
        result_params = ActiveRecord::Base.connection.execute(sql)
      end
    end
  end
  
  #〜以下は請求書の入力画面からcallされるもの〜
  
  #入金額・入金日が入力されていたら資金繰データに反映させる処理
  def set_cash_flow_detail_actual_prepare(invoice_header)
    #if @invoice_header.payment_date.present? && @invoice_header.deposit_amount > 0
      #さんしんか北越かの振り分けもここでできる
      
      #請求見出データのパラメータをインスタンス変数にセット
      @invoice_header = invoice_header
      
      #if @invoice_header.construction_datum_id.blank?
      #Ｂクラフト等、工事データが内訳にまとめられている場合
        #(保留)請求書の納品書IDから納品書の工事番号をたどる。
        #@invoice_large = InvoiceDetailLargeClassification.where(invoice_header_id: @invoice_header.id)
	    #if @invoice_large.present?
          #amount_total = 0
          #請求書の内訳でループ
          #@invoice_large.each do |invoice_large|
            #if invoice_large.delivery_slip_header_id.present?
            #  #納品書データを取得
            #  delivery_slip_header = DeliverySlipHeader.find(invoice_large.delivery_slip_header_id)
            #  if delivery_slip_header.construction_datum_id.present?
            #    #納品書の工事データを取得
            #    construction_id = delivery_slip_header.construction_datum_id
            #    amount = invoice_large.invoice_price   #内訳の請求金額とする
            #    #資金繰明細データに登録する処理
            #    set_cash_flow_detail_actual(construction_id, amount)
            #    #消費税計算用に合計をセット
            #    if amount.present?
            #      amount_total += amount.to_i
            #    end
            #  end
            #end
          #end  #loop end
          
          ####作成途中・・・・(200124)
          #消費税・手数料・調整額をセット
          #amount_tax = amount_total * $consumption_tax_only_per_ten
        #end
      
      #else
      ##地場産など、請求書に直接、工事番号が入っている場合
        
        #construction_id = @invoice_header.construction_datum_id
        
      amount = 0
        
      if @invoice_header.deposit_amount.present?
        amount = @invoice_header.deposit_amount
      end
       
      #add200212 手数料は引いたままにしておく
      #if @invoice_header.commission.present?
      #  amount += @invoice_header.commission
      #end
        
      #資金繰明細データに登録する処理
      #set_cash_flow_detail_actual(construction_id, amount)
      set_cash_flow_detail_actual(@invoice_header.id, amount)
      
      #end
      
    #end
  end
  
  #資金繰明細データに登録する処理
  #def set_cash_flow_detail_actual(construction_id, amount)
  def set_cash_flow_detail_actual(invoice_header_id, amount)
  
    #args = ["select * from account_cash_flow_detail_actual where construction_id = ?", construction_id]
    args = ["select * from account_cash_flow_detail_actual where invoice_header_id = ?", invoice_header_id]
    sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
    result_params = ActiveRecord::Base.connection.select_all(sql)
        
    #振込先IDを取得
    get_payment_bank_and_cash_id
    
    if result_params.rows.blank?
    #新規追加
      #入金日・入金額がある場合のみ
      if @invoice_header.payment_date.present? && @invoice_header.deposit_amount > 0  
        #account_title_idとbilling_year_monthは未使用だが適当な初期値を入れておく
        args = ["INSERT INTO account_cash_flow_detail_actual(actual_date, actual_expense, 
                                         actual_income, payment_bank_id, payment_bank_branch_id, cash_id, account_title_id, billing_year_month, invoice_header_id, adjust_flag, cash_book_id) VALUES(? ,? ,? ,? , ? ,?, ?, ?, ?, ?, ?)", 
                                    @invoice_header.payment_date, 0, 
                                         amount, @payment_bank_id, @payment_bank_branchid, @cash_id, nil, "2020-01-01", invoice_header_id, 0, nil]
        sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
        result_params = ActiveRecord::Base.connection.execute(sql)
      end
    else
    #更新
      if @invoice_header.payment_date.present? && @invoice_header.deposit_amount.present?
        #更新
        #args = ["UPDATE account_cash_flow_detail_actual SET actual_date=?, actual_income=?, payment_bank_id=?, cash_id=? where construction_id = ?" , 
        #                            @invoice_header.payment_date, amount, @payment_bank_id, @cash_id, construction_id]
        args = ["UPDATE account_cash_flow_detail_actual SET actual_date=?, actual_income=?, payment_bank_id=?, payment_bank_branch_id=?, cash_id=? where invoice_header_id = ?" , 
                                    @invoice_header.payment_date, amount, @payment_bank_id, @payment_bank_branch_id, @cash_id, invoice_header_id]
        
        sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
        result_params = ActiveRecord::Base.connection.execute(sql)
      else
        #すでにデータ存在していて、予定日が入ってなければ削除とする
        #args = ["DELETE FROM account_cash_flow_detail_actual where construction_id = ?" , 
        #                            construction_id]
        args = ["DELETE FROM account_cash_flow_detail_actual where invoice_header_id = ?" , 
                                    invoice_header_id]
        
        sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
        result_params = ActiveRecord::Base.connection.execute(sql)
            
      end
    end
  end
  
  #資金繰明細(消費税or手数料or調整額)へセット
  def set_cash_flow_detail_actual_adjust(invoice_header_id)
    args = ["select * from account_cash_flow_detail_actual where invoice_header_id = ?", invoice_header_id]
    sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
    result_params = ActiveRecord::Base.connection.select_all(sql)
    
    #振込先IDを取得
    get_payment_bank_and_cash_id
    
  end
  #
  
  #(rails側)銀行IDから(会計用の)銀行、銀行支店IDをセットする
  #外注費データの場合
  def get_payment_bank_and_cash_id_for_outsourcing(source_bank_id)
    @payment_bank_id = nil
    @payment_bank_branch_id = nil
    @cash_id = 0
    
    if source_bank_id != $BANK_ID_CASH
    #銀行振込の場合
      if source_bank_id == $BANK_ID_SANSHIN_HOKUETSU
      #北越(支店は考慮しない)
        @payment_bank_id = source_bank_id #同じIDでセット
      elsif source_bank_id == $BANK_ID_SANSHIN_TSUKANOME
      #三信(塚野目)
        @payment_bank_id = source_bank_id #同じIDでセット
        @payment_bank_branch_id = $A_BANK_BRANSH_ID_SANSHIN_TSUKANOME
      elsif source_bank_id == $BANK_ID_SANSHIN_MAIN
      #三信(本店)
        @payment_bank_id = $BANK_ID_SANSHIN_TSUKANOME #塚野目支店と同じ銀行ID(さんしん)でセット
        @payment_bank_branch_id = $A_BANK_BRANSH_ID_SANSHIN_MAIN
      end
    else
    #現金の場合(レアケースだが)
      @cash_id = 1
    end
  end
  
  def get_payment_bank_and_cash_id
    @payment_bank_id = nil
    @payment_bank_branch_id = nil
    @cash_id = 0
    if @invoice_header.payment_method_id.nil? || @invoice_header.payment_method_id == 1
    #現金
      @cash_id = 1
    else
    #銀行振込の場合
      if @invoice_header.payment_method_id == 2
      #北越
        @payment_bank_id = 1
      elsif @invoice_header.payment_method_id == 3
      #三信(塚野目)  本店はないものとする
        @payment_bank_id = 3
        @payment_bank_branch_id = $A_BANK_BRANSH_ID_SANSHIN_TSUKANOME
      end
    end
  end
  
  def destroy_outsourcing_expected(purchase_id)
  #直接削除時に資金繰のデータも(予定)削除する
    if purchase_id.present?
      args = ["DELETE FROM account_cash_flow_detail_expected where purchase_id = ?" , 
                                    purchase_id]
      sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
      result_params = ActiveRecord::Base.connection.execute(sql)
    end
  end
  def destroy_outsourcing_actual(purchase_id)
  #直接削除時に資金繰のデータ(実際)も削除する
    if purchase_id.present?
      args = ["DELETE FROM account_cash_flow_detail_actual where purchase_id = ?" , 
                                    purchase_id]
      sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
      result_params = ActiveRecord::Base.connection.execute(sql)
    end
  end

end  #Class end
