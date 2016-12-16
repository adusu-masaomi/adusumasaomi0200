class QuotationUnitsController < ApplicationController
  before_action :set_quotation_unit, only: [:show, :edit, :update, :destroy]

  # GET /quotation_units
  # GET /quotation_units.json
  def index
    @quotation_units = QuotationUnit.all
  end

  # GET /quotation_units/1
  # GET /quotation_units/1.json
  def show
  end

  # GET /quotation_units/new
  def new
    @quotation_unit = QuotationUnit.new
  end

  # GET /quotation_units/1/edit
  def edit
  end

  # POST /quotation_units
  # POST /quotation_units.json
  def create
    @quotation_unit = QuotationUnit.new(quotation_unit_params)

    respond_to do |format|
      if @quotation_unit.save
        format.html { redirect_to @quotation_unit, notice: 'Quotation unit was successfully created.' }
        format.json { render :show, status: :created, location: @quotation_unit }
      else
        format.html { render :new }
        format.json { render json: @quotation_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quotation_units/1
  # PATCH/PUT /quotation_units/1.json
  def update
    respond_to do |format|
      if @quotation_unit.update(quotation_unit_params)
        format.html { redirect_to @quotation_unit, notice: 'Quotation unit was successfully updated.' }
        format.json { render :show, status: :ok, location: @quotation_unit }
      else
        format.html { render :edit }
        format.json { render json: @quotation_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quotation_units/1
  # DELETE /quotation_units/1.json
  def destroy
    @quotation_unit.destroy
    respond_to do |format|
      format.html { redirect_to quotation_units_url, notice: 'Quotation unit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quotation_unit
      @quotation_unit = QuotationUnit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quotation_unit_params
      params.require(:quotation_unit).permit(:quotation_unit_name)
    end
end
