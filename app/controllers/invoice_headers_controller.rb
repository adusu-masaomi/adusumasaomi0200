class InvoiceHeadersController < ApplicationController
  before_action :set_invoice_header, only: [:show, :edit, :update, :destroy]

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
    
	#add170809
    #手入力時の顧客マスターの新規登録
  	create_manual_input_customer
	  
    @invoice_header = InvoiceHeader.new(invoice_header_params)

    respond_to do |format|
      if @invoice_header.save
	  
        #顧客Mも更新
		if @manual_flag.blank?  #add170809
	      update_params_customer
	    end
	  
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
	
	#add170809
    #手入力時の顧客マスターの新規登録
  	create_manual_input_customer
	
    respond_to do |format|
      if @invoice_header.update(invoice_header_params)

		#顧客Mも更新
		if @manual_flag.blank?  #add170809
          update_params_customer
        end

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
	invoice_header_id = @invoice_header.id
	
    @invoice_header.destroy
    respond_to do |format|
      format.html { redirect_to invoice_headers_url, notice: 'Invoice header was successfully destroyed.' }
      format.json { head :no_content }
    end
	
	#内訳も消す
	InvoiceDetailLargeClassification.where(invoice_header_id: invoice_header_id).destroy_all
		
	#明細も消す
	InvoiceDetailMiddleClassification.where(invoice_header_id: invoice_header_id).destroy_all
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
        #担当1
        if params[:invoice_header][:responsible1].present?
          params[:invoice_header][:customer_master_attributes][:responsible1] = params[:invoice_header][:responsible1]
		end
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
            :deposit_amount, :payment_method_id, :commission, :payment_date, :labor_insurance_not_flag, :last_line_number, :remarks)
    end
    
    # 
    def customer_masters_params
	     #upd170809
         params.require(:invoice_header).permit(customer_master_attributes: [:id, :customer_name, :honorific_id, :responsible1, :responsible2,
                                                :post, :address, :house_number, :address2, :tel_main, :fax_main ])
	end
end
