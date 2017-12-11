class InventoriesController < ApplicationController
  before_action :set_inventory, only: [:show, :edit, :update, :destroy]
  
  before_action :set_edit_flag, only: [:new, :edit ]
  
  # GET /inventories
  # GET /inventories.json
  def index
    #@inventories = Inventory.all
    
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)  	
   
	#ransack保持用-
    @q = Inventory.ransack(query)   
    
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
	
    @inventories  = @q.result(distinct: true)
    
    #kaminari用設定
    @inventories  = @inventories.page(params[:page])
	#
	
	#global set
	$inventories = @inventories
	respond_to do |format|
	  format.html
	  #pdf
	  format.pdf do
        
		$print_flag = params[:print_flag]
		report = InventoryListPDF.create @inventory_list 
       
		# ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data(
          report.generate,
          filename:  "inventory_list.pdf",
          type:        "application/pdf",
          disposition: "inline")
      end
      
      #
	end
	
	
  end

  # GET /inventories/1
  # GET /inventories/1.json
  def show
  end

  # GET /inventories/new
  def new
    @inventory = Inventory.new
  end

  # GET /inventories/1/edit
  def edit
  end

  # POST /inventories
  # POST /inventories.json
  def create
    @inventory = Inventory.new(inventory_params)

    respond_to do |format|
      if @inventory.save
        format.html { redirect_to @inventory, notice: 'Inventory was successfully created.' }
        format.json { render :show, status: :created, location: @inventory }
      else
        format.html { render :new }
        format.json { render json: @inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /inventories/1
  # PATCH/PUT /inventories/1.json
  def update
    respond_to do |format|
      if @inventory.update(inventory_params)
        format.html { redirect_to @inventory, notice: 'Inventory was successfully updated.' }
        format.json { render :show, status: :ok, location: @inventory }
      else
        format.html { render :edit }
        format.json { render json: @inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inventories/1
  # DELETE /inventories/1.json
  def destroy
    @inventory.destroy
    respond_to do |format|
      format.html { redirect_to inventories_url, notice: 'Inventory was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  #入出庫の場合は、在庫履歴データ、在庫マスターへも登録する。
  #(仕入マスター画面にて利用)
  def self.set_inventory_history(params, purchase_datum)
    
	#仕入データIDをセット
	if params[:id].present?
      purchase_datum_id = params[:id]
    else
      #新規の場合のID取得
      purchase_datum_id = purchase_datum.id
	end

	@inventory_division_id =  params[:purchase_datum][:inventory_division_id]
	
	if @inventory_division_id.present?
	  @inventory_division_id = @inventory_division_id.to_i
      #if (@inventory_division_id == $INDEX_DIVISION_STOCK) || (@inventory_division_id == $INDEX_DIVISION_SHIPPING)
      if (@inventory_division_id == $INDEX_INVENTORY_STOCK) || (@inventory_division_id == $INDEX_INVENTORY_SHIPPING)
	    
		        inventory_history_params = {inventory_date: params[:purchase_datum][:purchase_date], inventory_division_id: @inventory_division_id,
                                    construction_datum_id: params[:purchase_datum][:construction_datum_id], material_master_id: params[:purchase_datum][:material_id],
									quantity: params[:purchase_datum][:quantity], unit_master_id: params[:purchase_datum][:unit_id],
									unit_price: params[:purchase_datum][:purchase_unit_price], price: params[:purchase_datum][:purchase_amount],
									supplier_master_id: params[:purchase_datum][:supplier_id], slip_code: params[:purchase_datum][:slip_code],
								    purchase_datum_id: purchase_datum_id
                                   }
		
        #在庫マスターへ更新用の数・金額
		@differ_inventory_quantity = params[:purchase_datum][:quantity].to_i
		@differ_inventory_price = params[:purchase_datum][:purchase_amount].to_i
		#
		
		@inventory_history = InventoryHistory.where(purchase_datum_id: purchase_datum_id).first
        if @inventory_history.blank?
        #既存データなしの場合は新規
		   
		  @inventory_history = InventoryHistory.new(inventory_history_params)
		  @inventory_history.save!
		  
		  @differ_inventory_quantity = params[:purchase_datum][:quantity].to_i
		  
		else
		#更新
		  if params[:purchase_datum][:quantity].to_i != @inventory_history.quantity then
             @differ_inventory_quantity = params[:purchase_datum][:quantity].to_i - @inventory_history.quantity
		  else 
		  #add170413
		  #数量の違いがなければ、在庫を増減させない
		     @differ_inventory_quantity = 0
		  end
		  
		  #if params[:purchase_datum][:price].to_i != @inventory_history.price then
		  if ( params[:purchase_datum][:price].to_i != @inventory_history.price ) && @inventory_history.price.present? then
             @differ_inventory_price = params[:purchase_datum][:purchase_amount].to_i - @inventory_history.price
		  else
		  #add170413
		  #単価の違いがなければ、在庫を増減させない(???不要???)
		     @differ_inventory_price = 0
		  end
		
		  @inventory_history.update(inventory_history_params)
		end
        
		
        #在庫データの更新
        self.set_inventory

      end
    end
    
    
  end
  
  #在庫マスターへの登録
  #(仕入マスター画面にて利用)
  def self.set_inventory
    #倉庫・ロケーションはひとまず１とする（将来活用？）
    warehouse_id = 1
    location_id = 1
          
    @inventory = Inventory.where(material_master_id: @inventory_history.material_master_id, warehouse_id: warehouse_id, 
                              location_id: location_id ).first
    
    #初期値
	if @inventory.present? && @inventory.next_warehousing_date_1.present?
	  next_warehousing_date_1 = @inventory.next_warehousing_date_1
	else
	  next_warehousing_date_1 = nil
	end
	if @inventory.present? && @inventory.next_warehousing_date_2.present?
	  next_warehousing_date_2 = @inventory.next_warehousing_date_2
	else
	  next_warehousing_date_2 = nil
	end
	if @inventory.present?
	  current_warehousing_date = @inventory.current_warehousing_date
	end
	
	if @inventory.present? 
	  current_history_id = @inventory.current_history_id
      next_history_id_1 = @inventory.next_history_id_1
	  next_history_id_2 = @inventory.next_history_id_2
    end
	
	if next_history_id_1.nil?
	  next_history_id_1 = 0
	end
	if next_history_id_2.nil?
	  next_history_id_2 = 0
	end
	
	#current_unit_price = 0
	if @inventory.present? && @inventory.current_unit_price.present?
	  current_unit_price = @inventory.current_unit_price
	else
	  current_unit_price = 0
	end
	if  @inventory.present?
      next_unit_price_1 = @inventory.next_unit_price_1
	  next_unit_price_2 = @inventory.next_unit_price_2
	end
	if @inventory.present? && @inventory.current_quantity.present?
	  current_quantity = @inventory.current_quantity
	else
	  current_quantity = 0
	end
	if @inventory.present? && @inventory.next_quantity_1.present?
	  next_quantity_1 = @inventory.next_quantity_1
	else
	  next_quantity_1 = 0
	end
	if @inventory.present? && @inventory.next_quantity_2.present?
      next_quantity_2 = @inventory.next_quantity_2
	else
      next_quantity_2 = 0
	end
	##
	
    if @inventory.blank?
    #新規
      inventory_quantity = @inventory_history.quantity
      inventory_amount = @inventory_history.price
	  
	  current_unit_price = @inventory_history.unit_price 
	  #add170508
	  last_unit_price = @inventory_history.unit_price
	  
	  if @inventory_division_id == $INDEX_INVENTORY_STOCK
        current_history_id = @inventory_history.id  #履歴IDをセット(入庫の場合)
		current_warehousing_date = @inventory_history.inventory_date
        #add170508
        last_warehousing_date = @inventory_history.inventory_date
		current_quantity += @inventory_history.quantity    #数は加算する
	  else
	  #出庫がまず先に登録された場合
	    current_quantity -= @inventory_history.quantity    #数はマイナスする
	  end
	  
	  #仕入業者
	  supplier_master_id = @inventory_history.supplier_master_id
	  #
    else
    #更新
      
	  #inventory_quantity = @inventory.inventory_quantity + @differ_inventory_quantity
      #inventory_amount = @inventory.inventory_amount + @differ_inventory_price
	  
	  if @inventory_division_id == $INDEX_INVENTORY_STOCK
      #入庫
	    inventory_quantity = @inventory.inventory_quantity + @differ_inventory_quantity
	    inventory_amount = @inventory.inventory_amount + @differ_inventory_price
	  elsif @inventory_division_id == $INDEX_INVENTORY_SHIPPING
	  #出庫
	    inventory_quantity = @inventory.inventory_quantity - @differ_inventory_quantity
	    inventory_amount = @inventory.inventory_amount - @differ_inventory_price
	  end
      
	  #add170508
	  last_unit_price = @inventory.last_unit_price
	  last_warehousing_date = @inventory.last_warehousing_date
	  
	  if @inventory.current_history_id == @inventory_history.id
	    #同一仕入IDの場合のみ、単価を更新。
		if @inventory_division_id == $INDEX_INVENTORY_STOCK
		  current_warehousing_date = @inventory_history.inventory_date
	    end
		
	    current_unit_price = @inventory_history.unit_price
		current_quantity = @inventory_history.quantity
		
		#add170508
	    last_unit_price = @inventory_history.unit_price
        last_warehousing_date = @inventory_history.inventory_date
	  else
		
	  #IDが異なる場合
		if @inventory.current_unit_price ==  @inventory_history.unit_price
	    #単価が同じ場合
		  #そのまま加算する（未使用のロットと考える）
		  if @inventory_division_id == $INDEX_INVENTORY_STOCK
		    current_quantity += @inventory_history.quantity     #数は加算する
		  else
		    current_quantity -= @inventory_history.quantity
		  end 
		  
		else
		#単価が異なる場合
		  ####ここで仕入日の判定,切り分けが必要！！！！
		  
		  if (@inventory.current_warehousing_date.present? && @inventory.current_warehousing_date < @inventory_history.inventory_date) ||
		     @inventory_division_id == $INDEX_INVENTORY_SHIPPING
			 
		  #現在ストックのある入庫日より後に入庫された場合or出庫
		    if next_unit_price_1.blank? || next_unit_price_1 == @inventory_history.unit_price 
			#単価１が存在しない,または単価１と現在の単価が同じ場合
              #次の履歴IDへ現在の履歴IDをセット
			  if @inventory_division_id == $INDEX_INVENTORY_STOCK
			    next_history_id_1 = @inventory_history.id
				next_warehousing_date_1 = @inventory_history.inventory_date
			  end
			  next_unit_price_1 = @inventory_history.unit_price
			
		      if @inventory_division_id == $INDEX_INVENTORY_STOCK
		        next_quantity_1 +=  @inventory_history.quantity
		      else
		        next_quantity_1 -= @inventory_history.quantity
		      end
		    end
		  else
		  #現在ストックのある入庫日より前or同一日に入庫された場合
		    if @inventory.current_warehousing_date.present?
		      next_warehousing_date_1 = @inventory.current_warehousing_date
			next_unit_price_1 = @inventory.current_unit_price
			if @inventory_division_id == $INDEX_INVENTORY_STOCK
		      next_quantity_1 += @inventory.current_quantity
			else
			  next_quantity_1 -= @inventory.current_quantity
			end
		    end 
			#現在単価・数量は次の単価・数量へ塗り替える
		    current_history_id = @inventory_history.id 
		    current_warehousing_date = @inventory_history.inventory_date
			
			current_unit_price = @inventory_history.unit_price
			if @inventory_division_id == $INDEX_INVENTORY_STOCK
		      current_quantity += @differ_inventory_quantity
		    else
		      current_quantity -= @differ_inventory_quantity
		    end
			
		  end
		  
		
		  #単価１が存在し、かつ異なる場合は単価２へセット
		  if next_unit_price_1.present?
		    
		    if next_unit_price_1 != @inventory_history.unit_price
	          if next_warehousing_date_1 < @inventory_history.inventory_date
              #単価１の入庫日が現在単価の入庫日より前？＝＞現在のものを単価２へセット
			    next_history_id_2 = @inventory_history.id
				next_warehousing_date_2 = @inventory_history.inventory_date
			    next_unit_price_2 = @inventory_history.unit_price
				if @inventory_division_id == $INDEX_INVENTORY_STOCK
			      next_quantity_2 += @inventory_history.quantity
				else
				  next_quantity_2 -= @inventory_history.quantity
                end
			  else
			  #単価１の入庫日が現在単価の入庫日より後 => 単価２へセット
			    next_history_id_2 = @inventory.next_history_id_1
				next_warehousing_date_2 = @inventory.next_warehousing_date_1
			    next_unit_price_2 = @inventory.next_unit_price_1
			    next_quantity_2 = @inventory.next_quantity_1  
			  end
			end
		  end
		  
		  if next_unit_price_2 == @inventory_history.unit_price &&
             next_history_id_2 != @inventory_history.id
			#単価２と現在の単価が同じ場合(同一ID除く)
              #次の履歴IDへ現在の履歴IDをセット
			  if @inventory_division_id == $INDEX_INVENTORY_STOCK
			    next_history_id_2 = @inventory_history.id
			    next_warehousing_date_2 = @inventory_history.inventory_date
			  end
			  next_unit_price_2 = @inventory_history.unit_price
			
		      if @inventory_division_id == $INDEX_INVENTORY_STOCK
		        next_quantity_2 +=  @inventory_history.quantity
		      else
		        next_quantity_2 -= @inventory_history.quantity
		      end
		  end
		  
		end
		
		###
		#add170509
		#最終単価（棚卸時評価用）を書き込む
		if (@inventory.last_warehousing_date.blank? || @inventory.last_warehousing_date < @inventory_history.inventory_date) &&
		     @inventory_division_id == $INDEX_INVENTORY_STOCK
		  last_unit_price = @inventory_history.unit_price
          last_warehousing_date = @inventory_history.inventory_date
		end
		###
	  end
	  
	    #現在単価(current_unit_price)の数量がゼロになったら、次の単価をセットする処理
        if current_quantity <= 0
		  if next_quantity_1.present? && next_quantity_1 > 0
            current_warehousing_date = next_warehousing_date_1
            current_history_id = next_history_id_1
		    current_unit_price = next_unit_price_1
		    current_quantity = next_quantity_1
		  end
		  
		  if next_quantity_2.present? && next_quantity_2 > 0
		    #単価１へ単価２をセット
		    next_history_id_1 = next_history_id_2
		    next_warehousing_date_1 = next_warehousing_date_2
		    next_unit_price_1 = next_unit_price_2
		    next_quantity_1 = next_quantity_2
		  
		    #単価２はクリアする
		    next_history_id_2 = nil
		    next_warehousing_date_2 = nil
		    next_unit_price_2 = nil
		    next_quantity_2 = nil
	      end
		end
		#
	  
	  
	end
	
	#仕入業者(更新時はそのまま)
	if @inventory.blank?
	  supplier_master_id = @inventory_history.supplier_master_id
	else
	  supplier_master_id = @inventory.supplier_master_id
    end
	
	inventory_params = {warehouse_id: warehouse_id, location_id: location_id, material_master_id: @inventory_history.material_master_id, 
                        inventory_quantity: inventory_quantity, unit_master_id: @inventory_history.unit_master_id, inventory_amount: inventory_amount, 
                        supplier_master_id: supplier_master_id,
                        current_unit_price: current_unit_price, current_history_id: current_history_id, current_warehousing_date: current_warehousing_date, 
                        current_quantity: current_quantity, last_unit_price: last_unit_price, last_warehousing_date: last_warehousing_date, 
                        next_history_id_1: next_history_id_1, next_warehousing_date_1: next_warehousing_date_1, next_unit_price_1: next_unit_price_1,
                        next_quantity_1: next_quantity_1, next_history_id_2: next_history_id_2, next_warehousing_date_2: next_warehousing_date_2, next_unit_price_2: next_unit_price_2, 
                        next_quantity_2: next_quantity_2}
	
    if @inventory.blank?
    #新規
      @inventory = Inventory.new(inventory_params)
      @inventory.save!(:validate => false)
    else
    #更新
      @inventory.update(inventory_params)
    end
    
	#在庫履歴へも、入出庫直後の在庫数量を記録する。
	inventory_history_quantity_params = {inventory_quantity: inventory_quantity}
	
	@inventory_history.update(inventory_history_quantity_params)
  end
  
  #入出庫履歴マスターを削除
  #(仕入マスター画面にて利用)
  def self.destroy_inventory_history(purchase_datum)
    #division_id =  purchase_datum.division_id
	inventory_division_id =  purchase_datum.inventory_division_id
	
    if inventory_division_id.present?
	  inventory_division_id = inventory_division_id.to_i
      #if (division_id == $INDEX_DIVISION_STOCK) || (division_id == $INDEX_DIVISION_SHIPPING)
      if (inventory_division_id == $INDEX_INVENTORY_STOCK) || (inventory_division_id == $INDEX_INVENTORY_SHIPPING)
        
        if purchase_datum.present?
           purchase_datum_id = purchase_datum.id
        end
        @inventory_history = InventoryHistory.where(purchase_datum_id: purchase_datum_id).first
        if @inventory_history.present?
		  @inventory_history.destroy
        
		  #在庫マスターもここで直接更新
		  self.update_inventory
		end
		
        
	  end
	end
  end
  
  def self.update_inventory
  #入出庫データを削除した場合、在庫マスターの数量も増減させる。
    warehouse_id = 1
    location_id = 1
    @inventory = Inventory.where(material_master_id: @inventory_history.material_master_id, warehouse_id: warehouse_id, 
                              location_id: location_id ).first
    
	differ_quantity = 0
	differ_amount = 0
	
	###
	
	if @inventory.present?
	  if @inventory_history.inventory_division_id == $INDEX_INVENTORY_STOCK
	  #入庫 -> 数をマイナスさせる
	    differ_quantity = @inventory.inventory_quantity - @inventory_history.quantity
		differ_amount = @inventory.inventory_amount - @inventory_history.price
	  elsif @inventory_history.inventory_division_id == $INDEX_INVENTORY_SHIPPING
	  #出庫 -> 数をプラスさせる。
	    differ_quantity = @inventory.inventory_quantity + @inventory_history.quantity
		differ_amount = @inventory.inventory_amount + @inventory_history.price
	  end
      
	  ###
	  #出庫＆単価が異なった場合（次のロットにまたがる場合）、ここで先に次のロット分をマイナスしておく！
	  
	  #処理追加予定・・・
	  
	  ###
	  
	  
	  ###
	  
	  #３世代までの単価・数量への増減を行う
	  current_unit_price = @inventory.current_unit_price
	  next_unit_price_1 = @inventory.next_unit_price_1
	  next_unit_price_2 = @inventory.next_unit_price_2
	  
	  current_quantity = @inventory.current_quantity
	  next_quantity_1 = @inventory.next_quantity_1
	  next_quantity_2 = @inventory.next_quantity_2
	  
	  if @inventory_history.unit_price == @inventory.current_unit_price
	  #現在単価と同一？
	    if @inventory_history.inventory_division_id == $INDEX_INVENTORY_STOCK
	      current_quantity = @inventory.current_quantity - @inventory_history.quantity
		else
		  current_quantity = @inventory.current_quantity + @inventory_history.quantity
		end
	  elsif @inventory_history.unit_price == @inventory.next_unit_price_1
	  #次の単価と同一？
	  	if @inventory_history.inventory_division_id == $INDEX_INVENTORY_STOCK
	      next_quantity_1 = @inventory.next_quantity_1 - @inventory_history.quantity
		else
		  next_quantity_1 = @inventory.next_quantity_1 + @inventory_history.quantity
		end
	  elsif @inventory_history.unit_price == @inventory.next_unit_price_2
	  #次の次の単価と同一？
	    
		###
	    if @inventory_history.inventory_division_id == $INDEX_INVENTORY_STOCK
	      next_quantity_2 = @inventory.next_quantity_2 - @inventory_history.quantity
		else
		  next_quantity_2 = @inventory.next_quantity_2 + @inventory_history.quantity
		end
	  end
	  
	  ###
	  #数がゼロの場合、次の履歴から持ってくる
      if current_quantity == 0
        if @inventory.next_quantity_1.present? && @inventory.next_quantity_1 > 0
          current_quantity = @inventory_history.next_quantity_1
		  current_unit_price = @inventory_history.next_unit_price_1
		  if @inventory_history.next_quantity_2.present? && @inventory_history.next_quantity_2 > 0
		  #履歴２があれば１へセット
		    next_quantity_1 = @inventory_history.next_quantity_2
			next_unit_price_1 = @inventory_history.next_unit_price_2
			next_quantity_2 = nil
			next_unit_price_2 = nil
		  else
		    next_quantity_1 = nil
			next_unit_price_1 = nil
		  end
        end
      end
	  if next_quantity_1.present? && next_quantity_1 == 0
	  #次の在庫数が０の場合？
        if @inventory.next_quantity_2.present? && @inventory.next_quantity_2 > 0
          next_quantity_1 = @inventory_history.next_quantity_2
		  next_unit_price_1 = @inventory_history.next_unit_price_2
		  
		  next_quantity_2 = nil
		  next_unit_price_2 = nil
		else
		  next_quantity_1 = nil
		  next_unit_price_1 = nil
		end
      end
	  if next_quantity_2.present? && next_quantity_2 == 0
	    next_quantity_2 = nil
		next_unit_price_2 = nil
	  end
	  
	  ###
	  
	  inventory_update_params = {inventory_quantity: differ_quantity, inventory_amount: differ_amount, current_quantity: current_quantity, 
                                 next_quantity_1: next_quantity_1, next_unit_price_1: next_unit_price_1, next_quantity_2: next_quantity_2, 
                                 next_unit_price_2: next_unit_price_2}
	  
      @inventory.update(inventory_update_params)
   	end
  end 
  
  #ajax
  #最終単価を返す
  def get_unit_price
    record = Inventory.where(material_master_id: params[:material_id]).first
  	
	if record.present?
	  #@current_unit_price = record.current_unit_price
	  #@inventory_id = record.id   #idをセット add171128
	  
	  @current_unit_price = record.last_unit_price
	end
	  
  end
  #現在庫数,金額を返す
  def get_quantity
    record = Inventory.where(material_master_id: params[:material_id]).first
  	
	if record.present?
	  @inventory_quantity = record.inventory_quantity
	  @inventory_amount = record.inventory_amount
	end
	  
  end

  #ストロングパラメータ取得、インスタンス取得などの基本設定！！（重要）
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inventory
      @inventory = Inventory.find(params[:id])
    end

    #新規か編集かの判定フラグ
    def set_edit_flag
	  @action_flag = params[:action]
	end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inventory_params
      params.require(:inventory).permit(:warehouse_id, :location_id, :material_master_id, :inventory_quantity, :unit_master_id, :inventory_amount, :supplier_master_id,
      :current_history_id, :current_warehousing_date, :current_quantity, :current_unit_price, :last_unit_price, :last_warehousing_date, :next_history_id_1, :next_warehousing_date_1, :next_quantity_1, 
      :next_unit_price_1, :next_history_id_2, :next_warehousing_date_2, :next_quantity_2, :next_unit_price_2 )
    end
end
