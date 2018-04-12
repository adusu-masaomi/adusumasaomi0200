class ApplicationMailer < ActionMailer::Base
  
  default from: "from@example.com"
  layout 'mailer'
  
  default from:     "アデュース電気<adusudenki@gmail.com>"
  #↑カッコのメアドがないと555のエラーが出て送信できないので注意！！
  #        reply_to: "sample+reply@gmail.com"
  #layout 'mailer' 
 
end
