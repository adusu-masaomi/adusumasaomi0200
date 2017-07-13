class PurchaseOrderHistoriesController < ApplicationController
  #before_action :set_purchase_order_history, only: [:show, :edit, :update, :destroy]
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
	
	#工事画面からのパラメータ保管
	#@construction_id = params[:construction_id]
	#@move_flag = params[:construction_id]
	#
  end

  # GET /purchase_order_histories/1/edit
  def edit
    $quantity_nothing = false
	
    set_edit_params
	
	#工事画面からのパラメータ保管
	#$construction_id = params[:construction_id]
	#$move_flag = params[:move_flag]
	#
	 
  end

  def set_edit_params
    
    flag_nil = false
	
	if $purchase_order_history.nil?
      flag_nil = true
	else
      if $purchase_order_history .purchase_order_datum_id != params[:id].to_i
	    flag_nil = true
		
	  end
    end
    
	
    #ここでは例外的に、newをする
    #if $purchase_order_history.nil?
	if flag_nil == true
	    
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
        
	    
    else
        @purchase_order_history = $purchase_order_history 
        @purchase_order_data  = PurchaseOrderDatum.find($purchase_order_history.purchase_order_datum_id)
		
		
	#@purchase_order_history.build_orders
		
	end
    
	if @purchase_order_history.supplier_master.present?
      @purchase_order_history.email_responsible = @purchase_order_history.supplier_master.email1
    end
	
	#add170221
	#@purchase_order_history.assign_attributes(material_master_params)
	
  end

   #既存のデータを取得する(日付・仕入先指定後。)
  def get_data
 
	 #$purchase_order_history = PurchaseOrderHistory.find_by(purchase_order_datum_id: params[:purchase_order_datum_id], purchase_order_date: params[:purchase_order_date] , supplier_master_id: params[:supplier_master_id])
     $purchase_order_history = PurchaseOrderHistory.where(purchase_order_datum_id: params[:purchase_order_datum_id],
       purchase_order_date: params[:purchase_order_date] , supplier_master_id: params[:supplier_master_id]).first
	 
	  
     if $purchase_order_history.nil?
	    $purchase_order_date = params[:purchase_order_date]
		$supplier_master_id = params[:supplier_master_id]
     else 
        $purchase_order_date = nil
        $supplier_master_id = nil

     end

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
    
    #メール送信済みフラグをセット
    set_mail_sent_flag
  
    
    respond_to do |format|
	  if PurchaseOrderHistory.create(purchase_order_history_params)
	    
        if params[:move_flag] != "1"
	      format.html { redirect_to @purchase_order_history, notice: 'Purchase order history was successfully created.' }
          format.json { render :show, status: :created, location: @purchase_order_history }
        else
          #工事画面から遷移した場合→注文Noデータ一覧へ
		    format.html {redirect_to purchase_order_data_path( 
                 :construction_id => params[:construction_id] , :move_flag => params[:move_flag] )}
        end
      end
    end
  end

  # PATCH/PUT /purchase_order_histories/1
  # PATCH/PUT /purchase_order_histories/1.json
  def update
      
	  #すでに登録していた注文データは一旦抹消する。
	  destroy_before_update
	  
	  #パラーメータ補完＆メール送信する
      send_mail_and_params_complement
	  
	  #メール送信済みフラグをセット
	  set_mail_sent_flag
	  
	  respond_to do |format|
        
		
		if @purchase_order_history.update(purchase_order_history_params)
          
		  if params[:move_flag] != "1"
            format.html { redirect_to @purchase_order_history, notice: 'Purchase order history was successfully updated.' }
            format.json { render :show, status: :created, location: @purchase_order_history }
          else
		  #工事画面から遷移した場合→注文Noデータ一覧へ
		    format.html {redirect_to purchase_order_data_path( 
                 :construction_id => params[:construction_id] , :move_flag => params[:move_flag] )}
		  end
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
  
  def destroy_before_update
    #すでに登録していた注文データは一旦抹消する。
	purchase_order_history_id = @purchase_order_history.id
	Order.where(purchase_order_history_id: purchase_order_history_id).destroy_all
  end
  
  def set_mail_sent_flag
  #add170529 レコード毎にメール送信済みフラグをセットする
     if params[:purchase_order_history][:sent_flag] == "1" 
      if params[:purchase_order_history][:orders_attributes].present?
        params[:purchase_order_history][:orders_attributes].values.each do |item|
          item[:mail_sent_flag] = 1
        end
      end
    end
  end
  
  def send_mail_and_params_complement
    
	
	i = 0
   
    if params[:purchase_order_history][:orders_attributes].present?
	
	    params[:purchase_order_history][:orders_attributes].values.each do |item|
		
		 
		  ######
          #varidate用のために、本来の箇所から離れたパラメータを再セットする
		  item[:quantity] = params[:quantity][i]
		  item[:material_id] = params[:material_id][i]
		  
		  ##add170213
		  item[:material_code] = params[:material_code][i]
		  item[:material_name] = params[:material_name][i]
		  #item[:maker_name] = params[:maker_name][i]
		  item[:list_price] = params[:list_price][i]
		  
		  #メーカーの処理(upd170616)
		  item[:maker_id] = params[:maker_id][i]
          @maker_master = MakerMaster.find(params[:maker_id][i])
		  #あくまでもメール送信用のパラメータとしてのみ、メーカー名をセットしている
		  
		  
          if @maker_master.present?
            item[:maker_name] = @maker_master.maker_name
          end
		  ######
		 
		  
		  id = item[:material_id].to_i
           
		  #手入力以外なら、商品CD・IDをセットする。
          if id != 1 then
              @material_master = MaterialMaster.find(id)
              item[:material_code] = @material_master.material_code
              
              if @material_master.list_price != 0  #upd170310
			  #資材マスターの定価をセット
			  #(マスター側未登録を考慮。但しアプデは考慮していない）
                item[:list_price] = @material_master.list_price
			  end
			  
			  #del170616
			  #@maker_master = MakerMaster.find(@material_master.maker_id)
			  #if @maker_master.maker_name != "-"  #upd170310
			  ##資材マスターのメーカー名をセット
			  ##(マスター側未登録を考慮。但しアプデは考慮していない）
              #  item[:maker_name] = @maker_master.maker_name
			  #end
			  
			  if params[:material_name][i] != @material_master.material_name
			  #マスターの品名を変更した場合は、商品マスターへ反映させる。
			    materials = MaterialMaster.where(:id => @material_master.id).first
			    if materials.present?
                  materials.update_attributes!(:material_name => params[:material_name][i])
                end 
			  end
		  else
		  #手入力した場合も、商品＆単価マスターへ新規登録する
		    if item[:_destroy] != "1"
			
			  
			  if params[:material_code][i] != ""     #商品CD有りのものだけ登録する(バリデーションで引っかかるため)
			    
				#del170616
				#@maker_master = MakerMaster.find_by(maker_name: params[:maker_name][i])
			    #maker_id = 1
			    #if @maker_master.present?
                #  maker_id = @maker_master.id
			    #end
			  
			    @material_master = MaterialMaster.find_by(material_code: params[:material_code][i])
			    #商品マスターへセット(商品コード存在しない場合)
			    if @material_master.nil?
			      #material_master_params = {material_code: params[:material_code][i], material_name: params[:material_name][i], 
                  #                      maker_id: maker_id, list_price: params[:list_price][i] }
                  #upd 170616 for maker 
                  material_master_params = {material_code: params[:material_code][i], material_name: params[:material_name][i], 
                                        maker_id: params[:maker_id][i], list_price: params[:list_price][i] }
			      @material_master = MaterialMaster.create(material_master_params)
			    end
			  
                #仕入先単価マスターへも登録。
                @material_master = MaterialMaster.find_by(material_code: params[:material_code][i])
			    if @material_master.present?
			      material_id = @material_master.id
				  supplier_id = params[:purchase_order_history][:supplier_master_id]
				  
				  supplier_material_code = params[:material_code][i]
				  
				  if supplier_id.present? && ( supplier_id.to_i == $SUPPLIER_MASER_ID_OKADA_DENKI_SANGYO )
				  #岡田電気の場合のみ、品番のハイフンは抹消する
				      
					  #upd170710
					  no_hyphen_code = supplier_material_code.delete('-')  
					  
					  #if supplier_material_code.delete!('-').present?  #add170510
					  if no_hyphen_code.present?
				        supplier_material_code = no_hyphen_code
					  end
					  
				  end
				  
                  purchase_unit_price_params = {material_id: material_id, supplier_id: supplier_id, 
                                        supplier_material_code: supplier_material_code, unit_price: 0 ,
                                        unit_id: item[:unit_master_id]}
			      @purchase_unit_prices = PurchaseUnitPrice.create(purchase_unit_price_params)
                
		  	    end
			  end
			  
			end
			
		    
		  end 
		  
		  i = i + 1
		   
		end 
    
	    #メール送信する(メール送信ボタン押した場合)
        if params[:purchase_order_history][:sent_flag] == "1" then
	
      	  #set to global
	      $order_parameters = params[:purchase_order_history][:orders_attributes]
      
          #画面のメアドをグローバルへセット
          $email_responsible = params[:purchase_order_history][:email_responsible]
          PostMailer.send_purchase_order(@purchase_order_history).deliver
          #メール送信フラグをセット
          #params[:purchase_order_history][:mail_sent_flag] = 1
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
  
  #商品名などを取得
  def material_select
  
     @material_code = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_code).flatten.join(" ")
	 @material_name = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_name).flatten.join(" ")
	 @list_price = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:list_price).flatten.join(" ")
  
     #maker_id = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:maker_id).flatten.join(" ")
	 #@maker_name = MakerMaster.where(:id => maker_id).where("id is NOT NULL").pluck(:maker_name).flatten.join(" ")
	 
     @maker_id_hide = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:maker_id).flatten.join(" ")
	 
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_order_history
      @purchase_order_history = PurchaseOrderHistory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_order_history_params
	  #params.require(:purchase_order_history).permit(:purchase_order_datum_id, :supplier_master_id, :purchase_order_date, :mail_sent_flag, 
	  #                orders_attributes: [:id, :purchase_order_datum_id, :material_id, :material_code, :material_name, :quantity, :unit_master_id, 
      #               :maker_id, :maker_name, :list_price, :mail_sent_flag, :_destroy])
	  #upd170616 メーカー名は抹消
	  params.require(:purchase_order_history).permit(:purchase_order_datum_id, :supplier_master_id, :purchase_order_date, :mail_sent_flag, 
	                  orders_attributes: [:id, :purchase_order_datum_id, :material_id, :material_code, :material_name, :quantity, :unit_master_id, 
                     :maker_id, :list_price, :mail_sent_flag, :_destroy])
    end

end
