class MaterialMastersController < ApplicationController
  before_action :set_material_master, only: [:show, :edit, :update, :destroy]

  # GET /material_masters
  # GET /material_masters.json
  def index
    # @material_masters = MaterialMaster.all
    # @material_masters = MaterialMaster.page(params[:page])

    @q = MaterialMaster.ransack(params[:q])   
    @material_masters = @q.result(distinct: true)
    @material_masters = @material_masters.page(params[:page])


    @maker_masters = MakerMaster.all
    @unit_masters = UnitMaster.all
  end

  # GET /material_masters/1
  # GET /material_masters/1.json
  def show
  	@maker_masters = MakerMaster.all
  end

  # GET /material_masters/new
  def new
    @material_master = MaterialMaster.new
  end

  # GET /material_masters/1/edit
  def edit
  end

  # POST /material_masters
  # POST /material_masters.json
  def create
    @material_master = MaterialMaster.new(material_master_params)
    @error = Array.new
	#maker = MakerMaster.find_by_id(params[:maker_id])
	
    respond_to do |format|
      if @material_master.save
        format.html { redirect_to @material_master, notice: 'Material master was successfully created.' }
        format.json { render :show, status: :created, location: @material_master }
      else
	    # flash[:alert] = 'User was successfully failed.'
		 @material_master.errors.messages.each_key do |key|
          @error << key
        end
		
        format.html { render :new }
        format.json { render json: @material_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /material_masters/1
  # PATCH/PUT /material_masters/1.json
  def update
    respond_to do |format|
      if @material_master.update(material_master_params)
        format.html { redirect_to @material_master, notice: 'Material master was successfully updated.' }
        format.json { render :show, status: :ok, location: @material_master }
      else
        format.html { render :edit }
        format.json { render json: @material_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /material_masters/1
  # DELETE /material_masters/1.json
  def destroy
    @material_master.destroy
    respond_to do |format|
      format.html { redirect_to material_masters_url, notice: 'Material master was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  #select2高速化のための処理
  #def searchableMaterial
  #  respond_to do |format|
  #    format.json { render json: @material_master = MaterialMaster.search_faster(params[:q]) }
  #  end
  #end
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_material_master
      @material_master = MaterialMaster.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def material_master_params
      params.require(:material_master).permit(:material_code, :material_name, :maker_id, :unit_id, :list_price, :last_unit_price, :last_unit_price_update_at)
    end
end
