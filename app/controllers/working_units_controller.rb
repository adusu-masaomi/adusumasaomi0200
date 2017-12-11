class WorkingUnitsController < ApplicationController
  before_action :set_working_unit, only: [:show, :edit, :update, :destroy]

  # GET /working_units
  # GET /working_units.json
  def index
    @working_units = WorkingUnit.all
  end
 
  #ドラッグ＆ドロップによる並び替え機能(seqをセットする)
  def reorder
    row = params[:row].split(",").reverse    #ビューの並びが逆のため、パラメータの配列を逆順でセットさせる。
	
    row.each_with_index {|row, i| WorkingUnit.update(row, {:seq => i})}
    render :text => "OK"
  end
 
  # GET /working_units/1
  # GET /working_units/1.json
  def show
  end

  # GET /working_units/new
  def new
    @working_unit = WorkingUnit.new
  end

  # GET /working_units/1/edit
  def edit
  end

  # POST /working_units
  # POST /working_units.json
  def create
    @working_unit = WorkingUnit.new(working_unit_params)

    respond_to do |format|
      if @working_unit.save
	    #ソート用のseqにIDをセットする。
        @working_unit.update(seq: @working_unit.id)
		#
		
        format.html { redirect_to @working_unit, notice: 'Working unit was successfully created.' }
        format.json { render :show, status: :created, location: @working_unit }
      else
        format.html { render :new }
        format.json { render json: @working_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /working_units/1
  # PATCH/PUT /working_units/1.json
  def update
    respond_to do |format|
      if @working_unit.update(working_unit_params)
        format.html { redirect_to @working_unit, notice: 'Working unit was successfully updated.' }
        format.json { render :show, status: :ok, location: @working_unit }
      else
        format.html { render :edit }
        format.json { render json: @working_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /working_units/1
  # DELETE /working_units/1.json
  def destroy
    @working_unit.destroy
    respond_to do |format|
      format.html { redirect_to working_units_url, notice: 'Working unit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  #単位名
  def working_unit_name_select
     @working_unit_name = WorkingUnit.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_unit_name).flatten.join(" ")
  
     #binding.pry
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_working_unit
      @working_unit = WorkingUnit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def working_unit_params
      params.require(:working_unit).permit(:working_unit_name, :seq)
    end
end
