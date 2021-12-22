class DeliverySlipDetailMiddleClassificationsController < ApplicationController
  before_action :set_delivery_slip_detail_middle_classification, only: [:show, :edit, :update, :destroy, :copy]

   @@new_flag = []
   
   #add171016
  before_action :initialize_sort, only: [:show, :new, :edit, :update, :destroy ]

  
  # GET /delivery_slip_detail_middle_classifications
  # GET /delivery_slip_detail_middle_classifications.json
  def index
    
    @null_flag = ""
    
    @number = 1
	
    #ransack保持用コード
    if params[:delivery_slip_header_id].present?
      #$delivery_slip_header_id = params[:delivery_slip_header_id]
	  #upd170626
      @delivery_slip_header_id = params[:delivery_slip_header_id]
	  
      if params[:working_large_item_name].present?
          #$working_large_item_name = [params[:working_large_item_name], params[:working_large_specification]]
          #upd170626
          @working_large_item_name = [params[:working_large_item_name], params[:working_large_specification]]
	  end
	  if params[:delivery_slip_detail_large_classification_id].present?
          #$delivery_slip_detail_large_classification_id = params[:delivery_slip_detail_large_classification_id]
		#upd170626
        @delivery_slip_detail_large_classification_id = params[:delivery_slip_detail_large_classification_id]
	  end
	end
    
  
    #明細データ見出用
    if params[:delivery_slip_header_name].present?
      #$delivery_slip_header_name = params[:delivery_slip_header_name]
      #upd170626
      @delivery_slip_header_name = params[:delivery_slip_header_name]
    end
    #
	
    #if $delivery_slip_header_id.present?
    #upd170626
    if @delivery_slip_header_id.present?
      #query = {"delivery_slip_header_id_eq"=>"", "with_header_id"=> $delivery_slip_header_id, "with_large_item"=> $working_large_item_name , "working_middle_item_name_eq"=>""}
      query = {"delivery_slip_header_id_eq"=>"", "with_header_id"=> @delivery_slip_header_id, "with_large_item"=> @working_large_item_name , 
                   "working_middle_item_name_eq"=>""}

      @null_flag = "1"
    end 

    #if query.nil?
    if @null_flag == "" 
      #ransack保持用コード
      query = params[:q]
      query ||= eval(cookies[:recent_search_history].to_s)  	
    end
	
	
	#binding.pry
	
    #@q = DeliverySlipDetailMiddleClassification.ransack(params[:q]) 
    #ransack保持用--上記はこれに置き換える
    @q = DeliverySlipDetailMiddleClassification.ransack(query)   
    
    
    
    #ransack保持用コード
    if @null_flag == "" 
	  search_history = {
       value: params[:q],
       expires: 480.minutes.from_now
      }
      cookies[:recent_search_history] = search_history if params[:q].present?
    end
	#

    @delivery_slip_detail_middle_classifications = @q.result(distinct: true)
    
	#add171016
	#ビューでのソート処理追加
	if (params[:q].present? && params[:q][:s].present?) || $sort_dm != nil
	    
		#order順のパラメータ(asc/desc)がなぜか１パターンしか入らないので、カラム強制にセットする。
	    column_name = "line_number"
	    
		if $not_sort_dm != true
		#ここでにソートを切り替える。（パラメータで入ればベストだが）
		#（モーダル編集、行ソートでこの処理をしないようにしている）
		
		  if params[:q].present? 
            if $sort_dm.nil?
	           $sort_dm = "desc"
	        end   
 
		    if $sort_dm != "asc"
		      $sort_dm = "asc"
		    else
		      $sort_dm = "desc"
		    end
	      end
		else
		  $not_sort_dm = false
		end
		
		#並び替えする（降順/昇順）
		if $sort_dm == "asc"
	      @delivery_slip_detail_middle_classifications = @delivery_slip_detail_middle_classifications.order(column_name + " asc")
		elsif $sort_dm == "desc"
	      @delivery_slip_detail_middle_classifications = @delivery_slip_detail_middle_classifications.order(column_name + " desc")
		end
    end

    #add180423
    #内訳へのデータ移行を行う。
    if params[:data_type] == "1"
      #内訳へデータ移行
      move_middle_to_large
      if @success_flag == true
	    flash[:notice] = "データ作成が完了しました。"
      end
	end
    #add end 
    
  end

  #add170412
  #ドラッグ＆ドロップによる並び替え機能(seqをセットする)
  def reorder
  	
	$not_sort_dm = true               #add171016
	
    if $sort_dm != "asc"              #add171016
  	  row = params[:row].split(",").reverse    #ビューの並びが逆のため、パラメータの配列を逆順でセットさせる。
    else                              #add171016
	  row = params[:row].split(",")   #add171016
	end
  
    #row.each_with_index {|row, i| QuotationDetailLargeClassification.update(row, {:seq => i})}
	#行番号へセットするため、配列は１から開始させる。
	row.each_with_index {|row, i| DeliverySlipDetailMiddleClassification.update(row, {:line_number => i + 1})}
    render :text => "OK"

    #小計を全て再計算する
    recalc_subtotal_all
  end

  # GET /delivery_slip_detail_middle_classifications/1
  # GET /delivery_slip_detail_middle_classifications/1.json
  def show
  end

  # GET /delivery_slip_detail_middle_classifications/new
  def new
    @delivery_slip_detail_middle_classification = DeliverySlipDetailMiddleClassification.new
  
    @delivery_slip_detail_large_classification = DeliverySlipDetailLargeClassification.all
    
    ###
    #初期値をセット(見出画面からの遷移時のみ)
    @@new_flag = params[:new_flag]
	
	#add170626
	if params[:delivery_slip_header_id].present?
      @delivery_slip_header_id = params[:delivery_slip_header_id]
      
      #add180817
      #確定済みのものは、変更できないようにする
      delivery_slip_header = DeliverySlipHeader.find(params[:delivery_slip_header_id])
      if delivery_slip_header.present?
        if delivery_slip_header.fixed_flag == 1
          @status = "fixed"
        else
          @status = "not_fixed"
        end
      end
      #
      
    end
	
    if @@new_flag == "1"
       #@delivery_slip_detail_middle_classification.delivery_slip_header_id ||= $delivery_slip_header_id
	   #upd170626
	   @delivery_slip_detail_middle_classification.delivery_slip_header_id ||= @delivery_slip_header_id
	   
	   if params[:delivery_slip_detail_large_classification_id].present?
         @delivery_slip_detail_middle_classification.delivery_slip_detail_large_classification_id ||= params[:delivery_slip_detail_large_classification_id]
	   else
         #@delivery_slip_detail_middle_classification.delivery_slip_detail_large_classification_id ||= $delivery_slip_detail_large_classification_id
         @delivery_slip_detail_middle_classification.delivery_slip_detail_large_classification_id ||= @delivery_slip_detail_large_classification_id
       end
    end 
    
    #行番号を取得する
    get_line_number
	
	#カテゴリー保持フラグを取得
    #add180210
    get_category_save_flag
    get_category_id
	###
  end

  # GET /delivery_slip_detail_middle_classifications/1/edit
  def edit
    #カテゴリー保持フラグを取得
    #add180210
    get_category_save_flag
    
    #add180803
    #確定済みのものは、変更できないようにする
    if params[:delivery_slip_header_id].present?
      delivery_slip_header = DeliverySlipHeader.find(params[:delivery_slip_header_id])
      if delivery_slip_header.present?
        if delivery_slip_header.fixed_flag == 1
          @status = "fixed"
        else
          @status = "not_fixed"
        end
      end
    end
    #
    
    
  end

  # POST /delivery_slip_detail_middle_classifications
  # POST /delivery_slip_detail_middle_classifications.json
  def create
    
	#作業明細マスターの更新
	update_working_middle_item
	
    ###モーダル化対応
    @delivery_slip_detail_middle_classification = DeliverySlipDetailMiddleClassification.create(delivery_slip_detail_middle_classification_params)
    
    
    #歩掛りの集計を最新のもので書き換える。
    update_labor_productivity_unit_summary
    #小計を再計算する
    recalc_subtotal  
    
    #手入力用IDの場合は、単位マスタへも登録する。
    #@delivery_slip_unit = nil
    @working_unit = nil
    if @delivery_slip_detail_middle_classification.working_unit_id == 1
       
	   #既に登録してないかチェック
       @check_unit = WorkingUnit.find_by(working_unit_name: @delivery_slip_detail_middle_classification.working_unit_name)
       
	   if @check_unit.nil?
          unit_params = { working_unit_name:  @delivery_slip_detail_middle_classification.working_unit_name }
          @working_unit = WorkingUnit.create(unit_params)
		else
		  @working_unit = @check_unit
	   end
    end
    

     #品目データの金額を更新
    save_price_to_large_classifications
    #行挿入する 
	@max_line_number = @delivery_slip_detail_middle_classification.line_number
    if (params[:delivery_slip_detail_middle_classification][:check_line_insert] == 'true')
      line_insert
    end
    
    #行番号の最終を書き込む
    delivery_slip_dlc_set_last_line_number

    #add 180210
    #カテゴリー保持状態の保存
    set_category_save_flag
    
	#add170626
	if params[:delivery_slip_detail_middle_classification][:delivery_slip_header_id].present?
      @delivery_slip_header_id = params[:delivery_slip_detail_middle_classification][:delivery_slip_header_id]
    end
	if params[:delivery_slip_detail_middle_classification][:delivery_slip_detail_large_classification_id].present?
      @delivery_slip_detail_large_classification_id = params[:delivery_slip_detail_middle_classification][:delivery_slip_detail_large_classification_id]
    end
	#
	
    #@delivery_slip_detail_middle_classifications = DeliverySlipDetailMiddleClassification.where(:delivery_slip_header_id => $delivery_slip_header_id).where(:delivery_slip_detail_large_classification_id => $delivery_slip_detail_large_classification_id)
    #upd170626
    @delivery_slip_detail_middle_classifications = DeliverySlipDetailMiddleClassification.
      where(:delivery_slip_header_id => @delivery_slip_header_id).
        where(:delivery_slip_detail_large_classification_id => @delivery_slip_detail_large_classification_id)
	
	###
  end
  
  
  
  # PATCH/PUT /delivery_slip_detail_middle_classifications/1
  # PATCH/PUT /delivery_slip_detail_middle_classifications/1.json
  def update
    
	#作業明細マスターの更新
	update_working_middle_item
	
    @delivery_slip_detail_middle_classification.update(delivery_slip_detail_middle_classification_params)
    
    #歩掛りの集計を最新のもので書き換える。
    update_labor_productivity_unit_summary
    #小計を再計算する
	recalc_subtotal  
	
    #品目データの金額を更新
	save_price_to_large_classifications
	
    #add 180210
    #カテゴリー保持状態の保存
    set_category_save_flag
    
	#行挿入する 
	@max_line_number = @delivery_slip_detail_middle_classification.line_number
    if (params[:delivery_slip_detail_middle_classification][:check_line_insert] == 'true')
       line_insert
    end
    
	#行番号の最終を書き込む
    delivery_slip_dlc_set_last_line_number

    #手入力用IDの場合は、単位マスタへも登録する。
    @working_unit = nil
	
    if @delivery_slip_detail_middle_classification.working_unit_id == 1
       
       #既に登録してないかチェック
       @check_unit = WorkingUnit.find_by(working_unit_name: @delivery_slip_detail_middle_classification.working_unit_name)
       
	   if @check_unit.nil?
          unit_params = { working_unit_name:  @delivery_slip_detail_middle_classification.working_unit_name }
		  
          @working_unit = WorkingUnit.create(unit_params)
	   else
	      @working_unit = @check_unit
	   end
    end
	
	
