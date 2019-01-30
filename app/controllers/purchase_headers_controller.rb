class PurchaseHeadersController < ApplicationController
  before_action :set_purchase_header, only: [:show, :edit, :update, :destroy]

  # GET /purchase_headers
  # GET /purchase_headers.json
  def index
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s) 
  
    #@purchase_headers = PurchaseHeader.all
    @q = PurchaseHeader.ransack(query)   
    
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
	
	@purchase_headers = @q.result(distinct: true)
    @purchase_headers = @purchase_headers.page(params[:page])
    
  end

  # GET /purchase_headers/1
  # GET /purchase_headers/1.json
  def show
  end

  # GET /purchase_headers/new
  def new
    @purchase_header = PurchaseHeader.new
  end

  # GET /purchase_headers/1/edit
  def edit
  end

  # POST /purchase_headers
  # POST /purchase_headers.json
  def create
    @purchase_header = PurchaseHeader.new(purchase_header_params)

    respond_to do |format|
      if @purchase_header.save
        format.html { redirect_to @purchase_header, notice: 'Purchase header was successfully created.' }
        format.json { render :show, status: :created, location: @purchase_header }
      else
        format.html { render :new }
        format.json { render json: @purchase_header.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purchase_headers/1
  # PATCH/PUT /purchase_headers/1.json
  def update
    respond_to do |format|
      if @purchase_header.update(purchase_header_params)
        format.html { redirect_to @purchase_header, notice: 'Purchase header was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase_header }
      else
        format.html { render :edit }
        format.json { render json: @purchase_header.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_headers/1
  # DELETE /purchase_headers/1.json
  def destroy
    @purchase_header.destroy
    respond_to do |format|
      format.html { redirect_to purchase_headers_url, notice: 'Purchase header was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_header
      @purchase_header = PurchaseHeader.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_header_params
      params.require(:purchase_header).permit(:slip_code, :complete_flag)
    end
end
