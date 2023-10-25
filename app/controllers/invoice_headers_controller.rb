class InvoiceHeadersController < ApplicationController
  before_action :set_invoice_header, only: [:show, :edit, :update, :destroy]

  #add200123
  #include SetCashFlow

  # GET /invoice_headers
  # GET /invoice_headers.json
  def index
  
    #@invoice_headers = InvoiceHeader.all
    
	#ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)  	
		
    #@q = InvoiceHeader.ransack(params[:q])
    #ransack保持用--上記はこれに置き換える
    @q = InvoiceHeader.ransack(query)
	
	#ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
     #
    
    @invoice_headers = @q.result(distinct: true)
    @invoice_headers  = @invoice_headers.page(params[:page])
    
    #global set
    $invoice_headers = @invoice_headers
	$print_flag_invoice = params[:print_flag]
    
    
	#開始・終了日をセット
    if query.present? && query["invoice_date_gteq(1i)"].present? && query["invoice_date_lteq(1i)"].present?
      $invoice_date_start = query["invoice_date_gteq(1i)"] + "/" + query["invoice_date_gteq(2i)"]  + "/" + query["invoice_date_gteq(3i)"]
      $invoice_date_end = query["invoice_date_lteq(1i)"] + "/" + query["invoice_date_lteq(2i)"]  + "/" + query["invoice_date_lteq(3i)"]
    end
     
    respond_to do |format|
      format.html
      
      #csv
        #require 'kconv'		
        #format.csv { send_data @purchase_data.to_csv.kconv(Kconv::SJIS), type: 'text/csv; charset=shift_jis' }
      #pdf
	    format.pdf do

        report = InvoiceListPDF.create @invoice_list 
        
        # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data(
          report.generate,
          filename:  "invoice_list.pdf",
          type:        "application/pdf",
          disposition: "inline")
      end
      
      #
	end
	
  end

   #税込請求金額
  #def billing_amount_with_tax  
  #  @billing_amount_with_tax = params[:billing_amount] * $consumption_tax_include 
  #end

  # GET /invoice_headers/1
  # GET /invoice_headers/1.json
  def show
  end

  # GET /invoice_headers/new
  def new
    @invoice_header = InvoiceHeader.new
	#顧客Mをビルド
    @invoice_header.build_customer_master
    
     #add180206
    #顧客Mで絞られている場合は、初期値としてセットする
    if eval(cookies[:recent_search_history].to_s).present?
      if eval(cookies[:recent_search_history].to_s)["customer_id_eq"].present?
        @invoice_header.customer_id = eval(cookies[:recent_search_history].to_s)["customer_id_eq"]
      end
    end
    ##
  end

  # GET /invoice_headers/1/edit
  def edit
  end

  # POST /invoice_headers
  # POST /invoice_headers.json
  def create
    #住所のパラメータを正常化
    adjust_address_params
    
	#手入力時の顧客マスターの新規登録
  	create_manual_input_customer
	
    #工事集計の確定区分があればセット
    set_final_return_division_params
    
    @invoice_header = InvoiceHeader.new(invoice_header_params)

    respond_to do |format|
      if @invoice_header.save
  
        #顧客Mも更新
        if @manual_flag.blank?  
          update_params_customer
        end
	    
        #工事担当者を更新
        #add190131
        update_construction_personnel
        
        #入金ファイルの完了フラグを更新
        set_deposit
        
        format.html { redirect_to @invoice_header, notice: 'Invoice header was successfully created.' }
        format.json { render :show, status: :created, location: @invoice_header }
      else
        format.html { render :new }
        format.json { render json: @invoice_header.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invoice_headers/1
  # PATCH/PUT /invoice_headers/1.json
  def update
  
    #住所のパラメータを正常化
    adjust_address_params

    #手入力時の顧客マスターの新規登録
  	create_manual_input_customer
      
    #工事集計の確定区分があればセット
    set_final_return_division_params
    
    #binding.pry
    
    respond_to do |format|
      if @invoice_header.update(invoice_header_params)

        #顧客Mも更新
        if @manual_flag.blank?  
          update_params_customer
        end
        #工事担当者を更新
        update_construction_personnel
        
        #入金ファイルの完了フラグを更新
        set_deposit
        
        #add200127
        #資金繰データ(会計)を更新
        @set_cash_flow = SetCashFlow.new
        @set_cash_flow.set_cash_flow_detail_actual_prepare(@invoice_header)
        #
        
        format.html { redirect_to @invoice_header, notice: 'Invoice header was successfully updated.' }
        format.json { render :show, status: :ok, location: @invoice_header }
      else
        format.html { render :edit }
        format.json { render json: @invoice_header.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoice_headers/1
  # DELETE /invoice_headers/1.json
  def destroy
    #ヘッダIDをここで保持(内訳・明細も消すため)
    @invoice_header_id = @invoice_header.id

    @invoice_header.destroy
    respond_to do |format|
      format.html { redirect_to invoice_headers_url, notice: 'Invoice header was successfully destroyed.' }
      format.json { head :no_content }
    end
	
    #資金繰りのデータも削除 (add200127)
    args = ["DELETE FROM account_cash_flow_detail_actual where invoice_header_id = ?" , 
                                    @invoice_header_id]
    sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
    result_params = ActiveRecord::Base.connection.execute(sql)
    #add end    
    
    #内訳も消す
    InvoiceDetailLargeClassification.where(invoice_header_id: @invoice_header_id).destroy_all

    #明細も消す
    InvoiceDetailMiddleClassification.where(invoice_header_id: @invoice_header_id).destroy_all
    
    #add230125
    #入金・日次入出金ファイルをここで抹消
    destroy_deposit
    delete_daily_cash_flow
  end
  
  #入金ファイルを抹消
  def destroy_deposit
    #@deposit = Deposit.find_by(invoice_header_id: @invoice_header_id)
    @deposit = Deposit.find_by(table_id: @invoice_header_id)
    if @deposit.present?
      #日次入出金ファイルを減算するために値取得
      @differ_date = @deposit.deposit_due_date
      @differ_amount = @deposit.deposit_amount
      #
      @deposit.destroy
    end
  end
  
  #日次入出金ファイルからマイナスする
  #@differ_date, @differ_amountが取得されている事
  def delete_daily_cash_flow
    daily_cash_flow = DailyCashFlow.find_by(cash_flow_date: @differ_date)
    if daily_cash_flow.present?
      daily_cash_flow.income -= @differ_amount
      #残高も要計算(保留)
      #daily_cash_flow.balance = daily_cash_flow.previous_balance - daily_cash_flow.income - daily_cash_flow.expence.to_i
      daily_cash_flow.save!(:validate => false)
    end
  end
  
  #入金ファイルの完了フラグ等を更新
  def set_deposit
    
    #@deposit = Deposit.find_by(invoice_header_id: @invoice_header.id)
    @deposit = Deposit.find_by(table_id: @invoice_header.id)
    
    #@deposit = nil
    
    if @invoice_header.deposit_complete_flag.present?  && 
       @invoice_header.deposit_complete_flag == 1
       
       #@deposit = Deposit.find_by(invoice_header_id: @invoice_header.id)
       
       if @deposit.present?
         @deposit.completed_flag = 1
         
         ###
         if @deposit.deposit_due_date != @invoice_header.payment_date
         #入金予定日と入金日が異なった場合、増減させる
            @differ_date = @deposit.deposit_due_date                  #予定日
            @differ_amount = @deposit.deposit_amount
            @payment_due_date = @invoice_header.payment_date      #実際の支払日
            #
            app_upsert_daily_cash_flow  #日次入出金マスターへの書き込み
            #
            @deposit.deposit_due_date = @invoice_header.payment_date  #実際の支払日で更新
         end
         ###
         
         ###
         #支払方法を更新(実際は現金で受け取った場合等を考慮)
         deposit_source_id = nil  #default
         
         #ADUSUの支払方法IDをC#(共通)用のものに変換する
         case @invoice_header.payment_method_id
         when $PAYMENT_METHOD_ID_CASH
           deposit_source_id = $BANK_ID_CASH
         when $PAYMENT_METHOD_ID_DAISHI_HOKUETSU
           deposit_source_id = $BANK_ID_DAISHI_HOKUETSU
         when $PAYMENT_METHOD_ID_SANSHIN
           deposit_source_id = $BANK_ID_SANSHIN_TSUKANOME #実際は本店であるがIDを合わせる
         end
         
         @deposit.deposit_source_id = deposit_source_id
         ###
         
         @deposit.save!(:validate => false)
         
         #入出金管理ファイルの完了フラグを更新
         set_daily_cash_flow_completed_flag
       end
    else
      #フラグない場合でも既存の入金データがあれば解除する
      if @deposit.present?
         @deposit.completed_flag = 0
         @deposit.save!(:validate => false)
         
         daily_cash_flow = DailyCashFlow.find_by(cash_flow_date: @deposit.deposit_due_date)
         if daily_cash_flow.present?
           daily_cash_flow.income_completed_flag = 0
           daily_cash_flow.save!(:validate => false)
         end
      end
    end
  
  end
  
  #入出金管理ファイルの完了フラグを更新
  #@depositが取得されていること
  def set_daily_cash_flow_completed_flag
    #その他の同日の入金ファイル検索し、完了していたら管理ファイルも完了させる
    deposits = Deposit.where(deposit_due_date: @deposit.deposit_due_date).
                       where.not(id: @deposit.id)
    all_deposit_flag = true
    if deposits.present?
      deposits.each do |deposit|
        if deposit.completed_flag.blank? ||
          deposit.completed_flag == 0
          all_deposit_flag = false
        end
      end
    end
    if all_deposit_flag
      daily_cash_flow = DailyCashFlow.find_by(cash_flow_date: @deposit.deposit_due_date)
      if daily_cash_flow.present?
        daily_cash_flow.income_completed_flag = 1
        daily_cash_flow.save!(:validate => false)
      end
    end
    #
  end
  
  #viewで拡散されたパラメータを、正常更新できるように復元させる。
  def adjust_address_params
    params[:invoice_header][:address] = params[:address]
  end
  
  #add170809
  def create_manual_input_customer
  #手入力時の顧客マスターの新規登録
    if params[:invoice_header][:customer_id] == "1"
	  
	   @manual_flag = true

       #upd171010 住所関連追加
       customer_params = {customer_name: params[:invoice_header][:customer_name], 
	                    honorific_id: params[:invoice_header][:honorific_id], 
	                    responsible1: params[:invoice_header][:responsible1], 
						responsible2: params[:invoice_header][:responsible2],
                        post: params[:invoice_header][:post], 
                        address: params[:invoice_header][:address],
                        house_number: params[:invoice_header][:house_number], 
                        address2: params[:invoice_header][:address2], 
                        tel_main: params[:invoice_header][:tel], 
                        fax_main: params[:invoice_header][:fax],
						closing_date: 0, due_date: 0 }
	  
	   @customer_master = CustomerMaster.new(customer_params)
       if @customer_master.save!(:validate => false)
		 @success_flag = true
	   else
		 @success_flag = false
	   end
	   
	   #請求データの顧客IDを登録済みのものにする。
	   if @success_flag == true
         params[:invoice_header][:customer_id] = @customer_master.id
       end
  
    end 
  end
  
  
  #add190131
  #工事Mの担当者を更新
  def update_construction_personnel
    
    #名称 
    if params[:invoice_header][:customer_name].present? && params[:invoice_header][:customer_name] != ""
      id = params[:invoice_header][:construction_datum_id].to_i
      construction = ConstructionDatum.where(:id => id).first
      
      if construction.present?    #マスター削除を考慮
        construction_params = { personnel: params[:invoice_header][:responsible1] }
        #更新する
	    construction.update(construction_params)
      end
      
    end
  end
  def update_params_customer
  #顧客Mの敬称・担当を更新する(未登録の場合)
    
    if params[:invoice_header][:customer_master_attributes].present?
	  id = params[:invoice_header][:customer_id].to_i
      @customer_masters = CustomerMaster.find(id)

	  if @customer_masters.present?
	    #名称 add170809
        if params[:invoice_header][:customer_name].present?
          params[:invoice_header][:customer_master_attributes][:customer_name] = params[:invoice_header][:customer_name]
        end
	  
        #敬称
        if params[:invoice_header][:honorific_id].present?
          params[:invoice_header][:customer_master_attributes][:honorific_id] = params[:invoice_header][:honorific_id]
        end
        
        #del190131
        #担当1
        #if params[:invoice_header][:responsible1].present?
        #  params[:invoice_header][:customer_master_attributes][:responsible1] = params[:invoice_header][:responsible1]
		#end
		#担当2
        if params[:invoice_header][:responsible2].present?
          params[:invoice_header][:customer_master_attributes][:responsible2] = params[:invoice_header][:responsible2]
		end
      
	    #add171010
        #住所関連/tel,fax追加(viewにも追加必要なので追加時は注意する)
		if params[:invoice_header][:post].present?
          params[:invoice_header][:customer_master_attributes][:post] = params[:invoice_header][:post]
		end
		if params[:invoice_header][:address].present?
          params[:invoice_header][:customer_master_attributes][:address] = params[:invoice_header][:address]
		end
		if params[:invoice_header][:house_number].present?
          params[:invoice_header][:customer_master_attributes][:house_number] = params[:invoice_header][:house_number]
		end
        if params[:invoice_header][:address2].present?
          params[:invoice_header][:customer_master_attributes][:address2] = params[:invoice_header][:address2]
		end
		
		if params[:invoice_header][:tel].present?
          params[:invoice_header][:customer_master_attributes][:tel_main] = params[:invoice_header][:tel]
		end
		if params[:invoice_header][:fax].present?
          params[:invoice_header][:customer_master_attributes][:fax_main] = params[:invoice_header][:fax]
		end
		#
		
	    #更新する
	    @invoice_header.update(customer_masters_params)
  
	  end
	  
    end
  end
  
  # ajax
  def construction_name_select
     @construction_name = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_name).flatten.join(" ")
  end
  
  #def customer_name_select
  def customer_info_select
     @customer_name = CustomerMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:customer_name).flatten.join(" ")
     @post = CustomerMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:post).flatten.join(" ")
     @address = CustomerMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:address).flatten.join(" ")
     @tel = CustomerMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:tel_main).flatten.join(" ")
     @fax = CustomerMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:fax_main).flatten.join(" ")
     @responsible1 = CustomerMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:responsible1).flatten.join(" ")
     @responsible2 = CustomerMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:responsible2).flatten.join(" ")
     #敬称
     id  = CustomerMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:honorific_id).flatten.join(" ").to_i
     @honorific_id  = [CustomerMaster.honorific[id]]
	 #あとからも選択できるようにする。
	 for num in 1..CustomerMaster.honorific.length
	   number = num -1
	   if number != id
	     @honorific_id = @honorific_id + [CustomerMaster.honorific[number]]
	   end
	 end
     
  end
  
  #工事集計の確定区分があればセット
  def set_final_return_division_params
    
    if params[:invoice_header][:construction_datum_id].present?
      construction_datum_id = params[:invoice_header][:construction_datum_id].to_i
       
      construction_cost = ConstructionCost.where(:construction_datum_id => construction_datum_id).first
      #工事集計データあり？
      if construction_cost.present?
        if construction_cost.final_return_division.present? && construction_cost.final_return_division > 0
          params[:invoice_header][:final_return_division] = construction_cost.final_return_division
        end
      end
    end
  end
  
  #add00917
  #コード自動採番
  def set_invoice_code
    
    #パラメーターからコードを作る
    dateStr = format("%04d%02d%02d", params[:year], params[:month], params[:day] ) 
    
    codeMin = dateStr + "00"
    codeMax = dateStr + "98"  #１日99件以上は考慮しない
    
    tmp_invoice_header_code = InvoiceHeader.where(invoice_code: codeMin..codeMax).maximum(:invoice_code)
    
    @new_code = nil
    
    if tmp_invoice_header_code.present?
      under = tmp_invoice_header_code[-2, 2].to_i + 1  #下２桁コードに１足す
      @new_code = dateStr + format("%02d", under)
    else
    #指定日のコードが存在しなかった場合  
      @new_code = dateStr + "01"
    end
    
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice_header
      @invoice_header = InvoiceHeader.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invoice_header_params
      params.require(:invoice_header).permit(:invoice_code, :quotation_code, :delivery_slip_code, :invoice_date, :construction_datum_id, :construction_name, 
            :customer_id, :customer_name, :honorific_id, :responsible1, :responsible2, :post, :address, :house_number, :address2,  
            :tel, :fax, :construction_period, :construction_place,
            :payment_period, :invoice_period_start_date, :invoice_period_end_date, :billing_amount, :execution_amount, 
            :deposit_amount, :payment_method_id, :commission, :payment_date, :labor_insurance_not_flag, :last_line_number, :remarks, :final_return_division,
            :deposit_complete_flag)
    end
    
    # 
    def customer_masters_params
	     #upd170809
         params.require(:invoice_header).permit(customer_master_attributes: [:id, :customer_name, :honorific_id, :responsible1, :responsible2,
                                                :post, :address, :house_number, :address2, :tel_main, :fax_main ])
	end
end