#    #明細(中分類)マスターへ登録する。
#    if @delivery_slip_detail_middle_classification.working_middle_item_id == 1
#	#手入力用IDの場合
#      @check_item = WorkingMiddleItem.find_by(working_middle_item_name: @delivery_slip_detail_middle_classification.working_middle_item_name , working_middle_specification: @delivery_slip_detail_middle_classification.working_middle_specification)
#    else
#	#手入力以外の場合 add170729
#	  @check_item = WorkingMiddleItem.find(@delivery_slip_detail_middle_classification.working_middle_item_id)
#    end
#    @working_unit_id_params = @delivery_slip_detail_middle_classification.working_unit_id
#    if @working_unit.present?
#	  @working_unit_all_params = WorkingUnit.find_by(working_unit_name: @delivery_slip_detail_middle_classification.working_unit_name)
#	  @working_unit_id_params = @working_unit_all_params.id
#    end 

#     #if @check_item.nil?
#	# 全選択の場合
#	if params[:delivery_slip_detail_middle_classification][:check_update_all] == "true" 
#		      large_item_params = { working_middle_item_name:  @delivery_slip_detail_middle_classification.working_middle_item_name, 
#              working_middle_item_short_name: @delivery_slip_detail_middle_classification.working_middle_item_short_name, 
#              working_middle_specification:  @delivery_slip_detail_middle_classification.working_middle_specification, 
#              working_unit_id: @working_unit_id_params, 
#              working_unit_price: @delivery_slip_detail_middle_classification.working_unit_price,
#              execution_unit_price: @delivery_slip_detail_middle_classification.execution_unit_price,
#              material_id: @delivery_slip_detail_middle_classification.material_id,
#              working_material_name: @delivery_slip_detail_middle_classification.working_material_name,
#              material_unit_price: @delivery_slip_detail_middle_classification.material_unit_price,
#              labor_unit_price: @delivery_slip_detail_middle_classification.labor_unit_price,
#              labor_productivity_unit: @delivery_slip_detail_middle_classification.labor_productivity_unit,
#              labor_productivity_unit_total: @delivery_slip_detail_middle_classification.labor_productivity_unit_total,
#              material_quantity: @delivery_slip_detail_middle_classification.material_quantity,
#              accessory_cost: @delivery_slip_detail_middle_classification.accessory_cost,
#              material_cost_total: @delivery_slip_detail_middle_classification.material_cost_total,
#              labor_cost_total: @delivery_slip_detail_middle_classification.labor_cost_total,
#              other_cost: @delivery_slip_detail_middle_classification.other_cost }
              #@working_middle_item = WorkingMiddleItem.create(large_item_params)  del170729
#    else
#	  # アイテムのみ更新の場合
#	  if params[:delivery_slip_detail_middle_classification][:check_update_item] == "true"

#		       large_item_params = { working_middle_item_name:  @delivery_slip_detail_middle_classification.working_middle_item_name, 
#               working_middle_item_short_name: @delivery_slip_detail_middle_classification.working_middle_item_short_name, 
#               working_middle_specification:  @delivery_slip_detail_middle_classification.working_middle_specification,
#               working_unit_id: @working_unit_id_params } 
			   
			   #@working_middle_item = WorkingMiddleItem.create(large_item_params) del170729
#	  end
#    end
		 
    #upd170729
#    if large_item_params.present?
#	  if @check_item.nil?
#		@working_middle_item = WorkingMiddleItem.create(large_item_params)
#	  else
 #       @working_middle_item = @check_item.update(large_item_params)
