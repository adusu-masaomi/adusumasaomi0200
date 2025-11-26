class ProfitDetailRepaymentPDF < ConstantProfit
  #定数は別クラスより継承
  
  def self.create(profit_details, from_date, to_date)
    report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/profit_detail_cost_repayment_pdf.tlf")
    
    # 1ページ目を開始
    report.start_new_page
    
    report.page.item(:print_title).value("明細表(返済)")
    
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
    amount_total = 0
    
    #経費の集計
    profit_details.where(:cost_id => COST_ID_REPAYMENT).order(:occurred_on).each do |profit_detail|
      #発生日
      occurred_on = profit_detail.occurred_on.month.to_s + "/" + profit_detail.occurred_on.day.to_s
      
      #初期化
      payment_method = ""
      account_title_name = ""
      contents = ""
      amount = 0
      
      #
      
      payment = Payment.where(:id => profit_detail.table_id).first
      
      if payment.present?
        #支払方法
        if payment.payment_method_id.present?
          payment_method = PAYMENT_METHOD[payment.payment_method_id]
        end
        #勘定科目名
        account_title = AccountTitle.where(:id => payment.account_title_id).first
        
        if account_title.present?
          account_title_name = account_title.name
        end
        #項目(取引先名)
        if payment.partner_id.present?
          partner = Partner.where(:id => payment.partner_id).first
          if partner.present?
            contents = partner.name
          end
        end
        #
        #金額
        #支払金額>請求金額>概算金額の優先順でセット
        if payment.payment_amount.present? && 
          payment.payment_amount > 0
          amount = payment.payment_amount
        elsif payment.billing_amount.present? && 
          payment.billing_amount > 0
          amount = payment.billing_amount
        elsif payment.rough_estimate.present? &&
          payment.rough_estimate > 0
          amount = payment.rough_estimate
        end
        amount_total += amount
        
        #明細出力
        report.list(:default).add_row do |row|
          row.values occurred_on: occurred_on, payment_method: payment_method,
                   account_title: account_title_name, contents: contents, 
                   amount: amount
        end
        
      end
    
    end  #loop end
    
    #フッター(合計)
    report.list do |list|
      list.on_footer_insert do |footer|
        footer.item(:amount_total).value(amount_total)
      end
    end
    #
    
    # ThinReports::Reportを返す
    return report
    
  end
  
end