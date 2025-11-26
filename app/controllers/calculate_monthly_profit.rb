class CalculateMonthlyProfit < ApplicationController
  
  COST_ID_CONSTRUCTION = 1
  COST_ID_COST = 2
  COST_ID_REPAYMENT = 3     #返済
  
  #テーブル判別ID
  TABLE_TYPE_ID_CONSTRUCTION = 1
  TABLE_TYPE_ID_PAYMENT = 2
  TABLE_TYPE_ID_CASH_BOOK = 3
  #
  COST_FLAG_COST = 1
  COST_FLAG_REPAYMENT = 2
  
  ID_PARTNER_SHAKAI_HOKEN = 29
  ID_PARTNER_SHOHIZEI = 41
  ID_PARTNER_SHOHIZEI_BUNKATSU = 140
  
  #月間粗利集計の集計処理
  def set_monthly_profit(occurred_on)
      
    selected_date = occurred_on.to_date
      
    #月末と月初を求める
    @first_date = Date.new(selected_date.year, selected_date.month)
    @last_date = Date.new(selected_date.year, selected_date.month, -1)
    #
    
    @gross_profit = 0
    
    @sales = 0
    @variable_cost = 0
    
    @cost_amount = 0
    @repayment = 0
    
    #データを一旦抹消
    delete_data
    
    #工事集計データを集計
    set_construction_cost
    
    #支払データを集計
    set_payment
    
    set_payment_payment_date
    
    #返済データ集計
    set_repayment
    
    #出納帳データを集計
    set_cash_book
    
    #合計データへセット
    set_monthly_data
    #binding.pry
    
  end
  
  def set_construction_cost
  
    (@first_date..@last_date).each do |date|
      
      #construction_cost = ConstructionCost.where(:invoice_date => date).first
      construction_costs = ConstructionCost.where(:invoice_date => date)
      
      if construction_costs.present?
        construction_costs.each do |construction_cost|
          #明細データへ書き込み
          profit_detail = ProfitDetail.new
        
          profit_detail.occurred_on = construction_cost.invoice_date
          profit_detail.cost_id = COST_ID_CONSTRUCTION  
          profit_detail.table_type_id = TABLE_TYPE_ID_CONSTRUCTION
          profit_detail.table_id = construction_cost.id
        
          if profit_detail.save  #明細へ書き込み
          
            #合計用に集計する
            amount = construction_cost.constructing_amount
            if construction_cost.constructing_amount.present?
              @sales += construction_cost.constructing_amount
            end
            
            if amount.present? && construction_cost.purchase_amount.present?
              amount -= construction_cost.purchase_amount
              @variable_cost += construction_cost.purchase_amount
            end
          
            if amount.present?
              @gross_profit += amount
            end
          
          end
          #
        end  #end do
      end
      
    end
    
  end
  
  #支払データより経費を読込
  def set_payment
    
    #支払予定日で集計
    
    @cost_amount = 0
    
    (@first_date..@last_date).each do |date|
      
      #--ここは支払日で読み込むか？ 要確認
      #payments = Payment.where(:billing_year_month => date)
      payments = Payment.where(:payment_due_date => date)
      
      #取引先Mを取得し、対象か判断
      if payments.present?
        
        payments.each do |payment|
        
          partner = Partner.where(:id => payment.partner_id).first
        
          if partner.present?
          
            #経費フラグの場合、明細へセット
            if partner.cost_flag == COST_FLAG_COST
              
              not_save_flag = false
              
              case partner.id
              when ID_PARTNER_SHOHIZEI, ID_PARTNER_SHOHIZEI_BUNKATSU
                not_save_flag = true
              else
              end
              
              #if !not_save_flag
              if not_save_flag == false
                save_profit_detail(payment, partner, 1)
              end
             
              #profit_detail = ProfitDetail.new
            
              #profit_detail.occurred_on = payment.payment_due_date
              #profit_detail.cost_id = COST_ID_COST
              #profit_detail.table_type_id = TABLE_TYPE_ID_PAYMENT
              #profit_detail.table_id = payment.id
            
              #明細へ書き込み
              #if profit_detail.save
              #  amount = 0
                
                #合計用に集計する
                #
                #支払済金額があればその金額、なければ請求金額をセット
                #
                #支払金額>請求金額>概算金額の優先順でセット
              #  if payment.payment_amount.present?
              #    amount = payment.payment_amount
              #  elsif payment.billing_amount.present?
              #    amount = payment.billing_amount
              #  elsif payment.rough_estimate.present?
              #    amount = payment.rough_estimate
              #  end 
                #
                
              #  #--社会保険料の場合--２で割ったものを加算する
              #  if partner.id == 29
              #    if amount > 0
              #      amount = amount / 2
              #    end
              #  end
                #--
                
                
                #binding.pry
                
               # if amount > 0
               #   @cost_amount += amount
               # end
                
                
                #
              #end
            end
          end
          
        end
      end
      
    end  #loop end
  end
  
  #支払データより経費を読込
  def set_payment_payment_date
    
    #支払日で集計
    #@cost_amount = 0
    
    (@first_date..@last_date).each do |date|
      
      #--ここは支払日で読み込むか？ 要確認
      #payments = Payment.where(:billing_year_month => date)
      payments = Payment.where(:payment_date => date)
      
      #取引先Mを取得し、対象か判断
      if payments.present?
        
        payments.each do |payment|
        
          partner = Partner.where(:id => payment.partner_id).first
        
          if partner.present?
          
            #経費フラグの場合、明細へセット
            if partner.cost_flag == COST_FLAG_COST
              
              save_flag = false
              
              case partner.id
                when ID_PARTNER_SHOHIZEI, ID_PARTNER_SHOHIZEI_BUNKATSU
                  save_flag = true
                else
              end
              
              if save_flag == true
                save_profit_detail(payment, partner, 2)
              end
             
            end
          end
          
        end
      end
      
    end  #loop end
  end
  
  def save_profit_detail(payment, partner, day_flag)
    
    #if partner.id == ID_PARTNER_SHOHIZEI
    #binding.pry
    #end
    
    profit_detail = ProfitDetail.new
            
    #profit_detail.occurred_on = payment.billing_year_month
    if day_flag == 1
      profit_detail.occurred_on = payment.payment_due_date   ######
    else
      #予定日ではなく支払日にする
      profit_detail.occurred_on = payment.payment_date
    end 
    profit_detail.cost_id = COST_ID_COST
    profit_detail.table_type_id = TABLE_TYPE_ID_PAYMENT
    profit_detail.table_id = payment.id
            
    #明細へ書き込み
    if profit_detail.save
                
      amount = 0
                
      #合計用に集計する
      #
      #支払済金額があればその金額、なければ請求金額をセット
      #
      #支払金額>請求金額>概算金額の優先順でセット
      if payment.payment_amount.present?
        amount = payment.payment_amount
      elsif payment.billing_amount.present?
        amount = payment.billing_amount
      elsif payment.rough_estimate.present?
        amount = payment.rough_estimate
      end 
      #
      
      #--社会保険料の場合--２で割ったものを加算する
      if partner.id == ID_PARTNER_SHAKAI_HOKEN
      #if partner.id == 29
        if amount > 0
          amount = amount / 2
        end
      end
      #--
                
      if amount > 0
        @cost_amount += amount
      end
    #
    end
  end
  
  #支払データより返済金を読込
  def set_repayment
    
    @repayment = 0
    
    (@first_date..@last_date).each do |date|
      
      #
      payments = Payment.where(:payment_due_date => date)
      
      if payments.present?
        payments.each do |payment|
          
          partner = Partner.where(:id => payment.partner_id).first
          
          if partner.present?
            
            #返済フラグの場合、明細へセット
            if partner.cost_flag == COST_FLAG_REPAYMENT
              
              profit_detail = ProfitDetail.new
              
              profit_detail.occurred_on = payment.payment_due_date
              profit_detail.cost_id = COST_ID_REPAYMENT
              profit_detail.table_type_id = TABLE_TYPE_ID_PAYMENT
              profit_detail.table_id = payment.id
              
              #明細へ書き込み
              if profit_detail.save
                amount = 0
                
                #
                #支払金額>請求金額>概算金額の優先順でセット
                if payment.payment_amount.present?
                  amount = payment.payment_amount
                elsif payment.billing_amount.present?
                  amount = payment.billing_amount
                elsif payment.rough_estimate.present?
                  amount = payment.rough_estimate
                end 
                #
                
                if amount > 0
                  @repayment += amount
                end
                
              end
              #
              
            end
            
          end
          
        end  #end do
      end
      
    end  #end do
    
  end 
  
  #出納帳データより経費を取得
  def set_cash_book
    
    (@first_date..@last_date).each do |date|
      
      cash_books = CashBook.where(:settlement_date => date)
      
      if cash_books.present?
        
        cash_books.each do |cash_book|
          
          #if cash_book.is_cost == COST_FLAG_COST
          if cash_book.is_cost
          
            profit_detail = ProfitDetail.new
            profit_detail.occurred_on = cash_book.settlement_date
            profit_detail.cost_id = COST_ID_COST
            profit_detail.table_type_id = TABLE_TYPE_ID_CASH_BOOK
            profit_detail.table_id = cash_book.id
            
            if profit_detail.save
              
              amount = 0
              
              #合計用に集計する
              
              if cash_book.is_cost.present? && cash_book.is_cost
                if cash_book.expences.present?
                  amount = cash_book.expences
                end
              
                if amount > 0
                  @cost_amount += amount
                
                  #binding.pry
                end
              end
            end
            
          end
          
        end  #loop end
        
        
      end
      
    end
    
  end
  
  #月の合計データを集計
  def set_monthly_data
    
    monthly_profit = MonthlyProfit.new
    
    monthly_profit.occurred_on = @first_date
    #
    monthly_profit.sales = @sales
    monthly_profit.variable_cost = @variable_cost
    #
    monthly_profit.gross_profit = @gross_profit
    monthly_profit.expense = @cost_amount
    monthly_profit.repayment = @repayment
    
    monthly_profit.save
    
  end
  
  #対象月の明細データを一旦抹消する
  def delete_data
    #明細
    ProfitDetail.where(occurred_on: @first_date..@last_date).destroy_all
    #合計
    MonthlyProfit.where(occurred_on: @first_date).destroy_all
  end
  
  
end