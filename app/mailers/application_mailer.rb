class ApplicationMailer < ActionMailer::Base
  
  #default from: "from@example.com"
  layout 'mailer'
  
  #for centos6(220209) 
  default from:     "株式会社アデュース<adusudenki@gmail.com>"
  #↑カッコのメアドがないと555のエラーが出て送信できないので注意！！
  #        reply_to: "sample+reply@gmail.com"
  #layout 'mailer' 
 
end
