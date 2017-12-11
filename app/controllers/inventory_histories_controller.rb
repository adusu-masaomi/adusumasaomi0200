class InventoryHistoriesController < ApplicationController
  before_action :set_inventory_history, only: [:show, :edit, :update, :destroy]

  # GET /inventory_histories
  # GET /inventory_histories.json
  def index
    #@inventory_histories = InventoryHistory.all
	
	#ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)  	
   
   
	#ransack保持用-
    @q = InventoryHistory.ransack(query)   
    
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
	
    @inventory_histories  = @q.result(distinct: true)
    
    #kaminari用設定
    @inventory_histories  = @inventory_histories.page(params[:page])
	#
	
	
	#global set
	$inventory_histories = @inventory_histories
	
    #####
    #検索用のパラメータがセットされていたら、グローバルにもセットする
    if query.present?
      $material_search_flag = false
      #if query["with_material_code"].present? || query["with_material_code_include"].present? || 
      #   query["with_material_name_include"].present?
	  if query["with_material_code"].present?
      #品番／品名検索が行われていれば見出し表示させる
        $material_search_flag = true 
      end
    end
    #####
	
	respond_to do |format|
	  
	  format.html
	  
	  #pdf
	  #@print_type = params[:print_type]
	
	  format.pdf do
        
		report = WarehouseAndDeliveryListPDF.create @warehouse_and_delivery_list 
        
		# ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data(
          report.generate,
          filename:  "warehouse_and_delivery_list.pdf",
          type:        "application/pdf",
          disposition: "inline")
      end
      
      #
	end
	
	
	
  end

  # GET /inventory_histories/1
  # GET /inventory_histories/1.json
  def show
  end

  # GET /inventory_histories/new
  def new
    @inventory_history = InventoryHistory.new
  end

  # GET /inventory_histories/1/edit
  def edit
  end

  # POST /inventory_histories
  # POST /inventory_histories.json
  def create
    @inventory_history = InventoryHistory.new(inventory_history_params)

    respond_to do |format|
      if @inventory_history.save
        format.html { redirect_to @inventory_history, notice: 'Inventory history was successfully created.' }
        format.json { render :show, status: :created, location: @inventory_history }
      else
        format.html { render :new }
        format.json { render json: @inventory_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /inventory_histories/1
  # PATCH/PUT /inventory_histories/1.json
  def update
    respond_to do |format|
      if @inventory_history.update(inventory_history_params)
        format.html { redirect_to @inventory_history, notice: 'Inventory history was successfully updated.' }
        format.json { render :show, status: :ok, location: @inventory_history }
      else
        format.html { render :edit }
        format.json { render json: @inventory_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inventory_histories/1
  # DELETE /inventory_histories/1.json
  def destroy
    @inventory_history.destroy
    respond_to do |format|
      format.html { redirect_to inventory_histories_url, notice: 'Inventory history was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inventory_history
      @inventory_history = InventoryHistory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inventory_history_params
      params.require(:inventory_history).permit(:inventory_date, :construction_datum_id, :material_master_id, :quantity, :unit_master_id, :unit_price, 
                                                :price, :supplier_master_id, :inventory_division_id, :slip_code, :purchase_datm_id, 
                                                :previous_quantity, :previous_unit_price )
    end
end
