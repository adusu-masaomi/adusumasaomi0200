class QuotationMaterialDetailsController < ApplicationController
  before_action :set_quotation_material_detail, only: [:show, :edit, :update, :destroy]

  # GET /quotation_material_details
  # GET /quotation_material_details.json
  def index
    @quotation_material_details = QuotationMaterialDetail.all
  end

  # GET /quotation_material_details/1
  # GET /quotation_material_details/1.json
  def show
  end

  # GET /quotation_material_details/new
  def new
    @quotation_material_detail = QuotationMaterialDetail.new
  end

  # GET /quotation_material_details/1/edit
  def edit
  end

  # POST /quotation_material_details
  # POST /quotation_material_details.json
  def create
    @quotation_material_detail = QuotationMaterialDetail.new(quotation_material_detail_params)

    respond_to do |format|
      if @quotation_material_detail.save
        format.html { redirect_to @quotation_material_detail, notice: 'Quotation material detail was successfully created.' }
        format.json { render :show, status: :created, location: @quotation_material_detail }
      else
        format.html { render :new }
        format.json { render json: @quotation_material_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quotation_material_details/1
  # PATCH/PUT /quotation_material_details/1.json
  def update
    respond_to do |format|
      if @quotation_material_detail.update(quotation_material_detail_params)
        format.html { redirect_to @quotation_material_detail, notice: 'Quotation material detail was successfully updated.' }
        format.json { render :show, status: :ok, location: @quotation_material_detail }
      else
        format.html { render :edit }
        format.json { render json: @quotation_material_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quotation_material_details/1
  # DELETE /quotation_material_details/1.json
  def destroy
    @quotation_material_detail.destroy
    respond_to do |format|
      format.html { redirect_to quotation_material_details_url, notice: 'Quotation material detail was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quotation_material_detail
      @quotation_material_detail = QuotationMaterialDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quotation_material_detail_params
      params.require(:quotation_material_detail).permit(:quotation_material_header_id, :material_id, :material_code, :material_name, :maker_id, :maker_name, :quantity, :unit_master_id, :list_price, :mail_sent_flag)
    end
end
