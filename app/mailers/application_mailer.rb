class ApplicationMailer < ActionMailer::Base
  
  default from: "from@example.com"
  layout 'mailer'
  
  default from:     "アデュース電気"
  #        reply_to: "sample+reply@gmail.com"
  #layout 'mailer' 
 
end
