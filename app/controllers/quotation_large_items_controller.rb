class QuotationLargeItemsController < ApplicationController
  before_action :set_quotation_large_item, only: [:show, :edit, :update, :destroy]

  # GET /quotation_large_items
  # GET /quotation_large_items.json
  def index
    
    #@quotation_large_items = QuotationLargeItem.all
  	@q = QuotationLargeItem.ransack(params[:q])   
    @quotation_large_items  = @q.result(distinct: true)
    @quotation_large_items  = @quotation_large_items.page(params[:page])
	
  end

  # GET /quotation_large_items/1
  # GET /quotation_large_items/1.json
  def show
  end

  # GET /quotation_large_items/new
  def new
    @quotation_large_item = QuotationLargeItem.new
  end

  # GET /quotation_large_items/1/edit
  def edit
  end

  # POST /quotation_large_items
  # POST /quotation_large_items.json
  def create
    @quotation_large_item = QuotationLargeItem.new(quotation_large_item_params)

    respond_to do |format|
      if @quotation_large_item.save
        format.html { redirect_to @quotation_large_item, notice: 'Quotation large item was successfully created.' }
        format.json { render :show, status: :created, location: @quotation_large_item }
      else
        format.html { render :new }
        format.json { render json: @quotation_large_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quotation_large_items/1
  # PATCH/PUT /quotation_large_items/1.json
  def update
    respond_to do |format|
      if @quotation_large_item.update(quotation_large_item_params)
        format.html { redirect_to @quotation_large_item, notice: 'Quotation large item was successfully updated.' }
        format.json { render :show, status: :ok, location: @quotation_large_item }
      else
        format.html { render :edit }
        format.json { render json: @quotation_large_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quotation_large_items/1
  # DELETE /quotation_large_items/1.json
  def destroy
    @quotation_large_item.destroy
    respond_to do |format|
      format.html { redirect_to quotation_large_items_url, notice: 'Quotation large item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quotation_large_item
      @quotation_large_item = QuotationLargeItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quotation_large_item_params
      params.require(:quotation_large_item).permit(:quotation_large_item_name, :quotation_large_specification)
    end
end
