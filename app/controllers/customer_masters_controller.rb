class CustomerMastersController < ApplicationController
  before_action :set_customer_master, only: [:show, :edit, :update, :destroy]

  # GET /customer_masters
  # GET /customer_masters.json
  def index
    #@customer_masters = CustomerMaster.all
    #@customer_masters = CustomerMaster.page(params[:page])
   
    @q = CustomerMaster.ransack(params[:q])   
    @customer_masters  = @q.result(distinct: true)
    @customer_masters  = @customer_masters.page(params[:page])

  end

  # GET /customer_masters/1
  # GET /customer_masters/1.json
  def show
  end

  # GET /customer_masters/new
  def new
    @customer_master = CustomerMaster.new
  end

  # GET /customer_masters/1/edit
  def edit
  end

  # POST /customer_masters
  # POST /customer_masters.json
  def create
    
    #住所のパラメータ変換
    params[:customer_master][:address] = params[:addressX]
    
    @customer_master = CustomerMaster.new(customer_master_params)

    respond_to do |format|
      if @customer_master.save
        format.html { redirect_to @customer_master, notice: 'Customer master was successfully created.' }
        format.json { render :show, status: :created, location: @customer_master }
      else
        format.html { render :new }
        format.json { render json: @customer_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customer_masters/1
  # PATCH/PUT /customer_masters/1.json
  def update
    
	#binding.pry
    #住所のパラメータ変換
    params[:customer_master][:address] = params[:addressX]
	
    respond_to do |format|
      if @customer_master.update(customer_master_params)
        format.html { redirect_to @customer_master, notice: 'Customer master was successfully updated.' }
        format.json { render :show, status: :ok, location: @customer_master }
      else
        format.html { render :edit }
        format.json { render json: @customer_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customer_masters/1
  # DELETE /customer_masters/1.json
  def destroy
    @customer_master.destroy
    respond_to do |format|
      format.html { redirect_to customer_masters_url, notice: 'Customer master was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer_master
      @customer_master = CustomerMaster.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_master_params
      params.require(:customer_master).permit(:customer_name, :post, :address, :tel_main, :fax_main, :email_main, :closing_date, :due_date, :responsible1, :responsible2)
    end
end
