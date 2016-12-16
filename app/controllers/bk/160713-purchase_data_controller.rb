class PurchaseDataController < ApplicationController
  before_action :set_purchase_datum, only: [:show, :edit, :update, :destroy]

  # GET /purchase_data
  # GET /purchase_data.json
  
  def index
  	#@purchase_data = PurchaseDatum.all
    @q        = PurchaseDatum.search(params[:q])
	@v        = PurchaseOrderDatum.search(params[:q])
    @purchase_data = @q.result(distinct: true)
	@maker_masters = MakerMaster.all
	@purchase_division_masters = PurchaseDivisionMaster.all
	@supplier_masters = SupplierMaster.all
	@purchase_order_data = PurchaseOrderDatum.all
	@construction_data = ConstructionDatum.all
	@customer_masters = CustomerMaster.all
	@material_masters = MaterialMaster.all
	@unit_masters = UnitMaster.all
  end

  # GET /purchase_data/1
  # GET /purchase_data/1.json
  def show
  end

  # GET /purchase_data/new
  def new
    @purchase_datum = PurchaseDatum.new
  end

  # GET /purchase_data/1/edit
  def edit
  end

  # POST /purchase_data
  # POST /purchase_data.json
  def create
    @purchase_datum = PurchaseDatum.new(purchase_datum_params)

    respond_to do |format|
      if @purchase_datum.save
        format.html { redirect_to @purchase_datum, notice: 'Purchase datum was successfully created.' }
        format.json { render :show, status: :created, location: @purchase_datum }
      else
        format.html { render :new }
        format.json { render json: @purchase_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purchase_data/1
  # PATCH/PUT /purchase_data/1.json
  def update
    respond_to do |format|
      if @purchase_datum.update(purchase_datum_params)
        format.html { redirect_to @purchase_datum, notice: 'Purchase datum was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase_datum }
      else
        format.html { render :edit }
        format.json { render json: @purchase_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_data/1
  # DELETE /purchase_data/1.json
  def destroy
    @purchase_datum.destroy
    respond_to do |format|
      format.html { redirect_to purchase_data_url, notice: 'Purchase datum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_datum
      @purchase_datum = PurchaseDatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_datum_params
      params.require(:purchase_datum).permit(:purchase_date, :order_id, :material_id, :material_name, :maker_id, :maker_name, :quantity, :unit_id, :purchase_unit_price, :purchase_amount, :list_price, :supplier_id, :division_id)
    end
end
