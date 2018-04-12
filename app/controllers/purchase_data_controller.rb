class PurchaseDataController < ApplicationController
  before_action :set_purchase_datum, only: [:show, :edit, :update, :destroy]
  
  #ransack保持用 
  #before_action only: [:index] do
  #  get_query('query_purchase_data')
  #end
  #ransack保持用
  #def get_query(cookie_key)
  #    cookies.delete(cookie_key) if params[:clear]
  #    cookies[cookie_key] = params[:q].to_json if params[:q]
  #    @query = params[:q].presence || JSON.load(cookies[cookie_key])
  #end

  #新規登録の画面引継用
  @@purchase_datum_purchase_date = ""
  @@purchase_datum_order_id = []
  @@purchase_datum_slip_code = []
  @@purchase_datum_construction_id = []
  @@purchase_datum_supplier_id = []
  @@purchase_datum_notes = ""
  @@purchase_datum_division_id = []
  
  @@purchase_datum_inventory_division_id = ""   #fix180223
  @@purchase_datum_unit_price_not_update_flag = ""
  
  @@new_flag = []
  
  # GET /purchase_data
  # GET /purchase_data.json
  
  def index
        
        #ransack保持用コード
        query = params[:q]

        query ||= eval(cookies[:recent_search_history_purchase].to_s)  	

        @purchase_order_data_extract = PurchaseOrderDatum.all  #add180403

        
        #注文番号の絞り込み（登録済みのものだけにする） upd180403
        if query.present? && query[:with_construction].present?
          @purchase_order_data_extract = PurchaseOrderDatum.where(construction_datum_id: query[:with_construction])
        end
        ##upd end
        
        case params[:move_flag]
		when "1"
          #工事一覧画面から遷移した場合
          construction_id = params[:construction_id]
		  query = {"with_construction"=> construction_id }
		  
		  #注文番号のパラメータが存在した場合にセットする
		  if params[:purchase_order_id].present?
		    purchase_order_id = params[:purchase_order_id]
            query = {"with_construction"=> construction_id , "purchase_order_datum_id_eq"=> purchase_order_id}
          end
         
		  #仕入業者のパラメータが存在した場合にセットする
		  if params[:supplier_master_id].present?
		    supplier_master_id = params[:supplier_master_id]
            query = {"with_construction"=> construction_id , "purchase_order_datum_id_eq"=> purchase_order_id,
                     "supplier_id_eq"=> supplier_master_id}
          end
		  
          #注文番号の絞り込み（登録済みのものだけにする） upd180403
          @purchase_order_data_extract = PurchaseOrderDatum.where(construction_datum_id: params[:construction_id])
        when "2"
          
		  #注文一覧画面から遷移した場合
		  if params[:construction_id].present?
		  #工事→注文→仕入→注文の場合の分岐
		    params[:move_flag] = "1"
		  end
		  
		  purchase_order_id = params[:purchase_order_id]
          #工事番号のパラメータが存在した場合にセットする
		  query = {"purchase_order_datum_id_eq"=> purchase_order_id }
		  if params[:construction_id].present?
		    construction_id = params[:construction_id]
            query = {"with_construction"=> construction_id , "purchase_order_datum_id_eq"=> purchase_order_id}
          end
		  #仕入業者のパラメータが存在した場合にセットする
		  if params[:supplier_master_id].present?
		    supplier_master_id = params[:supplier_master_id]
            query = {"with_construction"=> construction_id , "purchase_order_datum_id_eq"=> purchase_order_id,
                     "supplier_id_eq"=> supplier_master_id}
          end
          #注文番号の絞り込み（登録済みのものだけにする） upd180403
          @purchase_order_data_extract = PurchaseOrderDatum.where(construction_datum_id: params[:construction_id])
		end
		
        #@q = PurchaseDatum.ransack(params[:q]) 
        #ransack保持用--上記はこれに置き換える
		@q = PurchaseDatum.ransack(query)
		
        #ransack保持用コード
        search_history = {
        value: params[:q],
        expires: 24.hours.from_now
        }
        #upd180403
        #クッキーは仕入専用とする（工事画面に影響してしまうので）
        cookies[:recent_search_history_purchase] = search_history if params[:q].present?
        #
       

	@purchase_data = @q.result(distinct: true)
	
    #add180324
    ###
    #仕入区分のみで検索をした場合は、"入庫"は除外する(在庫区分がヌルの場合のみ検索)。納品書チェックしたい場合等。
    if params[:q].present? && 
       params[:q][:division_id_eq] == $INDEX_DIVISION_PURCHASE.to_s && params[:q][:inventory_division_id_eq] == ""
      @purchase_data = @purchase_data.where(:inventory_division_id => nil)
    end
    ###
    
	#kaminari用設定。
	@purchase_data = @purchase_data.page(params[:page])
	
	@maker_masters = MakerMaster.all
	@purchase_divisions = PurchaseDivision.all
	@supplier_masters = SupplierMaster.all
	@purchase_order_data = PurchaseOrderDatum.all
	@construction_data = ConstructionDatum.all
	@customer_masters = CustomerMaster.all
	
	@material_masters = MaterialMaster.all
	
	@unit_masters = UnitMaster.all
	@purchase_unit_prices = PurchaseUnitPrice.none  
    
	#global set
	$purchase_data = @purchase_data
	
    #####
    #検索用のパラメータがセットされていたら、グローバルにもセットする
    #if params[:q].present?
    if query.present?
      $construction_flag = false
      $customer_flag = false
      $supplier_flag = false
      #if params[:q][:with_construction].present?
      if query["with_construction"].present?
        $construction_flag = true
        $customer_flag = true     #件名があれば得意先もセットする
      end
      #if params[:q][:with_customer].present?
      if query["with_customer"].present?
        $customer_flag = true
      end
      #if params[:q][:supplier_id_eq].present?
      if query["supplier_id_eq"].present?
        $supplier_flag = true
      end
    end
    #####
	
	respond_to do |format|
	  
	  format.html
	  
	      #csv
          require 'kconv'		
          format.csv { send_data @purchase_data.to_csv.kconv(Kconv::SJIS), type: 'text/csv; charset=shift_jis' }
      
	  #pdf
	  
	  #global set
	  #$purchase_data = @purchase_data
	  
	  @print_type = params[:print_type]
	
	  format.pdf do
        
		
        case @print_type
        when "1"
          report = PurchaseListPDF.create @purchase_list 
        when "2"
          report = PurchaseListBySupplierPDF.create @purchase_list_by_supplier
		end
        # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data(
          report.generate,
          filename:  "purchase_list.pdf",
          type:        "application/pdf",
          disposition: "inline")
      end
      
      #
	end
	
	#仕入表PDF発行
    #respond_to do |format|
    #  format.html # index.html.erb
      
  end
  

  # GET /purchase_data/1
  # GET /purchase_data/1.json
  def show
  	@purchase_order_data = PurchaseOrderDatum.all
    @material_masters = MaterialMaster.all
    @unit_masters = UnitMaster.all
    @supplier_masters = SupplierMaster.all
    @purchase_divisions = PurchaseDivision.all
    
    
    #新規登録の画面引継用
    @@purchase_datum_purchase_date = @purchase_datum.purchase_date
    @@purchase_datum_order_id = @purchase_datum.purchase_order_datum_id
    @@purchase_datum_slip_code = @purchase_datum.slip_code
    @@purchase_datum_construction_id = @purchase_datum.construction_datum_id
    @@purchase_datum_supplier_id = @purchase_datum.supplier_id
	@@purchase_datum_notes = @purchase_datum.notes
	@@purchase_datum_division_id = @purchase_datum.division_id
	@@purchase_datum_inventory_division_id = @purchase_datum.inventory_division_id
	#add171216
	@@purchase_datum_unit_price_not_update_flag = @purchase_datum.unit_price_not_update_flag
    
  end

  # GET /purchase_data/new
  def new
    @purchase_datum = PurchaseDatum.new
	
    Time.zone = "Tokyo"
	
      @purchase_unit_prices = PurchaseUnitPrice.none
      @purchase_datum.build_PurchaseUnitPrice
      @purchase_datum.build_MaterialMaster
    
    #工事データ/注文データの初期値をセット
	@outsourcing_flag = "0"
    set_construction_and_order_default


       @@new_flag = params[:new_flag]

       #binding.pry

       #初期値をセット(show画面からの遷移時のみ)
	   if @@new_flag == "1"
         @purchase_datum.purchase_date ||= @@purchase_datum_purchase_date
	     @purchase_datum.purchase_order_datum_id ||= @@purchase_datum_order_id
	     @purchase_datum.slip_code ||= @@purchase_datum_slip_code 
	     @purchase_datum.construction_datum_id ||= @@purchase_datum_construction_id
		 @purchase_datum.supplier_id ||= @@purchase_datum_supplier_id
         @purchase_datum.notes ||= @@purchase_datum_notes
         @purchase_datum.division_id ||= @@purchase_datum_division_id
         @purchase_datum.inventory_division_id ||= @@purchase_datum_inventory_division_id
         #add171216
		 @purchase_datum.unit_price_not_update_flag ||= @@purchase_datum_unit_price_not_update_flag
	   end
	   
       
      #add180223
      #伝票が登録済みかチェック
      check_complete_flag
  end

  #add180224
  def check_complete_flag
    if @purchase_datum.slip_code.present?
      purchase_header = PurchaseHeader.where(["slip_code = ?" , @purchase_datum.slip_code]).first
      if purchase_header.present?
        @purchase_datum.complete_flag = purchase_header.complete_flag
      end
    end
  end

  # GET /purchase_data/1/edit
  def edit
  	@purchase_unit_prices = PurchaseUnitPrice.where(["supplier_id = ? and material_id = ?", @purchase_datum.supplier_id, @purchase_datum.material_id])
    @material_masters = MaterialMaster.where(["id = ?", @purchase_datum.material_id]).pluck(:list_price)
	@maker_masters = MakerMaster.where(["id = ?", @purchase_datum.material_id])
	
	@outsourcing_flag = "0"
    
    #add180223
    #伝票が登録済みかチェック
    check_complete_flag
  end

  # POST /purchase_data
  # POST /purchase_data.json
  def create
    
    #viewで分解されたパラメータを、正常更新できるように復元させる。
    adjust_purchase_date_params
	 
    #登録済みフラグをセット(伝票重複防止のため)
    #add180223
    get_registerd_flag_param
  
	@purchase_datum = PurchaseDatum.new(purchase_datum_params)
    
    
    #仕入単価を更新
    #if (params[:purchase_datum][:unit_price_not_update_flag] == 'false')
	if (params[:purchase_datum][:unit_price_not_update_flag] == '0')
      
	  #仕入先単価マスターへの新規追加又は更新
	  create_or_update_purchase_unit_prices
	 
	  #資材Mも更新
      update_params_list_price_and_maker
	  @purchase_datum.update_attributes(material_masters_params)
	else
	  #資材マスターのみへの更新
	  #手入力のマスター反映(資材マスターのみ)
      add_manual_input_except_unit_price

    end    
    
	#資材マスターへ品名などを反映させる処理(手入力&入出庫以外)
	update_material_master
	
    
    respond_to do |format|
      
      #binding.pry
    
	  if @purchase_datum.save
      #if @purchase_datum.create(purchase_datum_params)
  
        #伝票が重複しないように登録フラグをセット
        set_registerd_flag_to_headers
  
        #入出庫の場合は、在庫履歴データ、在庫マスターへも登録する。
        #moved180407
        trans = InventoriesController.set_inventory_history(params, @purchase_datum)
		if trans == "new_inventory"
           flash[:notice] = "在庫マスターへ新規登録しました。資材マスターの在庫区分・在庫マスターの画像を登録してください。"
        end
  
        #format.html { redirect_to @purchase_datum, notice: 'Purchase datum was successfully created.' }
        #format.json { render :show, status: :created, location: @purchase_datum }
        
		#format.html {redirect_to purchase_datum_path(@purchase_datum, :construction_id => params[:construction_id], :move_flag => params[:move_flag])}
        format.html {redirect_to purchase_datum_path(@purchase_datum, :construction_id => params[:construction_id], 
         :purchase_order_id => params[:purchase_order_id], :supplier_master_id => params[:supplier_master_id],
         :move_flag => params[:move_flag])}
		
       
       #入出庫の場合は、在庫履歴データ、在庫マスターへも登録する。
       #InventoriesController.set_inventory_history(params, @purchase_datum)

      else
        format.html { render :new }
        format.json { render json: @purchase_datum.errors, status: :unprocessable_entity }
      end

       
    end
  end
  
  #単価更新フラグのパラメータ書き換え
  #真偽型がないため、int型に変換する
  #def change_unit_price_update_flag_params
  #  if (params[:purchase_datum][:unit_price_not_update_flag] == '')
  #  else
  #  end
  #end

   # PATCH/PUT /purchase_data/1
  # PATCH/PUT /purchase_data/1.json
  def update
  
   #viewで分解されたパラメータを、正常更新できるように復元させる。
   adjust_purchase_date_params
   
    #登録済みフラグをセット(伝票重複防止のため)
    #add180223
   get_registerd_flag_param
		
   
   #仕入単価Mも更新する 
   #if (params[:purchase_datum][:unit_price_not_update_flag] == 'false')
   if (params[:purchase_datum][:unit_price_not_update_flag] == '0')
	 
	 #仕入先単価マスターへの新規追加又は更新
	 create_or_update_purchase_unit_prices
	 
     #@purchase_unit_prices = PurchaseUnitPrice.where(["supplier_id = ? and material_id = ?", 
     #         params[:purchase_datum][:supplier_id], params[:purchase_datum][:material_id] ]).first
     #if @purchase_unit_prices.present?
	 #  purchase_unit_prices_update_params = {material_id:  params[:purchase_datum][:material_id], supplier_id: params[:purchase_datum][:supplier_id], unit_price: params[:purchase_datum][:purchase_unit_price]}
	 #    @purchase_unit_prices.update(purchase_unit_prices_update_params)
     #end     

     #定価・メーカーID、品番品名も更新
     update_params_list_price_and_maker
	 @purchase_datum.update(material_masters_params)  
   
   else
   #資材マスターのみへの更新
	 #手入力のマスター反映(資材マスターのみ)
     add_manual_input_except_unit_price
	   
   end 
   
   
   #資材マスターへ品名などを反映させる処理(手入力&入出庫以外)
   update_material_master

   respond_to do |format|
      
      if @purchase_datum.update(purchase_datum_params)
        
        #伝票が重複しないように登録フラグをセット
        set_registerd_flag_to_headers
        
        #入出庫の場合は、在庫履歴データ、在庫マスターへも登録する。
        #moved180407
        trans = InventoriesController.set_inventory_history(params, @purchase_datum)
		#if session[:inventory_new_flag] == "true"
        if trans == "new_inventory"
           flash[:notice] = "在庫マスターへ新規登録しました。資材マスターの在庫区分・在庫マスターの画像を登録してください。"
        end
        
        
        #format.html { redirect_to @purchase_datum, notice: 'Purchase datum was successfully updated.' }
        #format.json { render :show, status: :ok, location: @purchase_datum }
        
	    format.html {redirect_to purchase_datum_path(@purchase_datum, :construction_id => params[:construction_id], 
         :purchase_order_id => params[:purchase_order_id], :supplier_master_id => params[:supplier_master_id],
         :move_flag => params[:move_flag])}
       
        
      else
        format.html { render :edit }
        format.json { render json: @purchase_datum.errors, status: :unprocessable_entity }
      end
  
    end
  end
  
  #add180223
  #伝票が重複しないための登録フラグを見出しから取得
  def get_registerd_flag_param
    
    if params[:purchase_datum][:slip_code].present?
      #更新
      @purchase_header = PurchaseHeader.where(["slip_code = ?" , params[:purchase_datum][:slip_code]]).first
      
      if @purchase_header.present?
         #つくられたIDをセット
         params[:purchase_datum][:purchase_header_id] =  @purchase_header.id
      end
    end
  end 
  
  #add180223
  #伝票が重複しないように登録フラグをセット
  def set_registerd_flag_to_headers
    
    if params[:purchase_datum][:slip_code].present?
      #更新
      @purchase_header = PurchaseHeader.where(["slip_code = ?" , params[:purchase_datum][:slip_code]]).first
      
      if @purchase_header.present?
        
        if params[:purchase_datum][:complete_flag] == "1"   #更新は、済チェック入れた場合のみ登録する。(解除は、上手くできない..)
          purchase_header_params = {complete_flag: params[:purchase_datum][:complete_flag] }
          @purchase_header.update(purchase_header_params)
        end
      else
        #新規
         purchase_header_params = {slip_code: params[:purchase_datum][:slip_code], complete_flag: params[:purchase_datum][:complete_flag] }
	     @purchase_header = PurchaseHeader.create(purchase_header_params)
         
         #つくられたIDをセット
         #purchase_data_params = {purchase_header_id: @purchase_header.id }
         #@purchase_datum.update(purchase_data_params)
         
         #つくられたIDをセット(ヴァリデーションスキップ)
         @purchase_datum.purchase_header_id = @purchase_header.id 
         @purchase_datum.save(:validate => false)
      
      end
      
      #つくられたIDをセット
      #purchase_data_params = {purchase_header_id: @purchase_header.id }
      #@purchase_datum.update(purchase_data_params)
      
    end
  end 
  
  
  #資材マスターへ品名などを反映させる処理(手入力以外)
  def update_material_master
      
	  if @material_masters.present? && (@material_masters.material_name != params[:purchase_datum][:material_name] ||
	                                   @material_masters.material_code != params[:purchase_datum][:material_code] ||
                                       @material_masters.unit_id != params[:purchase_datum][:unit_id])
	    
        if @material_masters.id != 1  #手入力以外
          #更新
		  @materials = MaterialMaster.find(params[:purchase_datum][:material_id])
          #upd180402
          #資材コード、品名、単位を更新
          material_update_params = { material_code: params[:purchase_datum][:material_code],
		                           material_name: params[:purchase_datum][:material_name],
                                   unit_id: params[:purchase_datum][:unit_id] }
        
	      ##品番は、異なった場合はそのまま上書きする（別の品番としては原則、登録できない(ハイフン付与などの微調整と区別できないため。)）
		  #if params[:purchase_datum][:supplier_id].to_i != $SUPPLIER_MASER_ID_OKADA_DENKI_SANGYO
          #     material_update_params = { material_code: params[:purchase_datum][:material_code],
		  #                         material_name: params[:purchase_datum][:material_name] }
          #else
          #     #岡田電気の場合は、単位を資材マスターへ反映（見積の作業明細マスターに反映させるため）
          #     material_update_params = { material_code: params[:purchase_datum][:material_code],
		  #                         material_name: params[:purchase_datum][:material_name],
          #                         unit_id: params[:purchase_datum][:unit_id] }
          #end
          
	      @materials.update(material_update_params)
	    end
	  end
  end
  
  #仕入先単価マスターへの新規追加又は更新
  def create_or_update_purchase_unit_prices
    @purchase_unit_prices = PurchaseUnitPrice.where(["supplier_id = ? and material_id = ?", 
    params[:purchase_datum][:supplier_id], params[:purchase_datum][:material_id] ]).first

    if @purchase_unit_prices.present?
      #purchase_unit_prices_params = {material_id:  params[:purchase_datum][:material_id], supplier_id: params[:purchase_datum][:supplier_id], 
      #                  unit_price: params[:purchase_datum][:purchase_unit_price]}
      #upd180316
      #単位も更新
      purchase_unit_prices_params = {material_id:  params[:purchase_datum][:material_id], supplier_id: params[:purchase_datum][:supplier_id], 
                        unit_price: params[:purchase_datum][:purchase_unit_price], unit_id: params[:purchase_datum][:unit_id]}
      
      @purchase_unit_prices.update(purchase_unit_prices_params)
    else
    #該当なしの場合は新規追加  add180120
	   #仕入先用CDをセット
	   if params[:purchase_datum][:supplier_material_code].present?
		  supplier_masterial_code = params[:purchase_datum][:supplier_material_code]
	   else
		  #仕入先品番が未入力の場合は、品番をそのままセットする
		  supplier_masterial_code = params[:purchase_datum][:material_code]
	   end
	
      purchase_unit_prices_params = {material_id:  params[:purchase_datum][:material_id], supplier_id: params[:purchase_datum][:supplier_id], 
                        supplier_material_code: supplier_masterial_code, 
                        unit_price: params[:purchase_datum][:purchase_unit_price], unit_id: params[:purchase_datum][:unit_id]}
      @purchase_unit_prices = PurchaseUnitPrice.create(purchase_unit_prices_params)
    end
  end
  
  def set_construction_and_order_default
  #工事一覧画面等から遷移した場合に、フォームに初期値をセットさせる    
	  #.pry
	 if params[:purchase_order_id].present?
	   #注文idをセット
	   purchase_order_id = params[:purchase_order_id]
	   @purchase_order_data = PurchaseOrderDatum.where("id >= ?", purchase_order_id)
       tmp_record = PurchaseOrderDatum.where("id = ?", purchase_order_id).first
	   purchase_order_code = tmp_record.purchase_order_code
	   
	   #工事idをセット
	   construction_id = params[:construction_id]
	   @construction_data = ConstructionDatum.where("id >= ?", construction_id)
	   
	   #仕入idをセット
	   supplier_master_id = params[:supplier_master_id]
	   @supplier_master = SupplierMaster.where("id >= ?", supplier_master_id)
	   
	   #外注の注文Noの判定
	   
	   str = purchase_order_code
	   #if str[0,1] == "M" || str[0,1] == "O"
       #upd180220
       if str[0,1] == "M" || str[0,1] == "N" || str[0,1] == "O"
	     #binding.pry
		 @outsourcing_flag = "1"
	   end
	   #
	   
	 else
       #工事コードのみの場合。
       if params[:construction_id].present?
	     construction_id = params[:construction_id]
	     @construction_data = ConstructionDatum.where("id >= ?", construction_id)
	   end
	 end
	 
	 
  end
  
  def update_params_list_price_and_maker
  #資材Mの定価・メーカーを更新する(未登録の場合)
	if params[:purchase_datum][:MaterialMaster_attributes].present?
      if params[:purchase_datum][:material_id].present?   #add170904__
	  
	    id = params[:purchase_datum][:material_id].to_i
      
	    if id != 1  #手入力以外
          @material_masters = MaterialMaster.find(id)
          if @material_masters.present?
            #定価
            #if @material_masters.list_price.nil? || @material_masters.list_price == 0 then
              params[:purchase_datum][:MaterialMaster_attributes][:list_price] = params[:purchase_datum][:list_price]
            #end
            #メーカー
            if @material_masters.maker_id.nil? || @material_masters.maker_id== 1 then
               params[:purchase_datum][:MaterialMaster_attributes][:maker_id] = params[:purchase_datum][:maker_id]
            end
		  
		    #資材マスターへ品名などを反映させる処理(手入力以外)
		    #update_material_master
          end
        else 
	      #手入力をマスター反映させる
	      add_manual_input_to_masters
	    end
	  end
	end
  end
  
  #viewで分解されたパラメータを、正常更新できるように復元させる。
  def adjust_purchase_date_params
    params[:purchase_datum][:purchase_date] = params[:purchase_datum][:purchase_date][0] + "/" + 
                                                  params[:purchase_datum][:purchase_date][1] + "/" + 
                                                  params[:purchase_datum][:purchase_date][2]
  end
  
  #手入力のマスター反映(資材単価マスターの単価のみ更新しないVer)
  def add_manual_input_except_unit_price
    if params[:purchase_datum][:MaterialMaster_attributes].present?
      if params[:purchase_datum][:material_id].present?   #add170904__
	    id = params[:purchase_datum][:material_id].to_i
      
	    if id == 1  #手入力の場合のみ
		
	      if params[:purchase_datum][:material_id] == "1" && 
             params[:purchase_datum][:material_code] != "" && 
		     params[:purchase_datum][:material_code] != "＜手入力用＞" &&
             params[:purchase_datum][:material_code] != "-"
            #商品CD有りのものだけ登録する(バリデーションで引っかかるため)
            @material_master = MaterialMaster.find_by(material_code: params[:purchase_datum][:material_code])
	        #商品マスターへセット(商品コード存在しない場合)
	         if @material_master.nil?
               #upd180403 単位もセットする
		       material_master_params = {material_code: params[:purchase_datum][:material_code], 
		                             material_name: params[:purchase_datum][:material_name], 
                                     maker_id: params[:purchase_datum][:maker_id],
                                     list_price: params[:purchase_datum][:list_price],
                                     unit_id: params[:purchase_datum][:unit_id] }
		       @material_master = MaterialMaster.create(material_master_params)
		   
		       #仕入データのマスターIDも更新する  add170405
		       @purchase_datum.material_id = @material_master.id
	           params[:purchase_datum][:material_id] = @material_master.id
			 end
             
			 if @material_master.id.present?
	           material_id = @material_master.id
		       supplier_id = params[:purchase_datum][:supplier_id]
		 
	   	       if params[:purchase_datum][:supplier_material_code].present?
		         supplier_masterial_code = params[:purchase_datum][:supplier_material_code]
		       else
		       #仕入先品番が未入力の場合は、品番をそのままセットする
		         supplier_masterial_code = params[:purchase_datum][:material_code]
		       end
		       #単価は登録しないため、ゼロにする（必要ないかもだが・・）
			   purchase_unit_price_params = {material_id: material_id, supplier_id: supplier_id, 
                  supplier_material_code: supplier_masterial_code, 
                  unit_price: 0 ,
                  unit_id: params[:purchase_datum][:unit_id]}
	           @purchase_unit_prices = PurchaseUnitPrice.create(purchase_unit_price_params)
               
               
               #仕入データのマスターIDも更新する  add180407
		       @purchase_datum.material_id = @material_master.id
               params[:purchase_datum][:material_id] = @material_master.id
             end 
	      end
		end
	  end
	end
  end
  
  #手入力のマスター反映
  def add_manual_input_to_masters
    
    if params[:purchase_datum][:material_id] == "1" && 
         params[:purchase_datum][:material_code] != "" && 
		 params[:purchase_datum][:material_code] != "＜手入力用＞" &&
         params[:purchase_datum][:material_code] != "-"
       #商品CD有りのものだけ登録する(バリデーションで引っかかるため)
       @material_master = MaterialMaster.find_by(material_code: params[:purchase_datum][:material_code])
	   #商品マスターへセット(商品コード存在しない場合)
	   if @material_master.nil?
		   material_master_params = {material_code: params[:purchase_datum][:material_code], 
		                             material_name: params[:purchase_datum][:material_name], 
                                     maker_id: params[:purchase_datum][:maker_id],
									 list_price: params[:purchase_datum][:list_price],
                                     unit_id: params[:purchase_datum][:unit_id] }
		   @material_master = MaterialMaster.create(material_master_params)
		   
		   #仕入データのマスターIDも更新する  add170405
		   @purchase_datum.material_id = @material_master.id
           params[:purchase_datum][:material_id] = @material_master.id
		   #params[:purchase_datum][:material_id] = @material_master.id
	   end
	  
       #仕入単価マスターへも登録。
       @material_master = MaterialMaster.find_by(material_code: params[:purchase_datum][:material_code])
	   if @material_master.present?
	     material_id = @material_master.id
		 supplier_id = params[:purchase_datum][:supplier_id]
		 
		# binding.pry
		 
		 if params[:purchase_datum][:supplier_material_code].present?
		   supplier_masterial_code = params[:purchase_datum][:supplier_material_code]
		 else
		   #仕入先品番が未入力の場合は、品番をそのままセットする
		   supplier_masterial_code = params[:purchase_datum][:material_code]
		 end
		 
		 purchase_unit_price_params = {material_id: material_id, supplier_id: supplier_id, 
                  supplier_material_code: supplier_masterial_code, 
                  unit_price: params[:purchase_datum][:purchase_unit_price] ,
                  unit_id: params[:purchase_datum][:unit_id]}
	     @purchase_unit_prices = PurchaseUnitPrice.create(purchase_unit_price_params)
         
         #binding.pry
         
           #仕入データのマスターIDも更新する  add180407
		   @purchase_datum.material_id = @material_master.id
           params[:purchase_datum][:material_id] = @material_master.id    
	     end
	   end
  
  end
  
  # DELETE /purchase_data/1
  # DELETE /purchase_data/1.json
  def destroy
    #入出庫履歴マスターを削除
    #takano
	InventoriesController.destroy_inventory_history(@purchase_datum)
	
	#
	@purchase_datum.destroy
    respond_to do |format|
      
	  #format.html { redirect_to purchase_data_url, notice: 'Purchase datum was successfully destroyed.' }
      #format.json { head :no_content }
	  
	  #format.html {redirect_to purchase_data_path( :construction_id => params[:construction_id], :move_flag => params[:move_flag])}
	  format.html {redirect_to purchase_data_path( :construction_id => params[:construction_id], 
         :purchase_order_id => params[:purchase_order_id], :supplier_master_id => params[:supplier_master_id],
         :move_flag => params[:move_flag])}
    end
  end
  
  # ajax
  def unit_price_select
     @purchase_unit_prices = PurchaseUnitPrice.where(:supplier_id => params[:supplier_id], :material_id => params[:material_id]).where("supplier_id is NOT NULL").where("material_id is NOT NULL").pluck(:unit_price).flatten.join(",")
  end
  def list_price_select
     @material_masters = MaterialMaster.where(:id => params[:material_id]).where("id is NOT NULL").pluck(:list_price)
  end
  def maker_select
     @maker_masters = MaterialMaster.with_maker.where(:id => params[:material_id]).pluck("maker_masters.maker_name, maker_masters.id")
     
	 #binding.pry
	 
	 #未登録(-)の場合はセットしない。
     #if @maker_masters == [["-",1]]
     #upd170707
     if @maker_masters == [["-",1]] || @maker_masters.blank?
        #@maker_masters = MaterialMaster.all.pluck("maker_masters.maker_name, maker_masters.id")
		@maker_masters = MakerMaster.all.pluck("maker_masters.maker_name, maker_masters.id")
     end 
  end
  def unit_select
     @unit_masters  = PurchaseUnitPrice.with_unit.where(:supplier_id => params[:supplier_id], :material_id => params[:material_id]).where("supplier_id is NOT NULL").where("material_id is NOT NULL").pluck("unit_masters.unit_name, unit_masters.id")
     
     #登録済み単位と異なるケースもあるので、任意で変更もできるように全ての単位をセット
     unit_all = UnitMaster.all.pluck("unit_masters.unit_name, unit_masters.id")
     @unit_masters = @unit_masters + unit_all
     
     #単位未登録の場合はデフォルト値をセット
     if @unit_masters.blank?
        @unit_masters  = [["-",1]]
     end
     
     #未登録(-)の場合はセットしない。
     #if @unit_masters  == [["-",1]]
        #PurchaseUnitPrice.all.pluck("unit_masters.unit_name, unit_masters.id")
     #end 
  end

  def supplier_item_select
    @supplier_material  = PurchaseUnitPrice.where(:supplier_id => params[:supplier_id]).where("supplier_id is NOT NULL").pluck("supplier_material_code, material_id")
  end
  
  #add170226
  def supplier_select
   @supplier_id  = PurchaseOrderDatum.where(:purchase_order_code => params[:purchase_order_code]).where("id is NOT NULL").pluck("supplier_master_id")
  end
  
  #見出しデータを取得(伝票番号確認用）
  def get_header_id
    #@purchase_header_id = PurchaseHeader.where(:slip_code => params[:slip_code]).pluck(:id).flatten.join(",")
    @complete_flag = PurchaseHeader.where(:slip_code => params[:slip_code]).pluck(:complete_flag).flatten.join(",")
  end
  
  #入庫の場合、件名（工事No.）を自動取得する
  #add170428
  def construction_select_on_stocked
    #@construction_datum_id = 1  #デフォルト
	
	material_master = MaterialMaster.find(params[:material_id])
	if material_master.present?
      
	  if material_master.inventory_category_id.present?
	    
		inventory_category_id = material_master.inventory_category_id
		#モデルから取得
		@construction_datum_id = ConstructionDatum.get_construction_on_inventory_category(inventory_category_id)
  
	  end
	end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_datum
      @purchase_datum = PurchaseDatum.find(params[:id])

    end
	
	# Never trust parameters from the scary internet, only allow the white list through.
    def purchase_datum_params
      params.require(:purchase_datum).permit(:purchase_date, :slip_code, :purchase_order_datum_id, :construction_datum_id, 
                     :material_id, :material_code, :material_name, :maker_id, :maker_name, :quantity, :unit_id, :purchase_unit_price, 
                     :purchase_amount, :list_price, :division_id, :supplier_id, :inventory_division_id, :unit_price_not_update_flag, :notes, :purchase_header_id )
    end
    
    def purchase_unit_prices_params
         params.require(:purchase_datum).permit(PurchaseUnitPrice_attributes: [:material_id, :supplier_id, :unit_price])
    end

    def material_masters_params
         params.require(:purchase_datum).permit(MaterialMaster_attributes: [:id,  :last_unit_price, :last_unit_price_update_at, :list_price, :maker_id])
    end
    
	#資材Mへ最終単価・日付を更新用
    #def save_material_masters
    #    @material_master = MaterialMaster.where(["id = ?", @purchase_datum.material_id]).first
    # if @material_master.present?
    #    @material_master.last_unit_price = params[:last_unit_price]
    #    @material_master.last_unit_price_update_at = params[:last_unit_price_update_at]
    #    @material_master.save
    # end
    #end
end
