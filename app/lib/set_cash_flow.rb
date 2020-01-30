class SetCashFlow
#資金繰表明細データ(会計)への保存用クラス

  #@invoice_header = nil
  
  #〜以下は外注請求書の入力画面からcallされるもの〜
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
    payment_bank_id = 1
    
    #注文ID(工事IDはユニークではない為)で検索
    args = ["select * from account_cash_flow_detail_expected where purchase_id = ?", purchase_id]
    sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
    result_params = ActiveRecord::Base.connection.select_all(sql)
    
    if result_params.rows.blank?
    #新規追加
      #支払予定日・支払金額がある場合のみ登録
      if payment_due_date.present? && outsourcing_amount > 0
        args = ["INSERT INTO account_cash_flow_detail_expected(expected_date, purchase_id, expected_expense, 
                                         expected_income, payment_bank_id, payment_bank_branch_id, cash_id, account_title_id, billing_year_month) VALUES(? ,? , ? ,? ,? , ? ,?, ?, ?)", 
                                    payment_due_date, purchase_id, outsourcing_amount, 
                                    0, payment_bank_id, nil, nil, nil, nil]
        sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
        result_params = ActiveRecord::Base.connection.execute(sql)
      end
    else
    #更新
      #支払予定日・支払金額がある場合のみ登録
      if payment_due_date.present? && outsourcing_amount > 0
      
      else
      #すでにデータ存在していて、予定日or金額が入ってなければ削除とする
        args = ["DELETE FROM account_cash_flow_detail_expected where purchase_id = ?" , 
                                    purchase_id]
        sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
        result_params = ActiveRecord::Base.connection.execute(sql)
      end
    end
  end
  
  def destroy_outsourcing(purchase_id)
  #直接削除時に資金繰のデータも削除する
    if purchase_id.present?
      args = ["DELETE FROM account_cash_flow_detail_expected where purchase_id = ?" , 
                                    purchase_id]
      sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
      result_params = ActiveRecord::Base.connection.execute(sql)
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
        
      if @invoice_header.commission.present?
        amount += @invoice_header.commission
      end
        
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
                                         amount, @payment_bank_id, @cash_id, 1, 1, "2020-01-01", invoice_header_id, 0, nil]
        sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
        result_params = ActiveRecord::Base.connection.execute(sql)
      end
    else
    #更新
      if @invoice_header.payment_date.present? && @invoice_header.deposit_amount.present?
        #更新
        #args = ["UPDATE account_cash_flow_detail_actual SET actual_date=?, actual_income=?, payment_bank_id=?, cash_id=? where construction_id = ?" , 
        #                            @invoice_header.payment_date, amount, @payment_bank_id, @cash_id, construction_id]
        args = ["UPDATE account_cash_flow_detail_actual SET actual_date=?, actual_income=?, payment_bank_id=?, cash_id=? where invoice_header_id = ?" , 
                                    @invoice_header.payment_date, amount, @payment_bank_id, @cash_id, invoice_header_id]
        
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
  
  def get_payment_bank_and_cash_id
  
    @payment_bank_id = nil
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
      #三信(塚野目)
        @payment_bank_id = 3
      end
    end
  end
end