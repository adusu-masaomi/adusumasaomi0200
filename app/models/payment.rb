class Payment < ActiveRecord::Base
  #支払データ(django) アクセス用
  self.table_name = "account_payment"
end
