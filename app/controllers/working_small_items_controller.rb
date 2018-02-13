class WorkingSmallItemsController < ApplicationController
  before_action :set_working_small_item, only: [:show, :edit, :update, :destroy]

  # GET /working_small_items
  # GET /working_small_items.json
  def index
    @working_small_items = WorkingSmallItem.all
  end

  # GET /working_small_items/1
  # GET /working_small_items/1.json
  def show
  end

  # GET /working_small_items/new
  def new
    @working_small_item = WorkingSmallItem.new
  end

  # GET /working_small_items/1/edit
  def edit
  end

  # POST /working_small_items
  # POST /working_small_items.json
  def create
    @working_small_item = WorkingSmallItem.new(working_small_item_params)

    respond_to do |format|
      if @working_small_item.save
        format.html { redirect_to @working_small_item, notice: 'Working small item was successfully created.' }
        format.json { render :show, status: :created, location: @working_small_item }
      else
        format.html { render :new }
        format.json { render json: @working_small_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /working_small_items/1
  # PATCH/PUT /working_small_items/1.json
  def update
    respond_to do |format|
	
	  
	
      if @working_small_item.update(working_small_item_params)
        format.html { redirect_to @working_small_item, notice: 'Working small item was successfully updated.' }
        format.json { render :show, status: :ok, location: @working_small_item }
      else
        format.html { render :edit }
        format.json { render json: @working_small_item.errors, status: :unprocessable_entity }
      end
    end
  end
   
  
  # DELETE /working_small_items/1
  # DELETE /working_small_items/1.json
  def destroy
    @working_small_item.destroy
    respond_to do |format|
      format.html { redirect_to working_small_items_url, notice: 'Working small item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  # ajax
  def material_standard_select
     #品番
     @material_code = MaterialMaster.where(:id => params[:material_id]).where("id is NOT NULL").pluck(:material_code).flatten.join(",")
     #品名
     @material_name = MaterialMaster.where(:id => params[:material_id]).where("id is NOT NULL").pluck(:material_name).flatten.join(",")
	 
	 #数量
	 @quantity = MaterialMaster.where(:id => params[:material_id]).where("id is NOT NULL").pluck(:standard_quantity).flatten.join(",")
	 
     if @quantity.blank?   #未登録(null)なら１をセット
       @quantity = 1
     end
	 
	 #単価（定価）
	 @unit_price = MaterialMaster.where(:id => params[:material_id]).where("id is NOT NULL").pluck(:list_price).flatten.join(",")
	 
	 #歩掛
	 @labor_productivity_unit = MaterialMaster.where(:id => params[:material_id]).where("id is NOT NULL").pluck(:standard_labor_productivity_unit).flatten.join(",")
	 
     #メーカー add1802021
     @maker_master_id = MaterialMaster.where(:id => params[:material_id]).where("id is NOT NULL").pluck(:maker_id).flatten.join(" ")
     
     #単位  add1802021
     @unit_master_id = MaterialMaster.where(:id => params[:material_id]).where("id is NOT NULL").pluck(:unit_id).flatten.join(" ")
     
     #資材費（最終単価）add180201
     @material_price = MaterialMaster.where(:id => params[:material_id]).where("id is NOT NULL").pluck(:last_unit_price).flatten.join(",")
  end
  
  #add171113
  def material_code_standard_select
     #品番
     @material_code = MaterialMaster.where(:material_code => params[:material_code]).where("id is NOT NULL").pluck(:material_code).flatten.join(",")
     
	 if @material_code.present?
	   #品名
       @material_name = MaterialMaster.where(:material_code => params[:material_code]).where("id is NOT NULL").pluck(:material_name).flatten.join(",")
	 
	   #数量
	   @quantity = MaterialMaster.where(:material_code => params[:material_code]).where("id is NOT NULL").pluck(:standard_quantity).flatten.join(",")
	 
       if @quantity.blank?   #未登録(null)なら１をセット
         @quantity = 1
       end
	 
	   #単価(定価)
	   @unit_price = MaterialMaster.where(:material_code => params[:material_code]).where("id is NOT NULL").pluck(:list_price).flatten.join(",")
	 
	   #歩掛
	   @labor_productivity_unit = MaterialMaster.where(:material_code => params[:material_code]).where("id is NOT NULL").pluck(:standard_labor_productivity_unit).flatten.join(",")
	 
       #メーカー add1802021
       @maker_master_id = MaterialMaster.where(:material_code => params[:material_code]).where("id is NOT NULL").pluck(:maker_id).flatten.join(" ")
       
       #単位    add1802021
       @unit_master_id = MaterialMaster.where(:material_code => params[:material_code]).where("id is NOT NULL").pluck(:unit_id).flatten.join(" ")
       
       #資材費（最終単価）add180201
       @material_price = MaterialMaster.where(:material_code => params[:material_code]).where("id is NOT NULL").pluck(:last_unit_price).flatten.join(",")
       
     else
	 #該当なければそのまま・・・
	   @material_code =  params[:material_code]
	 end
	
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_working_small_item
      @working_small_item = WorkingSmallItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def working_small_item_params
      params.require(:working_small_item).permit(:working_middle_item_id, :working_small_item_code, :working_small_item_name, :unit_price, :rate, :quantity, :labor_productivity_unit)
    end
end
