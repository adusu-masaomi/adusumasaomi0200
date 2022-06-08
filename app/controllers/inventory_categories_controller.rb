class InventoryCategoriesController < ApplicationController
  before_action :set_inventory_category, only: [:show, :edit, :update, :destroy]

  # GET /inventory_categories
  # GET /inventory_categories.json
  def index
    @inventory_categories = InventoryCategory.all
  end

  # GET /inventory_categories/1
  # GET /inventory_categories/1.json
  def show
  end

  # GET /inventory_categories/new
  def new
    @inventory_category = InventoryCategory.new
  end

  # GET /inventory_categories/1/edit
  def edit
  end

  # POST /inventory_categories
  # POST /inventory_categories.json
  def create
    @inventory_category = InventoryCategory.new(inventory_category_params)

    respond_to do |format|
      if @inventory_category.save
        format.html { redirect_to @inventory_category, notice: 'Inventory category was successfully created.' }
        format.json { render :show, status: :created, location: @inventory_category }
      else
        format.html { render :new }
        format.json { render json: @inventory_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /inventory_categories/1
  # PATCH/PUT /inventory_categories/1.json
  def update
    respond_to do |format|
      if @inventory_category.update(inventory_category_params)
        format.html { redirect_to @inventory_category, notice: 'Inventory category was successfully updated.' }
        format.json { render :show, status: :ok, location: @inventory_category }
      else
        format.html { render :edit }
        format.json { render json: @inventory_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inventory_categories/1
  # DELETE /inventory_categories/1.json
  def destroy
    @inventory_category.destroy
    respond_to do |format|
      format.html { redirect_to inventory_categories_url, notice: 'Inventory category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inventory_category
      @inventory_category = InventoryCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inventory_category_params
      params.require(:inventory_category).permit(:name, :seq)
    end
end