#	  end
#    end
         #end
    #end
    
	#add170626
	if params[:delivery_slip_detail_middle_classification][:delivery_slip_header_id].present?
      @delivery_slip_header_id = params[:delivery_slip_detail_middle_classification][:delivery_slip_header_id]
    end
	if params[:delivery_slip_detail_middle_classification][:delivery_slip_detail_large_classification_id].present?
      @delivery_slip_detail_large_classification_id = params[:delivery_slip_detail_middle_classification][:delivery_slip_detail_large_classification_id]
    end
	#
	
    #@delivery_slip_detail_middle_classifications = DeliverySlipDetailMiddleClassification.where(:delivery_slip_header_id => $delivery_slip_header_id).where(:delivery_slip_detail_large_classification_id => $delivery_slip_detail_large_classification_id)
    #upd170626
    @delivery_slip_detail_middle_classifications = DeliverySlipDetailMiddleClassification.
      where(:delivery_slip_header_id => @delivery_slip_header_id).
        where(:delivery_slip_detail_large_classification_id => @delivery_slip_detail_large_classification_id)
  end
  
    
    
  #add 180911
  #レコードをコピーする
  def copy
    
    if params[:delivery_slip_header_id].present?
      #確定済みのものは、変更できないようにする
      delivery_slip_header = DeliverySlipHeader.find(params[:delivery_slip_header_id])
      if delivery_slip_header.present?
        if delivery_slip_header.fixed_flag == 1
          @status = "fixed"
        else
          @status = "not_fixed"
        end
      end
      #
    end
    
    if @status != "fixed"
    
      @delivery_slip_detail_middle_classification.working_middle_item_name += $STRING_COPY  #名前が被るとまずいので、文字を加えておく。
        
      #add210916
      @delivery_slip_detail_middle_classification.line_number += 1
      line_insert  #行番号をインクリメントする
      #
      
      new_record = @delivery_slip_detail_middle_classification.dup
      status = new_record.save
    
      if status == true
        notice = 'Delivery slip detail middle classification was successfully copied.'
            
        #品目データの金額を更新
        @delivery_slip_detail_middle_classification = new_record
        save_price_to_large_classifications
      
      else
        notice = 'Delivery slip detail middle classification was unfortunately failed...'
      end
        
      #redirect_to :action => "index", :notice => notice,  :delivery_slip_header_id => params[:delivery_slip_header_id], 
      #    :delivery_slip_header_name => params[:delivery_slip_header_name],  
      #    :delivery_slip_detail_large_classification_id => params[:delivery_slip_detail_large_classification_id],
      #    :working_large_item_name => params[:working_large_item_name], 
      #    :working_large_specification => params[:working_large_specification]
    end
  end
  
  
  #add170823
  #作業明細マスターの更新
  def update_working_middle_item
  
    if params[:delivery_slip_detail_middle_classification][:working_middle_item_id] == "1"
      if params[:delivery_slip_detail_middle_classification][:master_insert_flag] == "true"   #add171106
		    @check_item = WorkingMiddleItem.find_by(working_middle_item_name: params[:delivery_slip_detail_middle_classification][:working_middle_item_name] , 
		    working_middle_specification: params[:delivery_slip_detail_middle_classification][:working_middle_specification] )
      else
        #add171106 固有マスターより検索
        @check_item = WorkingSpecificMiddleItem.find_by(working_middle_item_name: params[:delivery_slip_detail_middle_classification][:working_middle_item_name] , 
        delivery_slip_header_id: params[:delivery_slip_detail_middle_classification][:delivery_slip_header_id] )
      end
    else
      #手入力以外の場合   
      if params[:delivery_slip_detail_middle_classification][:master_insert_flag] == "true"   
        @check_item = WorkingMiddleItem.find(params[:delivery_slip_detail_middle_classification][:working_middle_item_id])
      else
        #固有マスターより検索
        if params[:delivery_slip_detail_middle_classification][:working_middle_specific_item_id].present?
          @check_item = WorkingSpecificMiddleItem.find(params[:delivery_slip_detail_middle_classification][:working_middle_specific_item_id])
        end
      end
	  end
		
    @working_unit_id_params = params[:delivery_slip_detail_middle_classification][:working_unit_id]
		 
    if @working_unit.present?
      @working_unit_all_params = WorkingUnit.find_by(working_unit_name: params[:delivery_slip_detail_middle_classification][:working_unit_name] )
      @working_unit_id_params = @working_unit_all_params.id
    end 
 
    #if @check_item.nil?
    large_item_params = nil   
		  
    #短縮名（手入力）
    if params[:delivery_slip_detail_middle_classification][:working_middle_item_short_name_manual] != "<手入力>"
      working_middle_item_short_name_manual = params[:delivery_slip_detail_middle_classification][:working_middle_item_short_name_manual]
    else
      working_middle_item_short_name_manual = ""
    end
    ##
		  
    # 全選択の場合
    #upd170823 短縮名追加
    if params[:delivery_slip_detail_middle_classification][:check_update_all] == "true" 
      large_item_params = { working_middle_item_name:  params[:delivery_slip_detail_middle_classification][:working_middle_item_name], 
                                    working_middle_item_short_name: working_middle_item_short_name_manual, 
                                    working_middle_specification:  params[:delivery_slip_detail_middle_classification][:working_middle_specification] , 
                                    working_middle_item_category_id: params[:delivery_slip_detail_middle_classification][:working_middle_item_category_id] ,
                                    working_subcategory_id: params[:delivery_slip_detail_middle_classification][:working_middle_item_subcategory_id], 
                                    working_unit_id: @working_unit_id_params, 
                                    working_unit_price: params[:delivery_slip_detail_middle_classification][:working_unit_price] ,
                                    execution_unit_price: params[:delivery_slip_detail_middle_classification][:execution_unit_price] ,
                                    material_id: params[:delivery_slip_detail_middle_classification][:material_id] ,
                                    working_material_name: params[:delivery_slip_detail_middle_classification][:quotation_material_name],
                                    material_unit_price: params[:delivery_slip_detail_middle_classification][:material_unit_price] ,
                                    labor_unit_price: params[:delivery_slip_detail_middle_classification][:labor_unit_price] ,
                                    labor_productivity_unit: params[:delivery_slip_detail_middle_classification][:labor_productivity_unit] ,
                                    labor_productivity_unit_total: params[:delivery_slip_detail_middle_classification][:labor_productivity_unit_total] ,
                                    material_quantity: params[:delivery_slip_detail_middle_classification][:material_quantity] ,
                                    accessory_cost: params[:delivery_slip_detail_middle_classification][:accessory_cost] ,
                                    material_cost_total: params[:delivery_slip_detail_middle_classification][:material_cost_total] ,
                                    labor_cost_total: params[:delivery_slip_detail_middle_classification][:labor_cost_total],
                                    other_cost: params[:delivery_slip_detail_middle_classification][:other_cost] 
                           }
      #del170714 
      #@quotation_middle_item = WorkingMiddleItem.create(large_item_params)
    else
      # アイテムのみ更新の場合
      #upd170626 short_name抹消(無駄に１が入るため)
      if params[:delivery_slip_detail_middle_classification][:check_update_item] == "true" 
		         large_item_params = { working_middle_item_name: params[:delivery_slip_detail_middle_classification][:working_middle_item_name] , 
                 working_middle_item_short_name: working_middle_item_short_name_manual, 
                 working_middle_specification: params[:delivery_slip_detail_middle_classification][:working_middle_specification] ,
                 working_middle_item_category_id: params[:delivery_slip_detail_middle_classification][:working_middle_item_category_id] ,
                 working_subcategory_id: params[:delivery_slip_detail_middle_classification][:working_middle_item_subcategory_id], 
                 working_unit_id: @working_unit_id_params } 
   
      end
    end

    #upd170714
    if large_item_params.present?
      if @check_item.nil?
        if params[:delivery_slip_detail_middle_classification][:master_insert_flag] == "true"   #add171106
          @check_item = WorkingMiddleItem.create(large_item_params)
		     
			     #手入力の場合のパラメータを書き換える。
			     params[:delivery_slip_detail_middle_classification][:working_middle_item_id] = @check_item.id
			     params[:delivery_slip_detail_middle_classification][:working_middle_item_short_name] = @check_item.id
        else
			    #add171106 固有マスターへ登録
			    #ヘッダIDを連想配列へ追加
          large_item_params.store(:quotation_header_id, params[:delivery_slip_detail_middle_classification][:delivery_slip_header_id])
				 
			     @check_item = WorkingSpecificMiddleItem.create(large_item_params)
		         #手入力の場合のパラメータを書き換える。
			     params[:delivery_slip_detail_middle_classification][:working_specific_middle_item_id] = @check_item.id
        end
      else
			 
        #@quotation_middle_item = @check_item.update(large_item_params)
        @check_item.update(large_item_params)
      end
    end
    
  end

  # DELETE /delivery_slip_detail_middle_classifications/1
  # DELETE /delivery_slip_detail_middle_classifications/1.json
  def destroy
    
    if params[:delivery_slip_header_id].present?
	
      #$delivery_slip_header_id = params[:delivery_slip_header_id]
      #upd170626
      @delivery_slip_header_id = params[:delivery_slip_header_id]
      if params[:delivery_slip_detail_large_classification_id].present?
        @delivery_slip_detail_large_classification_id = params[:delivery_slip_detail_large_classification_id]
	    
        #add180817
        #確定済みのものは、変更できないようにする
        delivery_slip_header = DeliverySlipHeader.find(params[:delivery_slip_header_id])
        if delivery_slip_header.present?
          if delivery_slip_header.fixed_flag == 1
            @status = "fixed"
          else
            @status = "not_fixed"
          end
        end
        #
      end
    end
  
    if @status != "fixed"
      @delivery_slip_detail_middle_classification.destroy
      #respond_to do |format|
      #del180817
      #確定済みデータに警告を出すため、ここでリダイレクトさせない
	    #  format.html {redirect_to delivery_slip_detail_middle_classifications_path( :delivery_slip_header_id => params[:delivery_slip_header_id],
      #                :delivery_slip_detail_large_classification_id => params[:delivery_slip_detail_large_classification_id], 
	    #                :delivery_slip_header_name => params[:delivery_slip_header_name],
      #                :working_large_item_name => params[:working_large_item_name], :working_large_specification => params[:working_large_specification]
      #               )}
	    #品目データの金額を更新
      save_price_to_large_classifications
    
    end
  end
 
  #納品金額トータル
  def delivery_slip_total_price
    #@execution_total_price = DeliverySlipDetailMiddleClassification.where(["delivery_slip_detail_large_classification_id = ?", @delivery_slip_detail_middle_classification.delivery_slip_detail_large_classification_id]).sumpriceDeliverySlip
    #upd170511
    @execution_total_price = DeliverySlipDetailMiddleClassification.where(["delivery_slip_header_id = ? and delivery_slip_detail_large_classification_id = ?", 
    @delivery_slip_detail_middle_classification.delivery_slip_header_id, @delivery_slip_detail_middle_classification.delivery_slip_detail_large_classification_id]).sumpriceDeliverySlip
  end 
  #実行金額トータル
  def execution_total_price
    #@execution_total_price = DeliverySlipDetailMiddleClassification.where(["delivery_slip_detail_large_classification_id = ?", @delivery_slip_detail_middle_classification.delivery_slip_detail_large_classification_id]).sumpriceExecution
    @execution_total_price = DeliverySlipDetailMiddleClassification.where(["delivery_slip_header_id = ? and delivery_slip_detail_large_classification_id = ?", 
    @delivery_slip_detail_middle_classification.delivery_slip_header_id, @delivery_slip_detail_middle_classification.delivery_slip_detail_large_classification_id]).sumpriceExecution
  end

  #歩掛りトータル
  def labor_total
    #@labor_total = DeliverySlipDetailMiddleClassification.where(["delivery_slip_detail_large_classification_id = ?", @delivery_slip_detail_middle_classification.delivery_slip_detail_large_classification_id]).sumLaborProductivityUnit
    @labor_total = DeliverySlipDetailMiddleClassification.where(["delivery_slip_header_id = ? and delivery_slip_detail_large_classification_id = ?", 
    @delivery_slip_detail_middle_classification.delivery_slip_header_id, @delivery_slip_detail_middle_classification.delivery_slip_detail_large_classification_id]).sumLaborProductivityUnit 
  end
  #歩掛計トータル
  def labor_all_total
    #@labor_all_total = DeliverySlipDetailMiddleClassification.where(["delivery_slip_detail_large_classification_id = ?", @delivery_slip_detail_middle_classification.delivery_slip_detail_large_classification_id]).sumLaborProductivityUnitTotal
    @labor_all_total = DeliverySlipDetailMiddleClassification.where(["delivery_slip_header_id = ? and delivery_slip_detail_large_classification_id = ?", 
    @delivery_slip_detail_middle_classification.delivery_slip_header_id, @delivery_slip_detail_middle_classification.delivery_slip_detail_large_classification_id]).sumLaborProductivityUnitTotal 
  end
  
  #トータル(品目→見出保存用)
  
  #請求金額トータル
  def delivery_slip_total_price_Large
    @execution_total_price_Large = DeliverySlipDetailLargeClassification.where(["delivery_slip_header_id = ?", @delivery_slip_detail_middle_classification.delivery_slip_header_id]).sumpriceDeliverySlip
  end 
  #実行金額トータル
  def execution_total_price_Large
    @execution_total_price_Large = DeliverySlipDetailLargeClassification.where(["delivery_slip_header_id = ?", @delivery_slip_detail_middle_classification.delivery_slip_header_id]).sumpriceExecution
  end

  #歩掛りトータル
  #def labor_total_Large
  #   @labor_total_Large = DeliverySlipDetailLargeClassification.where(["id = ?", @delivery_slip_detail_middle_classification.delivery_slip_detail_large_classification_id]).sumLaborProductivityUnit 
  #end
  #

  # ajax
  #add170308
  def subtotal_select
  #小計を取得、セットする
    @search_records = DeliverySlipDetailMiddleClassification.where("delivery_slip_header_id = ? and delivery_slip_detail_large_classification_id = ?", 
                                                                 params[:delivery_slip_header_id], params[:delivery_slip_detail_large_classification_id] )
    if @search_records.present?
      start_line_number = 0
      end_line_number = 0
      current_line_number = params[:line_number].to_i
        
      @search_records.order(:line_number).each do |dsdmc|
        if dsdmc.construction_type.to_i != $INDEX_SUBTOTAL &&
          dsdmc.construction_type.to_i != $INDEX_DISCOUNT  
			    #小計,値引き以外なら開始行をセット
          if start_line_number == 0
            start_line_number = dsdmc.line_number
		      end
        else 
          if dsdmc.line_number < current_line_number
            start_line_number = 0   #開始行を初期化
          end
        end
		   
		    if dsdmc.line_number < current_line_number   #更新の場合もあるので現在の行はカウントしない。
		      end_line_number = dsdmc.line_number  #終了行をセット
        end
      end  #do end
        
      #範囲内の計を集計
      @delivery_slip_price = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:delivery_slip_price)
      @execution_price = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:execution_price)
      @labor_productivity_unit_total = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:labor_productivity_unit_total)
        
    end
  end 
  
  def recalc_subtotal_all
    #すべての小計を再計算する(ajax用)
    delivery_slip_price_sum = 0
    execution_price_sum = 0
    labor_productivity_unit_total_sum  = 0

    @search_records = DeliverySlipDetailMiddleClassification.where("delivery_slip_header_id = ? and delivery_slip_detail_large_classification_id = ?", 
                                                       params[:ajax_delivery_slip_header_id], params[:ajax_delivery_slip_detail_large_classification_id])
   
    if @search_records.present?
      @search_records.order(:line_number).each do |dsdmc|
	      if dsdmc.construction_type.to_i != $INDEX_SUBTOTAL
          if dsdmc.construction_type.to_i != $INDEX_DISCOUNT
            #小計・値引き以外？
            delivery_slip_price_sum += dsdmc.delivery_slip_price.to_i
            execution_price_sum += dsdmc.execution_price.to_i
            labor_productivity_unit_total_sum += dsdmc.labor_productivity_unit_total.to_f
          end
        else
		      #小計？=>更新
		      subtotal_params = {delivery_slip_price: delivery_slip_price_sum, execution_price: execution_price_sum, 
                 labor_productivity_unit_total: labor_productivity_unit_total_sum}
          dsdmc.update(subtotal_params)

          #カウンターを初期化
          delivery_slip_price_sum = 0
          execution_price_sum = 0
          labor_productivity_unit_total_sum  = 0
        end
	    end  #do end
    end
  end
  
  def recalc_subtotal
  #小計を再計算する
    @search_records = DeliverySlipDetailMiddleClassification.where("delivery_slip_header_id = ? and delivery_slip_detail_large_classification_id = ?", 
                                                                 params[:delivery_slip_detail_middle_classification][:delivery_slip_header_id], 
                                                                 params[:delivery_slip_detail_middle_classification][:delivery_slip_detail_large_classification_id] )
    if @search_records.present?
      start_line_number = 0
      end_line_number = 0
      current_line_number = params[:delivery_slip_detail_middle_classification][:line_number].to_i
        
      subtotal_exist = false
      id_saved = 0
      
      @search_records.order(:line_number).each do |dsdmc|
        if dsdmc.construction_type.to_i != $INDEX_SUBTOTAL &&
           dsdmc.construction_type.to_i != $INDEX_DISCOUNT  
			  
          #小計,値引き以外なら開始行をセット
          if start_line_number == 0
            start_line_number = dsdmc.line_number
          end
        else 
          if dsdmc.line_number < current_line_number
		        start_line_number = 0   #開始行を初期化
          elsif dsdmc.line_number > current_line_number
            #小計欄に来たら、処理を抜ける。
			      subtotal_exist = true
			      id_saved = dsdmc.id
               
			      break
			    end
        end
		   
        if dsdmc.line_number >= current_line_number   
          end_line_number = dsdmc.line_number  #終了行をセット
        end
      end  #do end
      
      #範囲内の計を集計
      if subtotal_exist == true
        subtotal_records = DeliverySlipDetailMiddleClassification.find(id_saved)
    
        if subtotal_records.present?
          delivery_slip_price = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:delivery_slip_price)
            execution_price = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:execution_price)
            labor_productivity_unit_total = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:labor_productivity_unit_total)

            subtotal_records.update_attributes!(:delivery_slip_price => delivery_slip_price, :execution_price => execution_price, 
                                                :labor_productivity_unit_total => labor_productivity_unit_total)
	      end
      end
    end
  end 
  #
  
  #行を全て＋１加算する。 add171120
  def increment_line_number
    status = false 
    if params[:delivery_slip_header_id].present?
	
      @search_records = DeliverySlipDetailMiddleClassification.where("delivery_slip_header_id = ?",
            params[:delivery_slip_header_id]).where(:delivery_slip_detail_large_classification_id => 
			        params[:delivery_slip_detail_large_classification_id])
      
      last_line_number = 0
	  
      if @search_records.present?
        @search_records.order("line_number desc").each do |ddmc|
	        if ddmc.line_number.present?
	          ddmc.line_number += 1
            #ループの初回が、最終レコードのになるので、行を最終行として保存する
            if last_line_number == 0
              last_line_number = ddmc.line_number
            end
            #
	          ddmc.update_attributes!(:line_number => ddmc.line_number)
	  	      status = true
	        end
        end
		
	      #最終行を書き込む
        if status == true
          delivery_slip_detail_large_classifiations = DeliverySlipDetailLargeClassification.where(["delivery_slip_header_id = ? and id = ?", 
		         params[:delivery_slip_header_id],  
		         params[:delivery_slip_detail_large_classification_id]]).first
		   
          if delivery_slip_detail_large_classifiations.present?
            delivery_slip_detail_large_classifiations.update_attributes!(:last_line_number => last_line_number)
          end
        end  #do end
      end  
    end  
  
    return status
	
  end
  
  def working_middle_item_select
    @working_middle_item_name = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_middle_item_name).flatten.join(" ")
  end
  def working_middle_specification_select
    @working_middle_specification = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_middle_specification).flatten.join(" ")
  
    #add171124
    @working_middle_item_category_id  = WorkingMiddleItem.with_category.where(:id => params[:id]).pluck("working_categories.category_name, working_categories.id")
	  #登録済みと異なるケースもあるので、任意で変更もできるように全て値をセット
	  @working_middle_item_category_id  += WorkingCategory.all.pluck("working_categories.category_name, working_categories.id")
	  #
  
    @working_middle_item_short_name = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_middle_item_short_name).flatten.join(" ")
  end
  def working_unit_price_select
    @working_unit_price = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_unit_price).flatten.join(" ")
  end
  def execution_unit_price_select
    @execution_unit_price = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:execution_unit_price).flatten.join(" ")
  end
  
  #使用材料id(うまくいかないので保留・・・)
  def material_id_select
    
    #@material_id = WorkingMiddleItem.with_material.where(:id => params[:id]).pluck("material_masters.material_name, material_masters.id")
    #@material_id = WorkingMiddleItem.with_material.where(:id => params[:id]).pluck("material_masters.material_code, material_masters.id")
    @material_id = WorkingMiddleItem.with_material.where(:id => params[:id]).pluck("material_masters.material_code") 
    @material_id.push(MaterialMaster.all.pluck("material_masters.material_code") + MaterialMaster.all.pluck("material_masters.id"))
    @material_id.flatten!        

    #未登録の場合はデフォルト値をセット
    if @material_id.blank?
      @material_id  = [["-",1]]
    end
     
    #未登録(-)の場合はセットしない。
    if @material_id  == [["-",1]]
      MaterialMaster.all.pluck("material_masters.material_name, id")
    end 
  end
  #使用材料名
  def working_material_name_select
    @working_material_name = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_material_name).flatten.join(" ")
  end
  #材料単価
  def material_unit_price_select
    @material_unit_price = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_unit_price).flatten.join(" ")
  end
  #労務単価
  def labor_unit_price_select
    @labor_unit_price = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:labor_unit_price).flatten.join(" ")
  end
  #歩掛り
  def labor_productivity_unit_select
    @labor_productivity_unit = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:labor_productivity_unit).flatten.join(" ")
  end
  #歩掛計
  def labor_productivity_unit_total_select
    @labor_productivity_unit_total = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:labor_productivity_unit_total).flatten.join(" ")
  end
  #使用材料
  def material_quantity_select
    @material_quantity = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_quantity).flatten.join(" ")
  end
  #付属品等
  def accessory_cost_select
    @accessory_cost = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:accessory_cost).flatten.join(" ")
  end
  #材料費等
  def material_cost_total_select
    @material_cost_total = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_cost_total).flatten.join(" ")
  end
  #労務費等
  def labor_cost_total_select
    @labor_cost_total = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:labor_cost_total).flatten.join(" ")
  end
  #その他
  def other_cost_select
    @other_cost = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:other_cost).flatten.join(" ")
  end
  #使用材料名(材料M)
  def m_working_material_name_select
    @m_working_material_name = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_name).flatten.join(" ")
  end
  #材料単価(材料M)
  def m_material_unit_price_select
    @m_material_unit_price = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:last_unit_price).flatten.join(" ")
  end
  
  #見出し→品目絞り込み用
  def delivery_slip_detail_large_classification_id_select
    @delivery_slip_detail_large_classification = DeliverySlipDetailLargeClassification.where(:delivery_slip_header_id => params[:delivery_slip_header_id]).where("id is NOT NULL").pluck(:working_large_item_name, :id)
  end
  
  #単位
  def working_unit_id_select
    @working_unit_id  = WorkingMiddleItem.with_unit.where(:id => params[:id]).pluck("working_units.working_unit_name, working_units.id")
	 
	  #登録済み単位と異なるケースもあるので、任意で変更もできるように全ての単位をセット
    unit_all = WorkingUnit.all.pluck("working_units.working_unit_name, working_units.id")
    @working_unit_id = @working_unit_id + unit_all
  end
  
  #単位名
  def working_unit_name_select
    @working_unit_name = WorkingUnit.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_unit_name).flatten.join(" ")
  end
  
  #add170223
  #歩掛り(配管配線集計用)
  def LPU_piping_wiring_select
    @labor_productivity_unit = DeliverySlipDetailMiddleClassification.sum_LPU_PipingWiring(params[:delivery_slip_header_id], params[:delivery_slip_detail_large_classification_id])
    @labor_productivity_unit_total = DeliverySlipDetailMiddleClassification.sum_LPUT_PipingWiring(params[:delivery_slip_header_id], params[:delivery_slip_detail_large_classification_id])
  
    #add180105金額計追加
    @delivery_slip_price = DeliverySlipDetailMiddleClassification.sum_delivery_slip_price_PipingWiring(params[:delivery_slip_header_id], params[:delivery_slip_detail_large_classification_id])
    @execution_price = DeliverySlipDetailMiddleClassification.sum_execution_price_PipingWiring(params[:delivery_slip_header_id], params[:delivery_slip_detail_large_classification_id])
    ###
  end
  #歩掛り(機器取付集計用)
  def LPU_equipment_mounting_select
    @labor_productivity_unit = DeliverySlipDetailMiddleClassification.sum_LPU_equipment_mounting(params[:delivery_slip_header_id], params[:delivery_slip_detail_large_classification_id])
    @labor_productivity_unit_total = DeliverySlipDetailMiddleClassification.sum_LPUT_equipment_mounting(params[:delivery_slip_header_id], params[:delivery_slip_detail_large_classification_id])
  
    #add180105金額計追加
    @delivery_slip_price = DeliverySlipDetailMiddleClassification.sum_delivery_slip_price_equipment_mounting(params[:delivery_slip_header_id], params[:delivery_slip_detail_large_classification_id])
    @execution_price = DeliverySlipDetailMiddleClassification.sum_execution_price_equipment_mounting(params[:delivery_slip_header_id], params[:delivery_slip_detail_large_classification_id])
    ###
  end
  #歩掛り(労務費集計用)
  def LPU_labor_cost_select
    @labor_productivity_unit = DeliverySlipDetailMiddleClassification.sum_LPU_labor_cost(params[:delivery_slip_header_id], params[:delivery_slip_detail_large_classification_id])
    @labor_productivity_unit_total = DeliverySlipDetailMiddleClassification.sum_LPUT_labor_cost(params[:delivery_slip_header_id], params[:delivery_slip_detail_large_classification_id])
  
    #add180105金額計追加
    @delivery_slip_price = DeliverySlipDetailMiddleClassification.sum_delivery_slip_price_labor_cost(params[:delivery_slip_header_id], params[:delivery_slip_detail_large_classification_id])
    @execution_price = DeliverySlipDetailMiddleClassification.sum_execution_price_labor_cost(params[:delivery_slip_header_id], params[:delivery_slip_detail_large_classification_id])
    ###
  end
  
  #歩掛りの集計を最新のもので書き換える。
  def update_labor_productivity_unit_summary
    delivery_slip_header_id = params[:delivery_slip_detail_middle_classification][:delivery_slip_header_id]
    delivery_slip_detail_large_classification_id = params[:delivery_slip_detail_middle_classification][:delivery_slip_detail_large_classification_id]
	
    #upd170308 construction_typeを定数化・順番変更
	
    #配管配線の計を更新(construction_type=x)
    @DSDMC_piping_wiring = DeliverySlipDetailMiddleClassification.where(delivery_slip_header_id: delivery_slip_header_id, 
                          delivery_slip_detail_large_classification_id: delivery_slip_detail_large_classification_id, construction_type: $INDEX_PIPING_WIRING_CONSTRUCTION).first
    if @DSDMC_piping_wiring.present?
      labor_productivity_unit_total = DeliverySlipDetailMiddleClassification.sum_LPUT_PipingWiring(delivery_slip_header_id, delivery_slip_detail_large_classification_id)
      @DSDMC_piping_wiring.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
    end
    
    #機器取付の計を更新(construction_type=x)
    @DSDMC_equipment_mounting = DeliverySlipDetailMiddleClassification.where(delivery_slip_header_id: delivery_slip_header_id, 
                          delivery_slip_detail_large_classification_id: delivery_slip_detail_large_classification_id, construction_type: $INDEX_EUIPMENT_MOUNTING).first
    if @DSDMC_equipment_mounting.present?
      labor_productivity_unit_total = DeliverySlipDetailMiddleClassification.sum_LPUT_equipment_mounting(delivery_slip_header_id, delivery_slip_detail_large_classification_id)
      @DSDMC_equipment_mounting.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
    end
    
    #労務費の計を更新(construction_type=x)
    @DSDMC_labor_cost = DeliverySlipDetailMiddleClassification.where(delivery_slip_header_id: delivery_slip_header_id, 
                          delivery_slip_detail_large_classification_id: delivery_slip_detail_large_classification_id, construction_type: $INDEX_LABOR_COST).first
    if @DSDMC_labor_cost.present?
      labor_productivity_unit_total = DeliverySlipDetailMiddleClassification.sum_LPUT_labor_cost(delivery_slip_header_id, delivery_slip_detail_large_classification_id)
      @DSDMC_labor_cost.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
    end
  
  end
  #固有マスター関連取得 add171125
  def working_specific_middle_item_select
    @working_middle_item_name = WorkingSpecificMiddleItem.where(:id => params[:working_specific_middle_item_id]).where("id is NOT NULL").pluck(:working_middle_item_name).flatten.join(" ")
    @working_middle_item_short_name = WorkingSpecificMiddleItem.where(:id => params[:working_specific_middle_item_id]).where("id is NOT NULL").pluck(:working_middle_item_short_name).flatten.join(" ")

    @working_middle_specification = WorkingSpecificMiddleItem.where(:id => params[:working_specific_middle_item_id]).where("id is NOT NULL").pluck(:working_middle_specification).flatten.join(" ")
     
    #単位
    @working_unit_id  = WorkingSpecificMiddleItem.with_unit.where(:id => params[:working_specific_middle_item_id]).pluck("working_units.working_unit_name, working_units.id")
    #登録済み単位と異なるケースもあるので、任意で変更もできるように全ての単位をセット
    unit_all = WorkingUnit.all.pluck("working_units.working_unit_name, working_units.id")
    @working_unit_id = @working_unit_id + unit_all
    #
	 
    @working_unit_price = WorkingSpecificMiddleItem.where(:id => params[:working_specific_middle_item_id]).where("id is NOT NULL").pluck(:working_unit_price).flatten.join(" ")
    @execution_unit_price = WorkingSpecificMiddleItem.where(:id => params[:working_specific_middle_item_id]).where("id is NOT NULL").pluck(:execution_unit_price).flatten.join(" ")
	 
    @labor_productivity_unit = WorkingSpecificMiddleItem.where(:id => params[:working_specific_middle_item_id]).where("id is NOT NULL").pluck(:labor_productivity_unit).flatten.join(" ")
    #歩掛計
    @labor_productivity_unit_total = WorkingSpecificMiddleItem.where(:id => params[:working_specific_middle_item_id]).where("id is NOT NULL").pluck(:labor_productivity_unit_total).flatten.join(" ")
    
  end
  #add end
  
  #カテゴリー保持フラグの取得
  #add180210
  def get_category_save_flag
    if @delivery_slip_detail_middle_classification.delivery_slip_header_id.present?
      @delivery_slip_headers = DeliverySlipHeader.find_by(id: @delivery_slip_detail_middle_classification.delivery_slip_header_id)
      if @delivery_slip_headers.present?
        @category_save_flag = @delivery_slip_headers.category_saved_flag
        #未入力なら、１をセット。
        if @category_save_flag.nil?
          @category_save_flag = 1
        end
        @delivery_slip_detail_middle_classification.category_save_flag_child = @category_save_flag
      end
    end
  end
  #カテゴリー、サブカテゴリーの取得
  #add180210
  def get_category_id
    if @delivery_slip_headers.present? && @category_save_flag == 1
      category_id = @delivery_slip_headers.category_saved_id
      subcategory_id = @delivery_slip_headers.subcategory_saved_id
      @delivery_slip_detail_middle_classification.working_middle_item_category_id_call = category_id
      @delivery_slip_detail_middle_classification.working_middle_item_subcategory_id_call = subcategory_id
    end
  end
  #カテゴリー保持フラグの保存
  #add180210
  def set_category_save_flag
    if @delivery_slip_detail_large_classification.delivery_slip_header_id.present?
      @delivery_slip_headers = DeliverySlipHeader.find_by(id: @delivery_slip_detail_large_classification.delivery_slip_header_id)
      if @delivery_slip_headers.present?
        delivery_slip_header_params = { category_saved_flag: params[:delivery_slip_detail_middle_classification][:category_save_flag_child], 
                                       category_saved_id: params[:delivery_slip_detail_middle_classification][:working_middle_item_category_id_call],
                                       subcategory_saved_id: params[:delivery_slip_detail_middle_classification][:working_middle_item_subcategory_id_call]}
        @delivery_slip_headers.attributes = delivery_slip_header_params
        @delivery_slip_headers.save(:validate => false)
      end
    end
  end
  
  #add180426
  #明細→内訳へのデータ移行
  def move_middle_to_large
    d_s_d_m_cs = 
        DeliverySlipDetailMiddleClassification.where(:delivery_slip_header_id => params[:delivery_slip_header_id]).
             where(:delivery_slip_detail_large_classification_id => params[:delivery_slip_detail_large_classification_id])
    if d_s_d_m_cs.present?
      success_flag = true
      
      #内訳、行数の最大値を取得する
      line_number = DeliverySlipDetailLargeClassification.
        where(:delivery_slip_header_id => params[:delivery_slip_header_id]).maximum(:line_number)
      
      #内訳が１件しかない場合は、行数１からカウントアップさせるようにする
      if line_number == 1
        line_number = 0
      end
      
      d_s_d_m_cs.each do |d_s_d_m_c|
        
        line_number += 1
        
        delivery_slip_detail_large_classification_params = 
          {delivery_slip_header_id: params[:delivery_slip_header_id], delivery_slip_items_division_id: d_s_d_m_c.delivery_slip_item_division_id,
           working_large_item_id: d_s_d_m_c.working_middle_item_id, working_specific_middle_item_id: d_s_d_m_c.working_specific_middle_item_id,
           working_large_item_name: d_s_d_m_c.working_middle_item_name, working_large_item_short_name: d_s_d_m_c.working_middle_item_short_name,
           working_middle_item_category_id: d_s_d_m_c.working_middle_item_category_id, working_middle_item_category_id_call: d_s_d_m_c.working_middle_item_category_id_call,
           working_middle_item_subcategory_id: d_s_d_m_c.working_middle_item_subcategory_id, working_middle_item_subcategory_id_call: d_s_d_m_c.working_middle_item_subcategory_id_call,
           working_large_specification: d_s_d_m_c.working_middle_specification, line_number: line_number, quantity: d_s_d_m_c.quantity, execution_quantity: d_s_d_m_c.execution_quantity,
           working_unit_id: d_s_d_m_c.working_unit_id, working_unit_name: d_s_d_m_c.working_unit_name, working_unit_price: d_s_d_m_c.working_unit_price, 
           delivery_slip_price: d_s_d_m_c.delivery_slip_price, execution_unit_price: d_s_d_m_c.execution_unit_price, execution_price: d_s_d_m_c.execution_price, labor_productivity_unit: d_s_d_m_c.labor_productivity_unit, 
           labor_productivity_unit_total: d_s_d_m_c.labor_productivity_unit_total, remarks: d_s_d_m_c.remarks, construction_type: d_s_d_m_c.construction_type, 
           piping_wiring_flag: d_s_d_m_c.piping_wiring_flag, equipment_mounting_flag: d_s_d_m_c.equipment_mounting_flag, labor_cost_flag: d_s_d_m_c.labor_cost_flag
          }
                                                         
        delivery_slip_detail_large_classification = DeliverySlipDetailLargeClassification.new(delivery_slip_detail_large_classification_params)
        unless delivery_slip_detail_large_classification.save!(:validate => false)
          success_flag = false
        end 
      end
      if success_flag == true
        #既存のデータを削除
        #明細データ削除
        d_s_d_m_cs.destroy_all
        #内訳データ削除
        DeliverySlipDetailLargeClassification.find(params[:delivery_slip_detail_large_classification_id]).destroy
        
        if save_price_to_headers_move(line_number) == true
        #合計値を一覧データへ書き込み
        
          #リダイレクト
          #(これをしないとパラメータが残る)
          respond_to do |format|
            format.html {redirect_to delivery_slip_detail_large_classifications_path(:delivery_slip_header_id => params[:delivery_slip_header_id], 
                    :delivery_slip_header_name => params[:delivery_slip_header_name], :working_large_item_name => params[:working_large_item_name], 
                    :working_large_specification => params[:working_large_specification] )}
          end
        end
      end
    end
  end
  
  
  #del180822
  #納品金額トータル
  #def delivery_slip_total_price_large
  #   @delivery_slip_total_price_large = DeliverySlipDetailLargeClassification.where(["delivery_slip_header_id = ?", 
  #        params[:delivery_slip_header_id]]).sumpriceDeliverySlip
  #end 
  #実行金額トータル
  #def execution_total_price_Large
  #   @execution_total_price_Large = DeliverySlipDetailLargeClassification.where(["delivery_slip_header_id = ?", 
  #      params[:delivery_slip_header_id]]).sumpriceExecution
  #end
  
  #見出データへ合計保存用
  def save_price_to_headers_move(line_number)
     delivery_slip_header = DeliverySlipHeader.find(params[:delivery_slip_header_id])
     
     status = false
     if delivery_slip_header.present? 
         #請求金額
          delivery_slip_header.delivery_amount = delivery_slip_total_price_large
		  
          #実行金額
          delivery_slip_header.execution_amount = execution_total_price_Large
          
          #最終行
          delivery_slip_header.last_line_number = line_number
          
          status = delivery_slip_header.save
          
     end 
     return status
     
  end
  #(ここまで)内訳→明細へのデータ移行
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivery_slip_detail_middle_classification
      @delivery_slip_detail_middle_classification = DeliverySlipDetailMiddleClassification.find(params[:id])
    end
    
	  #add171016
    def initialize_sort
	    $not_sort_dm = true
    end
	
    #以降のレコードの行番号を全てインクリメントする
    def line_insert
      DeliverySlipDetailMiddleClassification.where(["delivery_slip_header_id = ? and delivery_slip_detail_large_classification_id = ? and line_number >= ? and id != ?", @delivery_slip_detail_middle_classification.delivery_slip_header_id, @delivery_slip_detail_middle_classification.delivery_slip_detail_large_classification_id, @delivery_slip_detail_middle_classification.line_number, @delivery_slip_detail_middle_classification.id]).update_all("line_number = line_number + 1")
       
      #最終行番号も取得しておく
      @max_line_number = DeliverySlipDetailMiddleClassification.
        where(["delivery_slip_header_id = ? and delivery_slip_detail_large_classification_id = ? and line_number >= ? and id != ?", @delivery_slip_detail_middle_classification.delivery_slip_header_id, 
      @delivery_slip_detail_middle_classification.delivery_slip_detail_large_classification_id, @delivery_slip_detail_middle_classification.line_number, 
      @delivery_slip_detail_middle_classification.id]).maximum(:line_number)
    end 

    #納品品目データへ合計保存用　
    def save_price_to_large_classifications
      @delivery_slip_detail_large_classification = DeliverySlipDetailLargeClassification.where(["delivery_slip_header_id = ? and id = ?", @delivery_slip_detail_middle_classification.delivery_slip_header_id,@delivery_slip_detail_middle_classification.delivery_slip_detail_large_classification_id]).first

      if @delivery_slip_detail_large_classification.present?
      
        #add200917
        #数量が１より大きい場合の対応
        tmp_delivery_slip_total_price = delivery_slip_total_price
        tmp_execution_total_price = execution_total_price
        
        if @delivery_slip_detail_large_classification.quantity > 1
          @delivery_slip_detail_large_classification.working_unit_price = delivery_slip_total_price
          @delivery_slip_detail_large_classification.execution_unit_price = execution_total_price
          
          #金額は数量*単価でかける
          tmp_delivery_slip_total_price = delivery_slip_total_price.to_i * @delivery_slip_detail_large_classification.quantity
          tmp_execution_total_price = execution_total_price.to_i * @delivery_slip_detail_large_classification.quantity
        end 
        #
      
        #見積金額
        #@delivery_slip_detail_large_classification.delivery_slip_price = delivery_slip_total_price
        @delivery_slip_detail_large_classification.delivery_slip_price = tmp_delivery_slip_total_price
        #実行金額
        #@delivery_slip_detail_large_classification.execution_price = execution_total_price
        @delivery_slip_detail_large_classification.execution_price = tmp_execution_total_price
        #歩掛り
        @delivery_slip_detail_large_classification.labor_productivity_unit = labor_total
        #歩掛計
        @delivery_slip_detail_large_classification.labor_productivity_unit_total = labor_all_total
        @delivery_slip_detail_large_classification.save
    
        #見出データへも合計保存
        save_price_to_headers
      end

    end

    #見出データへ合計保存用
    def save_price_to_headers
      @delivery_slip_header = DeliverySlipHeader.find(@delivery_slip_detail_large_classification.delivery_slip_header_id)
       
      if @delivery_slip_header.present? 
        #請求金額
        @delivery_slip_header.delivery_amount = delivery_slip_total_price_Large
		  
		    #binding.pry
		  
        #実行金額
        @delivery_slip_header.execution_amount = execution_total_price_Large
        @delivery_slip_header.save
      end 
    end
   
    #見出しデータへ最終行番号保存用
    def delivery_slip_dlc_set_last_line_number
      @delivery_slip_detail_large_classifiations = DeliverySlipDetailLargeClassification.where(["delivery_slip_header_id = ? and id = ?", @delivery_slip_detail_middle_classification.delivery_slip_header_id,@delivery_slip_detail_middle_classification.delivery_slip_detail_large_classification_id]).first
      check_flag = false
      if @delivery_slip_detail_large_classifiations.last_line_number.nil? 
        check_flag = true
      else
	      if (@delivery_slip_detail_large_classifiations.last_line_number < @max_line_number) then
          check_flag = true
        end
      end
      if (check_flag == true)
        delivery_slip_dlc_params = { last_line_number:  @max_line_number}
        if @delivery_slip_detail_large_classifiations.present?
          #@delivery_slip_detail_large_classifiations.update(delivery_slip_dlc_params)
          #upd170412
          @delivery_slip_detail_large_classifiations.attributes = delivery_slip_dlc_params
          @delivery_slip_detail_large_classifiations.save(:validate => false)
        end 
      end 
    end
    #行番号を取得し、インクリメントする。（新規用）
    def get_line_number
      @line_number = 1
	  
      if $sort_dm != "asc"   #add171120
        if @delivery_slip_detail_middle_classification.delivery_slip_header_id.present? && @delivery_slip_detail_middle_classification.delivery_slip_detail_large_classification_id.present?
          @delivery_slip_detail_large_classifiations = DeliverySlipDetailLargeClassification.where(["delivery_slip_header_id = ? and id = ?", @delivery_slip_detail_middle_classification.delivery_slip_header_id,@delivery_slip_detail_middle_classification.delivery_slip_detail_large_classification_id]).first
		 
          if @delivery_slip_detail_large_classifiations.present?
            if @delivery_slip_detail_large_classifiations.last_line_number.present?
              @line_number = @delivery_slip_detail_large_classifiations.last_line_number + 1
            end
          end
        end
      else
        #add171120
        #昇順ソートしている場合は、行を最終ではなく先頭にする。
        #登録済みレコードの行を全て事前に加算する
        status = increment_line_number
        
        #インクリメント失敗していたら、行は０にする。
        if status == false
          @line_number = 0
        end
      end
	  
	    @delivery_slip_detail_middle_classification.line_number = @line_number
    end

    # ストロングパラメータ
    # Never trust parameters from the scary internet, only allow the white list through.
    def delivery_slip_detail_middle_classification_params
      params.require(:delivery_slip_detail_middle_classification).permit(:delivery_slip_header_id, :delivery_slip_detail_large_classification_id, 
      :delivery_slip_item_division_id, :working_middle_item_id, :working_middle_item_name, :working_middle_item_short_name, :working_middle_item_category_id, :working_middle_item_category_id_call, 
      :working_middle_item_subcategory_id, :working_middle_item_subcategory_id_call, :line_number, :working_middle_specification, :quantity, :execution_quantity, :working_unit_id, :working_unit_name, :working_unit_price, :delivery_slip_price,
      :execution_unit_price, :execution_price, :material_id, :material_id, :working_material_name, :material_unit_price, 
      :labor_unit_price, :labor_productivity_unit, :labor_productivity_unit_total, :material_quantity, :accessory_cost, :material_cost_total, 
      :labor_cost_total, :other_cost, :remarks, :construction_type, :piping_wiring_flag, :equipment_mounting_flag, 
      :labor_cost_flag)
    end
end
