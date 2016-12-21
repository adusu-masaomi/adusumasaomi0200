class PurchaseUnitPricesController < ApplicationController
  before_action :set_purchase_unit_price, only: [:show, :edit, :update, :destroy]
  autocomplete :supplier_master, :supplier_name, :full => true
  
  respond_to :html, :json
  
  # GET /purchase_unit_prices
  # GET /purchase_unit_prices.json
  def index
   
   #ransack保持用コード
   query = params[:q]
   query ||= eval(cookies[:recent_search_history].to_s)  	
  
   #@purchase_unit_prices = PurchaseUnitPrice.page(params[:page])
   #@q = PurchaseUnitPrice.ransack(params[:q])   
   #ransack保持用--上記はこれに置き換える
   @q = PurchaseUnitPrice.ransack(query)
   
   #ransack保持用コード
   search_history = {
   value: params[:q],
   expires: 30.minutes.from_now
   }
   cookies[:recent_search_history] = search_history if params[:q].present?
   #
   
   @purchase_unit_prices = @q.result(distinct: true)
   @purchase_unit_prices = @purchase_unit_prices.page(params[:page])


    @material_master = MaterialMaster.all
    @supplier_master = SupplierMaster.all
    @unit_master = UnitMaster.all
  end

  # GET /purchase_unit_prices/1
  # GET /purchase_unit_prices/1.json
  def show
  end

  # GET /purchase_unit_prices/new
  def new
    @purchase_unit_price = PurchaseUnitPrice.new
	
	#資材マスターから遷移した場合
	#予め資材ID/CDをセットする
	if params[:material_id].present?
          @purchase_unit_price.supplier_id = 1     #入力忘れ防止の為に１をセット
          @purchase_unit_price.material_id = params[:material_id]
	  @purchase_unit_price.supplier_material_code = @purchase_unit_price.MaterialMaster.material_code
       end
	
  end

  # GET /purchase_unit_prices/1/edit
  def edit
  end

  # POST /purchase_unit_prices
  # POST /purchase_unit_prices.json
  def create
    @purchase_unit_price = PurchaseUnitPrice.new(purchase_unit_price_params)

    respond_to do |format|
      if @purchase_unit_price.save
        format.html { redirect_to @purchase_unit_price, notice: 'Purchase unit price was successfully created.' }
        format.json { render :show, status: :created, location: @purchase_unit_price }
      else
        format.html { render :new }
        format.json { render json: @purchase_unit_price.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purchase_unit_prices/1
  # PATCH/PUT /purchase_unit_prices/1.json
  def update
    respond_to do |format|
      if @purchase_unit_price.update(purchase_unit_price_params)
        format.html { redirect_to @purchase_unit_price, notice: 'Purchase unit price was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase_unit_price }
      else
        format.html { render :edit }
        format.json { render json: @purchase_unit_price.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_unit_prices/1
  # DELETE /purchase_unit_prices/1.json
  def destroy
    @purchase_unit_price.destroy
    respond_to do |format|
      format.html { redirect_to purchase_unit_prices_url, notice: 'Purchase unit price was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_unit_price
      @purchase_unit_price = PurchaseUnitPrice.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_unit_price_params
      params.require(:purchase_unit_price).permit(:supplier_id, :material_id, :supplier_material_code, :unit_price, :list_price, :unit_id)
    end
end
