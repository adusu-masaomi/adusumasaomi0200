class WorkingSpecificSmallItemsController < ApplicationController
  before_action :set_working_specific_small_item, only: [:show, :edit, :update, :destroy]

  # GET /working_specific_small_items
  # GET /working_specific_small_items.json
  def index
    @working_specific_small_items = WorkingSpecificSmallItem.all
  end

  # GET /working_specific_small_items/1
  # GET /working_specific_small_items/1.json
  def show
  end

  # GET /working_specific_small_items/new
  def new
    @working_specific_small_item = WorkingSpecificSmallItem.new
  end

  # GET /working_specific_small_items/1/edit
  def edit
  end

  # POST /working_specific_small_items
  # POST /working_specific_small_items.json
  def create
    @working_specific_small_item = WorkingSpecificSmallItem.new(working_specific_small_item_params)

    respond_to do |format|
      if @working_specific_small_item.save
        format.html { redirect_to @working_specific_small_item, notice: 'Working specific small item was successfully created.' }
        format.json { render :show, status: :created, location: @working_specific_small_item }
      else
        format.html { render :new }
        format.json { render json: @working_specific_small_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /working_specific_small_items/1
  # PATCH/PUT /working_specific_small_items/1.json
  def update
    respond_to do |format|
      if @working_specific_small_item.update(working_specific_small_item_params)
        format.html { redirect_to @working_specific_small_item, notice: 'Working specific small item was successfully updated.' }
        format.json { render :show, status: :ok, location: @working_specific_small_item }
      else
        format.html { render :edit }
        format.json { render json: @working_specific_small_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /working_specific_small_items/1
  # DELETE /working_specific_small_items/1.json
  def destroy
    @working_specific_small_item.destroy
    respond_to do |format|
      format.html { redirect_to working_specific_small_items_url, notice: 'Working specific small item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_working_specific_small_item
      @working_specific_small_item = WorkingSpecificSmallItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def working_specific_small_item_params
      params.require(:working_specific_small_item).permit(:working_specific_middle_item_id, :working_small_item_id, :working_small_item_code, :working_small_item_name, :unit_price, :rate, :quantity, :labor_productivity_unit)
    end
end
