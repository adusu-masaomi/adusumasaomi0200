class ProfitDetailCostPDF < ConstantProfit
  
  #定数は別クラスより継承
  
  #COST_ID_CONSTRUCTION = 1
  #COST_ID_COST = 2
  #COST_ID_REPAYMENT = 3     #返済
  
  #テーブル判別ID
  #TABLE_TYPE_ID_CONSTRUCTION = 1
  #TABLE_TYPE_ID_PAYMENT = 2
  #TABLE_TYPE_ID_CASH_BOOK = 3
  #
  #COST_FLAG_COST = 1
  #COST_FLAG_REPAYMENT = 2
  #
  #支払方法
  #PAYMENT_METHOD = ["", "振込", "口座振替", "ＡＴＭ", "現金"]
  #PAYMENT_METHOD_CASH = 4  #現金
  
  #TITLE_COST = "経費"
  
  def self.create(profit_details, from_date, to_date)
    
    report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/profit_detail_cost_repayment_pdf.tlf")
    
    # 1ページ目を開始
    report.start_new_page
    
    
    report.page.item(:print_title).value("明細表(経費)")
    
    #日付(from-to)
    if from_date.present?
      from_month = from_date.year.to_s + "/" + from_date.month.to_s + "/" + from_date.day.to_s
      report.page.item(:from_date).value(from_month)
    end
    
    if to_date.present?
      to_month = to_date.year.to_s + "/" + to_date.month.to_s + "/" + to_date.day.to_s
      report.page.item(:to_date).value(to_month)
    end
    #
    
    #合計金額
    @amount_total = 0
    
    #経費の集計
    profit_details.where(:cost_id => COST_ID_COST).order(:occurred_on).each do |profit_detail|
      
      occurred_on = profit_detail.occurred_on.month.to_s + "/" + profit_detail.occurred_on.day.to_s
      
      #初期化
      @account_title = nil
      @payment_method = nil
      @contents = nil
      @amount = 0
      
      #支払・出納帳データでルーチンを切り分ける
      if profit_detail.table_type_id == TABLE_TYPE_ID_PAYMENT
        #支払データ
        set_payment(profit_detail)
      elsif profit_detail.table_type_id == TABLE_TYPE_ID_CASH_BOOK
        #出納帳
        set_cash_book(profit_detail)
      end
      
      
      #明細出力
      report.list(:default).add_row do |row|
        row.values occurred_on: occurred_on, payment_method: @payment_method,
                   account_title: @account_title, contents: @contents, 
                   amount: @amount
      end
      
    end
    
    #フッター(合計)
    report.list do |list|
      list.on_footer_insert do |footer|
        footer.item(:amount_total).value(@amount_total)
      end
    end
    #
    
    # ThinReports::Reportを返す
    return report
    
  end
  
  #支払データより集計
  def self.set_payment(profit_detail)
    
    #@account_title = nil
    
    payment = Payment.where(:id => profit_detail.table_id).first
    
    if payment.present?
      #支払方法
      if payment.payment_method_id.present?
        @payment_method = PAYMENT_METHOD[payment.payment_method_id]
      end
      #勘定科目名
      account_title = AccountTitle.where(:id => payment.account_title_id).first
      if account_title.present?
        @account_title = account_title.name
      else
        #勘定科目未入力の場合は、固定で文字を入れる
        @account_title = TITLE_COST
      end
      #
      if payment.partner_id.present?
        partner = Partner.where(:id => payment.partner_id).first
        if partner.present?
          @contents = partner.name
        end
      end
      
      #金額
      #支払金額>請求金額>概算金額の優先順でセット
      if payment.payment_amount.present? && 
         payment.payment_amount > 0
        @amount = payment.payment_amount
      elsif payment.billing_amount.present? && 
         payment.billing_amount > 0
        @amount = payment.billing_amount
      elsif payment.rough_estimate.present? &&
        payment.rough_estimate > 0
        @amount = payment.rough_estimate
      end
      
      #--社会保険料の場合--２で割ったものを加算する
      if partner.id == 29
        if @amount > 0
          @amount = @amount / 2
        end
      end
      #--
      
      @amount_total += @amount
      
    end
    
    #account_title = AccountTitle.where(id: => profit_detail.)
    
  end
  
  def self.set_cash_book(profit_detail)
    
    cash_book = CashBook.where(:id => profit_detail.table_id).first
    
    if cash_book.present?
      #支払方法
      @payment_method = PAYMENT_METHOD[PAYMENT_METHOD_CASH]
      #勘定科目名
      account_title = AccountTitle.where(:id => cash_book.account_title_id).first
      if account_title.present?
        @account_title = account_title.name
      end
      #項目
      @contents = cash_book.description_content
      #金額
      @amount = cash_book.expences
      @amount_total += @amount
    end
    
  end
end