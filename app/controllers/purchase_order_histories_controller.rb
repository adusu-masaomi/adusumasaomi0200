class PurchaseOrderHistoriesController < ApplicationController
  #before_action :set_purchase_order_history, only: [:show, :edit, :update, :destroy]
  #update,destroy未検証
  #binding.pry
  
  before_action :set_purchase_order_history, only: [:show, :update, :destroy]
  

  # GET /purchase_order_histories
  # GET /purchase_order_histories.json
  def index
    
    @purchase_order_histories = PurchaseOrderHistory.all
	#
	@purchase_order_data = PurchaseOrderDatum.all
    #@q = PurchaseOrderDatum.ransack(params[:q])   
    
	###
	#ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)  	

    #ransack保持用--上記はこれに置き換える
    @q = PurchaseOrderDatum.ransack(query)   
        
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 30.minutes.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    ###

	@purchase_order_data  = @q.result(distinct: true)
    @purchase_order_data  = @purchase_order_data.page(params[:page])
    #データ呼び出し用変数
    $purchase_order_history = nil
    $purchase_order_date =  nil
    $supplier_master_id =  nil
  		
  end
  
  def index2
  #一覧用
    
      purchase_order_datum_id = params[:purchase_order_datum_id].to_i
	  if params[:purchase_order_datum_id].present?
	    $purchase_order_datum_id = purchase_order_datum_id
      end
	  
	  #一覧ヘッダ表示用
	  @purchase_order_code = params[:purchase_order_code]
	  @construction_name = params[:construction_name]
	  @supplier_name = params[:supplier_name]
	
      @orders = Order.joins(:purchase_order_history).where("purchase_order_histories.purchase_order_datum_id = ?", purchase_order_datum_id)
                    .where("orders.purchase_order_history_id = purchase_order_histories.id")
     if @orders.present?
       $orders = @orders
	   
	 else
         if $orders.present?
	       temp_id = $orders.pluck('purchase_order_history_id').first
	       @tmp_purchase_order_history = PurchaseOrderHistory.find(temp_id)
	           #グローバルを適応するのはあくまでも検索時のみとしたいための処理
	      if @tmp_purchase_order_history.purchase_order_datum_id != $purchase_order_datum_id then
	        $orders = Order.none
	      end
        else
          $orders = Order.none
        end 
     end
     
	 #binding.pry
	 
     @q = $orders.ransack(params[:q])   
     @orders  = @q.result(distinct: true)
     @orders  = @orders.page(params[:page])
    
	
  end

  # GET /purchase_order_histories/1
  # GET /purchase_order_histories/1.json
  def show
  end

  # GET /purchase_order_histories/new
  def new
    $quantity_nothing = false
  
    @purchase_order_history = PurchaseOrderHistory.new
    if $purchase_order_history.present?
      @purchase_order_history = $purchase_order_history 
      @purchase_order_data  = PurchaseOrderDatum.find($purchase_order_history.purchase_order_datum_id)
    end
	
  end

  # GET /purchase_order_histories/1/edit
  def edit
    $quantity_nothing = false
	
    set_edit_params
	
  end

  def set_edit_params
     #ここでは例外的に、newをする
    if $purchase_order_history.nil?
        @purchase_order_history = PurchaseOrderHistory.new
        #NoデータのIDと工事IDをセット。
		if params[:id].present?
	      @purchase_order_data  = PurchaseOrderDatum.find(params[:id])
		else
		  @purchase_order_data  = PurchaseOrderDatum.find($id)
		end
        @purchase_order_history.purchase_order_datum_id = @purchase_order_data.id
        #デフォルトの仕入業者をセット
        @purchase_order_history.supplier_master_id = @purchase_order_data.supplier_master_id

		#リロード用（注文業者をセット）
        if $supplier_master_id.present?
          @purchase_order_history.supplier_master_id = $supplier_master_id
        end
        #リロード用（注文日をセット）
        if $purchase_order_date.present?
          @purchase_order_history.purchase_order_date = $purchase_order_date
        end
        
		#binding.pry
        
    else
        @purchase_order_history = $purchase_order_history 
        @purchase_order_data  = PurchaseOrderDatum.find($purchase_order_history.purchase_order_datum_id)
		
	#@purchase_order_history.build_orders
		
	end
    
	if @purchase_order_history.supplier_master.present?
      @purchase_order_history.email_responsible = @purchase_order_history.supplier_master.email1
    end
  end

   #既存のデータを取得する(日付・仕入先指定後。)
  def get_data
     
     
     $purchase_order_history = PurchaseOrderHistory.find_by(purchase_order_datum_id: params[:purchase_order_datum_id], purchase_order_date: params[:purchase_order_date] , supplier_master_id: params[:supplier_master_id])
      
     if $purchase_order_history.nil?
	    $purchase_order_date = params[:purchase_order_date]
		$supplier_master_id = params[:supplier_master_id]
     else 
        $purchase_order_date = nil
        $supplier_master_id = nil

     end
	 
	 #binding.pry
	 #@purchase_order_history.email_responsible = @purchase_order_history.supplier_master.email1
	 
	 
	 #ボタン表示用
     #$get_flag = 1
  end

  # POST /purchase_order_histories
  # POST /purchase_order_histories.json
  def create
  
  	  
	#パラーメータ補完＆メール送信する
    #send_mail_and_params_complement
    
	$id = params[:purchase_order_history][:purchase_order_datum_id]
    
    @purchase_order_history = PurchaseOrderHistory.new(purchase_order_history_params)
   
    #パラーメータ補完＆メール送信する
    send_mail_and_params_complement
    
    
    respond_to do |format|
      #if @purchase_order_history.save
	  if PurchaseOrderHistory.create(purchase_order_history_params)
	    format.html { redirect_to @purchase_order_history, notice: 'Purchase order history was successfully created.' }
        format.json { render :show, status: :created, location: @purchase_order_history }
      end
	  #else
	  #	set_edit_params  
	  #	format.html { render :edit }
	  #    format.json { render json: @purchase_order_history.errors, status: :unprocessable_entity }
      #end
    end
  end

  # PATCH/PUT /purchase_order_histories/1
  # PATCH/PUT /purchase_order_histories/1.json
  def update
      
	  #flash.now[:notice] = "ようこそ。本日は#{Date.today}です。"
	  #redirect_to @purchase_order_history, notice: 'ようこしそ'
	  
	  #パラーメータ補完＆メール送信する
      send_mail_and_params_complement
	  
	  #binding.pry
	  
	  respond_to do |format|
        
		if @purchase_order_history.update(purchase_order_history_params)
           format.html { redirect_to @purchase_order_history, notice: 'Purchase order history was successfully updated.' }
          format.json { render :show, status: :created, location: @purchase_order_history }
        
		else
		  
		  set_edit_params
          
		  #ヴァリデーションはview側で行う(ここでは再読み込みされてうまくいかないため)
		  #if $quantity_nothing = true then
		  #  flash.now[:alert] = "※数量が未入力の箇所があります。確認してください。"
		  #end
		  
		  format.html { render :edit }
          format.json { render json: @purchase_order_history.errors, status: :unprocessable_entity }
      	end
	  end
	
	#
  end 
  
  
  def send_mail_and_params_complement
    
	i = 0
   
    if params[:purchase_order_history][:orders_attributes].present?
        params[:purchase_order_history][:orders_attributes].values.each do |item|
          
		  ######
          #varidate用のために、本来の箇所から離れたパラメータを再セットする
		  item[:quantity] = params[:quantity][i]
		  item[:material_id] = params[:material_id][i]
		  i = i + 1
		  ######
		  
		  id = item[:material_id].to_i
           
		  #手入力以外なら、商品CD・IDをセットする。
          if id != 1 then
              @material_master = MaterialMaster.find(id)
              item[:material_code] = @material_master.material_code
              item[:material_name] = @material_master.material_name
              #add161208  
			  item[:list_price] = @material_master.list_price
			  @maker_master = MakerMaster.find(@material_master.maker_id)
			  item[:maker_name] = @maker_master.maker_name
		  end 
		  
		   
		end 
    
	    #メール送信する(メール送信ボタン押した場合)
        #if params[:send].present?
		
		if params[:purchase_order_history][:sent_flag] == "1" then
	
      
		    #set to global
	      $order_parameters = params[:purchase_order_history][:orders_attributes]
      
          #画面のメアドをグローバルへセット
          $email_responsible = params[:purchase_order_history][:email_responsible]
          PostMailer.send_purchase_order(@purchase_order_history).deliver
          #メール送信フラグをセット
          params[:purchase_order_history][:mail_sent_flag] = 1
        end

    end
  end
  

  # DELETE /purchase_order_histories/1
  # DELETE /purchase_order_histories/1.json
  def destroy
    @purchase_order_history.destroy
    respond_to do |format|
      format.html { redirect_to purchase_order_histories_url, notice: 'Purchase order history was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # ajax
  def email_select
     @email_responsible = SupplierMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:email1).flatten.join(" ")
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_order_history
      @purchase_order_history = PurchaseOrderHistory.find(params[:id])
	  #親データ取得
	  #binding.pry
	  #@purchase_order_datum = PurchaseOrderDatum.find(params[:purchase_order_datum_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_order_history_params
      #params.require(:purchase_order_history).permit(:purchase_order_date, :supplier_master_id, :purchase_order_history_id)
	  params.require(:purchase_order_history).permit(:purchase_order_datum_id, :supplier_master_id, :purchase_order_date, :mail_sent_flag, 
	                  orders_attributes: [:id, :purchase_order_datum_id, :material_id, :material_code, :material_name, :quantity, :unit_master_id, :maker_name, :list_price, :_destroy])
    end
end
