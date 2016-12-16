class PurchaseOrderData2Controller < ApplicationController
  
  before_action :set_purchase_order_datum, only: [:show, :edit, :update, :destroy]
  
  # Userクラスを作成していないので、擬似的なUser構造体を作る
  #MailUser = Struct.new(:name, :email)

  # GET /purchase_order_data
  # GET /purchase_order_data.json
  def index
    # @purchase_order_data = PurchaseOrderDatum.all
    # @purchase_order_data = PurchaseOrderDatum.page(params[:page])
    
    @q = PurchaseOrderDatum.ransack(params[:q])   
    @purchase_order_data  = @q.result(distinct: true)
    @purchase_order_data  = @purchase_order_data.page(params[:page])


    @construction_data = ConstructionDatum.all
  
end

  # GET /purchase_order_data/1
  # GET /purchase_order_data/1.json
  def show
  end

  @@update_flag = 0

  # GET /purchase_order_data/new
  def new
    @purchase_order_datum = PurchaseOrderDatum.new
	#Order.build_PurchaseOrderDatum
	#3.times do
	  @purchase_order_datum.orders.build
	#end
	
	#@orders = Order.new
	
	@@update_flag =  1
	
	
  end

  # GET /purchase_order_data/1/edit
  def edit
  
    #hitomazu
    #@purchase_order_datum.orders.build
	
	#if @purchase_order_datum.purchase_order_date.nil?
	#end
	
    @@update_flag = 2
	
  end
  
  #def send_email
  #	#登録または更新を行う。
  #  case @@update_flag
  #  when 1 then
  #     create
  #when 2 then
  #     set_purchase_order_datum
  #     update
  #end
  #  #メール送信する
  #  PostMailer.send_when_update(@purchase_order_datum).deliver
  #end

  # POST /purchase_order_data
  # POST /purchase_order_data.json
  def create
    @purchase_order_datum = PurchaseOrderDatum.new(purchase_order_datum_params)
    
	
	#メール送信する(メール送信ボタン押した場合)
	if params[:send].present?
      #binding.pry
	  PostMailer.send_when_update(@purchase_order_datum).deliver
	end
	
    respond_to do |format|
      if @purchase_order_datum.save
        format.html { redirect_to @purchase_order_datum, notice: 'Purchase order datum was successfully created.' }
        format.json { render :show, status: :created, location: @purchase_order_datum }
      else
        format.html { render :new }
        format.json { render json: @purchase_order_datum.errors, status: :unprocessable_entity }
      end
    end
	
	#メール送信する
	#PostMailer.send_when_update(@purchase_order_datum).deliver
	
  end

  # PATCH/PUT /purchase_order_data/1
  # PATCH/PUT /purchase_order_data/1.json
  def update
   
    
   #respond_to do |format|
   #   if @purchase_order_datum.update(purchase_order_datum_params)
        #format.html { redirect_to @purchase_order_datum, notice: 'Purchase order datum was successfully updated.' }
        #format.json { render :show, status: :ok, location: @purchase_order_datum }
	#  else
    #    format.html { render :edit }
    #    format.json { render json: @purchase_order_datum.errors, status: :unprocessable_entity }
    #  end
    #end

	  params[:purchase_order_datum][:orders_attributes].values.each do |item|
      id = item[:material_id].to_i
	   
	   #手入力以外なら、商品CD・IDをセットする。
	   if id != 1 then
	      @material_master = MaterialMaster.find(id)
		  item[:material_code] = @material_master.material_code
		  item[:material_name] = @material_master.material_name
		  
	    end 
	   
    end 
	
	
	#メール送信する(メール送信ボタン押した場合)
	if params[:send].present?
      #set to global
	  $order_parameters = params[:purchase_order_datum][:orders_attributes]

	  PostMailer.send_purchase_order(@purchase_order_datum).deliver
	end
	
	@purchase_order_datum.update(purchase_order_datum_params)
	
	
	redirect_to purchase_order_data2_index_path
	
  end

  #def add 
  #  binding.pry
  #end

  # DELETE /purchase_order_data/1
  # DELETE /purchase_order_data/1.json
  def destroy
    @purchase_order_datum.destroy
    respond_to do |format|
      format.html { redirect_to purchase_order_data_url, notice: 'Purchase order datum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  #ajax
  def get_last_number_select
     crescent = "%" + params[:header] + "%"
     @purchase_order_datum_new_code = PurchaseOrderDatum.where('purchase_order_code LIKE ?', crescent).all.maximum(:purchase_order_code) 
	 
	 #最終番号に１を足す。
	 newStr = @purchase_order_datum_new_code[1, 4]
	 header = @purchase_order_datum_new_code[0, 1]
	 newNum = newStr.to_i + 1
	 
	 @purchase_order_datum_new_code = header + newNum.to_s
	 
  end
  
   # ajax
  def material_select
     @material_code_hide = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_code).flatten.join(" ")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_order_datum
      @purchase_order_datum = PurchaseOrderDatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_order_datum_params
      params.require(:purchase_order_datum).permit(:purchase_order_code, :construction_datum_id, :supplier_master_id, :purchase_order_date, 
	                  orders_attributes: [:id, :purchase_order_datum_id, :material_id, :material_code, :material_name, :quantity, :unit_master_id, :_destroy])
    end
	
	#def order_params
    #  params.require(:purchase_order_datum).permit( orders_attributes: [:id, :purchase_order_datum_id, :material_id, 
	#  :material_code, :material_name, :quantity, :_destroy])
    #end
end
