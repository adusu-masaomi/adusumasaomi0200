class StorageInventoryHistoriesController < ApplicationController
  before_action :set_storage_inventory_history, only: [:show, :edit, :update, :destroy]

  # GET /storage_inventory_histories
  # GET /storage_inventory_histories.json
  def index
    @storage_inventory_histories = StorageInventoryHistory.all
  end

  # GET /storage_inventory_histories/1
  # GET /storage_inventory_histories/1.json
  def show
  end

  # GET /storage_inventory_histories/new
  def new
    @storage_inventory_history = StorageInventoryHistory.new
  end

  # GET /storage_inventory_histories/1/edit
  def edit
  end

  # POST /storage_inventory_histories
  # POST /storage_inventory_histories.json
  def create
    @storage_inventory_history = StorageInventoryHistory.new(storage_inventory_history_params)

    respond_to do |format|
      if @storage_inventory_history.save
        format.html { redirect_to @storage_inventory_history, notice: 'Storage inventory history was successfully created.' }
        format.json { render :show, status: :created, location: @storage_inventory_history }
      else
        format.html { render :new }
        format.json { render json: @storage_inventory_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /storage_inventory_histories/1
  # PATCH/PUT /storage_inventory_histories/1.json
  def update
    respond_to do |format|
      if @storage_inventory_history.update(storage_inventory_history_params)
        format.html { redirect_to @storage_inventory_history, notice: 'Storage inventory history was successfully updated.' }
        format.json { render :show, status: :ok, location: @storage_inventory_history }
      else
        format.html { render :edit }
        format.json { render json: @storage_inventory_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /storage_inventory_histories/1
  # DELETE /storage_inventory_histories/1.json
  def destroy
    @storage_inventory_history.destroy
    respond_to do |format|
      format.html { redirect_to storage_inventory_histories_url, notice: 'Storage inventory history was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_storage_inventory_history
      @storage_inventory_history = StorageInventoryHistory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def storage_inventory_history_params
      params.require(:storage_inventory_history).permit(:occurred_date, :slip_code, :purchase_order_datum_id, :construction_datum_id, :material_master_id, :quantity, :unit_price, :amount, :supplier_master_id, :invenrtory_division_id)
    end
end
