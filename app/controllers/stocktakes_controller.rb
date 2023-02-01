class StocktakesController < ApplicationController
  before_action :set_stocktake, only: [:show, :edit, :update, :destroy]

  # GET /stocktakes
  # GET /stocktakes.json
  def index
    
    #@stocktakes = Stocktake.all
   
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)  	
   
    #ransack保持用-
    @q = Stocktake.ransack(query)   
    
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
	
    @stocktakes  = @q.result(distinct: true)
    
    #kaminari用設定
    @stocktakes  = @stocktakes.page(params[:page])
	  #
	
	  #在庫マスター・履歴マスターへの反映（一括更新）
	  if params[:update_flag] == "1"
	    update_inventory
    elsif params[:update_flag] == "2"
	    #在庫マスターからのコピー
      calcFlag = true
    
      if params[:q].blank?
        calcFlag = false
      else
        if params[:q][:stocktake_date_gteq].blank?
          calcFlag = false
        end
        if params[:q][:with_material_category_include].blank?
          calcFlag = false
        end
      end
      if calcFlag == true
        copyFromInventory
      else
        flash[:notice] = "集計開始日もしくはカテゴリーで選択・集計されていません。処理を中止しました。"
      end
    end
	
    #global set
    $stocktakes = @stocktakes
	
    #棚卸日をセット
    $stocktake_date = nil
    $stocktake_list_header_subtitle = nil
    
    if query.present?
	    if query["stocktake_date_gteq"].present?
        $stocktake_date = query["stocktake_date_gteq"]
      end
      #エアコン、配線器具などのサブタイトルをセットする
      if query["with_material_category_include"].present?
        #$stocktake_list_header_subtitle = Inventory.category[(query["with_material_category_include"].to_i)-1][0]
        inventory_category = InventoryCategory.find(query["with_material_category_include"].to_i)
        $stocktake_list_header_subtitle = inventory_category.name
      end
    end
    
    respond_to do |format|
      format.html
      #pdf
      format.pdf do
        
        $print_flag = params[:print_flag]
        report = InventoryActionListPDF.create @inventory_action_list 
       
		    # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data(
          report.generate,
          filename:  "inventory_action_list.pdf",
          type:        "application/pdf",
          disposition: "inline")
      end
    end
	  #
	
  end
  
  #在庫マスターから対象のデータをコピー
  def copyFromInventory
  
    #最初にデータを一旦抹消させる。
    Stocktake.where(stocktake_date: params[:q][:stocktake_date_gteq]).destroy_all
    
    #検索用のカテゴリーは１つずれているので、マイナスさせる -> しない(220216)
    category = params[:q][:with_material_category_include].to_i 
    #category -= 1
  
    Inventory.all.each do |iv|
      if  iv.material_master.inventory_category_id == category
      #カテゴリー一致？
        #stocktake_params = { stocktake_date: params[:q][:stocktake_date_gteq], material_master_id: iv.material_master_id, 
        #                     inventory_id: iv.id, physical_quantity: iv.current_quantity, unit_price: iv.current_unit_price, 
        #                     physical_amount: iv.inventory_amount, book_quantity: iv.current_quantity, book_amount: iv.inventory_amount }
        
        #upd180322
        #在庫数は"現在数量"ではなく"在庫数"を持ってくるようにする
        stocktake_params = { stocktake_date: params[:q][:stocktake_date_gteq], material_master_id: iv.material_master_id, 
                             inventory_id: iv.id, physical_quantity: iv.inventory_quantity, unit_price: iv.current_unit_price, 
                             physical_amount: iv.inventory_amount, book_quantity: iv.current_quantity, book_amount: iv.inventory_amount }
      	#データへ新規登録
        @stocktake = Stocktake.new(stocktake_params)
        if @stocktake.save!(:validate => false)
          @success_flag = true
        else
          @success_flag = false
        end
      end
    end
  end
  
  #在庫マスターへの反映
  def update_inventory
  
    @stocktakes.where(inventory_update_flag: nil).each do |stocktake| 
      if stocktake.physical_quantity.present? && stocktake.book_quantity.present?
      #在庫履歴マスターを更新
    
        #棚卸日	#在庫区分
        #工事ID
        @stocktake_record = stocktake
        get_construction_datum_id
        #品番
        #差異数を求める
        differ_quantity =  stocktake.physical_quantity - stocktake.book_quantity
        #単位(在庫Mから取得)
        unit_master_id = 1
        inventory = Inventory.find_by(material_master_id: stocktake.material_master_id)
        if inventory.present? && inventory.unit_master_id.present?
          unit_master_id = inventory.unit_master_id
        end

        #単価(とりあえず最新)
        unit_price = stocktake.unit_price
    
        if differ_quantity.nil?
          differ_quantity = 0
        end
        if unit_price.nil?
          unit_price = 0
        end                   

        #金額
        price = differ_quantity * unit_price

        #仕入先ID(在庫Mから取得)
        supplier_master_id = 1
        if inventory.present? && inventory.supplier_master_id.present?
          supplier_master_id = inventory.supplier_master_id
        end
        
        inventory_hisotory_params = {inventory_date: stocktake.stocktake_date, inventory_division_id: $INDEX_INVENTORY_STOCKTAKE, 
               construction_datum_id: @construction_datum_id, material_master_id: stocktake.material_master_id, 
               quantity: differ_quantity, unit_master_id: unit_master_id, unit_price: unit_price, 
               price: price, supplier_master_id: supplier_master_id }
    
        @inventory_hisotry = InventoryHistory.create(inventory_hisotory_params)
    

        #在庫マスターを更新
        if inventory.present?
      
          #在庫数量・在庫現在数量へ棚卸数量をそのまま上書き
          inventory_quantity = stocktake.physical_quantity
		  
          #del200629
          #current_quantity = stocktake.physical_quantity
		      #上記同様に金額も上書き
		      #inventory_amount = stocktake.physical_amount
		  
          #add200629
          #単価の違う在庫も考慮(但し、単価違いは２つまで考慮とする)
          #差異数量=棚卸数-在庫数量
          #binding.pry
          
          differ_quantity = stocktake.physical_quantity - inventory.inventory_quantity
          
          #現在単価も更新用に保持
          current_quantity = inventory.current_quantity
          #add230107
          if current_quantity.nil?
            current_quantity = 0
          end
          #
          
          current_unit_price = inventory.current_unit_price
          
          #次回・次次回単価も更新用に保持しておく
          next_quantity_1 = inventory.next_quantity_1
          next_unit_price_1 = inventory.next_unit_price_1
          next_quantity_2 = inventory.next_quantity_2
          next_unit_price_2 = inventory.next_unit_price_2
          
          #現在・次回履歴ID,入庫日も保持
          current_history_id = inventory.current_history_id
          current_warehousing_date = inventory.current_warehousing_date
          next_history_id_1 = inventory.next_history_id_1
          next_warehousing_date_1 = inventory.next_warehousing_date_1
          next_history_id_2 = inventory.next_history_id_2
          next_warehousing_date_2 = inventory.next_warehousing_date_2
          #
          
          #差異を加減(現在数または次回ロット)
          if differ_quantity > 0 && inventory.next_quantity_2.present? && inventory.next_quantity_2 > 0
            #差異がプラスでロット３が存在する場合
            #ロット３へ加算
            next_quantity_2 = inventory.next_quantity_2 + differ_quantity
            #if differ_quantity > 0 && inventory.next_quantity_1 > 0
          elsif differ_quantity > 0 && inventory.next_quantity_1.present? && inventory.next_quantity_1 > 0
            #差異がプラスでロット２が存在する場合
            #ロット２へ加算
            next_quantity_1 = inventory.next_quantity_1 + differ_quantity
          else
            #差異プラスでロット２無、又は差異マイナスの場合
            #ロット１へ加減算
            current_quantity += differ_quantity
            #current_quantity = inventory.current_quantity + differ_quantity
            #unit_price_1 = inventory.current_unit_price
            
            #現在数(ロット１)がマイナスとなった場合、違う単価の在庫分ばあれば加減
            #if current_quantity < 0
            if current_quantity <= 0
              if inventory.next_unit_price_1.present? && inventory.next_unit_price_1 > 0
                #ロット１が現在庫に繰り上がる場合
                differ_quantity_2 = current_quantity
              
                #現在数量単価(最初のストック)に上書きし、ストック２はクリアする
                current_quantity = inventory.next_quantity_1 + differ_quantity_2
                current_unit_price = inventory.next_unit_price_1
                #履歴ID,入庫日をセット
                current_history_id = next_history_id_1
                current_warehousing_date = next_warehousing_date_1
              
                #次回数量単価(ストック２)をクリア
                next_quantity_1 = nil
                next_unit_price_1 = nil
                next_history_id_1 = nil
                next_warehousing_date_1 = nil
                
                #ロット２が０になった場合、ロット３から繰り上げる
                if current_quantity <= 0
                  differ_quantity_3 = current_quantity
                  #
                  current_quantity = inventory.next_quantity_2 + differ_quantity_3
                  current_unit_price = inventory.next_unit_price_2
                  #履歴ID,入庫日をセット
                  current_history_id = next_history_id_2
                  current_warehousing_date = next_warehousing_date_2
                  
                  #次回数量単価(ストック２)をクリア
                  next_quantity_2 = nil
                  next_unit_price_2 = nil
                  next_history_id_2 = nil
                  next_warehousing_date_2 = nil
                elsif inventory.next_quantity_2.present? && inventory.next_quantity_2 > 0
                #ロット３がある場合は、ロット２へ繰り上げる
                  next_quantity_1 = inventory.next_quantity_2 
                  next_unit_price_1 = inventory.next_unit_price_2
                  next_history_id_1 = next_history_id_2
                  next_warehousing_date_1 = next_warehousing_date_2
                  
                  #次回数量単価(ストック２)をクリア
                  next_quantity_2 = nil
                  next_unit_price_2 = nil
                  next_history_id_2 = nil
                  next_warehousing_date_2 = nil
                end
                #
                #elsif inventory.next_unit_price_2.present? && inventory.next_unit_price_2 > 0
                #ロット２が現在庫に繰り上がる場合
                #  differ_quantity_2 = current_quantity
              
                #  #現在数量単価(最初のストック)に上書きし、ストック２はクリアする
                #  current_quantity = inventory.next_quantity_2 + differ_quantity_2
                #  current_unit_price = inventory.next_unit_price_2
                #  #履歴ID,入庫日をセット
                #  current_history_id = next_history_id_2
                #  current_warehousing_date = next_warehousing_date_2
              
                #  #次回数量単価(ストック３)をクリア
                #  next_quantity_2 = nil
                #  next_unit_price_2 = nil
                #  next_history_id_2 = nil
                #  next_warehousing_date_2 = nil
              
              end
            end
            
          end 
          
          #金額を計算
          if current_quantity.nil?
            current_quantity = 0
          end 
          if current_unit_price.nil?
            current_unit_price = 0  
          end           

          inventory_amount = current_quantity * current_unit_price
          if next_quantity_1.present? && next_unit_price_1.present?
            inventory_amount += next_quantity_1 * next_unit_price_1
          end
          if next_quantity_2.present? && next_unit_price_2.present?
            inventory_amount += next_quantity_2 * next_unit_price_2
          end
          
          if inventory_amount.present?
            inventory_amount = inventory_amount.to_i
          end
          
          #next_quantity_1 = 0
          #if current_quantity < 0
          #  if inventory.next_unit_price_1.present? && inventory.next_unit_price_1 > 0
          #    next_quantity_1 = current_quantity.abs
          #    next_unit_price_1 = inventory.next_unit_price_1
          #  end
          #end
          #
          
		      ##差異を加えるVer(元々の在庫が狂っている場合もあるので、これは使えないかも・・・)
		      ##在庫Mへ差異数量を加える
		      #inventory_quantity = inventory.inventory_quantity + differ_quantity
		      ##
		      #current_quantity = inventory.current_quantity + differ_quantity
		      ##別ロット分数量への影響（先入先出）あり！！！！！
		      ##
		      ##差異金額
		      #differ_amount =  stocktake.physical_amount - stocktake.book_amount
		      ##在庫Mへ上記差異金額を加える
		      #inventory_amount = inventory.inventory_amount + differ_amount
		      #別ロット分数量への影響（先入先出）あり！！！！！
		      ###########
		  
          #本来なら現在数量、現在単価にも影響する！！（今のところはそのままとする！！）
          #inventory_update_params = {inventory_quantity: inventory_quantity, inventory_amount: inventory_amount, 
          #                           current_quantity: current_quantity }
          inventory_update_params = {inventory_quantity: inventory_quantity, inventory_amount: inventory_amount, 
                                     current_quantity: current_quantity, current_unit_price: current_unit_price,
                                     current_history_id: current_history_id, current_warehousing_date: current_warehousing_date,
                                     next_history_id_2: next_history_id_2, next_warehousing_date_2: next_warehousing_date_2,
                                     next_quantity_2: next_quantity_2, next_unit_price_2: next_unit_price_2,
                                     next_history_id_1: next_history_id_1, next_warehousing_date_1: next_warehousing_date_1,
                                     next_quantity_1: next_quantity_1, next_unit_price_1: next_unit_price_1}
          
          inventory.update(inventory_update_params)
	      end
      

        #棚卸しの在庫更新フラグを１にセット
        stocktake.update(:inventory_update_flag => 1)

      end
    
    end  #loop
    
	##
	#在庫更新フラグを全て１にセットする。(コールバック考慮してないので今一かも・・)
    #これだとなぜかundefined mapのエラー発生するので保留(171226)
	#@stocktakes.where(inventory_update_flag: nil).update_all(:inventory_update_flag => 1)
	
  end
  
  def get_construction_datum_id
  #資材マスターの品目区分より、工事IDを割振ってセットする
    material_master = MaterialMaster.find(@stocktake_record.material_master_id)
	
	@construction_datum_id = 1
	
	if material_master.present?
	  inventory_category_id = material_master.inventory_category_id
	  @construction_datum_id = ConstructionDatum.get_construction_on_inventory_category(inventory_category_id)
	end
    
  end
  
  
  # GET /stocktakes/1
  # GET /stocktakes/1.json
  def show
  end

  # GET /stocktakes/new
  def new
    @stocktake = Stocktake.new
  end

  # GET /stocktakes/1/edit
  def edit
  end

  # POST /stocktakes
  # POST /stocktakes.json
  def create

    @stocktake = Stocktake.new(stocktake_params)
    
    #在庫マスターのIDをセットする
	update_flag = 0
    set_inventories_id
	
    respond_to do |format|
      if @stocktake.save
        format.html { redirect_to @stocktake, notice: 'Stocktake was successfully created.' }
        format.json { render :show, status: :created, location: @stocktake }
      else
        format.html { render :new }
        format.json { render json: @stocktake.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stocktakes/1
  # PATCH/PUT /stocktakes/1.json
  def update
  
    #在庫マスターのIDをセットする
    update_flag = 1
	set_inventories_id
  
    respond_to do |format|
      if @stocktake.update(stocktake_params)
        format.html { redirect_to @stocktake, notice: 'Stocktake was successfully updated.' }
        format.json { render :show, status: :ok, location: @stocktake }
      else
        format.html { render :edit }
        format.json { render json: @stocktake.errors, status: :unprocessable_entity }
      end
    end
  end

  #在庫マスターのIDをセットする（主に単位取得用として）
  def set_inventories_id
    
    #倉庫・ロケーションは１で固定（将来的に設定追加するかも）
	inventory = Inventory.find_by(material_master_id: @stocktake.material_master_id, warehouse_id: 1, location_id: 1)
    
	if inventory.present?
	  if update_flag = 0
	    @stocktake.inventory_id = inventory.id
	  else
        params[:stocktake][:inventory_id] = inventory.id
	  end
	end 
    
  end

  # DELETE /stocktakes/1
  # DELETE /stocktakes/1.json
  def destroy
    @stocktake.destroy
    respond_to do |format|
      format.html { redirect_to stocktakes_url, notice: 'Stocktake was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stocktake
      @stocktake = Stocktake.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stocktake_params
      params.require(:stocktake).permit(:stocktake_date, :material_master_id, :inventory_id, :physical_quantity, :unit_price, 
                                        :physical_amount, :book_quantity, :book_amount, :inventory_update_flag)
    end
end
