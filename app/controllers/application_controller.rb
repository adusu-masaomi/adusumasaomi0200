class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  ### ここから追加(ログイン) ###
  #before_action :user_logged_in? #ログインチェックの事前認証

  def reset_user_session
    session[:user] = nil
    @current_user = nil
  end

  def user_logged_in?
    user_id = session[:user]
    if user_id then
      begin
        @current_user = User.find(user_id)
      rescue ActiveRecord::RecordNotFound
        reset_user_session
      end
    end

    # current_userが取れなかった場合はログイン画面にリダイレクト
    unless @current_user
      flash[:referer] = request.fullpath
      redirect_to "/rails/login"
    end
  end
  ### ここまで追加(ログイン) ###
  
  #元号の設定(改定時はここを変更する)
  $gengo_name = "平成"
  #$gengo_alphabet = "H"
  #$ad = 1988
  $gengo_minus_ad = 1988
  
  #消費税の設定(改定時はここを変更する)
  $consumption_tax_only = 0.08
  $consumption_tax_include = 1.08
  
end
