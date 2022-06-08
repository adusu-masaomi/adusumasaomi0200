class SupplierResponsiblesController < ApplicationController
  before_action :set_supplier_responsible, only: [:show, :edit, :update, :destroy]

  # GET /supplier_responsibles
  # GET /supplier_responsibles.json
  def index
    @supplier_responsibles = SupplierResponsible.all
  end

  # GET /supplier_responsibles/1
  # GET /supplier_responsibles/1.json
  def show
  end

  # GET /supplier_responsibles/new
  def new
    @supplier_responsible = SupplierResponsible.new
  end

  # GET /supplier_responsibles/1/edit
  def edit
  end

  # POST /supplier_responsibles
  # POST /supplier_responsibles.json
  def create
    @supplier_responsible = SupplierResponsible.new(supplier_responsible_params)

    respond_to do |format|
      if @supplier_responsible.save
        format.html { redirect_to @supplier_responsible, notice: 'Supplier responsible was successfully created.' }
        format.json { render :show, status: :created, location: @supplier_responsible }
      else
        format.html { render :new }
        format.json { render json: @supplier_responsible.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /supplier_responsibles/1
  # PATCH/PUT /supplier_responsibles/1.json
  def update
    respond_to do |format|
      if @supplier_responsible.update(supplier_responsible_params)
        format.html { redirect_to @supplier_responsible, notice: 'Supplier responsible was successfully updated.' }
        format.json { render :show, status: :ok, location: @supplier_responsible }
      else
        format.html { render :edit }
        format.json { render json: @supplier_responsible.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /supplier_responsibles/1
  # DELETE /supplier_responsibles/1.json
  def destroy
    @supplier_responsible.destroy
    respond_to do |format|
      format.html { redirect_to supplier_responsibles_url, notice: 'Supplier responsible was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supplier_responsible
      @supplier_responsible = SupplierResponsible.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supplier_responsible_params
      params.require(:supplier_responsible).permit(:supplier_master_id, :responsible_name, :responsible_email)
    end
end
