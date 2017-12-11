class WorkingMiddleItemsController < ApplicationController
  before_action :set_working_middle_item, only: [:show, :edit, :update, :destroy]
  
  before_action :set_move_flag, only: [:new, :edit]
  
  # GET /working_middle_items
  # GET /working_middle_items.json
  def index
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)
   
    
    #@working_middle_items = WorkingMiddleItem.all
	#@q = WorkingMiddleItem.ransack(params[:q])   
    #ransack保持用--上記はこれに置き換える
    @q = WorkingMiddleItem.ransack(query)
	
	#ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
	
	@working_middle_items  = @q.result(distinct: true)
    @working_middle_items  = @working_middle_items.page(params[:page])
	
	$sort = nil
	
	if params["q"].nil?  #upd170714
	  #binding.pry
	  @working_middle_items  = @working_middle_items.order('seq DESC') 
	else
	  if params["q"]["s"].present?
	     if params["q"]["s"] == "seq asc"
		   $sort = "normal"
		 elsif params["q"]["s"] == "seq desc"
		   $sort = "reverse"
		 end
	  end
	  
	  #binding.pry
	end
	
	
	#@working_middle_items = @working_middle_items.order('working_middle_items.position ASC')
  end
  
  #ドラッグ＆ドロップによる並び替え機能(seqをセットする)
  def reorder
    
	if $sort.nil? || $sort == "reverse"  #upd170714
	  row = params[:row].split(",").reverse    #ビューの並びが逆のため、パラメータの配列を逆順でセットさせる。
	elsif $sort == "normal"
	  row = params[:row].split(",")
	end
	
    #row.each_with_index {|row, i| WorkingMiddleItem.update(row, {:seq => i})}
	#upd171122
	row.each_with_index {|row, i| WorkingMiddleItem.update(row, {:seq => params[:category].to_i + i})}
    render :text => "OK"
  end
  
  # GET /working_middle_items/1
  # GET /working_middle_items/1.json
  def show
  end

  # GET /working_middle_items/new
  def new
  
    
    @working_middle_item = WorkingMiddleItem.new
	
	#作成中  171115
	#呼び出した場合
	if $working_middle_item.present?
	  #binding.pry
	
	  @working_middle_item = $working_middle_item
	  
	  $working_middle_item = nil
	end
	
	#労務単価の初期値をセットする
	@working_middle_item.labor_unit_price_standard ||= 11000
	
  end

  # GET /working_middle_items/1/edit
  def edit
    
	
	#労務単価の初期値をセットする
    @working_middle_item.labor_unit_price_standard ||= 11000
  end

  # POST /working_middle_items
  # POST /working_middle_items.json
  def create
    if params[:move_flag].blank?
	#upd171128
	  #マスター画面からの遷移の場合、モーダルのため、別ルーチンにて処理する。
	  create_or_update_modal
	
	else
	  master_insert_flag = false
      #共通マスターへ更新する場合
      if params[:working_middle_item][:master_insert_flag] == "true"
        master_insert_flag = true
      end
      #
	
      respond_to do |format|
	    #品目マスターへの追加・更新
	    create_or_update_material
	    #共通マスターへの登録（ダイアログ=OKの場合)
	    if master_insert_flag == true
		  status = nil
	      action_flag = params[:working_middle_item][:action_flag]
	      if action_flag == "new"
	      #新規の場合
		    @working_middle_item = WorkingMiddleItem.new(working_middle_item_params) 
	        status = @working_middle_item.save
	    
		  elsif action_flag == "edit"
	        #更新の場合
	        if @working_middle_item.present?
	          status = @working_middle_item.update(working_middle_item_params)
	        else
	 	    #該当なしの場合（ボタン誤操作など）は、新規登録する
		      @working_middle_item = WorkingMiddleItem.new(working_middle_item_params) 
	          status = @working_middle_item.save
		    end
	      end
	    else
	      #明細固有マスターへの新規追加(master_insert_flag == false)
          status = create_specific_master
  	    end
	  
	    if status == true
	      #手入力用IDの場合は、単位マスタへも登録する。
	      set_working_unit
	  
	      if master_insert_flag == true   #add171116
	        #ソート用のseqにIDをセットする。
            @working_middle_item.update(seq: @working_middle_item.id, working_unit_id: @working_unit.id)
		  end
		
		  if params[:move_flag].blank?
            format.html { redirect_to @working_middle_item, notice: 'Working middle item was successfully created.' }
            format.json { render :show, status: :created, location: @working_middle_item }
		  else
		  #見積書画面へ戻る！！
		    if params[:move_flag] == "1"
	  	    #見積内訳
               format.html {redirect_to quotation_detail_large_classifications_path(:quotation_header_id => params[:quotation_header_id], 
                :quotation_header_name => params[:quotation_header_name], :move_flag => params[:move_flag])}
		    elsif params[:move_flag] == "2"
		    #見積明細
		       format.html {redirect_to quotation_detail_middle_classifications_path(:quotation_header_id => params[:quotation_header_id], 
                :quotation_header_name => params[:quotation_header_name], :quotation_detail_large_classification_id => params[:quotation_detail_large_classification_id],
                :working_large_item_name => params[:working_large_item_name], :working_large_specification => params[:working_large_specification],
			    :move_flag => params[:move_flag])}
		    elsif params[:move_flag] == "3"
		    #納品内訳
               format.html {redirect_to delivery_slip_detail_large_classifications_path(:delivery_slip_header_id => params[:delivery_slip_header_id], 
                :delivery_slip_header_name => params[:delivery_slip_header_name], :move_flag => params[:move_flag])}
		    elsif params[:move_flag] == "4"
		    #納品明細
		      format.html {redirect_to delivery_slip_detail_middle_classifications_path(:delivery_slip_header_id => params[:delivery_slip_header_id], 
                :delivery_slip_header_name => params[:delivery_slip_header_name], :delivery_slip_detail_large_classification_id => params[:delivery_slip_detail_large_classification_id],
                :working_large_item_name => params[:working_large_item_name], :working_large_specification => params[:working_large_specification],
			    :move_flag => params[:move_flag])}
		    end
		  end
	    else
          format.html { render :new }
          format.json { render json: @working_middle_item.errors, status: :unprocessable_entity }
        end
      end
	end
  end

  # PATCH/PUT /working_middle_items/1
  # PATCH/PUT /working_middle_items/1.json
  def update
    
	if params[:move_flag].blank?
	#upd171128
	  #マスター画面からの遷移の場合、モーダルのため、別ルーチンにて処理する。
	  create_or_update_modal
	else
	#見積入力等の画面からの遷移の場合。
	
	  respond_to do |format|
	
	    #品目マスターへの追加・更新
	    create_or_update_material
	  
	    #upd171116
	    #共通・固有のどちらを更新するか切り分ける
	    status = false
	  
	    if params[:working_middle_item][:master_insert_flag] == "true"   
	      action_flag = params[:working_middle_item][:action_flag]
	   
	      if action_flag == "new"
		  #新規登録ボタン押下の場合
		  
		    #add171122
		    search_records = WorkingMiddleItem.exists?(:working_middle_item_name => params[:working_middle_item][:working_middle_item_name])
		  
		    if search_records.blank?
		  
		      #attributesの"id"のみ抹消する（しないとエラー）
		      if params[:working_middle_item][:working_small_items_attributes].present?
		        params[:working_middle_item][:working_small_items_attributes].flatten.each do |item|
                  item.delete("id")
                end
		      end
		      #
		
              @working_middle_item = WorkingMiddleItem.new(working_middle_item_params) 
	          status = @working_middle_item.save
		    else
		    #同一の品名ならば、更新とみなす（新規ボタンを押しても更新として扱い）
		       status = @working_middle_item.update(working_middle_item_params)
		    end
		  
		  elsif action_flag == "edit"
		  #更新ボタン押下の場合
            status = @working_middle_item.update(working_middle_item_params)
	      end
		
	    elsif params[:working_middle_item][:master_insert_flag] == "false"   ##false!
	      #明細固有マスターへの新規追加
          status = create_specific_master
	    
	    end 
	 
        if status == true
	      #add171108
	      #手入力用IDの場合は、単位マスタへも登録する。
	      set_working_unit
		
		  #upd171116
	      if params[:move_flag].blank?
		  #
		  else
	  	  #見積作成画面からの遷移の場合
		    if params[:move_flag] == "1"
		    #見積内訳
               format.html {redirect_to quotation_detail_large_classifications_path(:quotation_header_id => params[:quotation_header_id], 
                :quotation_header_name => params[:quotation_header_name], :move_flag => params[:move_flag])}
		    elsif params[:move_flag] == "2"
		    #見積明細
		       format.html {redirect_to quotation_detail_middle_classifications_path(:quotation_header_id => params[:quotation_header_id], 
                :quotation_header_name => params[:quotation_header_name], :quotation_detail_large_classification_id => params[:quotation_detail_large_classification_id],
                :working_large_item_name => params[:working_large_item_name], :working_large_specification => params[:working_large_specification],
			    :move_flag => params[:move_flag])}
		    elsif params[:move_flag] == "3"
		    #納品内訳
		       format.html {redirect_to delivery_slip_detail_large_classifications_path(:delivery_slip_header_id => params[:delivery_slip_header_id], 
                :delivery_slip_header_name => params[:delivery_slip_header_name], :move_flag => params[:move_flag])}
		    elsif params[:move_flag] == "4"
		    #納品明細
			    format.html {redirect_to delivery_slip_detail_middle_classifications_path(:delivery_slip_header_id => params[:delivery_slip_header_id], 
                :delivery_slip_header_name => params[:delivery_slip_header_name], :delivery_slip_detail_large_classification_id => params[:delivery_slip_detail_large_classification_id],
                :working_large_item_name => params[:working_large_item_name], :working_large_specification => params[:working_large_specification],
			    :move_flag => params[:move_flag])}
		    end
		  end
	    else
          format.html { render :edit }
          format.json { render json: @working_middle_item.errors, status: :unprocessable_entity }
        end
      end
	
	end
	
  end
  
  
  #登録・更新処理（モーダル画面より）
  def create_or_update_modal
    #品目マスターへの追加・更新
	create_or_update_material
	  
	#共通・固有のどちらを更新するか切り分ける
	status = false
	
	
	if params[:working_middle_item][:master_insert_flag] == "true"   
	  #action_flag = params[:working_middle_item][:action_flag]
	  action_flag = params[:action]
	   
	  if action_flag == "update"
	  #更新ボタン押下の場合
    	
		status = @working_middle_item.update(working_middle_item_params)
	  elsif action_flag == "create"
	  #新規ボタン押下の場合
	    @working_middle_item = WorkingMiddleItem.new(working_middle_item_params) 
	    status = @working_middle_item.save
			
	  end
	end 
	 
	if status == true
	  #add171108
	  #手入力用IDの場合は、単位マスタへも登録する。
	  set_working_unit
	
      #upd171116
	  if params[:move_flag].blank?
		#マスターメンテ画面からの遷移の場合
		@working_middle_items = WorkingMiddleItem.all
	  end
	else
    #
	end
  	
  end


  #add171116
  #明細固有マスターへの新規追加（更新はないものとする）
  def create_specific_master
    working_specific_middle_item_params = working_middle_item_params.dup
    
	#working_specific_middle_item_paramsのみにあるフィールド追加・attributesを追加
	working_specific_middle_item_params.store("quotation_header_id", params[:quotation_header_id])
    working_specific_middle_item_params.delete("working_small_items_attributes")
	#
	
	if working_middle_item_params["working_small_items_attributes"].present?
	  working_specific_middle_item_params.store("working_specific_small_items_attributes", 
	       working_middle_item_params["working_small_items_attributes"])
	end
	
	working_specific_middle_item = WorkingSpecificMiddleItem.new(working_specific_middle_item_params)
	status = working_specific_middle_item.save
	
	return status
	
  end

  #品目マスターへの追加・更新
  def create_or_update_material
  
     
     i = 0
	 
     if params[:working_middle_item][:working_small_items_attributes].present?
	
	    params[:working_middle_item][:working_small_items_attributes].values.each do |item|
		  
		  if item[:_destroy] != "1"
		  
		    if item[:working_small_item_id] == "1"
		    #手入力の場合→新規登録
			  material_master_params = {material_code: item[:working_small_item_code], material_name: item[:working_small_item_name], 
			     maker_id: 1, unit_id: 1, standard_quantity: item[:quantity], list_price: item[:unit_price], 
				 standard_labor_productivity_unit: item[:labor_productivity_unit]}
			     
                 @material_master = MaterialMaster.find_by(material_code: item[:working_small_item_code], material_name: item[:working_small_item_name])
                 if @material_master.blank?  #更新はないものとする
				   @material_master = MaterialMaster.create(material_master_params)
				 end
		    else
		    #手入力以外--特定のデータを更新
		      @material_master = MaterialMaster.find(item[:working_small_item_id])
			
			  if @material_master.present?
			    material_master_params = {standard_quantity: item[:quantity], 
			     standard_labor_productivity_unit: item[:labor_productivity_unit], 
				 material_name: item[:working_small_item_name], 
				 standard_quantity: item[:quantity], list_price: item[:unit_price]}
			  
			      @material_master.update(material_master_params)
			  end
			end
		  end
		
		end
		
		i += 1
	end
  
  end
  
  #手入力用IDの場合は、単位マスタへも登録する。
  #add171108
  def set_working_unit
    @working_unit = nil
	
    if @working_middle_item.working_unit_id == 1
       
       #既に登録してないかチェック
       @check_unit = WorkingUnit.find_by(working_unit_name: @working_middle_item.working_unit_name)
       
	   if @check_unit.nil?
          unit_params = { working_unit_name:  @working_middle_item.working_unit_name }
		  
          @working_unit = WorkingUnit.create(unit_params)
	   else
	      @working_unit = @check_unit
	   end
	else
	  @working_unit = WorkingUnit.find(@working_middle_item.working_unit_id)
    end
  
  end

  #パラメータを補充(今のところ未使用)
  def set_params_replenishment
     if params[:working_middle_item][:working_small_items_attributes].present?
	
	    params[:working_middle_item][:working_small_items_attributes].values.each do |item|
		
		  #varidate用のために、本来の箇所から離れたパラメータを再セットする
		  #item[:material_price] = params[:material_price][i]
		  #item[:material_id] = params[:material_id][i]
		end
		
		i += 1
	end
  
  end

  # DELETE /working_middle_items/1
  # DELETE /working_middle_items/1.json
  def destroy
  
    destroy_small_items  #小分類マスターを削除
	
    @working_middle_item.destroy
    respond_to do |format|
      format.html { redirect_to working_middle_items_url, notice: 'Working middle item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  #小分類マスターの削除
  def destroy_small_items
    WorkingSmallItem.where(working_middle_item_id: @working_middle_item.id).destroy_all
  end

  #ajax
  #メーカーから該当する商品を取得
  def item_extract
    #if params[:working_middle_item_category_id] != "0"
	#upd171113
	if params[:working_middle_item_category_id] != ""
      #初期値として、”手入力”も選択できるようにする
	  @item_extract  = WorkingMiddleItem.where(:id => "1").where("id is NOT NULL").order(:seq).
        pluck("working_middle_item_name, id")
	  #カテゴリー別のアイテムをセット
	  @item_extract  += WorkingMiddleItem.where(:working_middle_item_category_id => params[:working_middle_item_category_id]).where("id is NOT NULL").order(:seq).
        pluck("working_middle_item_name, id")
	
	  #初期値として、”手入力”も選択できるようにする
	  @item_short_name_extract  = WorkingMiddleItem.where(:id => "1").where("id is NOT NULL").order(:seq).
        pluck("working_middle_item_short_name, id")
	  #カテゴリー別のアイテムをセット
	  @item_short_name_extract += WorkingMiddleItem.where(:working_middle_item_category_id => params[:working_middle_item_category_id]).where("id is NOT NULL").order(:seq).
        pluck("working_middle_item_short_name, id")
    else
	#カテゴリーがデフォルト（指定なし）の場合
	  @item_extract = WorkingMiddleItem.all.order(:seq).
        pluck("working_middle_item_name, id")
	
	  @item_short_name_extract = WorkingMiddleItem.all.order(:seq).
        pluck("working_middle_item_short_name, id")
	end
	
  end
  
   #ajax
  #メーカーから該当する商品を取得
  def working_material_info_select
    
	#固有マスターより取得
    $working_middle_item = WorkingMiddleItem.find(params[:id])
 
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_working_middle_item
      @working_middle_item = WorkingMiddleItem.find(params[:id])
	end
    
	#移動フラグをセット（ビューに渡す為）
	#add171115
    def set_move_flag
	  @move_flag = params[:move_flag]
	end
	
    # Never trust parameters from the scary internet, only allow the white list through.
    def working_middle_item_params
	  #170714 ver
	  #params.require(:working_middle_item).permit(:working_middle_item_name, :working_middle_item_short_name, 
      #      :working_middle_specification, :working_unit_id, :working_unit_price, :execution_unit_price, :material_id, 
      #      :working_material_name, :execution_material_unit_price, :material_unit_price, :execution_labor_unit_price, 
      #      :labor_unit_price, :labor_unit_price_standard, :labor_productivity_unit, :material_quantity,
      #      :accessory_cost, :material_cost_total, :labor_cost_total, :other_cost, :seq)
	  
	  #170715
      params.require(:working_middle_item).permit(:working_middle_item_name, :working_middle_item_short_name, 
            :working_middle_item_category_id, :working_middle_specification, :working_unit_id, :working_unit_name, :working_unit_price, :execution_unit_price, :material_id, 
            :working_material_name, :execution_material_unit_price, :material_unit_price, :execution_labor_unit_price, 
            :labor_unit_price, :labor_unit_price_standard, :labor_productivity_unit, :material_quantity,
            :accessory_cost, :material_cost_total, :labor_cost_total, :other_cost, :seq, 
	     	working_small_items_attributes:   [:id, :working_specific_middle_item_id, :working_small_item_id, :working_small_item_code, :working_small_item_name, 
			:unit_price, :rate, :quantity, :labor_productivity_unit, :_destroy] )
    end
end
