class User < ActiveRecord::Base
# 以下を追加することで passwordとpassword_confirmationが自動で追加され、存在チェックのバリデーションも設定されます。
# そして、password_digestへ暗号化されて登録されます。
  has_secure_password
end
