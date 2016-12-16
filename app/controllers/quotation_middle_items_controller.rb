class QuotationMiddleItemsController < ApplicationController
  before_action :set_quotation_middle_item, only: [:show, :edit, :update, :destroy]

  # GET /quotation_middle_items
  # GET /quotation_middle_items.json
  def index
    #@quotation_middle_items = QuotationMiddleItem.all
	@q = QuotationMiddleItem.ransack(params[:q])   
    @quotation_middle_items  = @q.result(distinct: true)
    @quotation_middle_items  = @quotation_middle_items.page(params[:page])
  end

  # GET /quotation_middle_items/1
  # GET /quotation_middle_items/1.json
  def show
  end

  # GET /quotation_middle_items/new
  def new
    @quotation_middle_item = QuotationMiddleItem.new
  end

  # GET /quotation_middle_items/1/edit
  def edit
  end

  # POST /quotation_middle_items
  # POST /quotation_middle_items.json
  def create
    @quotation_middle_item = QuotationMiddleItem.new(quotation_middle_item_params)

    respond_to do |format|
      if @quotation_middle_item.save
        format.html { redirect_to @quotation_middle_item, notice: 'Quotation middle item was successfully created.' }
        format.json { render :show, status: :created, location: @quotation_middle_item }
      else
        format.html { render :new }
        format.json { render json: @quotation_middle_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quotation_middle_items/1
  # PATCH/PUT /quotation_middle_items/1.json
  def update
    respond_to do |format|
      if @quotation_middle_item.update(quotation_middle_item_params)
        format.html { redirect_to @quotation_middle_item, notice: 'Quotation middle item was successfully updated.' }
        format.json { render :show, status: :ok, location: @quotation_middle_item }
      else
        format.html { render :edit }
        format.json { render json: @quotation_middle_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quotation_middle_items/1
  # DELETE /quotation_middle_items/1.json
  def destroy
    @quotation_middle_item.destroy
    respond_to do |format|
      format.html { redirect_to quotation_middle_items_url, notice: 'Quotation middle item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  # ajax
  def quotation_material_name_select
     @quotation_material_name = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_name).flatten.join(" ")
  end
  def material_unit_price_select
     @material_unit_price = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:last_unit_price).flatten.join(" ")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quotation_middle_item
      @quotation_middle_item = QuotationMiddleItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quotation_middle_item_params
      params.require(:quotation_middle_item).permit(:quotation_middle_item_name, :quotation_middle_item_short_name, :quotation_middle_specification, :quotation_unit_id, :quotation_unit_price, :execution_unit_price, :material_id, :quotation_material_name, :material_unit_price, :labor_unit_price, :labor_productivity_unit, :material_quantity, :accessory_cost, :material_cost_total, :labor_cost_total, :other_cost)
    end
end
