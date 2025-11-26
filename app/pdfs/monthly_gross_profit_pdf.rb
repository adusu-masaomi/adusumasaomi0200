class MonthlyGrossProfitPDF
  def self.create(gross_profits, from_date, to_date)
    report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/monthly_gross_profit_pdf.tlf")
    
    # 1ページ目を開始
    report.start_new_page
    
    #日付(from-to)
    if from_date.present?
      from_month = from_date.year.to_s + "/" + from_date.month.to_s + "月"
      report.page.item(:from_date).value(from_month)
    end
    
    if to_date.present?
      to_month = to_date.year.to_s + "/" + to_date.month.to_s + "月"
      report.page.item(:to_date).value(to_month)
    end
    #
    
    #縦計(初期化)
    gross_profit_total = 0
    
    #
    sales_total = 0
    variable_cost_total = 0
    #
    
    cost_amount_total = 0
    net_profit_total = 0
    repayment_total = 0
    total = 0
    #  
    
    gross_profits.order(:occurred_on).each do |gross_profit|
      
      #純利益
      net_profit = nil
      if gross_profit.gross_profit.present? && gross_profit.expense.present?
        net_profit = gross_profit.gross_profit - gross_profit.expense
      end
      #
      
      #横罫
      sum_amount = 0
      if gross_profit.gross_profit.present? && gross_profit.expense.present? &&
         gross_profit.repayment.present?
        sum_amount = gross_profit.gross_profit - gross_profit.expense - gross_profit.repayment
      end
      
      #明細出力
      report.list(:default).add_row do |row|
        month = gross_profit.occurred_on.month.to_s + "月"
        row.values month: month, sales: gross_profit.sales, variable_cost: gross_profit.variable_cost,
                   gross_profit: gross_profit.gross_profit,
                   cost_amount: gross_profit.expense, net_profit: net_profit,
                   repayment: gross_profit.repayment, sum_amount: sum_amount
      end
    
      #縦計加算
      
      #
      if gross_profit.sales.present?
        sales_total += gross_profit.sales
      end
      if gross_profit.variable_cost.present?
        variable_cost_total += gross_profit.variable_cost
      end
      #
      
      if gross_profit.gross_profit.present?
        gross_profit_total += gross_profit.gross_profit
      end
      if gross_profit.expense.present?
        cost_amount_total += gross_profit.expense
      end
      if net_profit.present?
        net_profit_total += net_profit
      end
      if gross_profit.repayment.present?
        repayment_total += gross_profit.repayment
      end
      if sum_amount.present?
        total += sum_amount
      end
      #
      
      
    end
    
    
    #フッター(合計)
    report.list do |list|
      list.on_footer_insert do |footer|
        footer.item(:sales_total).value(sales_total)
        footer.item(:variable_cost_total).value(variable_cost_total)
        footer.item(:gross_profit_total).value(gross_profit_total)
        footer.item(:cost_amount_total).value(cost_amount_total)
        footer.item(:net_profit_total).value(net_profit_total)
        footer.item(:repayment_total).value(repayment_total)
        footer.item(:total).value(total)
      end
    end
    #
    
    # ThinReports::Reportを返す
    return report
        
  end
end