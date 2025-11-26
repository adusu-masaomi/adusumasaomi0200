class ConstantProfit
  
  #controllersの"calculate_monthly_profit"内にも
  #同様の定数があるので変更時は両方を直す必要がある
  
  #
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
  #
  #支払方法
  PAYMENT_METHOD = ["", "振込", "口座振替", "ＡＴＭ", "現金"]
  PAYMENT_METHOD_CASH = 4  #現金
  
  TITLE_COST = "経費"
  
end