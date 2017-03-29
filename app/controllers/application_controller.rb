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
  $GENGO_ALPHABET = "H"
  #$ad = 1988
  $gengo_minus_ad = 1988
  
  #消費税の設定(改定時はここを変更する)
  $consumption_tax_only = 0.08
  $consumption_tax_include = 1.08
  
  #add170308
  #見積等での工事種別の定数
  #(変更時はapplication.html.erbも要変更)
  $INDEX_SUBTOTAL = 1                    #小計
  $INDEX_DISCOUNT = 2                    #値引き
  $INDEX_PIPING_WIRING_CONSTRUCTION = 3  #配管配線工事
  $INDEX_EUIPMENT_MOUNTING = 4          #機器取付工事
  $INDEX_LABOR_COST = 5                  #労務費
  
  #add170310
  #見積書などの、見出しコードの仮番
  $HEADER_CODE_MAX = "9999999999"
  
  #仕入区分
  #--出庫
  $INDEX_DIVISION_SHIPPING = 6
  
end
