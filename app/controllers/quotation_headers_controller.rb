class QuotationHeadersController < ApplicationController
  before_action :set_quotation_header, only: [:show, :edit, :update, :destroy]

  # GET /quotation_headers
  # GET /quotation_headers.json
  def index
    #@quotation_headers = QuotationHeader.all

    @q = QuotationHeader.ransack(params[:q])  
    @quotation_headers = @q.result(distinct: true)
    @quotation_headers  = @quotation_headers.page(params[:page])
	
  end

  # GET /quotation_headers/1
  # GET /quotation_headers/1.json
  def show
  end

  # GET /quotation_headers/new
  def new
    @quotation_header = QuotationHeader.new
    #顧客Mをビルド
    @quotation_header.build_customer_master
  end

  # GET /quotation_headers/1/edit
  def edit
  
    #顧客Mをビルド
    #@quotation_header.build_customer_master
	
  end

  # POST /quotation_headers
  # POST /quotation_headers.json
  def create
    #住所のパラメータを正常化
    adjust_address_params
	
    @quotation_header = QuotationHeader.new(quotation_header_params)

    respond_to do |format|
      if @quotation_header.save
	  
	    #顧客Mも更新
	    update_params_customer
		
        format.html { redirect_to @quotation_header, notice: 'Quotation header was successfully created.' }
        format.json { render :show, status: :created, location: @quotation_header }
      else
        format.html { render :new }
        format.json { render json: @quotation_header.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quotation_headers/1
  # PATCH/PUT /quotation_headers/1.json
  def update
  
    #住所のパラメータを正常化
    adjust_address_params
  
    respond_to do |format|
      if @quotation_header.update(quotation_header_params)
	  
	    #顧客Mも更新
	    update_params_customer
	  
        format.html { redirect_to @quotation_header, notice: 'Quotation header was successfully updated.' }
        format.json { render :show, status: :ok, location: @quotation_header }
      else
        format.html { render :edit }
        format.json { render json: @quotation_header.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quotation_headers/1
  # DELETE /quotation_headers/1.json
  def destroy
    @quotation_header.destroy
    respond_to do |format|
      format.html { redirect_to quotation_headers_url, notice: 'Quotation header was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  #viewで拡散されたパラメータを、正常更新できるように復元させる。
  def adjust_address_params
    params[:quotation_header][:address] = params[:address]
  end
  
  
  def update_params_customer
  #顧客Mの敬称・担当を更新する(未登録の場合)
    
    if params[:quotation_header][:customer_master_attributes].present?
	  id = params[:quotation_header][:customer_id].to_i
      @customer_masters = CustomerMaster.find(id)

	  if @customer_masters.present?
        #敬称
        if params[:quotation_header][:honorific_id].present?
          params[:quotation_header][:customer_master_attributes][:honorific_id] = params[:quotation_header][:honorific_id]
        end
        #担当1
        if params[:quotation_header][:responsible1].present?
          params[:quotation_header][:customer_master_attributes][:responsible1] = params[:quotation_header][:responsible1]
		end
		#担当2
        if params[:quotation_header][:responsible2].present?
          params[:quotation_header][:customer_master_attributes][:responsible2] = params[:quotation_header][:responsible2]
		end
      
	    #更新する
	    @quotation_header.update(customer_masters_params)
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
    def set_quotation_header
      @quotation_header = QuotationHeader.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quotation_header_params
      params.require(:quotation_header).permit(:quotation_code, :quotation_date, :construction_datum_id, :construction_name, :honorific_id, :responsible1, :responsible2, 
                                               :customer_id, :customer_name, :post, :address, :tel, :fax, :construction_period, :construction_place, :trading_method, 
                                               :effective_period, :net_amount, :quote_price, :execution_amount )
    end
    
    # 
    def customer_masters_params
         params.require(:quotation_header).permit(customer_master_attributes: [:id,  :honorific_id, :responsible1, :responsible2 ])
    end

end
