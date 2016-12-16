class QuotationItemsDivisionsController < ApplicationController
  before_action :set_quotation_items_division, only: [:show, :edit, :update, :destroy]

  # GET /quotation_items_divisions
  # GET /quotation_items_divisions.json
  def index
    @quotation_items_divisions = QuotationItemsDivision.all
  end

  # GET /quotation_items_divisions/1
  # GET /quotation_items_divisions/1.json
  def show
  end

  # GET /quotation_items_divisions/new
  def new
    @quotation_items_division = QuotationItemsDivision.new
  end

  # GET /quotation_items_divisions/1/edit
  def edit
  end

  # POST /quotation_items_divisions
  # POST /quotation_items_divisions.json
  def create
    @quotation_items_division = QuotationItemsDivision.new(quotation_items_division_params)

    respond_to do |format|
      if @quotation_items_division.save
        format.html { redirect_to @quotation_items_division, notice: 'Quotation items division was successfully created.' }
        format.json { render :show, status: :created, location: @quotation_items_division }
      else
        format.html { render :new }
        format.json { render json: @quotation_items_division.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quotation_items_divisions/1
  # PATCH/PUT /quotation_items_divisions/1.json
  def update
    respond_to do |format|
      if @quotation_items_division.update(quotation_items_division_params)
        format.html { redirect_to @quotation_items_division, notice: 'Quotation items division was successfully updated.' }
        format.json { render :show, status: :ok, location: @quotation_items_division }
      else
        format.html { render :edit }
        format.json { render json: @quotation_items_division.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quotation_items_divisions/1
  # DELETE /quotation_items_divisions/1.json
  def destroy
    @quotation_items_division.destroy
    respond_to do |format|
      format.html { redirect_to quotation_items_divisions_url, notice: 'Quotation items division was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quotation_items_division
      @quotation_items_division = QuotationItemsDivision.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quotation_items_division_params
      params.require(:quotation_items_division).permit(:quotation_items_division_name)
    end
end
