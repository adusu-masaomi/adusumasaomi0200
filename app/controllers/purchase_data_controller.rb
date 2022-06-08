class PurchaseDataController < ApplicationController
  before_action :set_purchase_datum, only: [:show, :edit, :update, :destroy]
  
  #del200626
  #before_action :set_material, only: [:new, :edit]
  #add200626
  #before_action :set_purchase_unit_price, only: [:new, :edit]
  
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

  #@@material_masters = ""

  #新規登録の画面引継用
  @@purchase_datum_purchase_date = ""
  @@purchase_datum_order_id = []
  @@purchase_datum_slip_code = []
  @@purchase_datum_construction_id = []
  #@@purchase_datum_supplier_id = []
  @@purchase_datum_supplier_id = nil   #upd200626
  
  @@purchase_datum_notes = ""
  @@purchase_datum_division_id = []
  
  @@purchase_datum_inventory_division_id = ""   #fix180223
  @@purchase_datum_unit_price_not_update_flag = ""
  
  @@new_flag = []
  
  #@@supplier_material = []    #add200626
  
  #見積用の定価
  @@list_price_quotation = 0
  
  # GET /purchase_data
  # GET /purchase_data.json
  
  include ApplicationHelper
  @@clear = false
  @@count = 0
  
  def index
    
    #binding.pry
    
    #ransack保持用コード
    query = params[:q]

    #クッキーへのget/putはヘルパーに設定
    cky = get_cookies("recent_search_history_purchase")
    query ||= eval(cky.to_s)   
        
        
    #
    #クッキーをクリアさせる場合の処理
    if @@clear == true
      query = eval(cky.to_s) 
      @@count += 1
          
      if @@count == 1    #centos(本番)用
      #if @@count == 2   #(mac用)２回目の遷移時に(なぜか)、正常なパラメータが送られてくる
        @@clear = false
        @@count = 0
      end
    end
    #
        
    @purchase_order_data_extract = PurchaseOrderDatum.all  
    @construction_code_extract = ConstructionDatum.all     
        
    #注文番号の絞り込み（登録済みのものだけにする） 
    if query.present? && query[:with_construction].present?
      @purchase_order_data_extract = PurchaseOrderDatum.where(construction_datum_id: query[:with_construction])
          
      #add210319
      #仕入業者の絞り込み
      @supplier_master_extract = SupplierMaster.joins(:purchase_data).
                          where('purchase_data.construction_datum_id = ?', query[:with_construction]).distinct
    end
        
    #件名の絞り込み addd180830
    if query.present? && query[:with_customer].present?
      @construction_code_extract = ConstructionDatum.where(customer_id: query[:with_customer]).order("construction_code desc")
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
      
      #検索用クッキーへも保存
      params[:q] = query
          
      #注文番号の絞り込み（登録済みのものだけにする） upd180403
      @purchase_order_data_extract = PurchaseOrderDatum.where(construction_datum_id: params[:construction_id])
        
      #add210319
      #仕入業者の絞り込み
      @supplier_master_extract = SupplierMaster.joins(:purchase_data).
                      where('purchase_data.construction_datum_id = ?', params[:construction_id]).distinct
          
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
          
      #add181001
      #検索用クッキーへも保存
      params[:q] = query
          
      #注文番号の絞り込み（登録済みのものだけにする） upd180403
      @purchase_order_data_extract = PurchaseOrderDatum.where(construction_datum_id: params[:construction_id])
          
      #add210319
      #仕入業者の絞り込み
      @supplier_master_extract = SupplierMaster.joins(:purchase_data).
                          where('purchase_data.construction_datum_id = ?', params[:construction_id]).distinct
    end
		
    #@q = PurchaseDatum.ransack(params[:q]) 
    #ransack保持用--上記はこれに置き換える
    @q = PurchaseDatum.ransack(query)

    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 4.hours.from_now
    }
    #upd180403
    #クッキーは仕入専用とする（工事画面に影響してしまうので）
        
    #cookies[:recent_search_history_purchase] = search_history if params[:q].present?
    if params[:q].present?
          set_cookies("recent_search_history_purchase", search_history)
    end
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
    
    single_record = false
    
    #単価の最安値で検索する場合
    if params[:subaction].present? &&
       params[:subaction] == "bestprice"
      
      search_day = false
      if params[:q].present? &&
         (params[:q][:purchase_date_gteq].present? ||
         params[:q][:purchase_date_lteq].present?)
        search_day = true
      end
      
      #直近１年間にする(仕入日が入力されてない場合)
      if !search_day
        to    = Time.current.at_beginning_of_day
        from  = (to - 1.year)
        @purchase_data = @purchase_data.where(created_at: from...to)
      end
      #
      @purchase_data = @purchase_data.where(purchase_unit_price: @purchase_data.minimum(:purchase_unit_price)).order(created_at: :desc)
      
      single_record = true
    end
    ##
    
    if @supplier_master_extract.blank?
      @supplier_master_extract = SupplierMaster.all
    end
    
	#kaminari用設定。
    if !single_record
      @purchase_data = @purchase_data.page(params[:page])
	else
      #最安値の場合。一件だけ表示
      @purchase_data = @purchase_data.page(params[:page]).limit(1)
    end
    
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

    #add220114
    #一括変換した場合の処理
    if params[:commit] == "更新"
      all_convert_delivery_slip(params)
    end
    #
    
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
        when "3"
          #外注用請求
          report = PurchaseListForOutsourcingPDF.create @purchase_list_for_outsourcing
		end
        # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data(
          report.generate,
          filename:  "purchase_list.pdf",
          type:        "application/pdf",
          disposition: "inline")
      end
     
	end
	
    
    
	#仕入表PDF発行
    #respond_to do |format|
    #  format.html # index.html.erb
      
  end
  
  
  #伝票一括変更処理
  def all_convert_delivery_slip(params)
    
    if @purchase_data.present?
      if params[:old_slip_code].present? && params[:old_slip_code][:value].present?  #伝票番号で絞り込んでない場合は変換しない
        
        @purchase_data.find_each do |purchase_datum|
          
          update_flag = false
          
          #伝票番号の変更
          if params[:new_slip_code].present? && params[:new_slip_code][:value].present?
            purchase_datum.slip_code = params[:new_slip_code][:value]
            update_flag = true
          end
          
          #仕入日の変更
          if params[:new_purchase_date].present? && 
             params[:new_purchase_date]["new_date(1i)"].present? && 
             params[:new_purchase_date]["new_date(2i)"].present? &&
             params[:new_purchase_date]["new_date(3i)"].present?
             
             new_date = Date.new(params[:new_purchase_date]["new_date(1i)"].to_i,
                                 params[:new_purchase_date]["new_date(2i)"].to_i,
                                 params[:new_purchase_date]["new_date(3i)"].to_i)
                                 
             purchase_datum.purchase_date = new_date
             
             update_flag = true
          end
          
          #注文Noの変更
          if params[:new_purchase_order_datum_id].present? && 
             params[:new_purchase_order_datum_id][:value].present?
             
             new_purchase_order_datum_id = params[:new_purchase_order_datum_id][:value].to_i
             #工事IDも変換させる
             purchase_order_datum = PurchaseOrderDatum.find(new_purchase_order_datum_id)
             new_construction_id = purchase_order_datum.construction_datum_id
             
             purchase_datum.purchase_order_datum_id = new_purchase_order_datum_id
             purchase_datum.construction_datum_id = new_construction_id
             
             update_flag = true
          end
          #
          
          #備考の変更
          if (params[:new_notes].present? && 
             params[:new_notes][:value].present?) ||
             (params[:new_notes_check].present? && 
             params[:new_notes_check][:value] == "1")
             
             purchase_datum.notes = params[:new_notes][:value]
             update_flag = true
          end
          #
          
          if update_flag
            purchase_datum.save!(:validate => false)
          end
        end
      end
    end
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
	
    #ここで資材マスターもセットしておく(動作軽減のため)
    #@@material_masters = MaterialMaster.all
      
    
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
       #test del 200626
         @purchase_datum.purchase_date ||= @@purchase_datum_purchase_date
	     @purchase_datum.purchase_order_datum_id ||= @@purchase_datum_order_id
	     @purchase_datum.slip_code ||= @@purchase_datum_slip_code 
	     @purchase_datum.construction_datum_id ||= @@purchase_datum_construction_id
		 @purchase_datum.supplier_id ||= @@purchase_datum_supplier_id    #200626
         
         ##test
         #@@supplier_material  = @@purchase_unit_prices.where(:supplier_id => @@purchase_datum_supplier_id).
         #    where("supplier_id is NOT NULL").map{|x| [x.supplier_material_code, x.material_id]}
         ##
         @purchase_datum.notes ||= @@purchase_datum_notes
         @purchase_datum.division_id ||= @@purchase_datum_division_id
         @purchase_datum.inventory_division_id ||= @@purchase_datum_inventory_division_id
         @purchase_datum.unit_price_not_update_flag ||= @@purchase_datum_unit_price_not_update_flag
         
         ####@purchase_unit_prices = PurchaseUnitPrice.all
         
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
    #
    #del200626
    #@purchase_unit_prices = PurchaseUnitPrice.where(["supplier_id = ? and material_id = ?", @purchase_datum.supplier_id, @purchase_datum.material_id])
    @material_masters = MaterialMaster.where(["id = ?", @purchase_datum.material_id]).pluck(:list_price)
	@maker_masters = MakerMaster.where(["id = ?", @purchase_datum.material_id])
	#
    
    #ここで資材マスターもセットしておく(動作軽減のため)
    #@@material_masters = MaterialMaster.all
    
    
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
	
    
    #upd180627
    #資材マスターの分類を更新
    update_material_category
    
    #add190124
    #外注の場合に請求用の外注費をセット
    outsourcing_invoice_flag = false
    if params[:purchase_datum][:outsourcing_invoice_flag] == "1"
      outsourcing_invoice_flag = true
      @ajax_flag = false
      set_default_outsourcing_data  #外注費データの初期値をセット
    end
        
    respond_to do |format|
      
      #外注請求のチェック有りの場合は、ヴァリデーションを無効にする
      save_check = false
      if outsourcing_invoice_flag == false
        save_check = @purchase_datum.save
      else
        save_check = @purchase_datum.save!(:validate => false)
      end
      #
      
	  #if @purchase_datum.save
      if save_check
        #add190125
        #外注用の請求書発行
        print_outsourcing_invoice(format)
  
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


   #資材マスターの分類を更新
   update_material_category
   
   #add190124
   #外注の場合に請求用の外注費をセット
   outsourcing_invoice_flag = false
   if params[:purchase_datum][:outsourcing_invoice_flag] == "1"
     outsourcing_invoice_flag = true
     @ajax_flag = false
     set_default_outsourcing_data  #外注費データの初期値をセット
   end
   
   respond_to do |format|
      update_check = false
      if outsourcing_invoice_flag == false
        
        update_check = @purchase_datum.update(purchase_datum_params)
      else
      #外注請求のチェック有りの場合は、ヴァリデーションを無効にする
        @purchase_datum.assign_attributes(purchase_datum_params)
        update_check = @purchase_datum.save!(:validate => false)
      end
      
      #if @purchase_datum.update(purchase_datum_params)
      if update_check   
        
        #add190125
        #外注用の請求書発行
        print_outsourcing_invoice(format)
        
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
  
  #外注用の請求書発行
  def print_outsourcing_invoice(format)
      
      #グローバルにカレントの仕入データをセット
      $purchase_data_current = @purchase_datum
  
      format.pdf do
        report = OutsourcingInvoicePDF.create @outsourcing_invoice 
        # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data(
          report.generate,
          filename:  "outsourcing_invoice_list.pdf",
          type:        "application/pdf",
          disposition: "inline")
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
  
  #資材マスターの分類を更新
  def update_material_category
    
    if params[:purchase_datum][:MaterialMaster_attributes][:material_category_id].to_i > 0
        if params[:purchase_datum][:material_id].to_i > 1
            #手入力の場合の資材IDは、別ファンクション(add_manual_input_except_unit_price)で更新されている。
            @material = MaterialMaster.find(params[:purchase_datum][:material_id])
        
            #分類を更新
            material_update_params = { material_category_id: params[:purchase_datum][:MaterialMaster_attributes][:material_category_id] }
         
	        @material.update(material_update_params)
        end
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
          
          #資材コード、品名、単位を更新
          #material_update_params = { material_code: params[:purchase_datum][:material_code],
		  #                         material_name: params[:purchase_datum][:material_name],
          #                         unit_id: params[:purchase_datum][:unit_id] }
          
          #upd211222 単位は更新しない(社長の見積注文での入出力に影響するため)
          material_update_params = { material_code: params[:purchase_datum][:material_code],
		                           material_name: params[:purchase_datum][:material_name] }
          
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
      
      #仕入先用CDをセット
	  if params[:purchase_datum][:supplier_material_code].present?
        supplier_masterial_code = params[:purchase_datum][:supplier_material_code]
	  else
        #仕入先品番が未入力の場合は、登録済み品番をそのままセットする
        #supplier_masterial_code = params[:purchase_datum][:material_code]
        supplier_masterial_code = @purchase_unit_prices.supplier_material_code
	  end
      
      #upd200714
      #単位・品番も更新
      purchase_unit_prices_params = {material_id:  params[:purchase_datum][:material_id], supplier_id: params[:purchase_datum][:supplier_id], 
                        supplier_material_code: supplier_masterial_code, 
                        unit_price: params[:purchase_datum][:purchase_unit_price], unit_id: params[:purchase_datum][:unit_id]}
      
      @purchase_unit_prices.update(purchase_unit_prices_params)
    else
    #該当なしの場合は新規追加  add180120
       
       #add201221
       #手入力のものは、別途(add_manual_input_except_unit_price)で登録されるので除く 
       isExcept = false
       if params[:purchase_datum][:material_id] == "1" && 
         params[:purchase_datum][:material_code] != "" && 
         params[:purchase_datum][:material_code] != "＜手入力用＞" &&
         params[:purchase_datum][:material_code] != "-"
         
         isExcept = true
       end
       
      if !isExcept
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
       #add201229 仕入マスターの外注フラグで判定
       sm = SupplierMaster.find(params[:supplier_master_id])
	   outsourcing_flag = sm.outsourcing_flag
       
	   #str = purchase_order_code
	   #if str[0,1] == "M" || str[0,1] == "N" || str[0,1] == "O"
       #upd201229
       if outsourcing_flag == 1
         @outsourcing_flag = "1"
	   end
	   #
	   
	 else
       
       #工事コードのみの場合。
       if params[:construction_id].present?
         #add200716
         #注番もデフォで１をセットしておく(主に出庫の場合で使用)
	     @purchase_order_data = PurchaseOrderDatum.where("id >= ?", 1)
         #
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
            
            #add180726
            if (params[:purchase_datum][:unit_price_not_update_flag] == '0')
              #見積用の定価をセット
              set_material_list_price_quotation
              params[:purchase_datum][:MaterialMaster_attributes][:list_price_quotation] = @@list_price_quotation
            
              #見積用の掛け率をセット
              params[:purchase_datum][:MaterialMaster_attributes][:standard_rate] = set_material_standard_rate
            end
            #
            
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
  
  #add180725
  #見積用の定価を登録する
  def set_material_list_price_quotation
    
    @@list_price_quotation = 0
    
    if params[:purchase_datum][:list_price].to_i > 0
        @@list_price_quotation = params[:purchase_datum][:list_price]
    else
    #定価が0の場合は、単価を登録する
        @@list_price_quotation = params[:purchase_datum][:purchase_unit_price]
    end
    
    
  end
  
  #見積用の掛け率を登録する
  def set_material_standard_rate
    standard_rate = 0
    
    if @@list_price_quotation.to_f > 0
        if params[:purchase_datum][:purchase_unit_price].to_f > 0
            #if params[:purchase_datum][:purchase_unit_price] != @@list_price_quotation  #
           standard_rate = params[:purchase_datum][:purchase_unit_price].to_f / @@list_price_quotation.to_f
            #end
        end
    end
    
    return standard_rate
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
               
               #add180726
               #見積単価
               set_material_list_price_quotation
               material_list_price_quotation = @@list_price_quotation
               
               #見積用の掛け率をセット
               standard_rate = set_material_standard_rate
               #
               
               #upd180403 単位もセットする
		       material_master_params = {material_code: params[:purchase_datum][:material_code], 
		                             material_name: params[:purchase_datum][:material_name], 
                                     maker_id: params[:purchase_datum][:maker_id],
                                     list_price: params[:purchase_datum][:list_price],
                                     list_price_quotation: material_list_price_quotation,
                                     standard_rate: standard_rate,
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
       
           #add180726
           #見積単価
           set_material_list_price_quotation
           material_list_price_quotation = @@list_price_quotation
           
           #見積用の掛け率をセット
           standard_rate = set_material_standard_rate
           #
       
		   material_master_params = {material_code: params[:purchase_datum][:material_code], 
		                             material_name: params[:purchase_datum][:material_name], 
                                     maker_id: params[:purchase_datum][:maker_id],
									 list_price: params[:purchase_datum][:list_price],
                                     list_price_quotation: material_list_price_quotation,
                                     standard_rate: standard_rate,
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
  
  #外注費データの初期値をセットする
  def set_default_outsourcing_data
    
    @purchase_data = nil
    if @ajax_flag == true
      @purchase_data = PurchaseDatum.find(params[:id])
    end
    
    #労務費をセット
    #仕入先のパラメータがある場合のみ
    construction_labor_cost = 0
    
    #あとで社員マスターとリンクさせる。ひとまず固定で。
    staff_id = 0
    @construction_datum_id = 0
    purchase_amount = 0
    @purchase_date = Date.today
    
    if @ajax_flag == false   #フォーム側から呼んだ場合
        supplier_id = params[:purchase_datum][:supplier_id].to_i
        @construction_datum_id = params[:purchase_datum][:construction_datum_id]
        purchase_amount = params[:purchase_datum][:purchase_amount].to_i
        @purchase_date = params[:purchase_datum][:purchase_date].to_date
    else  #リストビュー側から呼んだ場合
        supplier_id = @purchase_data.supplier_id
        @construction_datum_id = @purchase_data.construction_datum_id
        purchase_amount = @purchase_data.purchase_amount
        @purchase_date = @purchase_data.purchase_date
    end
    
    case supplier_id
    when 37  #村山電気
      staff_id = 3
    when 31  #須戸
      staff_id = 6
    when 39  #小柳
      staff_id = 5
    else
    end
    #
    
    #請求書コードを取得
    invoice_code = set_invoice_code
    
    #労務費を取得
    construction_labor_cost = ConstructionDailyReport.where(:construction_datum_id => 
         @construction_datum_id).where(:staff_id => staff_id).sum(:labor_cost)
    
    #作業開始日を取得
    working_start_date = ConstructionDailyReport.where(:construction_datum_id => 
         @construction_datum_id).where(:staff_id => staff_id).minimum(:working_date)
    #作業終了日を取得
    working_end_date = ConstructionDailyReport.where(:construction_datum_id => 
         @construction_datum_id).where(:staff_id => staff_id).maximum(:working_date)
    
    #binding.pry
    
    #仕入金額をセット(外注労務費の、調整額とみなす)
    billing_amount = 0
    if purchase_amount > 0
      billing_amount = purchase_amount
    else
    #未入力なら、労務費をセットする
      billing_amount = construction_labor_cost
    end
    #purchase_amount = PurchaseDatum.where(:construction_datum_id => params[:purchase_datum][:construction_datum_id]).sum(:purchase_amount)
    #実行金額をセット(不要なので保留・・・)
	#execution_amount = construction_labor_cost + purchase_amount
    
        
    #得意先から締め日・支払日を算出
    get_customer_date_info
    
    outsourcing_cost = OutsourcingCost.where(:construction_datum_id => @construction_datum_id).
                           where(:staff_id => staff_id).first
    
    #@purchase_date.strftime("%Y%m%d")
    
    if outsourcing_cost.nil?
    #新規登録
      outsourcing_params = {invoice_code: invoice_code, construction_datum_id: @construction_datum_id, staff_id: staff_id, 
                            labor_cost: construction_labor_cost, billing_amount: billing_amount, closing_date: @closing_date, 
                            payment_due_date: @payment_due_date, working_start_date: working_start_date, 
                            working_end_date: working_end_date}
      outsourcing_cost = OutsourcingCost.create(outsourcing_params)
    else
    #更新
      outsourcing_params = {labor_cost: construction_labor_cost, billing_amount: billing_amount, closing_date: @closing_date, 
                            payment_due_date: @payment_due_date, working_start_date: working_start_date, 
                            working_end_date: working_end_date}
                            
      outsourcing_cost.update(outsourcing_params)
    end
    #@construction_costs[0].execution_amount = execution_amount
    #end
	
  end
  
  #外注費データの初期値をセットする(ajax)
  def set_ajax_outsourcing_default_data
    
    @ajax_flag = true
     
    #binding.pry
     
    set_default_outsourcing_data
   
  end
  
  #外注用の請求ナンバーを作成
  def set_invoice_code
    
    purchaseDate = @purchase_date.strftime("%Y%m%d")
    search_date = nil
    
    for i in 1..99 do
      num = "%02d" % i
      search_date = purchaseDate + num
      outsourcing_cost = OutsourcingCost.where(:invoice_code => search_date).first
      if outsourcing_cost.nil?
        break
      end
    end
    
    return search_date
    
  end
  
  
  #得意先から締め日・支払日を算出
  #未使用(200131)
  def get_customer_date_info
    
    require "date"
    
    #construction = ConstructionDatum.find(params[:purchase_datum][:construction_datum_id])
    construction = ConstructionDatum.find(@construction_datum_id)
    
    customer = nil
    if construction.present?
      customer = CustomerMaster.find(construction.customer_id)
    end
    
    if customer.present?
        @closing_date = nil
        @payment_due_date = nil
    
        #締め日算出
        if customer.closing_date_division == 1
        #月末の場合
          #d = params[:purchase_datum][:purchase_date]
          d = @purchase_date
          @closing_date = Date.new(d.year, d.month, -1)
        else
        #日付指定の場合
          #d = params[:purchase_datum][:purchase_date].to_date
          d = @purchase_date
          if Date.valid_date?(d.year, d.month, customer.closing_date)
            @closing_date = Date.new(d.year, d.month, customer.closing_date)
          end
        end
        
        #支払日算出
        #d = params[:purchase_datum][:purchase_date].to_date
        d = @purchase_date
        if customer.due_date.present?
          if Date.valid_date?(d.year, d.month, customer.due_date)
            d2 = Date.new(d.year, d.month, customer.due_date)
            addMonth = customer.due_date_division
            @payment_due_date = d2 >> addMonth
          end
        end
        
    end
    
  end
  
  #####
  
  # ajax
  
  #add190124
  #外注の場合に、労務費をセットする
  def get_labor_cost
    
    #あとで社員マスターとリンクさせる。ひとまず固定で。
    staff_id = 0
    supplier_id = params[:supplier_id].to_i
    case supplier_id
    when 37  #村山電気
      staff_id = 3
    when 31  #須戸
      staff_id = 6
    when 39  #小柳
    else
      staff_id = 5
    end
    #
  
  
    #労務費をそのままセット
      @purchase_unit_price = ConstructionDailyReport.where(:construction_datum_id => 
         params[:construction_datum_id]).where(:staff_id => staff_id).sum(:labor_cost)
  end
  #
  
  #検索クッキーをクリアする
  def clear_cookies
    
    #add180929
    #特定の検索クッキーを消去
    cookie_clear(cookies, "nothing") #２番目のパラメータは、cookieから削除したくないパラメータ名
    
    @@count = 0
    @@clear = true
    
    
    respond_to do |format|
      
      format.js {render inline: "location.reload();" }
      
      #redirect_to :back
      #format.html {redirect_to purchase_data_path( :construction_id => params[:construction_id], 
      #   :purchase_order_id => params[:purchase_order_id], :supplier_master_id => params[:supplier_master_id],
      #   :move_flag => params[:move_flag])}
    end
   
    #
  end
  
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

  
  #得意先別の品番を絞り込むajax
  #200626
  #処理落ちがひどいので、アクセスしないようにする
  def supplier_item_select
    
    #if @@supplier_material.present?
      #@supplier_material  = @@supplier_material
    #@supplier_material  = PurchaseUnitPrice.where(:supplier_id => params[:supplier_id]).where("supplier_id is NOT NULL").pluck("supplier_material_code, material_id")
    #else
    
    if @@purchase_datum_supplier_id.nil?   #新規データで引き継いでる場合を除く(処理落ちする)
      
      @supplier_material  = PurchaseUnitPrice.where(:supplier_id => params[:supplier_id]).
             where("supplier_id is NOT NULL").pluck("supplier_material_code, material_id")
      
      #binding.pry
      #@supplier_material  = @@purchase_unit_prices.where(:supplier_id => params[:supplier_id]).
      #       where("supplier_id is NOT NULL").map{|x| [x.supplier_material_code, x.material_id]}
    end
    
    #add180514
    #資材マスターからも取得する
    if @supplier_material.present?
      #restore200626
    #  @supplier_material += MaterialMaster.all.pluck("material_code", "id")
       #@supplier_material += @@material_masters.all.map{|x| [x.material_code, x.id]}
    end
    
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
  
  #add180627
  #資材分類をセット
  def material_category_select
     
     @material_categories = MaterialMaster.with_category.where(:id => params[:material_id]).
           where("material_masters.id is NOT NULL").pluck("material_categories.id").flatten.join(",")
  end
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_datum
      @purchase_datum = PurchaseDatum.find(params[:id])
      
    end
	
    #add180627
    #def set_material
    ##  #ここで資材マスターもセットしておく(動作軽減のため)
    #  @@material_masters = MaterialMaster.all
    #end
    #add200626
    def set_purchase_unit_price
      #ここで資材マスターもセットしておく(動作軽減のため)
      @@purchase_unit_prices = PurchaseUnitPrice.all
    end
    
	# Never trust parameters from the scary internet, only allow the white list through.
    def purchase_datum_params
      params.require(:purchase_datum).permit(:purchase_date, :slip_code, :purchase_order_datum_id, :construction_datum_id, 
                     :material_id, :material_code, :material_name, :maker_id, :maker_name, :quantity, :quantity2, :unit_id, :purchase_unit_price, :purchase_unit_price2,
                     :purchase_amount, :list_price, :division_id, :supplier_id, :inventory_division_id, :unit_price_not_update_flag, :outsourcing_invoice_flag, 
                     :notes, :purchase_header_id )
    end
    
    def purchase_unit_prices_params
         params.require(:purchase_datum).permit(PurchaseUnitPrice_attributes: [:material_id, :supplier_id, :unit_price])
    end

    def material_masters_params
         params.require(:purchase_datum).permit(MaterialMaster_attributes: [:id,  :last_unit_price, :last_unit_price_update_at, 
                :list_price, :list_price_quotation, :standard_rate, :maker_id])
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
