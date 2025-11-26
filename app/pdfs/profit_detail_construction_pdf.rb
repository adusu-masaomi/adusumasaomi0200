class ProfitDetailConstructionPDF < ConstantProfit
  
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
  
  def self.create(profit_details, from_date, to_date)
    
    report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/profit_detail_construction_pdf.tlf")
    
    # 1ページ目を開始
    report.start_new_page
    
    #日付(from-to)
    if from_date.present?
      #from_month = from_date.year.to_s + "/" + from_date.month.to_s + "月"
      from_month = from_date.year.to_s + "/" + from_date.month.to_s + "/" + from_date.day.to_s
      report.page.item(:from_date).value(from_month)
    end
    
    if to_date.present?
      #to_month = to_date.year.to_s + "/" + to_date.month.to_s + "月"
      to_month = to_date.year.to_s + "/" + to_date.month.to_s + "/" + to_date.day.to_s
      report.page.item(:to_date).value(to_month)
    end
    #
    
    #合計値(初期化)
    constructing_amount_total = 0
    purchase_amount_total = 0
    gross_profit_total = 0
    #
    
    #工事費の集計
    profit_details.where(:cost_id => COST_ID_CONSTRUCTION).order(:occurred_on).each do |profit_detail|
      
      occurred_on = profit_detail.occurred_on.month.to_s + "/" + profit_detail.occurred_on.day.to_s
      
      construction_cost = ConstructionCost.where(:id => profit_detail.table_id).first
      if construction_cost.present?
        #工事データ取得
        construction = ConstructionDatum.where(:id => construction_cost.construction_datum_id).first
        construction_code = ""
        customer_name = ""
        
        if construction.present?
          construction_code = construction.construction_code
          construction_name = construction.construction_name
          
          #得意先データ取得
          customer = CustomerMaster.where(:id => construction.customer_id).first
          if customer.present?
            customer_name = customer.customer_name
          end
        end
        
        #請負金額
        constructing_amount = 0
        if construction_cost.constructing_amount.present?
          constructing_amount = construction_cost.constructing_amount
        end
        constructing_amount_total += constructing_amount
        #仕入金額
        purchase_amount = 0
        if construction_cost.purchase_amount.present?
          purchase_amount = construction_cost.purchase_amount
        end
        purchase_amount_total += purchase_amount
        
        #差(荒利)
        gross_profit = constructing_amount - purchase_amount
        
        gross_profit_total += gross_profit
      end
      
      #明細の印刷
      
      #明細出力
      report.list(:default).add_row do |row|
        month = profit_detail.occurred_on.month.to_s + "月"
        row.values invoice_date: occurred_on, construction_code: construction_code,
                   construction_name: construction_name, customer_name: customer_name,
                   constructing_amount: constructing_amount, purchase_amount: purchase_amount,
                   gross_profit: gross_profit
      end
      
    end
    
    #フッター(合計)
    report.list do |list|
      list.on_footer_insert do |footer|
        footer.item(:constructing_amount_total).value(constructing_amount_total)
        footer.item(:purchase_amount_total).value(purchase_amount_total)
        footer.item(:gross_profit_total).value(gross_profit_total)
      end
    end
    #
    
    # ThinReports::Reportを返す
    return report
    
  end
end