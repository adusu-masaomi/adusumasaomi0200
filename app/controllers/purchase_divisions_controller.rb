class PurchaseDivisionsController < ApplicationController
  before_action :set_purchase_division, only: [:show, :edit, :update, :destroy]

  # GET /purchase_divisions
  # GET /purchase_divisions.json
  def index
    @purchase_divisions = PurchaseDivision.all
  end

  # GET /purchase_divisions/1
  # GET /purchase_divisions/1.json
  def show
  end

  # GET /purchase_divisions/new
  def new
    @purchase_division = PurchaseDivision.new
  end

  # GET /purchase_divisions/1/edit
  def edit
  end

  # POST /purchase_divisions
  # POST /purchase_divisions.json
  def create
    @purchase_division = PurchaseDivision.new(purchase_division_params)

    respond_to do |format|
      if @purchase_division.save
        format.html { redirect_to @purchase_division, notice: 'Purchase division was successfully created.' }
        format.json { render :show, status: :created, location: @purchase_division }
      else
        format.html { render :new }
        format.json { render json: @purchase_division.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purchase_divisions/1
  # PATCH/PUT /purchase_divisions/1.json
  def update
    respond_to do |format|
      if @purchase_division.update(purchase_division_params)
        format.html { redirect_to @purchase_division, notice: 'Purchase division was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase_division }
      else
        format.html { render :edit }
        format.json { render json: @purchase_division.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_divisions/1
  # DELETE /purchase_divisions/1.json
  def destroy
    @purchase_division.destroy
    respond_to do |format|
      format.html { redirect_to purchase_divisions_url, notice: 'Purchase division was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_division
      @purchase_division = PurchaseDivision.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_division_params
      params.require(:purchase_division).permit(:purchase_division_name, :purchase_division_long_name)
    end
end
