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

    #upd200703
    ##在庫マスターのデータをここで取得
    warehouse_id = 1
    location_id = 1
    @inventory = Inventory.where(material_master_id: params[:purchase_datum][:material_id], warehouse_id: warehouse_id, 
                              location_id: location_id ).first
    
    #履歴ID、入庫日、数量・単価(次ロット分含)をゲット
    current_quantity = nil
    current_unit_price = nil
    current_history_id = nil
    current_warehousing_date = nil
    next_history_id_1 = nil
    next_warehousing_date_1 = nil
    
    if @inventory.present?
      current_quantity = params[:purchase_datum][:quantity].to_i - params[:purchase_datum][:quantity2].to_i
      current_unit_price = params[:purchase_datum][:purchase_unit_price]
      next_quantity_1 = params[:purchase_datum][:quantity2]
      next_unit_price_1 = params[:purchase_datum][:purchase_unit_price2]
      
      #訂正(復元)もあるので、消去される前の情報を保持しておく
      current_history_id = @inventory.current_history_id
      current_warehousing_date = @inventory.current_warehousing_date
      next_history_id_1 = @inventory.next_history_id_1
      next_warehousing_date_1 = @inventory.next_warehousing_date_1
      
      ##
      #次ロット分数量単価(仕入側)がなければ在庫分から取得(復旧用)
      if next_quantity_1.blank? && next_unit_price_1.blank?
        next_quantity_1 = 0     #数はゼロにしておく
        next_unit_price_1 = @inventory.next_unit_price_1
      end
      ##
      #
    end
    ##

  
	@inventory_division_id =  params[:purchase_datum][:inventory_division_id]
	
	if @inventory_division_id.present?
	  @inventory_division_id = @inventory_division_id.to_i
      #if (@inventory_division_id == $INDEX_DIVISION_STOCK) || (@inventory_division_id == $INDEX_DIVISION_SHIPPING)
      #区分が入・出庫の場合
      if (@inventory_division_id == $INDEX_INVENTORY_STOCK) || (@inventory_division_id == $INDEX_INVENTORY_SHIPPING)
	    
		        inventory_history_params = {inventory_date: params[:purchase_datum][:purchase_date], inventory_division_id: @inventory_division_id,
                                    construction_datum_id: params[:purchase_datum][:construction_datum_id], material_master_id: params[:purchase_datum][:material_id],
									quantity: params[:purchase_datum][:quantity], unit_master_id: params[:purchase_datum][:unit_id],
									unit_price: params[:purchase_datum][:purchase_unit_price], price: params[:purchase_datum][:purchase_amount],
									supplier_master_id: params[:purchase_datum][:supplier_id], slip_code: params[:purchase_datum][:slip_code],
								    purchase_datum_id: purchase_datum_id, current_quantity: current_quantity, current_unit_price: current_unit_price,
                                    next_quantity_1: next_quantity_1, next_unit_price_1: next_unit_price_1, current_history_id: current_history_id,
                                    current_warehousing_date: current_warehousing_date, next_history_id_1: next_history_id_1, next_warehousing_date_1: next_warehousing_date_1
                                   }
		
            #在庫マスターへ更新用の数・金額
		        #@differ_inventory_quantity = params[:purchase_datum][:quantity].to_i
		        #@differ_inventory_price = params[:purchase_datum][:purchase_amount].to_i
		
            @current_quantity_before = 0
    
		        #upd171228 マイナス入庫の登録もあるので、絶対値とする
		        @differ_inventory_quantity = params[:purchase_datum][:quantity].to_i.abs
		        @differ_inventory_price = params[:purchase_datum][:purchase_amount].to_i.abs
	          #
		
            @differ_inventory_quantity2 = 0  #数２も考慮
            
		        @inventory_history = InventoryHistory.where(purchase_datum_id: purchase_datum_id).first
            if @inventory_history.blank?
            #既存データなしの場合は新規
		   
		          @inventory_history = InventoryHistory.new(inventory_history_params)
		          @inventory_history.save!
		  
		          #@differ_inventory_quantity = params[:purchase_datum][:quantity].to_i
		          #upd171228 マイナス入庫の登録もあるので、絶対値とする
	            quantity = params[:purchase_datum][:quantity].to_i.abs
		          @differ_inventory_quantity = quantity 
		          ##
			 
		        else
		        #更新
              if  @inventory_history.quantity.blank?
                @inventory_history.quantity = 0
              end 

		          if params[:purchase_datum][:quantity].to_i != @inventory_history.quantity then
              
              #221223...(修正中)
              #if params[:purchase_datum][:quantity].to_i != @inventory_history.quantity ||
              #   params[:purchase_datum][:material_id] != @inventory_history.material_master_id
                
                #upd221223 品番変更した場合も考慮...(修正中)
                #if params[:purchase_datum][:material_id] != @inventory_history.material_master_id
                #  @inventory_history.material_master_id = params[:purchase_datum][:material_id]
                #end
                
                #upd171228 マイナス入庫の登録もあるので、絶対値とする
                quantity = params[:purchase_datum][:quantity].to_i.abs
                
                ####数量２も考慮
                quantity2 = 0
                if params[:purchase_datum][:quantity2].present?
                  quantity2 = params[:purchase_datum][:quantity2].to_i
                end
                tmp_next_quantity_1 = 0
                if @inventory_history.next_quantity_1.present?
                  tmp_next_quantity_1 = @inventory_history.next_quantity_1
                end
                
                if quantity2 != @inventory_history.next_quantity_1
                  @differ_inventory_quantity2 = quantity2 - tmp_next_quantity_1
                end
                ####
                #
                
                #@differ_inventory_quantity = quantity - @inventory_history.quantity
                @differ_inventory_quantity = (quantity - quantity2) - (@inventory_history.quantity - tmp_next_quantity_1)
                ##
              else 
              #add170413
                #数量の違いがなければ、在庫を増減させない
                @differ_inventory_quantity = 0
              end
		  
              #binding.pry
      
		          #if params[:purchase_datum][:price].to_i != @inventory_history.price then
		          if ( params[:purchase_datum][:price].to_i != @inventory_history.price ) && @inventory_history.price.present? then
                  #@differ_inventory_price = params[:purchase_datum][:purchase_amount].to_i - @inventory_history.price
			          #upd171228 マイナス入庫の登録もあるので、絶対値とする
			          purchase_amount = params[:purchase_datum][:purchase_amount].to_i.abs
			          @differ_inventory_price = purchase_amount - @inventory_history.price
			        ##
		          else
		          #add170413
		          #単価の違いがなければ、在庫を増減させない(???不要???)
		            @differ_inventory_price = 0
		          end
		        
              #現在入庫日・IDは既存のままにさせる(新規は上部で、在庫から取得するようになっているため)
              inventory_history_params[:current_history_id] = @inventory_history.current_history_id
              inventory_history_params[:current_warehousing_date] = @inventory_history.current_warehousing_date
              inventory_history_params[:next_history_id_1] = @inventory_history.next_history_id_1
              inventory_history_params[:next_warehousing_date_1] = @inventory_history.next_warehousing_date_1
              
              @current_quantity_before = @inventory_history.current_quantity #保存前の現在数を保持
              @next_quantity_1_before = @inventory_history.next_quantity_1
              
              #if @inventory_history.current_quantity != params[:purchase_datum][:quantity].to_i
              #  @quantity_differ_flag = true
              #end
              #
              
              #ここで更新する
		          @inventory_history.update(inventory_history_params)
		        end
            
            #在庫データの更新
            #self.set_inventory
            self.set_inventory(params)

      end
    end
    
    
  end
  
  #在庫マスターへの登録
  #(仕入マスター画面にて利用)
  #def self.set_inventory
  def self.set_inventory(params)
    #倉庫・ロケーションはひとまず１とする（将来活用？）
    #200703 moved
    #warehouse_id = 1
    #location_id = 1
    
    #@inventory = Inventory.where(material_master_id: @inventory_history.material_master_id, warehouse_id: warehouse_id, 
    #                          location_id: location_id ).first
     
    next_adjust_flag = false 
     
    
    #初期値
    if @inventory.present? && @inventory.next_warehousing_date_1.present?
      @next_warehousing_date_1 = @inventory.next_warehousing_date_1
    else
      @next_warehousing_date_1 = nil
    end
  
    if @inventory.present? && @inventory.next_warehousing_date_2.present?
      @next_warehousing_date_2 = @inventory.next_warehousing_date_2
    else
      @next_warehousing_date_2 = nil
    end
  
    if @inventory.present?
      current_warehousing_date = @inventory.current_warehousing_date
    end

    if @inventory.present? 
      current_history_id = @inventory.current_history_id
      @next_history_id_1 = @inventory.next_history_id_1
      @next_history_id_2 = @inventory.next_history_id_2
    end
  
    if @next_history_id_1.nil?
      @next_history_id_1 = 0
    end
    if @next_history_id_2.nil?
      @next_history_id_2 = 0
    end
    
    #current_unit_price = 0
    if @inventory.present? && @inventory.current_quantity.present?
      current_quantity = @inventory.current_quantity
    else
      current_quantity = 0
    end
    if @inventory.present? && @inventory.next_quantity_1.present?
      @next_quantity_1 = @inventory.next_quantity_1
    else
      @next_quantity_1 = 0
    end
    if @inventory.present? && @inventory.next_quantity_2.present?
      @next_quantity_2 = @inventory.next_quantity_2
    else
      @next_quantity_2 = 0
    end
    ##

    if @inventory.present? && @inventory.current_unit_price.present?
      if current_quantity <= 0
      
        #前ロット(使用済)分のものであれば、単価はそのままにしておく
        tmp_check = false
        if @inventory_history.next_unit_price_1.present?
          tmp_q = params[:purchase_datum][:quantity].to_i - params[:purchase_datum][:quantity2].to_i
          
          if @inventory_history.current_quantity <= tmp_q
            tmp_check = true
            current_unit_price = @inventory.current_unit_price
          end
        end
      
        #在庫Mの数が０になっていれば、現行の単価も入れる
        if !tmp_check
          #add200703
          current_unit_price = params[:purchase_datum][:purchase_unit_price]
        end
      else
        current_unit_price = @inventory.current_unit_price
      end
    else
      current_unit_price = 0
    end
  
  if  @inventory.present?
    @next_unit_price_1 = @inventory.next_unit_price_1
    @next_unit_price_2 = @inventory.next_unit_price_2
  end
    
  if @inventory.blank?
  #新規
    #upd180626
    inventory_quantity = @inventory_history.quantity.to_i.abs
    inventory_amount = @inventory_history.price.to_i.abs
      
    #inventory_quantity = @inventory_history.quantity
    #inventory_amount = @inventory_history.price
	  
	  current_unit_price = @inventory_history.unit_price 
	  #add170508
	  last_unit_price = @inventory_history.unit_price
	  
    if @inventory_division_id == $INDEX_INVENTORY_STOCK
      current_history_id = @inventory_history.id  #履歴IDをセット(入庫の場合)
      current_warehousing_date = @inventory_history.inventory_date
      #add170508
      last_warehousing_date = @inventory_history.inventory_date
      #current_quantity += @inventory_history.quantity    #数は加算する
      current_quantity += @inventory_history.quantity.abs    #数は加算する(絶対値)
    else
    #出庫がまず先に登録された場合
      #current_quantity -= @inventory_history.quantity    #数はマイナスする
      current_quantity -= @inventory_history.quantity.abs    #数はマイナスする(絶対値)
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
      
      #binding.pry
      
      #inventory_quantity = @inventory.inventory_quantity - @differ_inventory_quantit
      inventory_quantity = @inventory.inventory_quantity - (@differ_inventory_quantity + @differ_inventory_quantity2)
      inventory_amount = @inventory.inventory_amount - @differ_inventory_price
      
      #upd200701
      #在庫２も考慮する必要あり！！
      #@differ_inventory_quantity = params[:purchase_datum][:quantity].to_i.abs
      tmp_quantity = params[:purchase_datum][:quantity].to_i
      tmp_quantity2 = 0
      
      if params[:purchase_datum][:quantity2].present?
        tmp_quantity -= params[:purchase_datum][:quantity2].to_i
        tmp_quantity2 = params[:purchase_datum][:quantity2].to_i
      end
      
      #現ロット数より出庫が多い場合
      if (@inventory.current_quantity.nil? && tmp_quantity > 0) ||
         (@inventory.current_quantity <= tmp_quantity)
        if @inventory.next_quantity_1.present? && @inventory.next_quantity_1 > 0 && 
          @inventory.next_unit_price_1.present?
          
          next_adjust_flag = true
          #tmp_next_quantity = @inventory.next_quantity_1 + (@inventory.current_quantity - tmp_quantity)
          #tmp_next_quantity = @inventory.next_quantity_1 - tmp_quantity
          #次ロットの数量を減算
          tmp_next_quantity = @inventory.next_quantity_1 - tmp_quantity2
            
          #次回ロットを空にして現在のものに繰り上げる
          @next_quantity_1 = 0
          @next_unit_price_1 = nil
          @next_warehousing_date_1 = nil
          @next_history_id_1 = nil
          
          #ロット３(_2)があれば、ロット２(_1)へ繰り上げる
          self.set_lot_third_to_lot_second
          
          #binding.pry
          #
          current_quantity = tmp_next_quantity
          current_unit_price = @inventory.next_unit_price_1
          current_warehousing_date = @inventory.next_warehousing_date_1
          current_history_id = @inventory.next_history_id_1
          
          #@inventory.current_unit_price = params[:purchase_datum]
        elsif @inventory.next_quantity_1 == 0
        #次ロットがなければ、現在数はそのまま在庫数となる
          next_adjust_flag = true
          current_quantity = inventory_quantity
        end
      else
      #現ロット数より出庫が少ない場合
      #ここで単価違いで別ロット判定・・・更に復元させる処理を行う・・・・・
        #@inventory.current_unit_price != 
        if @inventory.next_quantity_1 == 0
          next_adjust_flag = true
          current_quantity = inventory_quantity
        end
      end
        
    #
    end
      
	  #add170508
	  last_unit_price = @inventory.last_unit_price
	  last_warehousing_date = @inventory.last_warehousing_date
	  
    unit_price_no_move = false
    
    #現ロット、次ロットに入ったらtrue
    #first_in_flag = false
    #second_in_flag = false
    #
    
    if @inventory.current_history_id == @inventory_history.id
      #first_in_flag = true
      
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
      
      #ロット１と単価同一？
      check_same_unit_price_flag(current_unit_price)
      ###
      
      
      #IDが異なる場合
      #if current_unit_price ==  @inventory_history.unit_price
      if @sameUnitPriceFlag
	      #単価が同じ場合
        #そのまま加算する（未使用のロットと考える）
        if @inventory_division_id == $INDEX_INVENTORY_STOCK
          #first_in_flag = true
          current_quantity += @inventory_history.quantity.abs     #数は加算する(絶対値)
        else
          if next_adjust_flag == false #add200702
            current_quantity -= @inventory_history.quantity.abs     #数は減産する(絶対値)
          end
        end 
      else
      #単価が異なる場合
		  ####ここで仕入日の判定,切り分けが必要！！！！
		    #if (@inventory.current_warehousing_date.present? && @inventory.current_warehousing_date < @inventory_history.inventory_date) ||
		    #   @inventory_division_id == $INDEX_INVENTORY_SHIPPING
        
        #binding.pry
        
        #
        move_flag = 0
        if (@inventory.current_warehousing_date.present? && @inventory.current_warehousing_date < @inventory_history.inventory_date && 
              @inventory.inventory_quantity > 0 && @inventory_division_id == $INDEX_INVENTORY_STOCK ) ||
              @inventory.current_warehousing_date.blank? || (@inventory_division_id == $INDEX_INVENTORY_SHIPPING && 
                              @inventory.current_warehousing_date <= @inventory_history.current_warehousing_date)
          #現在ストックのある入庫日より後に入庫or出庫
          #@inventory.current_warehousing_date.blank?の条件追加 210408
          
          move_flag = 1
        elsif @inventory_division_id == $INDEX_INVENTORY_SHIPPING && 
              @inventory.current_warehousing_date > @inventory_history.current_warehousing_date
          #出庫＆現在在庫日より前のロットの場合
          move_flag = 3
        else
          #現在ストックのある入庫日より前or同一日に入庫された場合or在庫数０の場合
          if (@inventory.current_warehousing_date == @inventory_history.inventory_date &&
              @inventory_division_id == $INDEX_INVENTORY_STOCK)
            #同一日の入庫の場合は、先に入庫したものを現在数にさせる(先入先出法)(upd220304)
            move_flag = 1
          else
            move_flag = 2
          end
        end
        #
        
        #upd200704
        #数量があった場合のみ次回単価へ移行させる
        #if (@inventory.current_warehousing_date.present? && @inventory.current_warehousing_date < @inventory_history.inventory_date && 
        #      @inventory.inventory_quantity > 0 ) || @inventory_division_id == $INDEX_INVENTORY_SHIPPING
        case move_flag
          when 1
            #現在ストックのある入庫日より後に入庫された場合or出庫
            #if next_unit_price_1.blank? || next_unit_price_1 == @inventory_history.unit_price
            #upd200629
            if @next_unit_price_1.blank? || @next_unit_price_1.zero? || @next_unit_price_1 == @inventory_history.unit_price
            #単価１が存在しない,または単価１と現在の単価が同じ場合
              #次の履歴IDへ現在の履歴IDをセット
              if @inventory_division_id == $INDEX_INVENTORY_STOCK
                @next_history_id_1 = @inventory_history.id
                @next_warehousing_date_1 = @inventory_history.inventory_date
              end
              if next_adjust_flag == false  #add200704
                @next_unit_price_1 = @inventory_history.unit_price
              end
              #tmp_quantity = 0
              #if @inventory_history.quantity.present?
              #tmp_quantity = @inventory_history.quantity.to_i || 0
              tmp_quantity = @differ_inventory_quantity.to_i || 0
              
              #end
              
		          if @inventory_division_id == $INDEX_INVENTORY_STOCK
		            @next_quantity_1 +=  tmp_quantity
		          else
                if next_adjust_flag == false  #add200704
		              @next_quantity_1 -= tmp_quantity
                end
		          end
		        #elsif @next_unit_price_2.present? && @next_unit_price_2 == @inventory_history.unit_price && 
            #      @inventory_division_id == $INDEX_INVENTORY_STOCK
            #  #入庫で、単価２(ロット３)と単価が同じ場合
            #  #次の履歴IDへ現在の履歴IDをセット
            #  tmp_quantity = @differ_inventory_quantity.to_i || 0
            #  @next_quantity_2 +=  tmp_quantity
		        else
              #単価が異なる、かつ出庫の場合(入庫より先に出庫を登録した場合等)
              #add180607
              if @inventory_division_id == $INDEX_INVENTORY_SHIPPING
                if next_adjust_flag == false  #add200718
		              current_quantity -= @inventory_history.quantity.abs     #数は減産する(絶対値)
		              #単価・入出庫日を更新する
                  #最善ではないが、、ひとまず。
                  current_history_id = @inventory_history.id 
		              current_warehousing_date = @inventory_history.inventory_date
			            current_unit_price = @inventory_history.unit_price
                  last_unit_price = @inventory_history.unit_price
                  last_warehousing_date = @inventory_history.inventory_date
                  unit_price_no_move = true
                end
              end 
            end
		      #else
          when 2
		      #現在ストックのある入庫日より前or同一日に入庫された場合or在庫数０の場合
            if @inventory.inventory_quantity > 0 #aad200704
            
		          if @inventory.current_warehousing_date.present?
		            @next_warehousing_date_1 = @inventory.current_warehousing_date
			          @next_unit_price_1 = @inventory.current_unit_price
			          if @inventory_division_id == $INDEX_INVENTORY_STOCK
		              @next_quantity_1 += @inventory.current_quantity
			          else
			            @next_quantity_1 -= @inventory.current_quantity
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
			      else
              #在庫数０の場合で入庫の場合は、現在在庫数・現在入庫日を更新させる
              #add200704
              if @inventory_division_id == $INDEX_INVENTORY_STOCK
                current_history_id = @inventory_history.id 
		            current_warehousing_date = @inventory_history.inventory_date
                current_quantity += @differ_inventory_quantity
              end
            end
          when 3
          #出庫＆現在在庫日より前のロットの場合
            #現在数で比較させるため、ロット２があればマイナスさせる
            current_quantity = params[:purchase_datum][:quantity].to_i
            tmp_next_quantity_1 = 0
            if params[:purchase_datum][:quantity2].present?
              current_quantity -= params[:purchase_datum][:quantity2].to_i
              tmp_next_quantity_1 = params[:purchase_datum][:quantity2].to_i
            end
            #
            
            #binding.pry
            
            if @current_quantity_before != current_quantity
              
              if @current_quantity_before < current_quantity
              #訂正後の出庫が訂正前より増えた場合
                
                #current_quantity -= @inventory_history.quantity.abs     #数は減産する(絶対値)
                current_quantity -= @differ_inventory_quantity
              else
              #訂正後の出庫が訂正前より減った場合
              #在庫Mの現在数・単価を次ロットへ移動させて前のロットを復活させる
                
                #ロット2(_1)があれば、ロット3(_2)へ繰り下げる
                set_lot_second_to_lot_third
                
                #ロット２の処理
                if @inventory_history.next_unit_price_1 == @inventory.current_unit_price
                
                  @next_quantity_1 = @inventory.current_quantity - @differ_inventory_quantity2
                  @next_unit_price_1 = @inventory.current_unit_price
                  @next_history_id_1 = @inventory.current_history_id
                  @next_warehousing_date_1 = @inventory.current_warehousing_date
                
                else
                #ロット２とも単価が違う場合は、現在庫はロット３のものとみなす
                  #binding.pry
                  
                  #現在庫→ロット３へ移す
                  @next_quantity_2 = @inventory.current_quantity 
                  @next_unit_price_2 = @inventory.current_unit_price
                  @next_warehousing_date_2 = @inventory.current_warehousing_date
                  @next_history_id_2 = @inventory.current_history_id
                  #ロット２を復元
                  @next_quantity_1 = -@differ_inventory_quantity2
                  @next_unit_price_1 = @inventory_history.next_unit_price_1
                  @next_history_id_1 = @inventory_history.next_history_id_1
                  @next_warehousing_date_1 = @inventory_history.next_warehousing_date_1
                  
                #  @next_quantity_1 = 0  #下部で加算があるため
                #  @next_quantity_2 = @inventory.current_quantity - @differ_inventory_quantity2
                #  @next_unit_price_2 = @inventory.current_unit_price
                #  @next_warehousing_date_2 = @inventory.current_warehousing_date
                #  @next_history_id_2 = @inventory.current_history_id
                end
                
                #
                #current_quantity -= @differ_inventory_quantity
                current_quantity = -@differ_inventory_quantity
                current_unit_price = @inventory_history.current_unit_price
                current_history_id = @inventory_history.current_history_id
		            current_warehousing_date = @inventory_history.current_warehousing_date
                
                
              end
            elsif @next_quantity_1_before != tmp_next_quantity_1
            ##次ロット分の増減があった場合(大小も考慮する必要あり)
              #binding.pry
              
              if @inventory_history.next_unit_price_1 == @inventory.current_unit_price
                current_quantity = @inventory.current_quantity
                current_quantity -= @differ_inventory_quantity2
              else
              #在庫現在数が次ロット分に相当する場合
                current_quantity = 0
                current_quantity -= @differ_inventory_quantity2
                current_unit_price = @inventory_history.next_unit_price_1
                current_history_id = @inventory_history.next_history_id_1
		            current_warehousing_date = @inventory_history.next_warehousing_date_1
                #
                @next_quantity_1 = @inventory.current_quantity 
                @next_unit_price_1 = @inventory.current_unit_price
                @next_history_id_1 = @inventory.current_history_id
                @next_warehousing_date_1 = @inventory.current_warehousing_date
                  
              end
            end
        end  #case end
		  
		
		    #単価１が存在し、かつ異なる場合は単価２へセット
        #add200713 入庫のみセットする。出庫は、次々ロットまで考慮しない(pg複雑になり過ぎるため)
        if @inventory_division_id == $INDEX_INVENTORY_STOCK  
        
          if @next_unit_price_1.present?
		        if @next_unit_price_1 != @inventory_history.unit_price
              if unit_price_no_move == false
                #if next_warehousing_date_1 < @inventory_history.inventory_date
                #upd180713
                if @next_warehousing_date_1.nil? || @next_warehousing_date_1 < @inventory_history.inventory_date
                #単価１の入庫日が現在単価の入庫日より前？＝＞現在のものを単価２へセット
			            @next_history_id_2 = @inventory_history.id
				          @next_warehousing_date_2 = @inventory_history.inventory_date
			            @next_unit_price_2 = @inventory_history.unit_price
				          if @inventory_division_id == $INDEX_INVENTORY_STOCK
                    tmp_quantity = @differ_inventory_quantity.to_i || 0
			              @next_quantity_2 +=  tmp_quantity
                    #@next_quantity_2 += @inventory_history.quantity
				          else
				            @next_quantity_2 -= @inventory_history.quantity
                  end
			          else
			          #単価１の入庫日が現在単価の入庫日より後 => 単価２へセット
			            @next_history_id_2 = @inventory.next_history_id_1
				          @next_warehousing_date_2 = @inventory.next_warehousing_date_1
			            @next_unit_price_2 = @inventory.next_unit_price_1
			            @next_quantity_2 = @inventory.next_quantity_1  
			          end
			        end
            end
		      end
		  
		      if @next_unit_price_2 == @inventory_history.unit_price &&
             @next_history_id_2 != @inventory_history.id
			    #単価２と現在の単価が同じ場合(同一ID除く)
          #次の履歴IDへ現在の履歴IDをセット
			      if @inventory_division_id == $INDEX_INVENTORY_STOCK
			        @next_history_id_2 = @inventory_history.id
			        @next_warehousing_date_2 = @inventory_history.inventory_date
			      end
			      @next_unit_price_2 = @inventory_history.unit_price
			
		        if @inventory_division_id == $INDEX_INVENTORY_STOCK
		          @next_quantity_2 +=  @inventory_history.quantity
		        else
		          @next_quantity_2 -= @inventory_history.quantity
		        end
		      
          elsif @next_history_id_2.present? && @next_history_id_2 > 0 && @next_history_id_2 != @inventory_history.id
          #add200717
          #単価違っても、入庫の場合２ロット目のものへ加算するようにする(レアケースと考える)
            
            #if @inventory_division_id == $INDEX_INVENTORY_STOCK
            #  binding.pry
            #  next_history_id_2 = @inventory_history.id
			      #  next_warehousing_date_2 = @inventory_history.inventory_date
			      #  next_unit_price_2 = @inventory_history.unit_price
			      #  next_quantity_2 +=  @inventory_history.quantity
		        #end
            
          end
        
        end  #if @inventory_division_id == $INDEX_INVENTORY_STOCK 
		  #####
      end  #単価が異なる場合 end
		
		  ###
		  #add170509
      #最終単価（棚卸時評価用）を書き込む
      if (@inventory.last_warehousing_date.blank? || @inventory.last_warehousing_date < @inventory_history.inventory_date) &&
         @inventory_division_id == $INDEX_INVENTORY_STOCK
        last_unit_price = @inventory_history.unit_price
        last_warehousing_date = @inventory_history.inventory_date
		  end
		  ###
	
    end  ##IDが異なる場合 end
	  
      #binding.pry
    
	    #現在単価(current_unit_price)の数量がゼロになったら、次の単価をセットする処理
      if current_quantity <= 0
        upd_flag = false
        
        if @next_quantity_1.present? && @next_quantity_1 > 0
          upd_flag = true
          
          current_warehousing_date = @next_warehousing_date_1
          current_history_id = @next_history_id_1
          current_unit_price = @next_unit_price_1
          current_quantity = @next_quantity_1
        
          #add200718
          #単価1はクリアする
		      @next_history_id_1 = nil
		      @next_warehousing_date_1 = nil
		      @next_unit_price_1 = nil
		      @next_quantity_1 = nil
        end
		  
		    if @next_quantity_2.present? && @next_quantity_2 > 0
		      upd_flag = true
          
          #単価１へ単価２をセット
		      @next_history_id_1 = @next_history_id_2
		      @next_warehousing_date_1 = @next_warehousing_date_2
		      @next_unit_price_1 = @next_unit_price_2
		      @next_quantity_1 = @next_quantity_2
		  
		      #単価２はクリアする
		      @next_history_id_2 = nil
		      @next_warehousing_date_2 = nil
		      @next_unit_price_2 = nil
		      @next_quantity_2 = nil
	      end
        
        #在庫数量が繰り上がる場合
        if !upd_flag
          current_warehousing_date = @inventory.next_warehousing_date_1
          current_history_id = @inventory.next_history_id_1
          current_unit_price = @inventory.next_unit_price_1
          current_quantity = @inventory.next_quantity_1
        end
		  end
		#
	  
	  
  end  #更新 end
	
	#仕入業者(更新時はそのまま)
	if @inventory.blank?
	  supplier_master_id = @inventory_history.supplier_master_id
	else
	  supplier_master_id = @inventory.supplier_master_id
  end
	
  #
  if @inventory.blank?
    warehouse_id = 1
    location_id = 1
  else
    warehouse_id = @inventory.warehouse_id
    location_id = @inventory.location_id
  end
  
  #
  #moved201017 inventory_params 
	inventory_params = {warehouse_id: warehouse_id, location_id: location_id, material_master_id: @inventory_history.material_master_id, 
                        inventory_quantity: inventory_quantity, unit_master_id: @inventory_history.unit_master_id, inventory_amount: inventory_amount, 
                        supplier_master_id: supplier_master_id,
                        current_unit_price: current_unit_price, current_history_id: current_history_id, current_warehousing_date: current_warehousing_date, 
                        current_quantity: current_quantity, last_unit_price: last_unit_price, last_warehousing_date: last_warehousing_date, 
                        next_history_id_1: @next_history_id_1, next_warehousing_date_1: @next_warehousing_date_1, next_unit_price_1: @next_unit_price_1,
                        next_quantity_1: @next_quantity_1, next_history_id_2: @next_history_id_2, next_warehousing_date_2: @next_warehousing_date_2, 
                        next_unit_price_2: @next_unit_price_2, 
                        next_quantity_2: @next_quantity_2}
	 #binding.pry
  
    if @inventory.blank?
    #新規
      @inventory = Inventory.new(inventory_params)
      @inventory.save!(:validate => false)
      
      return "new_inventory"
      #以下はなぜかNG
      #flash.now[:notice] = "在庫マスターへ新規登録しました。資材マスターの在庫区分・在庫マスターの画像を登録してください。"
      #session[:inventory_new_flag] = "true"
      
    else
    #更新
      
      
      #@inventory.update(inventory_params)
      
      #upd210330
      #バリデーション無効にする
      @inventory.assign_attributes(inventory_params)
      update_check = @inventory.save!(:validate => false)
      
    end
    
	  #在庫履歴へも、入出庫直後の在庫数量を記録する。
	  inventory_history_quantity_params = {inventory_quantity: inventory_quantity}
	
	  @inventory_history.update(inventory_history_quantity_params)
  end  #def end
  
  def self.set_lot_third_to_lot_second
    
    #ロット３(_2)があれば、ロット２(_1)へ繰り上げる
    if @inventory.next_quantity_2.present? && @inventory.next_quantity_2 > 0
      
      
      @next_quantity_1 = @inventory.next_quantity_2
      @next_unit_price_1 = @inventory.next_unit_price_2
      @next_warehousing_date_1 = @inventory.next_warehousing_date_2
      @next_history_id_1 = @inventory.next_history_id_2
      
      #ロット３(_2)はクリアする
      @next_quantity_2 = 0
      @next_unit_price_2 = nil
      @next_warehousing_date_2 = nil
      @next_history_id_2 = nil
      #
      
    end
  end
  
  def self.set_lot_second_to_lot_third
    
    #ロット2(_1)があれば、ロット3(_2)へ繰り下げる
    if @inventory.next_quantity_1.present? && @inventory.next_quantity_1 > 0
      
      
      @next_quantity_2 = @inventory.next_quantity_1
      @next_unit_price_2 = @inventory.next_unit_price_1
      @next_warehousing_date_2 = @inventory.next_warehousing_date_1
      @next_history_id_2 = @inventory.next_history_id_1
      
      #ロット２(_1)はクリアする
      @next_quantity_1 = 0
      @next_unit_price_1 = nil
      @next_warehousing_date_1 = nil
      @next_history_id_1 = nil
      #
      
    end
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
	    #入庫 -> 数をマイナスさせる(絶対値)
        if @inventory_history.present?  #add200629
	        differ_quantity = @inventory.inventory_quantity - @inventory_history.quantity.abs
		      differ_amount = @inventory.inventory_amount - @inventory_history.price.abs
        end
	    elsif @inventory_history.inventory_division_id == $INDEX_INVENTORY_SHIPPING
	    #出庫 -> 数をプラスさせる(絶対値)
	      differ_quantity = @inventory.inventory_quantity + @inventory_history.quantity.abs
        differ_amount = @inventory.inventory_amount + @inventory_history.price.abs
      end
      
	    ###
      #出庫＆単価が異なった場合（次のロットにまたがる場合）、ここで先に次のロット分をマイナスしておく！
	  
      #処理追加予定・・・
      ###
    
      ###
    
      #３世代までの単価・数量への増減を行う
      current_unit_price = @inventory.current_unit_price
      @next_unit_price_1 = @inventory.next_unit_price_1
      @next_unit_price_2 = @inventory.next_unit_price_2
    
      current_quantity = @inventory.current_quantity
      @next_quantity_1 = @inventory.next_quantity_1
      @next_quantity_2 = @inventory.next_quantity_2
      
      #
      current_history_id = @inventory.current_history_id
      current_warehousing_date = @inventory.current_warehousing_date
      @next_history_id_1 = @inventory.next_history_id_1
      @next_warehousing_date_1 = @inventory.next_warehousing_date_1
      
      @next_history_id_2 = @inventory.next_history_id_2
      @next_warehousing_date_2 = @inventory.next_warehousing_date_2
      #
    
      #ロット１と単価同一？
      @inventory_division_id = @inventory_history.inventory_division_id
      check_same_unit_price_flag(current_unit_price)
      
    
      #if @inventory_history.unit_price == @inventory.current_unit_price
	    if @sameUnitPriceFlag
      #現在単価と同一？
	      if @inventory_history.inventory_division_id == $INDEX_INVENTORY_STOCK
	        current_quantity = @inventory.current_quantity - @inventory_history.quantity
        else
          current_quantity = @inventory.current_quantity + @inventory_history.quantity
        end
      elsif @inventory_history.unit_price == @inventory.next_unit_price_1
      #次の単価と同一？
        if @inventory_history.inventory_division_id == $INDEX_INVENTORY_STOCK
          @next_quantity_1 = @inventory.next_quantity_1 - @inventory_history.quantity
        else
          @next_quantity_1 = @inventory.next_quantity_1 + @inventory_history.quantity
        end
	    elsif @inventory_history.unit_price == @inventory.next_unit_price_2
	    #次の次の単価と同一？
	    ###
        if @inventory_history.inventory_division_id == $INDEX_INVENTORY_STOCK
          @next_quantity_2 = @inventory.next_quantity_2 - @inventory_history.quantity
        else
          @next_quantity_2 = @inventory.next_quantity_2 + @inventory_history.quantity
        end
      else
      #現、次と単価不一致の場合は旧ロットとみなす(出庫の場合のみ)
        if @inventory_history.inventory_division_id == $INDEX_INVENTORY_SHIPPING
          
          #ロット2(_1)があれば、ロット3(_2)へ繰り下げる
          set_lot_second_to_lot_third
          
          if @inventory_history.next_unit_price_1 == @inventory.current_unit_price
            @next_quantity_1 = @inventory.current_quantity
            @next_unit_price_1 = @inventory.current_unit_price
            @next_warehousing_date_1 = @inventory.current_warehousing_date
            @next_history_id_1 = @inventory.current_history_id
          else
          #ロット１とも単価が違う場合は、現在庫はロット２のものとみなす
            @next_quantity_1 = 0  #下部で加算があるため
            
            @next_quantity_2 = @inventory.current_quantity
            @next_unit_price_2 = @inventory.current_unit_price
            @next_warehousing_date_2 = @inventory.current_warehousing_date
            @next_history_id_2 = @inventory.current_history_id
          end
          
          #現ロット
          tmp_quantity = @inventory_history.quantity
          tmp_quantity2 = 0
          if @inventory_history.next_quantity_1.present?
            tmp_quantity -= @inventory_history.next_quantity_1
            tmp_quantity2 = @inventory_history.next_quantity_1
          end
          
          #current_quantity = @inventory_history.quantity
          current_quantity = tmp_quantity
          current_unit_price = @inventory_history.current_unit_price
          current_history_id = @inventory_history.current_history_id
          current_warehousing_date = @inventory_history.current_warehousing_date
          if tmp_quantity2 > 0
            @next_quantity_1 += tmp_quantity2
            #
            @next_unit_price_1 = @inventory_history.next_unit_price_1
            @next_warehousing_date_1 = @inventory_history.next_warehousing_date_1
            @next_history_id_1 = @inventory_history.next_history_id_1
          end
        end
      end
	  
	    ###
	    #数がゼロの場合、次の履歴から持ってくる
      if current_quantity == 0
        if @inventory.next_quantity_1.present? && @inventory.next_quantity_1 > 0
          #del200629
          #current_quantity = @inventory_history.next_quantity_1
		      #current_unit_price = @inventory_history.next_unit_price_1
		      #del200629
          #if @inventory_history.next_quantity_2.present? && @inventory_history.next_quantity_2 > 0
		      #履歴２があれば１へセット
		      #del200629
          #next_quantity_1 = @inventory_history.next_quantity_2
			    #next_unit_price_1 = @inventory_history.next_unit_price_2
			    
          #@next_quantity_2 = nil
			    #@next_unit_price_2 = nil
		      
          #else
		      #  next_quantity_1 = nil
		      #  next_unit_price_1 = nil
		      #end
        end
      end
      
      #moved200715
      #next_history_id_1 = @inventory.next_history_id_1
      #next_warehousing_date_1 = @inventory.next_warehousing_date_1
      
      
	    if @next_quantity_1.present? && @next_quantity_1 == 0
	      #add200704
        #next_history_id_1 = nil
        #next_warehousing_date_1 = nil
        #
        
        @next_quantity_1 = nil
		    @next_unit_price_1 = nil
		    @next_history_id_1 = nil
        @next_warehousing_date_1 = nil
        
      end
	    if @next_quantity_2.present? && @next_quantity_2 == 0
	      @next_quantity_2 = nil
		    @next_unit_price_2 = nil
        
        @next_history_id_2 = nil
        @next_warehousing_date_2 = nil
	    end
	    ###
	  
	    inventory_update_params = {inventory_quantity: differ_quantity, inventory_amount: differ_amount, current_quantity: current_quantity, 
                                 current_unit_price: current_unit_price, 
                                 current_history_id: current_history_id, current_warehousing_date: current_warehousing_date,
                                 next_history_id_1: @next_history_id_1, next_warehousing_date_1: @next_warehousing_date_1, 
                                 next_quantity_1: @next_quantity_1, next_unit_price_1: @next_unit_price_1, 
                                 next_history_id_2: @next_history_id_2, next_warehousing_date_2: @next_warehousing_date_2,
                                 next_quantity_2: @next_quantity_2, next_unit_price_2: @next_unit_price_2}
	  
      @inventory.update(inventory_update_params)
   	end
  end 
  
  #ロット１と同一単価かチェック
  def self.check_same_unit_price_flag(current_unit_price)
    @sameUnitPriceFlag = false
    if current_unit_price ==  @inventory_history.unit_price
      if @inventory_division_id == $INDEX_INVENTORY_STOCK
      
        if @inventory.next_warehousing_date_1.present? && @inventory.next_warehousing_date_1 < @inventory_history.inventory_date &&
           @inventory.next_quantity_1.present? && @inventory.next_quantity_1 > 0
        #入庫で、ロット１と同一単価でも、ロット２が存在・かつロット２以降の入庫日であれば、ロット３へセットさせる
          #
        else
          @sameUnitPriceFlag = true
        end
      
      else
      #出庫
        if @inventory_history.next_quantity_1.present? && @inventory_history.next_quantity_1 > 0
          #次のロットがあった場合は、現在の在庫ロットはロット３のもの(A->B->A)とみなす
        else
          @sameUnitPriceFlag = true
        end
      end
    end
    ###
  end
  
  
  #ajax
  #最終単価＆仕入業者を返す(アイテム選択時)
  def get_unit_price
    record = Inventory.where(material_master_id: params[:material_id]).first
  	
      
  if record.present?
    #@current_unit_price = record.current_unit_price
    #@inventory_id = record.id   #idをセット add171128
    
    #@current_unit_price = record.last_unit_price
    #upd200701
    if record.inventory_quantity.present? && record.inventory_quantity > 0
      @current_unit_price = record.current_unit_price
    else
      #数量がなければ、単価は入れないでおく(警告メッセージを出すため)
      @current_unit_price = nil
    end
    #@supplier  = SupplierMaster.where(:id => record.supplier_master_id).where("id is NOT NULL").pluck("supplier_name, id")
    #200627
    #ここで仕入先を自社にする。
    @supplier  = SupplierMaster.where(:id => $SUPPLIER_MASER_ID_OWN_COMPANY).where("id is NOT NULL").pluck("supplier_name, id")
    @supplier += SupplierMaster.all.pluck("supplier_name, id")
  else
      #自社にする
      @supplier  = SupplierMaster.where(:id => $SUPPLIER_MASER_ID_OWN_COMPANY).where("id is NOT NULL").pluck("supplier_name, id")
    
      @supplier += SupplierMaster.all.pluck("supplier_name, id")
      #@supplier = SupplierMaster.all.pluck("supplier_name, id")
	end
	  
  end
  
  ###
  #add200701
  #数量入力後、単価を取得する(次ロットも考慮)
  def get_unit_price_on_quantity_changed
    #params[:quantity] 必要
  
    #ここで在庫も取得
    @inventory = Inventory.where(material_master_id: params[:material_id]).first
      
    history_exist = false
    
    if params[:id].present?
      
      #最初に履歴マスターを取得(数量２の比較)
      inventory_history = InventoryHistory.where(purchase_datum_id: params[:id]).first
      
      #履歴が存在し、次ロットIDが保存されていた場合のみこっちのデータから取得するようにする
      if inventory_history.present? && inventory_history.next_history_id_1 > 0
      #if inventory_history.present? && inventory_history.next_history_id_1 > 0 && 
      #   inventory_history.next_unit_price_1.present?
      
        history_exist = true
        
        tmp_next_quantity_1 = inventory_history.next_quantity_1 || 0
        
        
        #quantity = params[:quantity].to_i - tmp_next_quantity_1
        #next_quantity
        quantity = params[:quantity].to_i - inventory_history.current_quantity
        
        #quantity = params[:quantity].to_i - (inventory_history.quantity - tmp_next_quantity_1)
        
        @quantity2 = inventory_history.next_quantity_1
        @unit_price2 = inventory_history.next_unit_price_1
        
        #if inventory_history.current_quantity > quantity
        if quantity <= 0  
          #数２以下とみなし、次ロットの在庫は使わないものとする
          @quantity2 = 0  #単価２は復活の場合もあるので、クリアせず保持しておく
          #@unit_price2 = nil
        else
          #次ロットの在庫からマイナスさせる場合
          if quantity != inventory_history.next_quantity_1
          
            if inventory_history.next_quantity_1 > quantity
            #更新済み数２より少ない場合はマイナスさせる
              #@quantity2 = inventory_history.next_quantity_1 - quantity 
              @quantity2 = quantity
            else
            #更新済み数２より数量が大きい場合は、差分を足す
              if inventory_history.next_quantity_1 > 0
                @quantity2 = inventory_history.next_quantity_1 + (quantity - inventory_history.next_quantity_1)
              else
              #数量２がゼロ(次ロット履歴有)の場合で履歴と異なる場合は、次ロットにまたがったものとする
                if params[:quantity].to_i > inventory_history.quantity
                  
                  #binding.pry
                  
                  tmp_q = 0
                  if @inventory.present?
                    #binding.pry
                    if params[:purchase_unit_price].present?
                      if @inventory.current_unit_price == params[:purchase_unit_price].to_i
                        tmp_q = @inventory.current_quantity
                      end
                    end
                  end
                
                  #@quantity2 = params[:quantity].to_i - inventory_history.quantity
                  @quantity2 = params[:quantity].to_i - tmp_q - inventory_history.quantity
                end
              end
            end
          end
        end
        
        #数量２がはいってなければ、クリアする
        if @quantity2.blank? || @quantity2.zero?
          #@unit_price2 = nil  #単価２は復活の場合もあるので、クリアせず保持しておく
          @quantity2 = 0
        end
        ##
      end
      
    end
    
    #binding.pry
        
    
    if !history_exist
    
      #inventory = Inventory.where(material_master_id: params[:material_id]).first
    
      if @inventory.present?
        #200708
        ##test 
        #if inventory_history.quantity < params[:quantity].to_i 
        #  if inventory_history.unit_price != inventory.current_unit_price
        #  end
        #end
        ##
      
        quantity = params[:quantity].to_i
      
        @quantity2 = nil
        @unit_price2 = nil
      
        #次ロット分にかかるものなら、そっちから単価・数量を取得する
        if @inventory.current_quantity < quantity
          if @inventory.next_quantity_1 > 0
            @quantity2 = (@inventory.current_quantity - quantity).abs
            @unit_price2 = @inventory.next_unit_price_1
          end
        end
      end
    end
  end
  ###
  
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
      :next_unit_price_1, :next_history_id_2, :next_warehousing_date_2, :next_quantity_2, :next_unit_price_2 , :no_stocktake_flag, :image)
    end
  end
