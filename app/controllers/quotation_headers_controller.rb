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
  end

  # GET /quotation_headers/1/edit
  def edit
  end

  # POST /quotation_headers
  # POST /quotation_headers.json
  def create
    @quotation_header = QuotationHeader.new(quotation_header_params)

    respond_to do |format|
      if @quotation_header.save
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
    respond_to do |format|
      if @quotation_header.update(quotation_header_params)
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
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quotation_header
      @quotation_header = QuotationHeader.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quotation_header_params
      params.require(:quotation_header).permit(:quotation_code, :quotation_date, :construction_datum_id, :construction_name, :customer_id, :customer_name, :post, :address, :tel, :fax, :construction_period, :construction_place, :trading_method, :effective_period, :net_amount, :quote_price, :execution_amount)
    end
end
