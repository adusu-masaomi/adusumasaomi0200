class SupplierMastersController < ApplicationController
  before_action :set_supplier_master, only: [:show, :edit, :update, :destroy]

  # GET /supplier_masters
  # GET /supplier_masters.json
  def index
    #@supplier_masters = SupplierMaster.all
	
	@q = SupplierMaster.ransack(params[:q])   
    @supplier_masters  = @q.result(distinct: true)
	
  end

  # GET /supplier_masters/1
  # GET /supplier_masters/1.json
  def show
  end

  # GET /supplier_masters/new
  def new
    @supplier_master = SupplierMaster.new
  end

  # GET /supplier_masters/1/edit
  def edit
  end

  # POST /supplier_masters
  # POST /supplier_masters.json
  def create
    @supplier_master = SupplierMaster.new(supplier_master_params)

    respond_to do |format|
      if @supplier_master.save
        format.html { redirect_to @supplier_master, notice: 'Supplier master was successfully created.' }
        format.json { render :show, status: :created, location: @supplier_master }
      else
        format.html { render :new }
        format.json { render json: @supplier_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /supplier_masters/1
  # PATCH/PUT /supplier_masters/1.json
  def update
    respond_to do |format|
	
	   if @supplier_master.update(supplier_master_params)
        format.html { redirect_to @supplier_master, notice: 'Supplier master was successfully updated.' }
        format.json { render :show, status: :ok, location: @supplier_master }
      else
        format.html { render :edit }
        format.json { render json: @supplier_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /supplier_masters/1
  # DELETE /supplier_masters/1.json
  def destroy
    @supplier_master.destroy
    respond_to do |format|
      format.html { redirect_to supplier_masters_url, notice: 'Supplier master was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supplier_master
      @supplier_master = SupplierMaster.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supplier_master_params
      params.require(:supplier_master).permit(:supplier_name, :tel_main, :fax_main, :email_main, :responsible1, :email1, :responsible2, :email2, :responsible3, :email3)
    end
end
