class StocktakesController < ApplicationController
  before_action :set_stocktake, only: [:show, :edit, :update, :destroy]

  # GET /stocktakes
  # GET /stocktakes.json
  def index
    #@stocktakes = Stocktake.all
   
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)  	
   
	#ransack保持用-
    @q = Stocktake.ransack(query)   
    
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
	
    @stocktakes  = @q.result(distinct: true)
    
    #kaminari用設定
    @stocktakes  = @stocktakes.page(params[:page])
	#
	
	#在庫マスター・履歴マスターへの反映（一括更新）
	if params[:update_flag] == "1"
	  update_inventory
	end
	
	
	#global set
	$stocktakes = @stocktakes
	
	#棚卸日をセット
	$stocktake_date = nil
    if query.present?
	  if query["stocktake_date_gteq"].present?
        $stocktake_date = query["stocktake_date_gteq"]
	  end
	end
	
	respond_to do |format|
	  format.html
	  #pdf
	  format.pdf do
        
		$print_flag = params[:print_flag]
		report = InventoryActionListPDF.create @inventory_action_list 
       
		# ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data(
          report.generate,
          filename:  "inventory_action_list.pdf",
          type:        "application/pdf",
          disposition: "inline")
      end
	end
	#
	
  end
  
  #在庫マスターへの反映
  def update_inventory
    #binding.pry
	
	@stocktakes.where(inventory_update_flag: nil).each do |stocktake| 
	  if stocktake.physical_quantity.present? && stocktake.book_quantity.present?
	#在庫履歴マスターを更新
		
		#棚卸日	#在庫区分
		#工事ID
		@stocktake_record = stocktake
		get_construction_datum_id
		#品番
		#差異数を求める
	    differ_quantity =  stocktake.physical_quantity - stocktake.book_quantity
		#単位(在庫Mから取得)
		unit_master_id = 1
		inventory = Inventory.find_by(material_master_id: stocktake.material_master_id)
		if inventory.present? && inventory.unit_master_id.present?
		  unit_master_id = inventory.unit_master_id
		end
		
		#単価(とりあえず最新)
		unit_price = stocktake.unit_price
		#金額
		price = differ_quantity * unit_price
		#仕入先ID(在庫Mから取得)
		supplier_master_id = 1
		if inventory.present? && inventory.supplier_master_id.present?
		  supplier_master_id = inventory.supplier_master_id
		end
		
		inventory_hisotory_params = {inventory_date: stocktake.stocktake_date, inventory_division_id: $INDEX_INVENTORY_STOCKTAKE, 
                                     construction_datum_id: @construction_datum_id, material_master_id: stocktake.material_master_id, 
									 quantity: differ_quantity, unit_master_id: unit_master_id, unit_price: unit_price, 
									 price: price, supplier_master_id: supplier_master_id }
		
		@inventory_hisotry = InventoryHistory.create(inventory_hisotory_params)
		
		
	#在庫マスターを更新
		if inventory.present?
		  
		  #在庫Mへ差異数量を加える
		  inventory_quantity = inventory.inventory_quantity + differ_quantity
		  #
		  current_quantity = inventory.current_quantity + differ_quantity
		  #別ロット分数量への影響（先入先出）あり！！！！！
		  #
		  
		  #差異金額
		  differ_amount =  stocktake.physical_amount - stocktake.book_amount
		  #在庫Mへ上記差異金額を加える
		  inventory_amount = inventory.inventory_amount + differ_amount
		  #別ロット分数量への影響（先入先出）あり！！！！！
		  #
		  #
		  
		  #本来なら現在数量、現在単価にも影響する！！（今のところはそのままとする！！）
	      inventory_update_params = {inventory_quantity: inventory_quantity, inventory_amount: inventory_amount, 
                                     current_quantity: current_quantity }
	  
          inventory.update(inventory_update_params)
	    end
	  
	  end
	  
	end
    
	##
	#在庫更新フラグを全て１にセットする。(コールバック考慮してないので今一かも・・)
    @stocktakes.where(inventory_update_flag: nil).update_all(:inventory_update_flag => 1)
    
  end
  
  def get_construction_datum_id
  #資材マスターの品目区分より、工事IDを割振ってセットする
    material_master = MaterialMaster.find(@stocktake_record.material_master_id)
	
	@construction_datum_id = 1
	
	if material_master.present?
	  inventory_category_id = material_master.inventory_category_id
	  @construction_datum_id = ConstructionDatum.get_construction_on_inventory_category(inventory_category_id)
	end
    
  end
  
  
  # GET /stocktakes/1
  # GET /stocktakes/1.json
  def show
  end

  # GET /stocktakes/new
  def new
    @stocktake = Stocktake.new
  end

  # GET /stocktakes/1/edit
  def edit
  end

  # POST /stocktakes
  # POST /stocktakes.json
  def create

    @stocktake = Stocktake.new(stocktake_params)
    
    #在庫マスターのIDをセットする
	update_flag = 0
    set_inventories_id
	
    respond_to do |format|
      if @stocktake.save
        format.html { redirect_to @stocktake, notice: 'Stocktake was successfully created.' }
        format.json { render :show, status: :created, location: @stocktake }
      else
        format.html { render :new }
        format.json { render json: @stocktake.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stocktakes/1
  # PATCH/PUT /stocktakes/1.json
  def update
  
    #在庫マスターのIDをセットする
    update_flag = 1
	set_inventories_id
  
    respond_to do |format|
      if @stocktake.update(stocktake_params)
        format.html { redirect_to @stocktake, notice: 'Stocktake was successfully updated.' }
        format.json { render :show, status: :ok, location: @stocktake }
      else
        format.html { render :edit }
        format.json { render json: @stocktake.errors, status: :unprocessable_entity }
      end
    end
  end

  #在庫マスターのIDをセットする（主に単位取得用として）
  def set_inventories_id
    
    #倉庫・ロケーションは１で固定（将来的に設定追加するかも）
	inventory = Inventory.find_by(material_master_id: @stocktake.material_master_id, warehouse_id: 1, location_id: 1)
    
	if inventory.present?
	  if update_flag = 0
	    @stocktake.inventory_id = inventory.id
	  else
        params[:stocktake][:inventory_id] = inventory.id
	  end
	end 
    
  end

  # DELETE /stocktakes/1
  # DELETE /stocktakes/1.json
  def destroy
    @stocktake.destroy
    respond_to do |format|
      format.html { redirect_to stocktakes_url, notice: 'Stocktake was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stocktake
      @stocktake = Stocktake.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stocktake_params
      params.require(:stocktake).permit(:stocktake_date, :material_master_id, :inventory_id, :physical_quantity, :unit_price, 
                                        :physical_amount, :book_quantity, :book_amount, :inventory_update_flag)
    end
end
