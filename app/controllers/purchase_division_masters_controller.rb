class PurchaseDivisionMastersController < ApplicationController
  before_action :set_purchase_division_master, only: [:show, :edit, :update, :destroy]

  # GET /purchase_division_masters
  # GET /purchase_division_masters.json
  def index
    @purchase_division_masters = PurchaseDivisionMaster.all
  end

  # GET /purchase_division_masters/1
  # GET /purchase_division_masters/1.json
  def show
  end

  # GET /purchase_division_masters/new
  def new
    @purchase_division_master = PurchaseDivisionMaster.new
  end

  # GET /purchase_division_masters/1/edit
  def edit
  end

  # POST /purchase_division_masters
  # POST /purchase_division_masters.json
  def create
    @purchase_division_master = PurchaseDivisionMaster.new(purchase_division_master_params)

    respond_to do |format|
      if @purchase_division_master.save
        format.html { redirect_to @purchase_division_master, notice: 'Purchase division master was successfully created.' }
        format.json { render :show, status: :created, location: @purchase_division_master }
      else
        format.html { render :new }
        format.json { render json: @purchase_division_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purchase_division_masters/1
  # PATCH/PUT /purchase_division_masters/1.json
  def update
    respond_to do |format|
      if @purchase_division_master.update(purchase_division_master_params)
        format.html { redirect_to @purchase_division_master, notice: 'Purchase division master was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase_division_master }
      else
        format.html { render :edit }
        format.json { render json: @purchase_division_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_division_masters/1
  # DELETE /purchase_division_masters/1.json
  def destroy
    @purchase_division_master.destroy
    respond_to do |format|
      format.html { redirect_to purchase_division_masters_url, notice: 'Purchase division master was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_division_master
      @purchase_division_master = PurchaseDivisionMaster.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_division_master_params
      params.require(:purchase_division_master).permit(:purchase_division_name)
    end
end
