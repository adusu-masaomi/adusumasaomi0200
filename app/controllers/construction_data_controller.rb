class ConstructionDataController < ApplicationController
  
  #before_action :set_construction_datum, only: [:show, :edit, :edit2, :update, :destroy]
  before_action :set_construction_datum, only: [:show, :edit, :edit2, :edit3, :update, :destroy]

  # GET /construction_data
  # GET /construction_data.json
  def index
    
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)  	
	
   
    @construction_code_extract = ConstructionDatum.all     #add180830
    #件名の絞り込み addd180830
    if query.present? && query[:customer_id_eq].present?
       @construction_code_extract = ConstructionDatum.where(customer_id: query[:customer_id_eq]).order("construction_code desc")
    end
    ##upd end
 
   
	#@q = ConstructionDatum.ransack(params[:q])
    #ransack保持用--上記はこれに置き換える
    @q = ConstructionDatum.ransack(query)   
    
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
	
    @construction_data  = @q.result(distinct: true)
    
    #kaminari用設定
    @construction_data  = @construction_data .page(params[:page])

    @customer_masters = CustomerMaster.all
    
	$construction_data = @construction_data
	
    #add180903
    #資料フォルダを開く
	if params[:document_flag] == "1"
      openFileDialog
    end
    
    if params[:document_flag] != "1"
      respond_to do |format|
	    format.html
		
	    format.pdf do
        
          report = ConstructionListPDF.create @construction_list 
        
          # ブラウザでPDFを表示する
          # disposition: "inline" によりダウンロードではなく表示させている
          send_data(
            report.generate,
            filename:  "construction_list.pdf",
            type:        "application/pdf",
            disposition: "inline")
        end
	  end
    
    end
  end

  # GET /construction_data/1
  # GET /construction_data/1.json
  def show
  end

  # GET /construction_data/new
  def new
    @construction_datum = ConstructionDatum.new
    
    #画像ファイル用
    #3.times { @construction_datum.construction_attachments.build }
    
    
    Time.zone = "Tokyo"

    #工事コードの最終番号を取得
    get_last_construction_code_select
    @construction_datum.construction_code = @@construction_new_code
	
  end

  # GET /construction_data/1/edit
  def edit
  end
  
  # GET /construction_data/1/edit2
  def edit2
     Time.zone = "Tokyo"
	 @construction_datum.issue_date = Date.today
  end
  
  
  #資料添付用
  # GET /construction_data/1/edit3
  def edit3
     #test
     #3.times { @construction_datum.construction_attachments.build }
    
  end
  def openFileDialog
     
     if params[:format].present?
       @construction_datum = ConstructionDatum.find(params[:format])
     end
     
     if @construction_datum.present?
       dir_detail_path = @construction_datum.construction_code + "-" + @construction_datum.construction_name + "/"
     
       if browser.platform.windows?
         #windowsの場合
         system("explorer #{"/Users/%username%/OneDrive/ADUSU/工事資料/" + dir_detail_path}")
         #system("start /Users/$USER/OneDrive/ADUSU/工事資料/")
       elsif browser.platform.mac?
         #macの場合
         system("open #{"/Users/$USER/OneDrive/ADUSU/工事資料/" + dir_detail_path}")
       end
     end
  end
  
  def download
    
    @construction_attachment = ConstructionAttachment.find(params[:id])
    # ref: https://github.com/carrierwaveuploader/carrierwave#activerecord
    filepath = @construction_attachment.attachment.current_path
    stat = File::stat(filepath)
    send_file(filepath, :filename => @construction_attachment.title, :length => stat.size)
  end

  # POST /construction_data
  # POST /construction_data.json
  def create
  
    #add200114
    #viewで分解されたパラメータを、正常更新できるように復元させる。
    adjust_billing_due_date_params
  
    #住所のパラメータ変換
    params[:construction_datum][:address] = params[:addressX]

    #現場名を登録 
    #未検証
    #add190124
    create_or_update_site
    
    @construction_datum = ConstructionDatum.new(construction_datum_params)
    
        #工事開始日・終了日（実績）の初期値をセットする
    @construction_datum.construction_start_date = '3000-01-01'
    @construction_datum.construction_end_date = '2000-01-01'
	
    respond_to do |format|

	
      if @construction_datum.save
        
        #add200114
        #djangoの資金繰り用のデータ更新
        set_cash_flow = SetCashFlow.new
        set_cash_flow.set_cash_flow_detail_expected_for_construction(params, @construction_datum)
        
        #set_cash_flow_detail
        
        #add180903
        #OneDrive用のディレクトリを作る
        #makeDocumentsFolder
        
        #工事費集計表データも空で作成
        #add170330
        construction_cost_params = {construction_datum_id: @construction_datum.id, purchase_amount: 0, 
                       execution_amount: 0, purchase_order_amount: ""}
        @construction_cost = ConstructionCost.create(construction_cost_params)
        #
	  
        format.html { redirect_to @construction_datum, notice: 'Construction datum was successfully created.' }
        format.json { render :show, status: :created, location: @construction_datum }
      else
  
        format.html { render :new }
        format.json { render json: @construction_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /construction_data/1
  # PATCH/PUT /construction_data/1.json
  def update
   
    #add200114
    #viewで分解されたパラメータを、正常更新できるように復元させる。
    adjust_billing_due_date_params
    
    #住所のパラメータ変換
    if params[:addressX].present?
      params[:construction_datum][:address] = params[:addressX]
    end
    
    #現場名を登録 
    #add190124
    create_or_update_site
    
    if params[:directions].present?
	  
	  #手入力用IDの場合は、安全事項マスタへも登録する。
      @matter_name = nil
      if @construction_datum.working_safety_matter_id == 1
         
       #既に登録してないかチェック
	   new_name =  params[:construction_datum][:working_safety_matter_name]
	   
	   if new_name != "" then
             @check_matter = WorkingSafetyMatter.find_by(working_safety_matter_name: new_name)
             if @check_matter.nil?
	        matter_params = { working_safety_matter_name:  new_name }
               @matter_name = WorkingSafetyMatter.create(matter_params)
             end
          end 
      end
      
	  
	end
	
   
    respond_to do |format|
	
      document_flag = false
    
	  @update = nil
      if params[:documents].nil?
        #通常のアップデート
        @update = @construction_datum.update(construction_datum_params)
      else
        #資料のみ更新した場合
        @update = @construction_datum.update_attributes(construction_datum_attachments_params)
      
        document_flag = true
      end
      
      
      if @update
      
        #add200114
        #set_cash_flow_detail
        #djangoの資金繰り用のデータ更新
        set_cash_flow = SetCashFlow.new
        set_cash_flow.set_cash_flow_detail_expected_for_construction(params, @construction_datum)
      
	  #if @construction_datum.update(construction_datum_params)
        
        #add180903
        #OneDrive用のディレクトリを作る
        #makeDocumentsFolder
        
        
        #工事費集計表データも空で作成(データ存在しない場合のみ)
        #add170330
        construction_cost = ConstructionCost.where(:construction_datum_id => @construction_datum.id).first
        if construction_cost.blank?
            construction_cost_params = {construction_datum_id: @construction_datum.id, purchase_amount: 0, 
                       execution_amount: 0, purchase_order_amount: ""}
		
            @construction_cost = ConstructionCost.create(construction_cost_params)
        end
        #
		if document_flag = false
          format.html { redirect_to @construction_datum, notice: 'Construction datum was successfully updated.' }
		else
        #資料更新の場合、indexへそのまま戻る
          format.html { redirect_to action: "index", notice: 'Documents was successfully created.' }
        end
        
		if params[:directions].present?
		  #指示書の発行
		  
		  #global set
          $construction_datum = @construction_datum 
		  
		  #作業日をグローバルへセット
		  #$working_date = params[:construction_datum]["working_date(1i)"] + "/" + 
          #                params[:construction_datum]["working_date(2i)"] + "/" + params[:construction_datum]["working_date(3i)"]
          working_date = params[:construction_datum]["working_date(1i)"] + "/" + 
                          params[:construction_datum]["working_date(2i)"] + "/" + params[:construction_datum]["working_date(3i)"]
		  #upd191009
          #曜日を追加
          week = %w{日 月 火 水 木 金 土}[Date.parse(working_date).wday]
          $working_date = working_date + "（" + week + "）"
                    
		  #発行日をグローバルへセット
          #191009~現在未使用
          $issue_date = params[:construction_datum][:issue_date]
          
          #復活した場合に残しておく
          #曜日を追加
          #issue_date = params[:construction_datum][:issue_date]
		  #week = %w{日 月 火 水 木 金 土}[Date.parse(issue_date).wday]
          #$issue_date = issue_date + "（" + week + "）"
          #復活~end
          
		  #作業者をグローバルへセット
		  staff_id = params[:construction_datum][:staff_id]
		  @staff = Staff.find_by(id: staff_id)
		  $staff_name = ""
		  if @staff.present?
		   $staff_name = @staff.staff_name
		  end
		  
		  format.pdf do
            report = WorkingDirectionsPDF.create @working_dirctions
		    # ブラウザでPDFを表示する
            # disposition: "inline" によりダウンロードではなく表示させている
            send_data(
              report.generate,
              filename:  "working_directions.pdf",
              type:        "application/pdf",
              disposition: "inline")
          end
		 end
		
         if document_flag == false
           format.json { render :show, status: :ok, location: @construction_datum }
         end
      else
        format.html { render :edit }
        format.json { render json: @construction_datum.errors, status: :unprocessable_entity }
      end
	  
	
    end
    
    
  end
  
  #文字列が数字かチェックする
  def isNumeric(strData)
    if strData.to_i.to_s == strData.to_s  
      return true
    end
    
    return false
  end
  
  #delete later
  #add200114
  #資金繰り表用のデータ作成する
  #djangoのカラムのため、SQL操作
  #def set_cash_flow_detail 
  #  deposit_due_date = nil
  #  if params[:construction_datum][:deposit_due_date].present? 
  #    deposit_due_date = params[:construction_datum][:deposit_due_date]
  #  end
  #    args = ["select * from account_cash_flow_detail_expected where construction_id = ?", @construction_datum.id]
  #    sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
  #    result_params = ActiveRecord::Base.connection.select_all(sql)
  #    #予定金額<>決定金額なら決定金額を優先する
  #    expected_income = 0
  #    if params[:construction_datum][:final_amount].present? && 
  #      params[:construction_datum][:final_amount].to_i > 0
  #      #決定金額をセット
  #      expected_income = params[:construction_datum][:final_amount]
  #    else
  #      #予定金額をそのままセット
  #      if params[:construction_datum][:estimated_amount].present?
  #        expected_income = params[:construction_datum][:estimated_amount]
  #      end
  #    end
  #    #登録時に消費税をかける
  #    if expected_income.present? && expected_income.to_i > 0
  #      tmp_amount = expected_income.to_i * $consumption_tax_include_per_ten
  #      expected_income = tmp_amount.to_s
  #    end
  #    #支払先の銀行ID取得
  #    payment_bank_id = 1  #デフォルトは北越にする
  #    payment_bank_branch_id = 1
  #    customer = nil
  #    if params[:construction_datum][:customer_id].present?
  #      customer = CustomerMaster.find(params[:construction_datum][:customer_id].to_i)
  #    end
  #    #銀行によって支店を振り分ける(rails側では支店マスターがないため）
  #    #現金予定のパターン有り？？
  #    if customer.present?
  #      if customer.payment_bank_id.present? && customer.payment_bank_id > 0
  #        case payment_bank_id 
  #        when $BANK_ID_SANSHIN_HOKUETSU
  #          payment_bank_id = customer.payment_bank_id
  #        when $BANK_ID_SANSHIN_TSUKANOME
  #          payment_bank_id = customer.payment_bank_id
  #          payment_bank_branch_id = $A_BANK_BRANSH_ID_SANSHIN_TSUKANOME
  #        when $BANK_ID_SANSHIN_MAIN
  #          payment_bank_id = $BANK_ID_SANSHIN_TSUKANOME  #会計sysでは塚野目と同じIDになっている
  #          payment_bank_branch_id = $A_BANK_BRANSH_ID_SANSHIN_MAIN
  #        end
  #      end
  #    end
  #    #
  #    #新規・更新処理
  #    if result_params.rows.blank?
  #      #新規追加
  #      if deposit_due_date.present?  #入金予定日が入ってなければ登録しない
  #          args = ["INSERT INTO account_cash_flow_detail_expected(expected_date, construction_id, expected_expense, 
  #                                          expected_income, payment_bank_id, payment_bank_branch_id, account_title_id, billing_year_month) VALUES(? ,? , ? ,? ,? , ? ,? ,?)", 
  #                                      deposit_due_date, @construction_datum.id, 0, expected_income, payment_bank_id, payment_bank_branch_id, 
  #                                      1, "2020-01-01"]
  #          sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
  #          result_params = ActiveRecord::Base.connection.execute(sql)
  #      end
  #    else
  #      if deposit_due_date.present?
  #          #更新
  #          args = ["UPDATE account_cash_flow_detail_expected SET expected_date=?, expected_income=?, payment_bank_id=?, 
  #                         payment_bank_branch_id=? where construction_id = ?" , 
  #                                      deposit_due_date, expected_income, payment_bank_id, payment_bank_branch_id, @construction_datum.id]
  #          sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
  #          result_params = ActiveRecord::Base.connection.execute(sql)
  #      else
  #         #すでにデータ存在していて、予定日が入ってなければ削除とする
  #         args = ["DELETE FROM account_cash_flow_detail_expected where construction_id = ?" , 
  #                                      @construction_datum.id]
  #         sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
  #         result_params = ActiveRecord::Base.connection.execute(sql)
  #      end
  #    end
  #end
  
    
  #現場マスターへの新規追加又は更新
  def create_or_update_site
  
    numeric = false
    @site = nil
  
    if isNumeric(params[:construction_datum][:site_id])
      numeric = true
      @site = Site.find(params[:construction_datum][:site_id])
    else
    #名称手入力されている場合は、名称で検索
      @site = Site.where(["name = ?", 
             params[:construction_datum][:site_id]]).first
    end
   
    
    if @site.nil?
      #if numeric == false
      if numeric == false && params[:construction_datum][:site_id] != ""
      #文字の場合(コード入力はないものとする)
        site_params = {name: params[:construction_datum][:site_id], post: params[:construction_datum][:post], 
                       address: params[:construction_datum][:address], house_number: params[:construction_datum][:house_number],
                       address2: params[:construction_datum][:address2] }
      
        @site = Site.create(site_params)
        #生成された現場IDをパラメータに戻す
        params[:construction_datum][:site_id] = @site.id
      end
    else
    #更新
      #（IDor手入力一致→住所のみ更新)
      site_params = {post: params[:construction_datum][:post], 
                     address: params[:construction_datum][:address], house_number: params[:construction_datum][:house_number],
                     address2: params[:construction_datum][:address2] }
      
      @site.update(site_params)
    end
    
    
    #if @site.present?
    #  purchase_unit_prices_params = {material_id:  params[:purchase_datum][:material_id], supplier_id: params[:purchase_datum][:supplier_id], 
    #                    unit_price: params[:purchase_datum][:purchase_unit_price], unit_id: params[:purchase_datum][:unit_id]}
      
    #  @purchase_unit_prices.update(purchase_unit_prices_params)
    #else
    ##該当なしの場合は新規追加  add180120
	#   #仕入先用CDをセット
	#   if params[:purchase_datum][:supplier_material_code].present?
	#	  supplier_masterial_code = params[:purchase_datum][:supplier_material_code]
	#   else
#		  #仕入先品番が未入力の場合は、品番をそのままセットする
	#	  supplier_masterial_code = params[:purchase_datum][:material_code]
	#   end
	
    #  purchase_unit_prices_params = {material_id:  params[:purchase_datum][:material_id], supplier_id: params[:purchase_datum][:supplier_id], 
    #                    supplier_material_code: supplier_masterial_code, 
    #                    unit_price: params[:purchase_datum][:purchase_unit_price], unit_id: params[:purchase_datum][:unit_id]}
    #  @purchase_unit_prices = PurchaseUnitPrice.create(purchase_unit_prices_params)
    #end
  end
  ##
  
  #資料保管用のフォルダーをOneDriveへ作成する
  #winアプリ側で行うことにしたので、一旦保留(180910)
  def makeDocumentsFolder
    ###
    #dir_detail_path = @construction_datum.construction_code + "-" + @construction_datum.construction_name
    #require "fileutils"
    
    username = ENV['USER']
    
    #mac or windows の場合
    #if browser.platform.windows? || browser.platform.mac?
    
      dir_path += @construction_datum.construction_code + "-" + @construction_datum.construction_name
      
      #this can't sync folders...
      #dir_path = "/rootOneDrive/共有/工事資料/"
      dir_path = "/rootOneDrive/attachment/"       

      #FileUtils.mkdir_p(dir_path) unless FileTest.exist?(dir_path)
      FileUtils.mkdir_p(dir_path, :mode => 0777) unless FileTest.exist?(dir_path)
    #end
    #
  end
  
  
  
  #作業指示書PDF発行
  def set_pdf
      
      
	
      #respond_to do |format|
      #  format.html # index.html.erb
        format.pdf do
         
        report = WorkingDirectionsPDF.create @working_dirctions
        # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data(
          report.generate,
          filename:  "working_directions.pdf",
          type:        "application/pdf",
          disposition: "inline")
        end
      
	  #end
  end
  
  #def update_and_pdf
  #  update
  #end

  # DELETE /construction_data/1
  # DELETE /construction_data/1.json
  def destroy
    @construction_datum.destroy
    respond_to do |format|
      format.html { redirect_to construction_data_url, notice: 'Construction datum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  #工事コードの最終番号(+1)を取得する
  def get_last_construction_code_select
     #crescent = "%" + params[:header] + "%"
     #@construction_new_code = ConstructionDatum.where('construction_code LIKE ?', crescent).all.maximum(:construction_code)
     @construction_new_code = ConstructionDatum.all.maximum(:construction_code) 
	 
	 #最終番号に１を足す。
	 #newStr = @construction_new_code[1, 4]
	 #header = @construction_new_code[0, 1]
	 newNum = @construction_new_code.to_i + 1
	 
     @@construction_new_code = newNum.to_s
	 
  end
  
  #viewで分解されたパラメータを、正常更新できるように復元させる。
  def adjust_billing_due_date_params
    
    if params[:construction_datum][:billing_due_date].present? 
      params[:construction_datum][:billing_due_date] = params[:construction_datum][:billing_due_date][0] + "/" + 
                                                  params[:construction_datum][:billing_due_date][1] + "/" + 
                                                  params[:construction_datum][:billing_due_date][2]
    end
  end
    
  # ajax
  def working_safety_matter_name_select
     @working_safety_matter_name = WorkingSafetyMatter.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_safety_matter_name).flatten.join(" ")
  end
  
  #add171121
  def customer_extract
    
	if params[:customer_id] != ""
      #初期値として、”手入力”も選択できるようにする
	  @customer_extract = ConstructionDatum.where(:id => 1).where("id is NOT NULL").
           pluck("CONCAT(construction_data.construction_code, ':' , construction_data.construction_name), construction_data.id")

	  
	  #カテゴリー別のアイテムをセット
	  @customer_extract  += ConstructionDatum.where(:customer_id => params[:customer_id]).where("id is NOT NULL").order("construction_data.construction_code desc").
           pluck("CONCAT(construction_data.construction_code, ':' , construction_data.construction_name), construction_data.id")
    else
	#未選択状態の場合は、全リストを出す
	  #カテゴリー別のアイテムをセット
	  
	  #upd171205 リストに全て載せようとすると処理落ちするので
	  #現在日から１年前からの、登録された工事データのみ表示させるようにする。
	  #
	  require 'date'
      now_date = Date.today
      past_date = now_date << 12
	  #
	  
	  @customer_extract  = ConstructionDatum.where( "created_at >= ?" , past_date).order("construction_data.construction_code desc").
	      pluck("CONCAT(construction_data.construction_code, ':' , construction_data.construction_name), construction_data.id")
	  
	  #@customer_extract  = ConstructionDatum.all.
      #     pluck("CONCAT(construction_data.construction_code, ':' , construction_data.construction_name), construction_data.id")
	
	end
  end
    
  # ajax
  
  #add180926
  #請求フラグのON/OFF
  def set_billed_flag
    construction_data = ConstructionDatum.find(params[:id])
    if construction_data.present?
        #更新する
        construction_data_params = { billed_flag: params[:billed_flag] }
        construction_data.update(construction_data_params)
    end
  end
  #受注フラグのON/OFF
  def set_order_flag
    construction_data = ConstructionDatum.find(params[:id])
    if construction_data.present?
        #更新する
        construction_data_params = { order_flag: params[:order_flag] }
        construction_data.update(construction_data_params)
    end
  end
  #集計フラグのON/OFF(add200130)
  def set_calculated_flag
    construction_data = ConstructionDatum.find(params[:id])
    if construction_data.present?
        #更新する
        construction_data_params = { calculated_flag: params[:calculated_flag] }
        construction_data.update(construction_data_params)
    end
  end
  
  #現場名から住所をセットする
  def get_site_address
     
	 #郵便番号・住所
	 @post = Site.where(:id => params[:id]).where("id is NOT NULL").pluck(:post).flatten.join(" ")
	 add1 = Site.where(:id => params[:id]).where("id is NOT NULL").pluck(:address).flatten.join(" ")
	 #番地  
	 num = Site.where(:id => params[:id]).where("id is NOT NULL").pluck(:house_number).flatten.join(" ")
	 add2 = Site.where(:id => params[:id]).where("id is NOT NULL").pluck(:address2).flatten.join(" ")
	 
	 @address = ""
	 if add1.present?
	   @address = add1 
	 end
	 
	 #番地
	 if num.present?
	   @house_number = num 
	 end
	 
	 if add2.present?
	   @address2 = add2 
	 end
  end
  
  #add200111
  #請求予定日から入金予定日を取得
  def get_deposit_due_date
    #binding.pry
    @customer = nil
    if params[:customer_id].present?
      @customer = CustomerMaster.find(params[:customer_id])
    end
    
    if @customer.present?
        
        @purchase_date = Date.parse(params[:billing_due_date])
        
        @closing_date = nil
        @payment_due_date = nil
        addMonth = 0
    
        #締め日算出
        if @customer.closing_date_division == 1
        #月末の場合
          d = @purchase_date
          @closing_date = Date.new(d.year, d.month, -1)
        else
        #日付指定の場合
          d = @purchase_date
          
          if @customer.closing_date != 0
          
            #if d.day < @customer.closing_date
            if d.day <= @customer.closing_date  #bugfix 200127
              if Date.valid_date?(d.year, d.month, @customer.closing_date)
                @closing_date = Date.new(d.year, d.month, @customer.closing_date)
              end
            else
            #締め日を過ぎていた場合、月＋１
              addMonth += 1
            
              d = d >> addMonth
            
              if Date.valid_date?(d.year, d.month, @customer.closing_date)
                @closing_date = Date.new(d.year, d.month, @customer.closing_date) 
              end
            end
          else
          #日付指定有で指定日未入力なら、月末とみなす
          #add200110
            d = @purchase_date
            @closing_date = Date.new(d.year, d.month, -1)
          end
          
        end
        
        #支払日算出
        d = @closing_date   
        if @customer.due_date.present?  && @customer.due_date > 0
          
          #binding.pry
          
          if @customer.due_date >= 28   #月末とみなす
            d2 = Date.new(d.year, d.month, 28)  #一旦、エラーの出ない２８日を月末とさせる
            
            addMonth = @customer.due_date_division 
            
            d2 = d2 >> addMonth
            d2 = Date.new(d2.year, d2.month, -1)
            
            @payment_due_date = d2
          
          else
          ##月末の扱いでなければ、そのまま
            if Date.valid_date?(d.year, d.month, @customer.due_date)
              d2 = Date.new(d.year, d.month, @customer.due_date)
            
              addMonth = @customer.due_date_division
              
              @payment_due_date = d2 >> addMonth
            
            end
          end
        
        end
        
        
        
      end
  end
  
  #見積書などで使用
  def construction_and_customer_select
     @construction_name = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_name).flatten.join(" ")
	 @customer_id = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:customer_id).flatten.join(" ")
	 
	 #郵便番号・住所
	 @post = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:post).flatten.join(" ")
	 add1 = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:address).flatten.join(" ")
	 #番地  
	 num = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:house_number).flatten.join(" ")
	 add2 = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:address2).flatten.join(" ")
	 
	 @address = ""
	 if add1.present?
	   @address = add1 
	 end
	 
	 #番地
	 if num.present?
	   @house_number = num 
	 end
	 
	 if add2.present?
	   @address2 = add2 
	 end
	 
     #担当名追加
     #add190131
     @personnel = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:personnel).flatten.join(" ")
     
  end
  
  #見積書をもとに、初期情報をセットする
  def quotation_header_select
    
	 @construction_name = QuotationHeader.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_name).flatten.join(" ")
	 
	 customer = QuotationHeader.where(:id => params[:id]).where("id is NOT NULL").pluck(:customer_id).flatten.join(" ")
     @customer_id = CustomerMaster.where(:id => customer).where("id is NOT NULL").pluck(:customer_name, :id)
	 
	 #郵便番号（*工事場所）
     @post = QuotationHeader.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_post).flatten.join(" ")
	 
	 #住所（*工事場所）
	 @address = QuotationHeader.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_place).flatten.join(" ")
 
  end
  
  #納品書をもとに、初期情報をセットする
  def delivery_slip_header_select
    
	 @construction_name = DeliverySlipHeader.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_name).flatten.join(" ")
	 
	 customer = DeliverySlipHeader.where(:id => params[:id]).where("id is NOT NULL").pluck(:customer_id).flatten.join(" ")
     @customer_id = CustomerMaster.where(:id => customer).where("id is NOT NULL").pluck(:customer_name, :id)
	 
	 #郵便番号（*工事場所）
     @post = DeliverySlipHeader.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_post).flatten.join(" ")
	 
	 #住所（*工事場所）
	 @address = DeliverySlipHeader.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_place).flatten.join(" ")
 
  end
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_construction_datum
	  #binding.pry
	  
      @construction_datum = ConstructionDatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def construction_datum_params
      params.require(:construction_datum).permit(:construction_code, :construction_name, :alias_name, :reception_date, :customer_id, :personnel, :site_id, :construction_start_date, 
      :construction_end_date, :construction_period_start, :construction_period_end, :post, :address, :house_number, :address2, :latitude, :longitude, :construction_detail, :attention_matter, 
      :working_safety_matter_id, :working_safety_matter_name, :estimated_amount, :final_amount, :billing_due_date, :deposit_due_date, :deposit_date, :quotation_header_id, :delivery_slip_header_id, :billed_flag, :calculated_flag, :order_flag)
    end
    def construction_datum_attachments_params
      params.require(:construction_datum).permit(construction_attachments_attributes: [:id, :attachment, :title, :_destroy])
    end
end
