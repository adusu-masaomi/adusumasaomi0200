class WorkingSpecificMiddleItemsController < ApplicationController
  before_action :set_working_specific_middle_item, only: [:show, :edit, :update, :destroy]

  # GET /working_specific_middle_items
  # GET /working_specific_middle_items.json
  def index
    @working_specific_middle_items = WorkingSpecificMiddleItem.all
  end

  # GET /working_specific_middle_items/1
  # GET /working_specific_middle_items/1.json
  def show
  end

  # GET /working_specific_middle_items/new
  def new
    @working_specific_middle_item = WorkingSpecificMiddleItem.new
	
	#作成中！！！！！171113
	#呼び出した場合
	if $working_specific_middle_item.present?
	  @working_specific_middle_item = $working_specific_middle_item
	  
	  $working_specific_middle_item = nil
	end
	
	#労務単価の初期値をセットする
	@working_specific_middle_item.labor_unit_price_standard ||= $LABOR_COST
  end

  # GET /working_specific_middle_items/1/edit
  def edit
    #労務単価の初期値をセットする
	@working_specific_middle_item.labor_unit_price_standard ||= $LABOR_COST
  end

  # POST /working_specific_middle_items
  # POST /working_specific_middle_items.json
  def create
    
    #明細マスターのパラメータ補正 add180310
    set_params_replenishment
	
	master_insert_flag = false
	#共通マスターへ更新する場合
	if params[:working_specific_middle_item][:master_insert_flag] == "true"
	  master_insert_flag = true
	end
	#
	
	#見積一覧IDをセット
	set_quotation_and_delivery_header
	
	#if master_insert_flag == false
	  
    #else
	#共通マスターへ登録する場合
	 ##作成中　１７１１０８ 
	#end

    respond_to do |format|
	
	  #品目マスターへの追加・更新
	  create_or_update_material
	  
	  #新規か更新かの判定処理追加 add171114
	  status = nil
	  action_flag = params[:working_specific_middle_item][:action_flag]
	  
	  if action_flag == "new"
	  #新規の場合
		@working_specific_middle_item = WorkingSpecificMiddleItem.new(working_specific_middle_item_params) 
	    status = @working_specific_middle_item.save
	  elsif action_flag == "edit"
	  #更新の場合
	    if @working_specific_middle_item.present?
	      status = @working_specific_middle_item.update(working_specific_middle_item_params)
	    else
		#該当なしの場合（ボタン誤操作など）は、新規登録する
		  @working_specific_middle_item = WorkingSpecificMiddleItem.new(working_specific_middle_item_params) 
	      status = @working_specific_middle_item.save
		end
	  end
	  #
	  
	  #if @working_specific_middle_item.save
      if status == true    #upa171114
        
		if params[:working_specific_middle_item][:master_insert_flag] == "true"
	      #共通（明細）マスターへの新規追加
          create_common_master
        end
		
		#手入力用IDの場合は、単位マスタへも登録する。
	    set_working_unit
	
		#upd171108 単位IDも更新
		@working_specific_middle_item.update(seq: @working_specific_middle_item.id, working_unit_id: @working_unit.id)
		
		#if params[:move_flag].blank?
        #  if action_flag == "new"
        #    format.html { redirect_to @working_specific_middle_item, notice: 'Working specific middle item was successfully created.' }
        #  elsif action_flag == "edit"
		#    format.html { redirect_to @working_specific_middle_item, notice: 'Working specific middle item was successfully updated.' }
		#  end
		#  format.json { render :show, status: :created, location: @working_specific_middle_item }
		#else
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
		  
		#end
		
        #format.html { redirect_to @working_specific_middle_item, notice: 'Working specific middle item was successfully created.' }
        #format.json { render :show, status: :created, location: @working_specific_middle_item }
      else
        format.html { render :new }
        format.json { render json: @working_specific_middle_item.errors, status: :unprocessable_entity }
      end
    end
  end

  
  #共通マスターへのパラメータをセット
  #def set_master_common_parameters
  #  working_middle_item_params = { working_middle_item_name:  params[:working_specific_middle_item][:working_middle_item_name], 
  #    working_middle_item_short_name:  params[:working_specific_middle_item][:working_middle_item_short_name], 
  #  working_middle_item_category_id:  params[:working_specific_middle_item][:working_middle_item_category_id], 
  #    working_middle_specification:  params[:working_specific_middle_item][:working_middle_specification], 
  #  working_unit_id:  params[:working_specific_middle_item][:working_unit_id],   working_unit_price:  params[:working_specific_middle_item][:working_unit_price], 
  #  execution_unit_price:  params[:working_specific_middle_item][:execution_unit_price],
  #    material_id:  params[:working_specific_middle_item][:material_id],   working_material_name: params[:working_specific_middle_item][:working_material_name],
  #    execution_material_unit_price:  params[:working_specific_middle_item][:execution_material_unit_price],
  #    material_unit_price:  params[:working_specific_middle_item][:material_unit_price], 
  #  execution_labor_unit_price:  params[:working_specific_middle_item][:execution_labor_unit_price], 
  #  labor_unit_price:  params[:working_specific_middle_item][:labor_unit_price],   labor_unit_price_standard:  params[:working_specific_middle_item][:labor_unit_price_standard], 
  #    labor_productivity_unit:  params[:working_specific_middle_item][:labor_productivity_unit],
  #    labor_productivity_unit_total:  params[:working_specific_middle_item][:labor_productivity_unit_total],
  #  material_cost_total:  params[:working_specific_middle_item][:material_cost_total],   seq:  params[:working_specific_middle_item][:seq],
  #end

   #手入力用IDの場合は、単位マスタへも登録する。
  #add171108
  def set_working_unit
    @working_unit = nil
	
    if @working_specific_middle_item.working_unit_id == 1
       
       #既に登録してないかチェック
       @check_unit = WorkingUnit.find_by(working_unit_name: @working_specific_middle_item.working_unit_name)
       
	   if @check_unit.nil?
          unit_params = { working_unit_name:  @working_specific_middle_item.working_unit_name }
		  
          @working_unit = WorkingUnit.create(unit_params)
	   else
	      @working_unit = @check_unit
	   end
	else
	  @working_unit = WorkingUnit.find(@working_specific_middle_item.working_unit_id)
	  
    end
  
  end
  
  #見積・納品一覧IDをセット（画面遷移の場合）
  def set_quotation_and_delivery_header
    if  params[:quotation_header_id].present?
	  params[:working_specific_middle_item][:quotation_header_id] = params[:quotation_header_id]
	end
	#納品書の場合
	if  params[:delivery_slip_header_id].present?
	  params[:working_specific_middle_item][:delivery_slip_header_id] = params[:delivery_slip_header_id]
	end
  end

  # PATCH/PUT /working_specific_middle_items/1
  # PATCH/PUT /working_specific_middle_items/1.json
  def update
    
    #明細マスターのパラメータ補正 
    #add180310
    set_params_replenishment
    
	respond_to do |format|
      #見積一覧IDをセット
	  set_quotation_and_delivery_header
	  
      #品目マスターへの追加・更新
	  create_or_update_material
	
	  #新規か更新かの判定処理追加 add171114
	  status = nil
	  
	    action_flag = params[:working_specific_middle_item][:action_flag]
	    if action_flag == "new"
		  #add171122
		  search_records =
              WorkingSpecificMiddleItem.exists?(:working_middle_item_name => params[:working_specific_middle_item][:working_middle_item_name])
		  
		  if search_records.blank?
		
		    #attributesの"id"のみ抹消する（しないとエラー）
		    if params[:working_specific_middle_item][:working_specific_small_items_attributes].present?
		      params[:working_specific_middle_item][:working_specific_small_items_attributes].flatten.each do |item|
                item.delete("id")
              end
		    end
		    #
		    @working_specific_middle_item = WorkingSpecificMiddleItem.new(working_specific_middle_item_params)
	        status = @working_specific_middle_item.save
	      else
		  #同一の品名ならば、更新とみなす（新規ボタンを押しても更新として扱い）
		    status = @working_specific_middle_item.update(working_specific_middle_item_params)
		  end
	    elsif action_flag == "edit"
        
          status = @working_specific_middle_item.update(working_specific_middle_item_params)
	    end
	  #

	  #if @working_specific_middle_item.update(working_specific_middle_item_params)
	  if status == true    #upa171114
  
        if params[:working_specific_middle_item][:master_insert_flag] == "true"
          
		  if action_flag == "new"  #登録ボタンを押した場合のみ
 			#共通（明細）マスターへの新規追加
            create_common_master
		  end
        end
  
		#add171108
	    #手入力用IDの場合は、単位マスタへも登録する。
	    set_working_unit
		
		if params[:move_flag] == "1"
		#内訳
             format.html {redirect_to quotation_detail_large_classifications_path(:quotation_header_id => params[:quotation_header_id], 
              :quotation_header_name => params[:quotation_header_name], :move_flag => params[:move_flag])}
		elsif params[:move_flag] == "2"
		#明細
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
		else
		#単独フォームからの場合（未使用）
          format.html { redirect_to @working_specific_middle_item, notice: 'Working specific middle item was successfully updated.' }
          format.json { render :show, status: :ok, location: @working_specific_middle_item }
      	end
		
      else
        format.html { render :edit }
        format.json { render json: @working_specific_middle_item.errors, status: :unprocessable_entity }
      end
    end
  end

  #共通（明細）マスターへの新規追加（更新はないものとする）
  def create_common_master
    working_middle_item_params = working_specific_middle_item_params.dup
    
	#working_middle_itemにないフィールド・attributesを抹消
    working_middle_item_params.delete("quotation_header_id")
    working_middle_item_params.delete("working_specific_small_items_attributes")
	#
	
	if working_specific_middle_item_params["working_specific_small_items_attributes"].present?
	  working_middle_item_params["working_small_items_attributes"] =
      working_specific_middle_item_params["working_specific_small_items_attributes"]
	end
	
	
	working_middle_item = WorkingMiddleItem.new(working_middle_item_params)
	status = working_middle_item.save
		
   
  end
  
  
  #品目マスターへの追加・更新
  def create_or_update_material
     
     i = 0
	 
     if params[:working_specific_middle_item][:working_specific_small_items_attributes].present?
	
	    params[:working_specific_middle_item][:working_specific_small_items_attributes].values.each do |item|
		  
		 
		  if item[:_destroy] != "1"
		  
		    if item[:working_small_item_id] == "1"
		    #手入力の場合→新規登録
			 
              material_master_params = {material_code: item[:working_small_item_code], material_name: item[:working_small_item_name], 
			     list_price: item[:unit_price], maker_id: item[:maker_master_id] }
                 
			  #material_master_params = {material_code: item[:working_small_item_code], material_name: item[:working_small_item_name], 
			  #   maker_id: 1, unit_id: 1, standard_quantity: item[:quantity], list_price: item[:unit_price], 
			  #  standard_labor_productivity_unit: item[:labor_productivity_unit]}
				 
			     
                 @material_master = MaterialMaster.find_by(material_code: item[:working_small_item_code], material_name: item[:working_small_item_name])
                 if @material_master.blank?  #更新はないものとする
				   @material_master = MaterialMaster.create(material_master_params)
				 end
		    else
		    #手入力以外--特定のデータを更新
		      @material_master = MaterialMaster.find(item[:working_small_item_id])
			
			  if @material_master.present?
			    
                #upd180316
                #品名・メーカーのみ登録とする
                material_master_params = {material_name: item[:working_small_item_name], 
				 maker_id: item[:maker_master_id] }
                 
                #material_master_params = {standard_quantity: item[:quantity], 
			    # standard_labor_productivity_unit: item[:labor_productivity_unit],
				# material_name: item[:working_small_item_name], 
				# standard_quantity: item[:quantity], list_price: item[:unit_price]}
			  
			      @material_master.update(material_master_params)
			  end
			end
		  end
		
		end
		
		i += 1
	end
  
  end

  # DELETE /working_specific_middle_items/1
  # DELETE /working_specific_middle_items/1.json
  def destroy
    @working_specific_middle_item.destroy
    respond_to do |format|
      format.html { redirect_to working_specific_middle_items_url, notice: 'Working specific middle item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  #パラメータを補充
  def set_params_replenishment
     if params[:working_specific_middle_item][:working_specific_small_items_attributes].present?
        i = 0
	    params[:working_specific_middle_item][:working_specific_small_items_attributes].values.each do |item|
		  #varidate用のために、本来の箇所から離れたパラメータを再セットする
		  item[:material_price] = params[:material_price][i]
          i += 1
		end
	end
  end
  
  #ajax
  #メーカーから該当する商品を取得
  #作成中！！！
  def working_material_info_select
    
	#固有マスターより取得
	$working_specific_middle_item = WorkingSpecificMiddleItem.find(params[:id])

	
	#WorkingSpecificMiddleItem.exists?(params[:id])
	
	#if params[:master_flag] == "1"
	#共通マスターより取得
	#  $working_specific_middle_item = WorkingMiddleItem.find(params[:id])
	#elsif  params[:master_flag] == "2"
	#固有マスターより取得
	#   $working_specific_middle_item = WorkingSpecificMiddleItem.find(params[:id])
	#else
	#  $working_specific_middle_item = nil
	#end
	
	
	#初期値として、”手入力”も選択できるようにする
	#@working_middle_item_name  = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_middle_item_name).flatten.join(" ")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_working_specific_middle_item
      @working_specific_middle_item = WorkingSpecificMiddleItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def working_specific_middle_item_params
      params.require(:working_specific_middle_item).permit(:quotation_header_id, :delivery_slip_header_id, :working_middle_item_name, 
	  :working_middle_item_short_name, :working_middle_item_category_id, :working_middle_specification, :working_unit_id, :working_unit_name, :working_unit_price, 
	  :execution_unit_price, :material_id, :working_material_name, :execution_material_unit_price, :material_unit_price, :execution_labor_unit_price, 
	  :labor_unit_price, :labor_unit_price_standard, :labor_productivity_unit, :labor_productivity_unit_total, :material_cost_total, :seq,
	  working_specific_small_items_attributes:   [:id, :working_specific_middle_item_id, :working_small_item_id, :working_small_item_id, :working_small_item_code, :working_small_item_name, 
			:unit_price, :rate, :quantity, :material_price, :maker_master_id, :unit_master_id, :labor_productivity_unit, :_destroy])
    end
	
	
end
