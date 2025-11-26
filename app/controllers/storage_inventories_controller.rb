class StorageInventoriesController < ApplicationController
  before_action :set_storage_inventory, only: [:show, :edit, :update, :destroy]

  # GET /storage_inventories
  # GET /storage_inventories.json
  def index
    #@storage_inventories = StorageInventory.all
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)
    
    #ransack保持用-
    @q = StorageInventory.ransack(query)
    
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
	
    @storage_inventories  = @q.result(distinct: true)
    
    #pdf用にセット
    @storage_inventory_list = @storage_inventories
    
    #kaminari用設定
    @storage_inventories  = @storage_inventories.page(params[:page])
    
    #事務所or倉庫をセット
    if params[:q] && params[:q][:warehouse_id_eq].present?
      warehouse_name = StorageInventory.warehouse[params[:q][:warehouse_id_eq].to_i][0]
      cookies[:warehouse] = warehouse_name
    else
      if params[:q].present?
        cookies[:warehouse] = nil  #未選択とする
      end
    end
    #分類をセット
    #params[:q][:with_material_category_include]
    if params[:q].present? && params[:q] && params[:q][:with_material_category_include].present?
      tmp_id = params[:q][:with_material_category_include].to_i
      inventory_category = InventoryCategory.where(:id => tmp_id).first
      name = inventory_category.name
      cookies[:category_name] = name
    else
      if params[:q].present?
        cookies[:category_name] = nil  #未選択とする
      end
    end
    #
    
    respond_to do |format|
      format.html
      #pdf
      format.pdf do
        
        $print_flag = params[:print_flag]
        #report = StorageInventoryListPDF.create @inventory_list
        #report = StorageInventoryListPDF.create @storage_inventory_list
        report = StorageInventoryListPDF.create(@storage_inventory_list, cookies[:warehouse], cookies[:category_name])
       
        # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data(
          report.generate,
          filename:  "storage_inventory_list.pdf",
          type:        "application/pdf",
          disposition: "inline")
      end
      #
    end
    
  end

  # GET /storage_inventories/1
  # GET /storage_inventories/1.json
  def show
  end

  # GET /storage_inventories/new
  def new
    @storage_inventory = StorageInventory.new
  end

  # GET /storage_inventories/1/edit
  def edit
  end

  # POST /storage_inventories
  # POST /storage_inventories.json
  def create
    @storage_inventory = StorageInventory.new(storage_inventory_params)

    respond_to do |format|
      if @storage_inventory.save
        format.html { redirect_to @storage_inventory, notice: 'Storage inventory was successfully created.' }
        format.json { render :show, status: :created, location: @storage_inventory }
      else
        format.html { render :new }
        format.json { render json: @storage_inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /storage_inventories/1
  # PATCH/PUT /storage_inventories/1.json
  def update
    respond_to do |format|
      if @storage_inventory.update(storage_inventory_params)
        format.html { redirect_to @storage_inventory, notice: 'Storage inventory was successfully updated.' }
        format.json { render :show, status: :ok, location: @storage_inventory }
      else
        format.html { render :edit }
        format.json { render json: @storage_inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /storage_inventories/1
  # DELETE /storage_inventories/1.json
  def destroy
    @storage_inventory.destroy
    respond_to do |format|
      format.html { redirect_to storage_inventories_url, notice: 'Storage inventory was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  #ajax
  def get_material_unit_price
    @last_unit_price = ""
    material_master = MaterialMaster.where(:id => params[:material_master_id]).first
    if material_master.present?
      @last_unit_price = material_master.last_unit_price
    end
    
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_storage_inventory
      @storage_inventory = StorageInventory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def storage_inventory_params
      params.require(:storage_inventory).permit(:warehouse_id, :location_id, :material_master_id, :quantity, :unit_master_id, :unit_price)
    end
end
