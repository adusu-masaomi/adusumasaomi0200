class DeliverySlipHeadersController < ApplicationController
  before_action :set_delivery_slip_header, only: [:show, :edit, :update, :destroy]

  # GET /delivery_slip_headers
  # GET /delivery_slip_headers.json
  def index
    #@delivery_slip_headers = DeliverySlipHeader.all
    
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)  	

    #binding.pry

    #@q = DeliverySlipHeader.ransack(params[:q])  
    #ransack保持用--上記はこれに置き換える
    @q = DeliverySlipHeader.ransack(query)
    
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
    
    @delivery_slip_headers = @q.result(distinct: true)
    @delivery_slip_headers  = @delivery_slip_headers.page(params[:page])

  end

  # GET /delivery_slip_headers/1
  # GET /delivery_slip_headers/1.json
  def show
  end

  # GET /delivery_slip_headers/new
  def new
    @delivery_slip_header = DeliverySlipHeader.new
    #顧客Mをビルド
    @delivery_slip_header.build_customer_master
    
    #add180206
    #顧客Mで絞られている場合は、初期値としてセットする
    if eval(cookies[:recent_search_history].to_s).present?
      if eval(cookies[:recent_search_history].to_s)["customer_id_eq"].present?
        @delivery_slip_header.customer_id = eval(cookies[:recent_search_history].to_s)["customer_id_eq"]
      end
    end
    ##
    
  end

  # GET /delivery_slip_headers/1/edit
  def edit
  end

  # POST /delivery_slip_headers
  # POST /delivery_slip_headers.json
  def create
    #住所のパラメータを正常化
    adjust_address_params
    
	 #add170809
    #手入力時の顧客マスターの新規登録
  	create_manual_input_customer
	
    @delivery_slip_header = DeliverySlipHeader.new(delivery_slip_header_params)

    respond_to do |format|
      if @delivery_slip_header.save
        
        #顧客Mも更新
		if @manual_flag.blank?
          update_params_customer
        end
		
        format.html { redirect_to @delivery_slip_header, notice: 'Delivery slip header was successfully created.' }
        format.json { render :show, status: :created, location: @delivery_slip_header }
      else
        format.html { render :new }
        format.json { render json: @delivery_slip_header.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  # PATCH/PUT /delivery_slip_headers/1
  # PATCH/PUT /delivery_slip_headers/1.json
  def update
    
    #住所のパラメータを正常化
    adjust_address_params
  
    #add170809
    #手入力時の顧客マスターの新規登録
  	create_manual_input_customer
  
    respond_to do |format|
      if @delivery_slip_header.update(delivery_slip_header_params)
        
		#顧客Mも更新
		if @manual_flag.blank?
          update_params_customer
		end
		
        format.html { redirect_to @delivery_slip_header, notice: 'Delivery slip header was successfully updated.' }
        format.json { render :show, status: :ok, location: @delivery_slip_header }
      else
        format.html { render :edit }
        format.json { render json: @delivery_slip_header.errors, status: :unprocessable_entity }
      end
    end
  end
 
  # DELETE /delivery_slip_headers/1
  # DELETE /delivery_slip_headers/1.json
  def destroy
    #ヘッダIDをここで保持(内訳・明細も消すため)
    delivery_slip_header_id = @delivery_slip_header.id
  
    @delivery_slip_header.destroy
    respond_to do |format|
      format.html { redirect_to delivery_slip_headers_url, notice: 'Delivery slip header was successfully destroyed.' }
      format.json { head :no_content }
    end
	
	#内訳も消す
	DeliverySlipDetailLargeClassification.where(delivery_slip_header_id: delivery_slip_header_id).destroy_all
		
	#明細も消す
	DeliverySlipDetailMiddleClassification.where(delivery_slip_header_id: delivery_slip_header_id).destroy_all
  end
  
   #viewで拡散されたパラメータを、正常更新できるように復元させる。
  def adjust_address_params
    params[:delivery_slip_header][:address] = params[:address]
	
	#add170830
	params[:delivery_slip_header][:construction_place] = params[:construction_place]
  end
  
  
   #add170809
  def create_manual_input_customer
  #手入力時の顧客マスターの新規登録
    
    if params[:delivery_slip_header][:customer_id] == "1"
	
	   @manual_flag = true
	
       customer_params = {customer_name: params[:delivery_slip_header][:customer_name], 
	                    honorific_id: params[:delivery_slip_header][:honorific_id], 
	                    responsible1: params[:delivery_slip_header][:responsible1], 
                        responsible2: params[:delivery_slip_header][:responsible2],
                        post: params[:delivery_slip_header][:post], 
                        address: params[:delivery_slip_header][:address],
                        house_number: params[:delivery_slip_header][:house_number], 
                        address2: params[:delivery_slip_header][:address2], 
                        tel_main: params[:delivery_slip_header][:tel], 
                        fax_main: params[:delivery_slip_header][:fax],
                        closing_date: 0, due_date: 0 }
	  
	   @customer_master = CustomerMaster.new(customer_params)
       if @customer_master.save!(:validate => false)
		 @success_flag = true
	   else
		 @success_flag = false
	   end
	   
	   #納品データの顧客IDを登録済みのものにする。
	   if @success_flag == true
         params[:delivery_slip_header][:customer_id] = @customer_master.id
       end
  
    end 
  end
  
  def update_params_customer
  #顧客Mの敬称・担当を更新する(未登録の場合)
    
    if params[:delivery_slip_header][:customer_master_attributes].present?
	  id = params[:delivery_slip_header][:customer_id].to_i
      @customer_masters = CustomerMaster.find(id)

	  if @customer_masters.present?
	    #名称 add170809
        if params[:delivery_slip_header][:customer_name].present?
          params[:delivery_slip_header][:customer_master_attributes][:customer_name] = params[:delivery_slip_header][:customer_name]
        end
		
        #敬称
        if params[:delivery_slip_header][:honorific_id].present?
          params[:delivery_slip_header][:customer_master_attributes][:honorific_id] = params[:delivery_slip_header][:honorific_id]
        end
        #担当1
        if params[:delivery_slip_header][:responsible1].present?
          params[:delivery_slip_header][:customer_master_attributes][:responsible1] = params[:delivery_slip_header][:responsible1]
		end
		#担当2
        if params[:delivery_slip_header][:responsible2].present?
          params[:delivery_slip_header][:customer_master_attributes][:responsible2] = params[:delivery_slip_header][:responsible2]
		end
        
		#add171010
        #住所関連/tel,fax追加
		if params[:delivery_slip_header][:post].present?
          params[:delivery_slip_header][:customer_master_attributes][:post] = params[:delivery_slip_header][:post]
		end
		if params[:delivery_slip_header][:address].present?
          params[:delivery_slip_header][:customer_master_attributes][:address] = params[:delivery_slip_header][:address]
		end
		if params[:delivery_slip_header][:house_number].present?
          params[:delivery_slip_header][:customer_master_attributes][:house_number] = params[:delivery_slip_header][:house_number]
		end
        if params[:delivery_slip_header][:address2].present?
          params[:delivery_slip_header][:customer_master_attributes][:address2] = params[:delivery_slip_header][:address2]
		end
		if params[:delivery_slip_header][:tel].present?
          params[:delivery_slip_header][:customer_master_attributes][:tel_main] = params[:delivery_slip_header][:tel]
		end
		if params[:delivery_slip_header][:fax].present?
          params[:delivery_slip_header][:customer_master_attributes][:fax_main] = params[:delivery_slip_header][:fax]
		end
		#
		
	    #更新する
	    @delivery_slip_header.update(customer_masters_params)
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
    def set_delivery_slip_header
      @delivery_slip_header = DeliverySlipHeader.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def delivery_slip_header_params
      params.require(:delivery_slip_header).permit(:delivery_slip_code, :quotation_code, :invoice_code, :delivery_slip_date,
                     :construction_datum_id, :construction_name, :customer_id, :customer_name, :honorific_id, :responsible1, :responsible2, 
                     :post, :address, :tel, :house_number, :address2, :fax, :construction_period, :construction_post, :construction_place, 
                     :construction_house_number, :construction_place2, :delivery_amount, :execution_amount, :last_line_number)
    end
	
	  # 
    def customer_masters_params
      #params.require(:delivery_slip_header).permit(customer_master_attributes: [:id,  :honorific_id, :responsible1, :responsible2 ])
	  #upd170809
	  params.require(:delivery_slip_header).permit(customer_master_attributes: [:id, :customer_name, :honorific_id, :responsible1, :responsible2, 
                                                                            :post, :address, :house_number, :address2, :tel_main, :fax_main ])
    end
end
