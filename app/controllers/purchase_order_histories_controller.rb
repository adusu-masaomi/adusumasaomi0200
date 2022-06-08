class PurchaseOrderHistoriesController < ApplicationController
  #before_action :set_purchase_order_history, only: [:show, :edit, :update, :destroy]
  before_action :set_purchase_order_history, only: [:show, :update, :destroy]
  
  #サブフォームの描写速度を上げるため、メモリへ貯める
  before_action :set_masters
  
  # GET /purchase_order_histories
  # GET /purchase_order_histories.json
  def index
    #フォーム連番用
    $seq  = 0        #フォーム用(追加時)
    $seq_exists = 0  #フォーム用
    $seq_max = 0  #最大値取得用
  
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
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    ###

    @purchase_order_data  = @q.result(distinct: true)
    @purchase_order_data  = @purchase_order_data.page(params[:page])
    
    #del210827 ここは通らない???
    #データ呼び出し用変数
    #$purchase_order_history = nil
    #$purchase_order_date =  nil
    #$supplier_master_id =  nil
    
    #臨時FAX用
    #binding.pry
    
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
        if temp_id.present?
          @tmp_purchase_order_history = PurchaseOrderHistory.find(temp_id)
        else
          @tmp_purchase_order_history = nil
        end 
        #グローバルを適応するのはあくまでも検索時のみとしたいための処理
        if @tmp_purchase_order_history.nil? ||
          @tmp_purchase_order_history.purchase_order_datum_id != $purchase_order_datum_id then
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
 
  def index3
  #add220107
  #注文明細用
    
    #binding.pry
    
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)  	
    
    #if construction_datum_id.present?
    #他で使えそうなので消さないこと。(ネストモデルの呼び出し)
    #  @orders = Order.joins({:purchase_order_history => :purchase_order_datum}).where("purchase_order_data.construction_datum_id = ?", 
    #                               construction_datum_id)
    #end
    
    construction_datum_id = params[:construction_id]
    
    case params[:move_flag] 
      when "1"
        #工事一覧画面から遷移した場合
        #construction_datum_id = params[:construction_id]
        #注文No,仕入先もセット
        purchase_order_datum_id = params[:purchase_order_datum_id]
        supplier_master_id = params[:supplier_master_id]
        
        #binding.pry
        
        if params[:q].present?
          params[:q][:purchase_order_history_purchase_order_datum_construction_datum_id_eq] = construction_datum_id
          query = params[:q]
        else
        #前画面からの初期値をセットする
          query = {"purchase_order_history_purchase_order_datum_construction_datum_id_eq"=> construction_datum_id,
                   "purchase_order_history_purchase_order_datum_id_eq" => purchase_order_datum_id, 
                   "purchase_order_history_purchase_order_datum_supplier_master_id_eq" => supplier_master_id }
        end
      else
        #明細画面で検索かけた場合
        if construction_datum_id.nil?
          if params[:q].present? && params[:q][:purchase_order_history_purchase_order_datum_construction_datum_id_eq].present?
            construction_datum_id = params[:q][:purchase_order_history_purchase_order_datum_construction_datum_id_eq]
            #画面遷移用にセット
            params[:construction_id] = params[:q][:purchase_order_history_purchase_order_datum_construction_datum_id_eq]
          end
        end
    end
    
    #ransack保持用コード
    if query.nil?
      query = params[:q]
    end
    
    @q = Order.ransack(query)
    
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
    
    #一覧ヘッダ表示用
    @construction_name = ""
    if construction_datum_id.present?
      construction = ConstructionDatum.find(construction_datum_id)
      if construction.present?
        @construction_name = construction.construction_name
      end
    end
    @purchase_order_code = params[:purchase_order_code]
    @supplier_name = params[:supplier_name]
	  #
    
    #検索用
    @purchase_order_datum = PurchaseOrderDatum.where(construction_datum_id: construction_datum_id)
    @supplier = SupplierMaster.joins(:purchase_order_data).where('purchase_order_data.construction_datum_id = ?', construction_datum_id)
    #
    
    @orders  = @q.result(distinct: true)
    @orders  = @orders.page(params[:page])
    
    #global set
	  $orders = @orders
    
	  #PDF用
    #工事コード、工事名、得意先名
    if construction.present?
      if params[:format].present? && params[:format] == "pdf"
        $customer_name_for_detail_pdf = construction.CustomerMaster.customer_name
        $construction_code_for_detail_pdf = construction.construction_code
        $construction_name_for_detail_pdf = construction.construction_name
      end 
    end
    #
    
    respond_to do |format|
	    
      format.html
	    #pdf
	    format.pdf do
        report = OrderDetailListPDF.create @order_detail_list 
        # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data(
          report.generate,
          filename:  "order_detail_list.pdf",
          type:        "application/pdf",
          disposition: "inline")
      end
      
      #納品フラグ全チェック/解除処理
      if params[:delivery].present?
        all_check_delivery(params[:delivery])
        format.js {render inline: "location.reload();" }
      end
      #
    end
    
    
    
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
  
    #add210521
    #新しいデータの場合は、納品場所を初期値としてセット  
    #-->  ここ(new)は通らない????
    #納品場所が画面で指定されていたらセット(未登録の場合)
    if $delivery_place_flag.present?
      if @purchase_order_history.delivery_place_flag.nil?
        @purchase_order_history.delivery_place_flag = $delivery_place_flag
      end
    end
    #
    
    #連番の最大値を取る(フォーム用)
    get_max_seq
  
    #工事画面からのパラメータ保管
    #@construction_id = params[:construction_id]
    #@move_flag = params[:construction_id]
    #
  end

  # GET /purchase_order_histories/1/edit
  def edit
    
    $quantity_nothing = false
    
    set_edit_params
  
    #納品場所が画面で指定されていたらセット(未登録の場合)
    if $delivery_place_flag.present?
      if @purchase_order_history.delivery_place_flag.nil?
        @purchase_order_history.delivery_place_flag = $delivery_place_flag
      end
    end
    #
    
    #add210707
    #担当emailの初期値をセット
    set_email_default
    
    #連番の最大値を取る(フォーム用)
    get_max_seq
    
    
    ##
    #ここは直で仕入先ID取るべきかも?
    @supplier_responsible = SupplierResponsible.where(:supplier_master_id => 
               @purchase_order_history.purchase_order_datum.supplier_master.id)
    #binding.pry
 
  end

  def get_max_seq
        
    @details = nil
    if @purchase_order_history.orders.present?
      
      @details = @purchase_order_history.orders
    end
    
    if  @details.present?
      if @details.maximum(:sequential_id).present?
        $seq_exists = @details.maximum(:sequential_id)
        $seq_max = $seq_exists
		  end
      #SEQが逆になっているのでみやすいよう再び逆にする
      #reverse_seq
    end
    ##
  
  end

  def set_edit_params
    #
    #画面の連番用
    #@seq = 0
    
    flag_nil = false

    if $purchase_order_history.nil?
      flag_nil = true
    else
      if $purchase_order_history .purchase_order_datum_id != params[:id].to_i
        flag_nil = true
      end
    end
    
    #ここでは例外的に、newをする
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
      if @purchase_order_history.supplier_master_id.blank?   #addd170914
        if $supplier_master_id.present?
          @purchase_order_history.supplier_master_id = $supplier_master_id
        end
      end
      #リロード用（注文日をセット）
      if $purchase_order_date.present?
        @purchase_order_history.purchase_order_date = $purchase_order_date
      end
      #add170721
      @supplier_master = SupplierMaster.find(@purchase_order_data.supplier_master_id)
    else
      
      @purchase_order_history = $purchase_order_history 
      #@purchase_order_history = @purchase_order_history_saved  
        
		  #add170721
      @purchase_order_data  = PurchaseOrderDatum.find($purchase_order_history.purchase_order_datum_id)
      @supplier_master = SupplierMaster.find($purchase_order_history.supplier_master_id)
    
      #add170719 呼び出さない不具合対応
      #@purchase_order_history.orders.build
      #@purchase_order_history.build_orders
      #@purchase_order_history.assign_attributes(purchase_order_history_params)
    
    end
    
    #add170721
    if @purchase_order_history.present?
    
      #kaminariは更新でうまくいかないので一旦保留・・・
      #@orders = Order.where( purchase_order_history_id: @purchase_order_history.id)
      #@orders  = @orders.page(params[:page])
    
      #うまく行かないので（データが被ってしまう）一旦保留
      ##
      #連番を割り振る処理
      @orders = nil
      if @purchase_order_history.orders.present?
        @orders = @purchase_order_history.orders
      end
    
      if  @orders.present?
        if @orders.maximum(:sequential_id).present?
          $seq = @orders.maximum(:sequential_id)
        end
        #SEQが逆になっているのでみやすいよう再び逆にする
        reverse_seq
      end
      ##
    
    #
    end
	
	
    if @purchase_order_history.supplier_master.present?
      @purchase_order_history.email_responsible = @purchase_order_history.supplier_master.email1
    end

    #add170721
    if @purchase_order_data.present?
      @construction_data = ConstructionDatum.find(@purchase_order_data.construction_datum_id)
    end

  end

  #連番が登録と逆順になっているので、みやすいように正しい順に（逆に）する
  def reverse_seq
  
    if $max.present?
      
      max = $seq 
      reverse_num = max 
    
      for num in 0..max do
	    
        if @orders.present?
          if @orders[num].present?
            @orders[num][:sequential_id] = reverse_num
            reverse_num -= 1
          end
        end
      end
    
    end
  end
  
  #add210707
  #担当emailの初期値をセット
  def set_email_default
    
    @supplier_responsibles = nil
    @supplier_responsible_emails = nil
    
    if @purchase_order_history.purchase_order_datum.supplier_responsible_id.present?
      
      @supplier_responsibles = 
            SupplierResponsible.where(:id => params[:supplier_responsible_id]).pluck("responsible_email, id")
    end     
  end
  
   #既存のデータを取得する(日付・仕入先指定後。)
  def get_data
    #
    $purchase_order_history = PurchaseOrderHistory.find_by(purchase_order_datum_id: params[:purchase_order_datum_id], 
    purchase_order_date: params[:purchase_order_date] , supplier_master_id: params[:supplier_master_id])

    $delivery_place_flag = nil
    
    if $purchase_order_history.nil?
      $purchase_order_date = params[:purchase_order_date]
      $supplier_master_id = params[:supplier_master_id]
      $delivery_place_flag = params[:delivery_place_flag]
    else 
      $purchase_order_date = nil
      $supplier_master_id = nil
    end
    
  end

  # POST /purchase_order_histories
  # POST /purchase_order_histories.json
  def create
  
    $id = params[:purchase_order_history][:purchase_order_datum_id]
    
    @purchase_order_history = PurchaseOrderHistory.new(purchase_order_history_params)

    #パラーメータ補完する
    set_params_complement
    
    @purchase_order_history = PurchaseOrderHistory.new(purchase_order_history_params)
  
    #メール送信済みフラグをセット
    #set_mail_sent_flag
    
    respond_to do |format|
      #if PurchaseOrderHistory.create(purchase_order_history_params)
      if @purchase_order_history.save!(:validate => false)   
	    
        #臨時FAX用
        set_order_data_fax(format)
        
        #注文書発行
        set_purchase_order(format)
        
        #メール送信する
        send_email
        
        #メール送信の場合(add220601)
        if params[:purchase_order_history][:sent_flag] == "1" 
          #format.js {render inline: "location.reload();" }
          redirect_to request.referer, alert: "Successfully sending message"  #ここでalertを適当に入れないと下部のflashメッセージが出ない。
          flash[:notice] = "メールを送信しました。"
          
          break
        end
        
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
      
    #del170724 
    #すでに登録していた注文データは一旦抹消する。
    destroy_before_update
    
    #パラーメータ補完する
    set_params_complement
	  
	  #170911 moved
	  #メール送信済みフラグをセット
	  #set_mail_sent_flag
	  
    ##test now
    #if params[:purchase_order_history][:sent_flag] == "1"
    #  format.html
    #end
    
    respond_to do |format|
        
      #format.html
      
      if @purchase_order_history.update(purchase_order_history_params)
          
        #臨時FAX用
        #save_only_flag = true
        set_order_data_fax(format)
        
        #注文書発行
        set_purchase_order(format)
        
		    #メール送信する
        send_email
        
         #メール送信の場合(add220601)
        if params[:purchase_order_history][:sent_flag] == "1"
          
          #redirect_to purchase_order_data_path(
          #         :construction_id => params[:construction_id] , :move_flag => params[:move_flag] ) and return
          
          redirect_to request.referer, alert: "Successfully sending message"  #ここでalertを適当に入れないと下部のflashメッセージが出ない。
          flash[:notice] = "メールを送信しました。"
          
          break
        end
          
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
  
  def set_params_complement
    
    i = 0
   
    #仕入先を画面で変更している場合があるので、その場合に差し替える
    #add170907
    if @purchase_order_history.supplier_master_id != params[:purchase_order_history][:supplier_master_id]
      @purchase_order_history.supplier_master_id = params[:purchase_order_history][:supplier_master_id]
    
      #注文データの仕入先も更新する
      purchase_order_data = PurchaseOrderDatum.find(@purchase_order_history.purchase_order_datum_id)
      if purchase_order_data.present?
        purchase_order_data_params = {supplier_master_id: params[:purchase_order_history][:supplier_master_id]}
        purchase_order_data.update(purchase_order_data_params)
      end
    end
    ##
  
    #del210712
    #仕入先の担当者・メアドも変更されていたらマスター反映させる
    #if @purchase_order_history.supplier_master.present?
    #  if @purchase_order_history.supplier_master.email1 != params[:purchase_order_history][:email_responsible]   ||
    #   @purchase_order_history.supplier_master.responsible1 != params[:purchase_order_history][:responsible]
    #   supplier_master = SupplierMaster.find(@purchase_order_history.supplier_master_id)
    #   if supplier_master.present?
    #      supplier_master_params = {email1: params[:purchase_order_history][:email_responsible], 
    #                                 responsible1: params[:purchase_order_history][:responsible]}
    #     supplier_master.update(supplier_master_params)
    #   end
    #  end
    #end
	  #
	
    if params[:purchase_order_history][:orders_attributes].present?
	
	    params[:purchase_order_history][:orders_attributes].values.each do |item|
      
        if  item[:quantity].to_i == 0
          item[:quantity] = item[:quantity].tr('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z')
        end
        item[:quantity] = item[:quantity].to_i
        @maker_master = MakerMaster.where(:id => item[:maker_id]).first
          
        #メーカーを手入力した場合の新規登録
        if @maker_master.nil?
          #名称にID(カテゴリー名が入ってくる--やや強引？)をセット。
          maker_params = {maker_name: item[:maker_id] }
          @maker_master = MakerMaster.new(maker_params)
          @maker_master.save!(:validate => false)
                     
          if @maker_master.present?
            #メーカーIDを更新（パラメータ）
            item[:maker_id] = @maker_master.id
          end
        end
        ##
      
        #分類手入力の場合の新規登録
        #add201212
        @material_category = MaterialCategory.where(:id => item[:material_category_id]).first
      
        if @material_category.nil?
          #名称にID(カテゴリー名が入ってくる--やや強引？)をセット。
          material_category_params = {name: item[:material_category_id] }
          @material_category = MaterialCategory.new(material_category_params)
          @material_category.save!(:validate => false)
                     
          if @material_category.present?
            #メーカーIDを更新（パラメータ）
            item[:material_category_id] = @material_category.id
          end
        end
        ###
                    
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
          
          if item[:list_price].nil?   #add211222
            if @material_master.list_price != 0  #upd170310
			        #資材マスターの定価をセット
			        #(マスター側未登録を考慮。但しアプデは考慮していない）
              item[:list_price] = @material_master.list_price
			      end
			    end
          #if (item[:material_name] != @material_master.material_name) || 
          #   (item[:maker_id] != @material_master.maker_id)
              
          if (item[:material_name] != @material_master.material_name) || 
               (item[:maker_id] != @material_master.maker_id) ||
               (item[:list_price] != @material_master.list_price) ||
               (item[:material_category_id] != @material_master.material_category_id) || 
               (item[:unit_master_id] != @material_master.unit_id )
                 
			      #品名・メーカーを登録or変更した場合は、商品マスターへ反映させる。
            #upd211222 定価・単位も追加
			      materials = MaterialMaster.where(:id => @material_master.id).first
			      if materials.present?
                  materials.update_attributes!(:material_name => item[:material_name], :maker_id => item[:maker_id], 
                                               :list_price => item[:list_price], 
                                               :notes => item[:notes], :material_category_id => item[:material_category_id],
                                               :unit_id => item[:unit_master_id])
            end 
			    end
			  
			    #仕入単価マスターの単位も更新する
			    #purchase_unit_price = PurchaseUnitPrice.where(["supplier_id = ? and material_id = ?", 
              #   params[:purchase_order_history][:supplier_master_id], params[:material_id][i] ]).first
			  
			    purchase_unit_price = PurchaseUnitPrice.where(["supplier_id = ? and material_id = ?", 
                   params[:purchase_order_history][:supplier_master_id], item[:material_id] ]).first 
			  
			    if item[:unit_master_id].present?
			      unit_price = 0
                
            if purchase_unit_price.present? && purchase_unit_price.unit_price.present?
              unit_price = purchase_unit_price.unit_price
            end
                
            if item[:order_unit_price].present?
              unit_price = item[:order_unit_price].to_f
            end
          
            #upd210527 単価も更新
            purchase_unit_price_params = {material_id: item[:material_id], supplier_id: params[:purchase_order_history][:supplier_master_id], 
				                               unit_id: item[:unit_master_id], unit_price: unit_price}
                
				    if purchase_unit_price.present?
				      purchase_unit_price.update(purchase_unit_price_params)
				    else
				      #新規登録も考慮
			        purchase_unit_price = PurchaseUnitPrice.create(purchase_unit_price_params)
				    end
			    end
		
		    else
		      #手入力した場合も、商品＆単価マスターへ新規登録する
		      if item[:_destroy] != "1"
			  
			      if item[:material_code] != ""     #商品CD有りのものだけ登録する(バリデーションで引っかかるため)
			    
				      @material_master = MaterialMaster.find_by(material_code: item[:material_code])
			        #商品マスターへセット(商品コード存在しない場合)
			        if @material_master.nil?
				        #material_master_params = {material_code: item[:material_code], material_name: item[:material_name], 
                #                      maker_id: item[:maker_id], list_price: item[:list_price], notes: item[:notes] }
                  
                #upd211222
                #単位追加
                material_master_params = {material_code: item[:material_code], material_name: item[:material_name], 
                                      maker_id: item[:maker_id], list_price: item[:list_price], notes: item[:notes], 
                                      material_category_id: item[:material_category_id],
                                      unit_id: item[:unit_master_id] }
                  
                @material_master = MaterialMaster.create(material_master_params)
                #生成された商品ＩＤをorderへセットする。
                if @material_master.present?
                  item[:material_id] = @material_master.id
                end
                  
              end

              #仕入先単価マスターへも登録。
              @material_master = MaterialMaster.find_by(material_code: item[:material_code])
              if @material_master.present?
                material_id = @material_master.id
                supplier_id = params[:purchase_order_history][:supplier_master_id]
  
                #supplier_material_code = params[:material_code][i]
                supplier_material_code = item[:material_code]
                  
                #if supplier_id.present? && ( supplier_id.to_i == $SUPPLIER_MASER_ID_OKADA_DENKI_SANGYO )
                if supplier_id.present? && ( supplier_id.to_i == $SUPPLIER_MASER_ID_OKADA_DENKI_SANGYO  || 
                                               supplier_id.to_i == $SUPPLIER_MASER_ID_OST)
				          #岡田・オストの場合のみ、品番のハイフンは抹消する
				      
					        no_hyphen_code = supplier_material_code.delete('-')  
					  
                  if no_hyphen_code.present?
                    supplier_material_code = no_hyphen_code
                  end
          
				        end
				  
                #add210527 単価も更新
                unit_price = 0
                if item[:order_unit_price].present?
                  unit_price = item[:order_unit_price].to_f
                end
                #
                  
                purchase_unit_price_params = {material_id: material_id, supplier_id: supplier_id, 
                                      supplier_material_code: supplier_material_code, unit_price: 0 ,
                                      unit_id: item[:unit_master_id], unit_price: unit_price}
                @purchase_unit_prices = PurchaseUnitPrice.create(purchase_unit_price_params)
                
              end  #@material_master.present?
        
            end  #item[:material_code] != ""
        
          end  #item[:_destroy] != "1"
      
        end #id != 1 then
		  
		    i = i + 1
		   
		  end #params[:purchase_order_history][:orders_attributes].values.each do |item|

    end  #params[:purchase_order_history][:orders_attributes].present?
  end  #def end
  
  def send_email
    #メール送信する(メール送信ボタン押した場合)
    if params[:purchase_order_history][:sent_flag] == "1" then
      #set to global
	    $order_parameters = params[:purchase_order_history][:orders_attributes]
      
      #画面のメアドをグローバルへセット
      $email_responsible = params[:purchase_order_history][:email_responsible]
      
      ##
      #upd210712
      #担当者・Emailコンボ化による変更
      @supplier_update_flag = 0  # 1:new  2:upd
      
      #app.contollerで処理
      #担当者/Emailをメール送信用のグローバルへセット・更新フラグをセット
      app_set_responsible(params[:purchase_order_history][:responsible],
                                        params[:purchase_order_history][:email_responsible],
                                        params[:purchase_order_history][:supplier_master_id])
      
      #担当者
      #supplier_responsible = nil
      #if params[:purchase_order_history][:responsible].to_i > 0
      #  #担当者選択した場合
      #  supplier_responsible = SupplierResponsible.where(id: params[:purchase_order_history][:responsible]).first
      #  if supplier_responsible.present?
      #    #担当者をセット
      #    $responsible = supplier_responsible.responsible_name
      #    #担当Emailをセット
      #    $email_responsible = supplier_responsible.responsible_email
      #    if (params[:purchase_order_history][:email_responsible] != 
      #      supplier_responsible.responsible_email)
      #      @supplier_update_flag = 2
      #      #メアドのみ新規の場合
      #      if params[:purchase_order_history][:email_responsible].to_i == 0
      #        $email_responsible = params[:purchase_order_history][:email_responsible]
      #      else
      #        #メアドが別IDのものの場合(あり得る？？)
      #        supplier_responsible_other = SupplierResponsible.
      #              where(id: params[:purchase_order_history][:email_responsible]).first
      #        if supplier_responsible_other.present?
      #          $email_responsible = supplier_responsible_other.responsible_email
      #        end
      #      end
      #    end
      #  end
      #else
      #  #担当者手入力の場合
      #  @supplier_update_flag = 1
      #  #担当者をセット
      #  $responsible = params[:purchase_order_history][:responsible]
      #  $email_responsible = params[:purchase_order_history][:email_responsible]
      #  #メアドがIDの場合(違う名前で同一Emailの場合)
      #  if params[:purchase_order_history][:email_responsible].to_i > 0
      #    supplier_responsible = SupplierResponsible.where(id: 
      #                                  params[:purchase_order_history][:email_responsible]).first
      #    if supplier_responsible.present?
      #      $email_responsible = supplier_responsible.responsible_email
      #    end
      #  end
      #end
      
      #変更 end
      ##
            
      #CC用に担当者２のアドレスもグローバルへセット
      $email_responsible2 = nil
      if params[:purchase_order_history][:supplier_master_id].present?
        supplier = SupplierMaster.where(id: params[:purchase_order_history][:supplier_master_id]).first
         
        #if supplier.present? && supplier.email2.present?
        #  $email_responsible2 = supplier.email2
        if supplier.present? && supplier.email_cc.present?
          $email_responsible2 = supplier.email_cc
        end
      end
      #add end
      
      ##del later
	    #del210712
      #$responsible = params[:purchase_order_history][:responsible]
      
      PostMailer.send_purchase_order(@purchase_order_history).deliver
      
      #add210712
      #仕入担当者の追加・更新
      #update_responsible
      app_update_responsible(params[:purchase_order_history][:supplier_master_id],
                             params[:purchase_order_history][:responsible],
                             params[:purchase_order_history][:purchase_order_datum_id], 
                             0)
      
	    #メール送信フラグをセット＆データ更新
      set_mail_sent_flag
    end
  end
  
  #レコード毎にメール送信済みフラグをセットする
  def set_mail_sent_flag
  
    if params[:purchase_order_history][:sent_flag] == "1" 
      if params[:purchase_order_history][:orders_attributes].present?
        params[:purchase_order_history][:orders_attributes].values.each do |item|
          item[:mail_sent_flag] = 1
        end
		
        #再度ここで更新をかける(削除後)
        destroy_before_update
        @purchase_order_history.update(purchase_order_history_params)
      end
    end
  end
  
  #仕入担当者の追加・更新
  def update_responsible
    
    #params[:purchase_order_history][:supplier_master_id]
    
    supplier_responsible_params = { supplier_master_id: params[:purchase_order_history][:supplier_master_id],
                                    responsible_name: $responsible,
                                    responsible_email: $email_responsible
                                  }
    
    supplier_responsible_id = 0
    
    case @supplier_update_flag
      when 1  #新規
        supplier_responsible = SupplierResponsible.new(supplier_responsible_params)
        supplier_responsible.save!(:validate => false)
        
        #パラメーターへ再び戻す
        #params[:purchase_order_datum][:supplier_responsible_id] = supplier_responsible.id
        supplier_responsible_id = supplier_responsible.id
      when 2  #更新
        supplier_responsible = SupplierResponsible.where(:id => params[:purchase_order_history][:responsible]).first
        
        if supplier_responsible.present?
          supplier_responsible_id = supplier_responsible.id
          supplier_responsible.update(supplier_responsible_params)
        end
    end
    
    #注文データの担当者もアプデしておく
    if @supplier_update_flag > 0
      purchase_order_data = PurchaseOrderDatum.where(:id => params[:purchase_order_history][:purchase_order_datum_id]).first
      if purchase_order_data.present?
        purchase_order_data_params = { supplier_responsible_id: supplier_responsible_id }
        purchase_order_data.update(purchase_order_data_params)
      end
    end
  end
  
  #注文書の発行
  def set_purchase_order(format)
    
    $attachment = nil
    
    if params[:format] == "pdf"
    #  if params[:print_type] == "purchase_order"
         
        #注文書の発行
        save_only_flag = false
        #global set
        $purchase_order_history = @purchase_order_history 
        
        $mail_flag = 0
        
        #送信済み・削除判定が必要なので現在のパラメータをセット
        $order_parameters = params[:purchase_order_history][:orders_attributes]
        
        
        if params[:purchase_order_history][:sent_flag] != "1" 
          format.pdf do
            report = PurchaseOrderPDF.create @purchase_order
            #report = PurchaseOrderAndEstimatePDF.create @purchase_order
            # ブラウザでPDFを表示する
            # disposition: "inline" によりダウンロードではなく表示させている
            send_data(
              report.generate,
              filename:  "purchase_order.pdf",
              type:        "application/pdf",
              disposition: "inline")
          end
        else
        #メール送信し添付する場合
          
        
          $mail_flag = 1
          #ＰＤＦを作成
          #report = PurchaseOrderAndEstimatePDF.create @purchase_order
          report = PurchaseOrderPDF.create @purchase_order
            
          # PDFファイルのバイナリデータを生成する
          $attachment = report.generate
            
          # ダウンロードは必要なし。又ここでsend_dataするとredirectができない為、抹消
          #send_data(
          #  @file,
          #  filename:  "purchase_order.pdf",
          #  type:        "application/pdf",
          #  disposition: "attachment")
          
        end
        #pdf
	      
        ##########
    #  end
    end
  end
  
  def set_order_data_fax(format)
  #def print_fax_or_puchase_order(format)
    
    if params[:format] == "pdf"
      #FAXの場合
      if params[:print_type] == "fax"
        #ｆａｘ用紙の発行
        save_only_flag = false
        #global set
        $purchase_order_history = @purchase_order_history 
        #pdf
	      format.pdf do
          report = OrderFaxPDF.create @order_fax 
          # ブラウザでPDFを表示する
          # disposition: "inline" によりダウンロードではなく表示させている
          send_data(
            report.generate,
            filename:  "order_fax.pdf",
            type:        "application/pdf",
            disposition: "inline")
        end
      #elsif params[:print_type] == "purchase_order"
      #  #注文書の発行
      #  save_only_flag = false
      #  #global set
      #  $purchase_order_history = @purchase_order_history 
      #  $order_parameters = params[:purchase_order_history][:orders_attributes]
      #  #pdf
	    #  format.pdf do
      #    report = PurchaseOrderPDF.create @purchase_order
      #    # ブラウザでPDFを表示する
      #    # disposition: "inline" によりダウンロードではなく表示させている
      #    send_data(
      #      report.generate,
      #      filename:  "purchase_order.pdf",
      #      type:        "application/pdf",
      #      disposition: "inline")
      #  end
      end
    end
    
    ##
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
  
  #納品フラグ全チェック/解除処理
  def all_check_delivery(params)
    if @orders.present?
      @orders.find_each do |order|
        if params == "all_check"
          order.delivery_complete_flag = 1
          order.save
        elsif params == "all_uncheck"
          order.delivery_complete_flag = 0
          order.save
        end
      end
    end
  end
 
  # ajax
  def email_select
     @email_responsible = SupplierMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:email1).flatten.join(" ")
	 #担当者
	 #add170907
	 @responsible = SupplierMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:responsible1).flatten.join(" ")
  end
  
  #商品名などを取得
  def material_select
  
    @material_code = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_code).flatten.join(" ")
    @material_name = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_name).flatten.join(" ")
    @list_price = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:list_price).flatten.join(" ")
    @maker_id = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:maker_id).flatten.join(" ")

    @material_category_id = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_category_id).flatten.join(" ")
     
    #add211222
    #単位はまず商品マスターから取得する(ここは見積・注文時のみ更新)、なければ仕入単価Mより取得
    @unit_id = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:unit_id).flatten.join(" ")

    if @unit_id.blank?  #ここは基本的に起こり得ない
      @unit_id = PurchaseUnitPrice.where(["supplier_id = ? and material_id = ?", 
                 params[:supplier_master_id], params[:id] ]).pluck(:unit_id).flatten.join(" ")
    end
    
    #いずれも該当なければひとまず”個”にする
    if @unit_id.blank?
      @unit_id = "3"
    end
     
     #supplier_master_id
     @order_unit_price = PurchaseUnitPrice.where(:material_id => params[:id], :supplier_id => params[:supplier_master_id]).
                                 where("id is NOT NULL").pluck(:unit_price).flatten.join(" ")
     
  end
  
  #メーカーから該当する商品を取得
  def material_extract
  
     #exist = MaterialMaster.where(:maker_id => params[:maker_id]).where("id is NOT NULL").first
     
     #if exist.present?
       #まず手入力用IDをセット。
       @material_extract = MaterialMaster.where(:id => 1).where("id is NOT NULL").
        pluck("CONCAT(material_masters.material_code, ':' , material_masters.material_name), material_masters.id")
	
	   #次に抽出されたアイテムをセット
	   @material_extract += MaterialMaster.where(:maker_id => params[:maker_id]).where("id is NOT NULL").
        pluck("CONCAT(material_masters.material_code, ':' , material_masters.material_name), material_masters.id")
        
       
       #add190226 
       #商品コードも同様
       @material_extract_category_code = MaterialMaster.where(:id => 1).where("id is NOT NULL").
        pluck("material_masters.material_code, material_masters.material_code")
       @material_extract_category_code += MaterialMaster.where(:maker_id => params[:maker_id]).where("id is NOT NULL").
        pluck("material_masters.material_code, material_masters.material_code")
       #
     #end
	
  end
  #add190226
  #分類から該当する商品を取得
  def material_extract_by_category
  
   
    if !(params[:material_category_id].blank?)
  
       #まず手入力用IDをセット。
       @material_extract_category = MaterialMaster.where(:id => 1).where("id is NOT NULL").
        pluck("CONCAT(material_masters.material_code, ':' , material_masters.material_name), material_masters.id")
	   #次に抽出されたアイテムをセット
	   @material_extract_category += MaterialMaster.where(:material_category_id => params[:material_category_id]).where("id is NOT NULL").
        pluck("CONCAT(material_masters.material_code, ':' , material_masters.material_name), material_masters.id")
    
       #商品コードも同様
       @material_extract_category_code = MaterialMaster.where(:id => 1).where("id is NOT NULL").
        pluck("material_masters.material_code, material_masters.material_code")
       @material_extract_category_code += MaterialMaster.where(:material_category_id => params[:material_category_id]).where("id is NOT NULL").
        pluck("material_masters.material_code, material_masters.material_code")
        
       
    else
      #未選択状態の場合は、全て表示
      @material_extract_category = MaterialMaster.all.
        pluck("CONCAT(material_masters.material_code, ':' , material_masters.material_name), material_masters.id")
      
      #商品コードも同様      
      @material_extract_category_code = MaterialMaster.all.
        pluck("material_masters.material_code, material_masters.material_code")
      
	end
  end
  
  #add170721
  def set_sequence
    if $seq.blank?
      $seq = 0
    end
    $seq += 1
  end
  
  #def get_email
  #  @supplier_responsibles = SupplierResponsible.where(:supplier_master_id => params[:id])
  #end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_order_history
      @purchase_order_history = PurchaseOrderHistory.find(params[:id])

      #@purchase_order_history_saved = nil
    end
 
    #サブフォームの描写速度を上げるため、メモリへ貯める
    def set_masters
      @material_masters = MaterialMaster.all
	  @unit_masters = UnitMaster.all
	  @maker_masters = MakerMaster.all
	  #add190226
      @material_categories = MaterialCategory.all
      
	  #@seq = 0 #画面の連番用
	end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_order_history_params
	  #params.require(:purchase_order_history).permit(:purchase_order_datum_id, :supplier_master_id, :purchase_order_date, :mail_sent_flag, 
	  #                orders_attributes: [:id, :purchase_order_datum_id, :material_id, :material_code, :material_name, :quantity, :unit_master_id, 
      #               :maker_id, :maker_name, :list_price, :mail_sent_flag, :_destroy])
	  #upd170616 メーカー名は抹消
	  params.require(:purchase_order_history).permit(:purchase_order_datum_id, :supplier_master_id, :purchase_order_date, :mail_sent_flag, 
                     :delivery_place_flag, :notes, 
	                  orders_attributes: [:id, :material_id, :material_code, :material_name, :quantity, :unit_master_id, 
                     :maker_id, :list_price, :order_unit_price, :order_price, :material_category_id, :mail_sent_flag, :_destroy])
    end

end
