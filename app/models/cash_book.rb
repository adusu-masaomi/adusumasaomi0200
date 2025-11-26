class CashBook < ActiveRecord::Base
  #取引先データ(django) アクセス用
  self.table_name = "account_cash_book"
end
