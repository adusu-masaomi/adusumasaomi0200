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
  
  #add191204
  #西暦から和暦に変換するメソッド(in=Date , out=String)
  def WesternToJapaneseCalendar(westernYear)
  
    japaneseCalendar = westernYear
    japaneseCalendarChar = westernYear.to_s
    
    d_heisei_limit = Date.parse("2019/5/1");
    
    #元号変わったらここも要変更
    if japaneseCalendar >= d_heisei_limit
      #令和
      if japaneseCalendar.year - $gengo_minus_ad_2 == 1
      #１年の場合は元年と表記
        japaneseCalendarChar = $gengo_name_2 + "元年#{japaneseCalendar.strftime('%-m')}月#{japaneseCalendar.strftime('%-d')}日"
      else
        japaneseCalendarChar = $gengo_name_2 + "#{japaneseCalendar.year - $gengo_minus_ad_2}年#{japaneseCalendar.strftime('%-m')}月#{japaneseCalendar.strftime('%-d')}日"
      end
    else
      #平成
      japaneseCalendarChar = $gengo_name + "#{japaneseCalendar.year - $gengo_minus_ad}年#{japaneseCalendar.strftime('%-m')}月#{japaneseCalendar.strftime('%-d')}日" 
    end
    
    return japaneseCalendarChar
  end
  
  #元号の設定(改定時はここを変更する)
  $gengo_name = "平成"      #平成の場合
  $gengo_name_2 = "令和"    #令和 〃
  $GENGO_ALPHABET = "H"    #平成の場合
  $GENGO_ALPHABET_2 = "R"  #令和 〃
  #$ad = 1988
  $gengo_minus_ad = 1988   #平成の場合
  $gengo_minus_ad_2 = 2018
  
  #消費税の設定(改定時はここを変更する→xx)
  $consumption_tax_only = 0.08
  $consumption_tax_include = 1.08
  
  #消費税１０％の対応(切り替えのタイミングがあるので、こうやって定数追加した方がよい)
  $consumption_tax_only_per_ten = 0.10
  $consumption_tax_include_per_ten = 1.10
  
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
  $INDEX_DIVISION_PURCHASE = 1    #仕入 add180324
  $INDEX_DIVISION_SHIPPING = 5    #出庫 
  
  #在庫の区分
  $INDEX_INVENTORY_STOCK = 0       #入庫
  $INDEX_INVENTORY_SHIPPING = 1    #出庫
  $INDEX_INVENTORY_STOCKTAKE = 2   #棚卸
  
  #仕入先業者
  $SUPPLIER_MASER_ID_OKADA_DENKI_SANGYO = 2
  
  #工事ID(170915~未使用？)
  $CUNSTRUCTION_ID_AIR_CONDITIONING_ELEMENT = 976 #エアコン部材
  $CUNSTRUCTION_ID_PIPE_AND_WIRING = 977          #配管配線
  $CUNSTRUCTION_ID_CABLE = 978                    #ケーブル
  #$CONSTRUCTION_ID_LIGHTING_EQUIPMENT = 1083      #照明器具 add170915
  
  #在庫品目(170915~未使用？)
  $INVENTORY_CATEGORY_AIR_CONDITIONING_ELEMENT = 0
  $INVENTORY_CATEGORY_PIPE_AND_WIRING = 1
  $INVENTORY_CATEGORY_ID_CABLE = 2
  #$INVENTORY_LIGHTING_EQUIPMENT = 3               #照明器具 add170915
  
  $CONSTRUCTION_NULL_DATE = "2021/01/01"         #工事開始日などの、NULL値として扱う日付(add180113)
  $CONSTRUCTION_QUERY_NULL_DATE = "//"           #(add180113)
  
  #労務単価定数
  $LABOR_COST = 11000
  #$LABOR_COST = 12100   #upd200108
  
  $INDEX_SUPPLIER_OKADA = 2     #仕入先ID(岡田電気)
  
  $STRING_COPY = "(コピー)"      #明細をコピーした場合にアイテム名につける文字  (add180912)
end
