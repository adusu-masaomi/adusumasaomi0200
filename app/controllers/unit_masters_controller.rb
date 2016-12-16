class UnitMastersController < ApplicationController
  before_action :set_unit_master, only: [:show, :edit, :update, :destroy]

  # GET /unit_masters
  # GET /unit_masters.json
  def index
    @unit_masters = UnitMaster.all
  end

  # GET /unit_masters/1
  # GET /unit_masters/1.json
  def show
  end

  # GET /unit_masters/new
  def new
    @unit_master = UnitMaster.new
  end

  # GET /unit_masters/1/edit
  def edit
  end

  # POST /unit_masters
  # POST /unit_masters.json
  def create
    @unit_master = UnitMaster.new(unit_master_params)

    respond_to do |format|
      if @unit_master.save
        format.html { redirect_to @unit_master, notice: 'Unit master was successfully created.' }
        format.json { render :show, status: :created, location: @unit_master }
      else
        format.html { render :new }
        format.json { render json: @unit_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /unit_masters/1
  # PATCH/PUT /unit_masters/1.json
  def update
    respond_to do |format|
      if @unit_master.update(unit_master_params)
        format.html { redirect_to @unit_master, notice: 'Unit master was successfully updated.' }
        format.json { render :show, status: :ok, location: @unit_master }
      else
        format.html { render :edit }
        format.json { render json: @unit_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /unit_masters/1
  # DELETE /unit_masters/1.json
  def destroy
    @unit_master.destroy
    respond_to do |format|
      format.html { redirect_to unit_masters_url, notice: 'Unit master was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_unit_master
      @unit_master = UnitMaster.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def unit_master_params
      params.require(:unit_master).permit(:unit_name)
    end
end
