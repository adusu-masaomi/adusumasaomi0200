class MakerMastersController < ApplicationController
  before_action :set_maker_master, only: [:show, :edit, :update, :destroy]

  # GET /maker_masters
  # GET /maker_masters.json
  def index
    #@maker_masters = MakerMaster.all
	
	@q = MakerMaster.ransack(params[:q])   
    @maker_masters = @q.result(distinct: true)
    @maker_masters = @maker_masters.page(params[:page])

  end

  # GET /maker_masters/1
  # GET /maker_masters/1.json
  def show
  end

  # GET /maker_masters/new
  def new
    @maker_master = MakerMaster.new
  end

  # GET /maker_masters/1/edit
  def edit
  end

  # POST /maker_masters
  # POST /maker_masters.json
  def create
    @maker_master = MakerMaster.new(maker_master_params)

    respond_to do |format|
      if @maker_master.save
        format.html { redirect_to @maker_master, notice: 'Maker master was successfully created.' }
        format.json { render :show, status: :created, location: @maker_master }
      else
        format.html { render :new }
        format.json { render json: @maker_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /maker_masters/1
  # PATCH/PUT /maker_masters/1.json
  def update
    respond_to do |format|
      if @maker_master.update(maker_master_params)
        format.html { redirect_to @maker_master, notice: 'Maker master was successfully updated.' }
        format.json { render :show, status: :ok, location: @maker_master }
      else
        format.html { render :edit }
        format.json { render json: @maker_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /maker_masters/1
  # DELETE /maker_masters/1.json
  def destroy
    @maker_master.destroy
    respond_to do |format|
      format.html { redirect_to maker_masters_url, notice: 'Maker master was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_maker_master
      @maker_master = MakerMaster.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def maker_master_params
      params.require(:maker_master).permit(:maker_name)
    end
end
