class QuotationDetailMiddleClassificationsController < ApplicationController
  before_action :set_quotation_detail_middle_classification, only: [:show, :edit, :update, :destroy]
  
  #add171016
  before_action :initialize_sort, only: [:show, :new, :edit, :update, :destroy ]
  
  #add180210
  before_action :set_action_flag, only: [:new, :edit ]
  
  @@new_flag = []
  
    # GET /quotation_detail_middle_classifications
  # GET /quotation_detail_middle_classifications.json
  def index
    
	
	#@quotation_detail_middle_classifications = QuotationDetailMiddleClassification.all
    
    @null_flag = ""
    @number = 1
	
    #ransack保持用コード
    if params[:quotation_header_id].present?
	  @quotation_header_id = params[:quotation_header_id]
      if params[:working_large_item_name].present?
	    @working_large_item_name = [params[:working_large_item_name], params[:working_large_specification]]
      end
	  if params[:quotation_detail_large_classification_id].present?
	    @quotation_detail_large_classification_id = params[:quotation_detail_large_classification_id]
	  end
	end
    
  
    #明細データ見出用
    if params[:quotation_header_name].present?
      @quotation_header_name = params[:quotation_header_name]
    end
    #
	if @quotation_header_id.present?
    
      query = {"quotation_header_id_eq"=>"", "with_header_id"=> @quotation_header_id, "with_large_item"=> @working_large_item_name , 
             "working_middle_item_name_eq"=>""}

      @null_flag = "1"
    end 
    
	
    if @null_flag == "" 
      #ransack保持用コード
      query = params[:q]
      query ||= eval(cookies[:recent_search_history].to_s)
    end
	
    #@q = QuotationDetailMiddleClassification.ransack(params[:q]) 
    #ransack保持用--上記はこれに置き換える
    @q = QuotationDetailMiddleClassification.ransack(query)   
    
    #ransack保持用コード
    if @null_flag == "" 
	  search_history = {
       value: params[:q],
       #expires: 24.hours.from_now
       expires: 480.minutes.from_now
      }
      cookies[:recent_search_history] = search_history if params[:q].present?
	  
	end
	#
	

    @quotation_detail_middle_classifications = @q.result(distinct: true)
	
	
	#add171016
	#ビューでのソート処理追加
	if (params[:q].present? && params[:q][:s].present?) || $sort_qm != nil
	    
		#order順のパラメータ(asc/desc)がなぜか１パターンしか入らないので、カラム強制にセットする。
	    column_name = "line_number"
	    
		if $not_sort_qm != true
		#ここでにソートを切り替える。（パラメータで入ればベストだが）
		#（モーダル編集、行ソートでこの処理をしないようにしている）
		
		  if params[:q].present? 
            if $sort_qm.nil?
	           $sort_qm = "desc"
	        end   
 
		    if $sort_qm != "asc"
		      $sort_qm = "asc"
		    else
		      $sort_qm = "desc"
		    end
	      end
		else
		  $not_sort_qm = false
		end
		
		#並び替えする（降順/昇順）
		if $sort_qm == "asc"
	      @quotation_detail_middle_classifications = @quotation_detail_middle_classifications.order(column_name + " asc")
		elsif $sort_qm == "desc"
	      @quotation_detail_middle_classifications = @quotation_detail_middle_classifications.order(column_name + " desc")
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
    
  #ドラッグ＆ドロップによる並び替え機能(seqをセットする)
  def reorder
    
	$not_sort_qm = true               #add171016
	
    if $sort_qm != "asc"              #add171016
  	  row = params[:row].split(",").reverse    #ビューの並びが逆のため、パラメータの配列を逆順でセットさせる。
    else                              #add171016
	  row = params[:row].split(",")   #add171016
	end
	
	
	#row.each_with_index {|row, i| QuotationDetailLargeClassification.update(row, {:seq => i})}
	#行番号へセットするため、配列は１から開始させる。
	row.each_with_index {|row, i| QuotationDetailMiddleClassification.update(row, {:line_number => i + 1})}
    render :text => "OK"

    #小計を全て再計算する
    recalc_subtotal_all

  end
  
  # GET /quotation_detail_middle_classifications/1
  # GET /quotation_detail_middle_classifications/1.json
  def show
  end

  # GET /quotation_detail_middle_classifications/new
  def new
  
    @quotation_detail_middle_classification = QuotationDetailMiddleClassification.new
    @quotation_detail_large_classification = QuotationDetailLargeClassification.all
    
    ###
    #初期値をセット(見出画面からの遷移時のみ)
    @@new_flag = params[:new_flag]

    if params[:quotation_header_id].present?
      @quotation_header_id = params[:quotation_header_id]
      #add180803
      #確定済みのものは、変更できないようにする
      quotation_header = QuotationHeader.find(params[:quotation_header_id])
      if quotation_header.present?
        if quotation_header.fixed_flag == 1
          @status = "fixed"
        else
          @status = "not_fixed"
        end
      end
      #
    end
	
    if @@new_flag == "1"
       @quotation_detail_middle_classification.quotation_header_id ||= @quotation_header_id
	   if params[:quotation_detail_large_classification_id].present?
         @quotation_detail_middle_classification.quotation_detail_large_classification_id ||= params[:quotation_detail_large_classification_id]
	   else
		 @quotation_detail_middle_classification.quotation_detail_large_classification_id ||= @quotation_detail_large_classification_id
       end
    end 
    
	#行番号を取得する
    get_line_number
    
    #カテゴリー保持フラグを取得
    #add180210
    get_category_save_flag
    get_category_id
    
  end

  # GET /quotation_detail_middle_classifications/1/edit
  def edit
    #カテゴリー保持フラグを取得
    #add180210
    get_category_save_flag
    
    #add180803
    #確定済みのものは、変更できないようにする
    if params[:quotation_header_id].present?
      quotation_header = QuotationHeader.find(params[:quotation_header_id])
      if quotation_header.present?
        if quotation_header.fixed_flag == 1
          @status = "fixed"
        else
          @status = "not_fixed"
        end
      end
    end
    #
    
  end

  # POST /quotation_detail_middle_classifications
  # POST /quotation_detail_middle_classifications.json
  def create
    
	#作業明細マスターの更新
	update_working_middle_item
	
    ###モーダル化対応
    @quotation_detail_middle_classification = QuotationDetailMiddleClassification.create(quotation_detail_middle_classification_params)
    
    #歩掛りの集計を最新のもので書き換える。
    update_labor_productivity_unit_summary
	#小計を再計算する
	recalc_subtotal  
	
     #手入力用IDの場合は、単位マスタへも登録する。
    @working_unit = nil
    if @quotation_detail_middle_classification.working_unit_id == 1
       
	   #既に登録してないかチェック
       @check_unit = WorkingUnit.find_by(working_unit_name: @quotation_detail_middle_classification.working_unit_name)
       
	   if @check_unit.nil?
          unit_params = { working_unit_name:  @quotation_detail_middle_classification.working_unit_name }
          @working_unit = WorkingUnit.create(unit_params)
		else
		  @working_unit = @check_unit
	   end
    end
      


     #品目データの金額を更新
    save_price_to_large_classifications
    #行挿入する 
	@max_line_number = @quotation_detail_middle_classification.line_number
    if (params[:quotation_detail_middle_classification][:check_line_insert] == 'true')
      line_insert
    end
    
    #行番号の最終を書き込む
    quotation_dlc_set_last_line_number
	
    #add 180210
    #カテゴリー保持状態の保存
    set_category_save_flag
    
	if params[:quotation_detail_middle_classification][:quotation_header_id].present?
      @quotation_header_id = params[:quotation_detail_middle_classification][:quotation_header_id]
    end
	if params[:quotation_detail_middle_classification][:quotation_detail_large_classification_id].present?
      @quotation_detail_large_classification_id = params[:quotation_detail_middle_classification][:quotation_detail_large_classification_id]
    end
	#
	
	@quotation_detail_middle_classifications = 
        QuotationDetailMiddleClassification.where(:quotation_header_id => @quotation_header_id).
             where(:quotation_detail_large_classification_id => @quotation_detail_large_classification_id)

    ###
  end
  
  
  
  # PATCH/PUT /quotation_detail_middle_classifications/1
  # PATCH/PUT /quotation_detail_middle_classifications/1.json
  def update
    
	#作業明細マスターの更新
	update_working_middle_item
    
    @quotation_detail_middle_classification.update(quotation_detail_middle_classification_params)
    
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
	@max_line_number = @quotation_detail_middle_classification.line_number
    if (params[:quotation_detail_middle_classification][:check_line_insert] == 'true')
       line_insert
    end
    
	#行番号の最終を書き込む
    quotation_dlc_set_last_line_number

    #手入力用IDの場合は、単位マスタへも登録する。
    @working_unit = nil
	
    if @quotation_detail_middle_classification.working_unit_id == 1
       
       #既に登録してないかチェック
       @check_unit = WorkingUnit.find_by(working_unit_name: @quotation_detail_middle_classification.working_unit_name)
       
	   if @check_unit.nil?
          unit_params = { working_unit_name:  @quotation_detail_middle_classification.working_unit_name }
		  
          @working_unit = WorkingUnit.create(unit_params)
	   else
	      @working_unit = @check_unit
	   end
    end
	
	
    #  #同様に手入力用IDの場合、明細(中分類)マスターへ登録する。
    #  if @quotation_detail_middle_classification.working_middle_item_id == 1
#		 @check_item = WorkingMiddleItem.find_by(working_middle_item_name: @quotation_detail_middle_classification.working_middle_item_name , working_middle_specification: @quotation_detail_middle_classification.working_middle_specification)
 #     else
#	     #手入力以外の場合   #add170714
#		 @check_item = WorkingMiddleItem.find(@quotation_detail_middle_classification.working_middle_item_id)
#	  end 
#		 @working_unit_id_params = @quotation_detail_middle_classification.working_unit_id
#		 
 #        if @working_unit.present?
#		   
#		   @working_unit_all_params = WorkingUnit.find_by(working_unit_name: @quotation_detail_middle_classification.working_unit_name)
#		   @working_unit_id_params = @working_unit_all_params.id
#		 end 
 
         #if @check_item.nil?   del170714
 		   
#		  large_item_params = nil   #add170714
		  
#		  #add170823
#		  #短縮名（手入力）
#		  if params[:quotation_detail_middle_classification][:working_middle_item_short_name_manual] != "<手入力>"
#		    working_middle_item_short_name_manual = params[:quotation_detail_middle_classification][:working_middle_item_short_name_manual]
#		  else
#		    working_middle_item_short_name_manual = ""
#		  end
#		  ##
		  
#		  # 全選択の場合
#		  #upd170823 短縮名追加
 #         if params[:quotation_detail_middle_classification][:check_update_all] == "true" 
#		      large_item_params = { working_middle_item_name:  @quotation_detail_middle_classification.working_middle_item_name, 
 #                                   working_middle_item_short_name: working_middle_item_short_name_manual, 
#working_middle_specification:  @quotation_detail_middle_classification.working_middle_specification, 
#working_unit_id: @working_unit_id_params, 
#working_unit_price: @quotation_detail_middle_classification.working_unit_price,
#execution_unit_price: @quotation_detail_middle_classification.execution_unit_price,
#material_id: @quotation_detail_middle_classification.material_id,
#working_material_name: @quotation_detail_middle_classification.quotation_material_name,
#material_unit_price: @quotation_detail_middle_classification.material_unit_price,
#labor_unit_price: @quotation_detail_middle_classification.labor_unit_price,
#labor_productivity_unit: @quotation_detail_middle_classification.labor_productivity_unit,
#labor_productivity_unit_total: @quotation_detail_middle_classification.labor_productivity_unit_total,
#material_quantity: @quotation_detail_middle_classification.material_quantity,
#accessory_cost: @quotation_detail_middle_classification.accessory_cost,
#material_cost_total: @quotation_detail_middle_classification.material_cost_total,
#labor_cost_total: @quotation_detail_middle_classification.labor_cost_total,
#other_cost: @quotation_detail_middle_classification.other_cost
# }
            
               #@quotation_middle_item = WorkingMiddleItem.create(large_item_params)
#          else
		    
		     # アイテムのみ更新の場合
			 #upd170823 短縮名追加
#		     if params[:quotation_detail_middle_classification][:check_update_item] == "true"
#		       large_item_params = { working_middle_item_name:  @quotation_detail_middle_classification.working_middle_item_name, 
#                 working_middle_item_short_name: working_middle_item_short_name_manual, 
#                 working_middle_specification:  @quotation_detail_middle_classification.working_middle_specification,
#                 working_unit_id: @working_unit_id_params } 
			   
			     #@quotation_middle_item = WorkingMiddleItem.create(large_item_params)
#		     end
#          end
		 
          #upd170714
#		  if large_item_params.present?
#		     if @check_item.nil?
#		       @quotation_middle_item = WorkingMiddleItem.create(large_item_params)
#		     else
			 
#			   @quotation_middle_item = @check_item.update(large_item_params)
#		     end
#		  end
         #end del170714
    #end del170714
    ######################
    
	if params[:quotation_detail_middle_classification][:quotation_header_id].present?
      @quotation_header_id = params[:quotation_detail_middle_classification][:quotation_header_id]
    end
	if params[:quotation_detail_middle_classification][:quotation_detail_large_classification_id].present?
      @quotation_detail_large_classification_id = params[:quotation_detail_middle_classification][:quotation_detail_large_classification_id]
    end
	#
    
    @quotation_detail_middle_classifications = QuotationDetailMiddleClassification.where(:quotation_header_id => @quotation_header_id).
            where(:quotation_detail_large_classification_id => @quotation_detail_large_classification_id)
  end

  # DELETE /quotation_detail_middle_classifications/1
  # DELETE /quotation_detail_middle_classifications/1.json
  def destroy
	if params[:quotation_header_id].present?
	
      @quotation_header_id = params[:quotation_header_id]
      if params[:quotation_detail_large_classification_id].present?
          @quotation_detail_large_classification_id = params[:quotation_detail_large_classification_id]
      
          #add180803
          #確定済みのものは、変更できないようにする
          quotation_header = QuotationHeader.find(params[:quotation_header_id])
          if quotation_header.present?
            if quotation_header.fixed_flag == 1
              @status = "fixed"
            else
              @status = "not_fixed"
            end
          end
          #
      end
	end
  
    if @status != "fixed"
      @quotation_detail_middle_classification.destroy
    #respond_to do |format|
      #del180803
      #確定済みデータに警告を出すため、ここでリダイレクトさせない
	  #format.html {redirect_to quotation_detail_middle_classifications_path( :quotation_header_id => params[:quotation_header_id],
      #              :quotation_detail_large_classification_id => params[:quotation_detail_large_classification_id], 
	  #              :quotation_header_name => params[:quotation_header_name],
      #              :working_large_item_name => params[:working_large_item_name], :working_large_specification => params[:working_large_specification]
      #             )}
	  
	  #品目データの金額を更新
      save_price_to_large_classifications
	  
    #end
    end
  end
  
  #行を全て＋１加算する。 add171120
  def increment_line_number
    status = false 
    if params[:quotation_header_id].present?
	
	  @search_records = QuotationDetailMiddleClassification.where("quotation_header_id = ?",
            params[:quotation_header_id]).where(:quotation_detail_large_classification_id => 
			        params[:quotation_detail_large_classification_id])
      
	  last_line_number = 0
	  
	  if @search_records.present?
        @search_records.order("line_number desc").each do |qdmc|
	      if qdmc.line_number.present?
	        qdmc.line_number += 1
			#ループの初回が、最終レコードのになるので、行を最終行として保存する
		    if last_line_number == 0
			  last_line_number = qdmc.line_number
		    end
		    #
	        qdmc.update_attributes!(:line_number => qdmc.line_number)
	  	    status = true
	      end
        end
		
	    #最終行を書き込む
		if status == true
		  quotation_detail_large_classifiations = QuotationDetailLargeClassification.where(["quotation_header_id = ? and id = ?", 
		         params[:quotation_header_id],  
		            params[:quotation_detail_large_classification_id]]).first
		   
		  if quotation_detail_large_classifiations.present?
		    quotation_detail_large_classifiations.update_attributes!(:last_line_number => last_line_number)
		  end
		end
		
	  end
	end  
	
	return status
	
  end
  
  
  #作業明細マスターの更新
  def update_working_middle_item
  
      if params[:quotation_detail_middle_classification][:working_middle_item_id] == "1"
         
		 if params[:quotation_detail_middle_classification][:master_insert_flag] == "true"   #add171106
		   @check_item = WorkingMiddleItem.find_by(working_middle_item_name: params[:quotation_detail_middle_classification][:working_middle_item_name] , 
		     working_middle_specification: params[:quotation_detail_middle_classification][:working_middle_specification] )
	     else
		 #add171106 固有マスターより検索
		   @check_item = WorkingSpecificMiddleItem.find_by(working_middle_item_name: params[:quotation_detail_middle_classification][:working_middle_item_name] , 
		     quotation_header_id: params[:quotation_detail_middle_classification][:quotation_header_id] )
		 end
      else
	    #手入力以外の場合   
		 if params[:quotation_detail_middle_classification][:master_insert_flag] == "true"   #add171106
		   @check_item = WorkingMiddleItem.find(params[:quotation_detail_middle_classification][:working_middle_item_id])
		 else
		 #add171106 固有マスターより検索
		   if params[:quotation_detail_middle_classification][:working_middle_specific_item_id].present?
		     @check_item = WorkingSpecificMiddleItem.find(params[:quotation_detail_middle_classification][:working_middle_specific_item_id])
		   end
		 end
      end
		
		 @working_unit_id_params = params[:quotation_detail_middle_classification][:working_unit_id]
		 
         if @working_unit.present?
           @working_unit_all_params = WorkingUnit.find_by(working_unit_name: params[:quotation_detail_middle_classification][:working_unit_name] )
		   @working_unit_id_params = @working_unit_all_params.id
		 end 
 		  
          large_item_params = nil   
		  
		  #短縮名（手入力）
		  if params[:quotation_detail_middle_classification][:working_middle_item_short_name_manual] != "<手入力>"
		    working_middle_item_short_name_manual = params[:quotation_detail_middle_classification][:working_middle_item_short_name_manual]
		  else
		    working_middle_item_short_name_manual = ""
		  end
		  ##
		  
		  # 全選択の場合
		  #upd170823 短縮名追加
		  if params[:quotation_detail_middle_classification][:check_update_all] == "true" 
		      #upd171106 未使用項目を削除
		      large_item_params = { working_middle_item_name:  params[:quotation_detail_middle_classification][:working_middle_item_name], 
                                    working_middle_item_short_name: working_middle_item_short_name_manual, 
                                    working_middle_specification:  params[:quotation_detail_middle_classification][:working_middle_specification] , 
                                    working_middle_item_category_id: params[:quotation_detail_middle_classification][:working_middle_item_category_id], 
                                    working_subcategory_id: params[:quotation_detail_middle_classification][:working_middle_item_subcategory_id], 
									working_unit_id: @working_unit_id_params, 
                                    working_unit_price: params[:quotation_detail_middle_classification][:working_unit_price] ,
                                    execution_unit_price: params[:quotation_detail_middle_classification][:execution_unit_price] ,
                                    #material_id: params[:quotation_detail_middle_classification][:material_id] ,
                                    #working_material_name: params[:quotation_detail_middle_classification][:quotation_material_name],
                                    material_unit_price: params[:quotation_detail_middle_classification][:material_unit_price] ,
                                    labor_unit_price: params[:quotation_detail_middle_classification][:labor_unit_price] ,
                                    labor_productivity_unit: params[:quotation_detail_middle_classification][:labor_productivity_unit] ,
                                    labor_productivity_unit_total: params[:quotation_detail_middle_classification][:labor_productivity_unit_total] 
                                    #material_quantity: params[:quotation_detail_middle_classification][:material_quantity] ,
                                    #accessory_cost: params[:quotation_detail_middle_classification][:accessory_cost] ,
                                    #material_cost_total: params[:quotation_detail_middle_classification][:material_cost_total] ,
                                    #labor_cost_total: params[:quotation_detail_middle_classification][:labor_cost_total]
                                    #other_cost: params[:quotation_detail_middle_classification][:other_cost] 
                                  }
               #del170714 
               #@quotation_middle_item = WorkingMiddleItem.create(large_item_params)
          else
		     # アイテムのみ更新の場合
			 #upd170626 short_name抹消(無駄に１が入るため)
			 
		     if params[:quotation_detail_middle_classification][:check_update_item] == "true" 
		         large_item_params = { working_middle_item_name: params[:quotation_detail_middle_classification][:working_middle_item_name] , 
                 working_middle_item_short_name: working_middle_item_short_name_manual, 
                 working_middle_specification: params[:quotation_detail_middle_classification][:working_middle_specification] ,
                 working_middle_item_category_id: params[:quotation_detail_middle_classification][:working_middle_item_category_id], 
                 working_subcategory_id: params[:quotation_detail_middle_classification][:working_middle_item_subcategory_id], 
				 working_unit_id: @working_unit_id_params } 
		   
		     end
		   
          end

          if large_item_params.present?
		     if @check_item.nil?
		       if params[:quotation_detail_middle_classification][:master_insert_flag] == "true"   #add171106
			     @check_item = WorkingMiddleItem.create(large_item_params)
		         #手入力の場合のパラメータを書き換える。
			     params[:quotation_detail_middle_classification][:working_middle_item_id] = @check_item.id
			     params[:quotation_detail_middle_classification][:working_middle_item_short_name] = @check_item.id
			   else
			   #add171106 固有マスターへ登録
			     #ヘッダIDを連想配列へ追加
				 large_item_params.store(:quotation_header_id, params[:quotation_detail_middle_classification][:quotation_header_id])
				 
			     @check_item = WorkingSpecificMiddleItem.create(large_item_params)
		         #手入力の場合のパラメータを書き換える。
			     params[:quotation_detail_middle_classification][:working_specific_middle_item_id] = @check_item.id
			   end
			 else
			 
			   @check_item.update(large_item_params)
		     end
			 
			 
		  end

  
  end
 
  #見積金額トータル
  def quote_total_price
    @execution_total_price = QuotationDetailMiddleClassification.where(["quotation_header_id = ? and quotation_detail_large_classification_id = ?", 
               @quotation_detail_middle_classification.quotation_header_id, @quotation_detail_middle_classification.quotation_detail_large_classification_id]).sumpriceQuote
  end 
  #実行金額トータル
  def execution_total_price
    @execution_total_price = QuotationDetailMiddleClassification.where(["quotation_header_id = ? and quotation_detail_large_classification_id = ?", 
              @quotation_detail_middle_classification.quotation_header_id, @quotation_detail_middle_classification.quotation_detail_large_classification_id]).sumpriceExecution
  end

  #歩掛りトータル
  def labor_total
    @labor_total = QuotationDetailMiddleClassification.where(["quotation_header_id = ? and quotation_detail_large_classification_id = ?", 
              @quotation_detail_middle_classification.quotation_header_id, @quotation_detail_middle_classification.quotation_detail_large_classification_id]).sumLaborProductivityUnit 
  end
  #歩掛計トータル
  def labor_all_total
    @labor_all_total = QuotationDetailMiddleClassification.where(["quotation_header_id = ? and quotation_detail_large_classification_id = ?", 
              @quotation_detail_middle_classification.quotation_header_id, @quotation_detail_middle_classification.quotation_detail_large_classification_id]).sumLaborProductivityUnitTotal 
  end
  
  #トータル(品目→見出保存用)
  
  #見積金額トータル
  def quote_total_price_Large
     @execution_total_price_Large = QuotationDetailLargeClassification.where(["quotation_header_id = ?", @quotation_detail_middle_classification.quotation_header_id]).sumpriceQuote
  end 
  #実行金額トータル
  def execution_total_price_Large
     @execution_total_price_Large = QuotationDetailLargeClassification.where(["quotation_header_id = ?", @quotation_detail_middle_classification.quotation_header_id]).sumpriceExecution
  end

  # ajax
  def subtotal_select
  #小計を取得、セットする
     @search_records = QuotationDetailMiddleClassification.where("quotation_header_id = ? and quotation_detail_large_classification_id = ?", 
                                                                 params[:quotation_header_id], params[:quotation_detail_large_classification_id] )
     if @search_records.present?
        start_line_number = 0
        end_line_number = 0
        current_line_number = params[:line_number].to_i
        
		@search_records.order(:line_number).each do |qdmc|
           if qdmc.construction_type.to_i != $INDEX_SUBTOTAL &&
              qdmc.construction_type.to_i != $INDEX_DISCOUNT  
			  #小計,値引き以外なら開始行をセット
             if start_line_number == 0
                start_line_number = qdmc.line_number
		     end
		   else 
		     if qdmc.line_number < current_line_number
		       start_line_number = 0   #開始行を初期化
			 end
           end
		   
		   if qdmc.line_number < current_line_number   #更新の場合もあるので現在の行はカウントしない。
		     end_line_number = qdmc.line_number  #終了行をセット
           end
        end
        
        #範囲内の計を集計
        @quote_price = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:quote_price)
        @execution_price = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:execution_price)
        @labor_productivity_unit_total = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:labor_productivity_unit_total)
        
     end
  end 
  
  def recalc_subtotal_all
  #すべての小計を再計算する(ajax用)
    quote_price_sum = 0
    execution_price_sum = 0
    labor_productivity_unit_total_sum  = 0
	
	@search_records = QuotationDetailMiddleClassification.where("quotation_header_id = ? and quotation_detail_large_classification_id = ?", 
                                                       params[:ajax_quotation_header_id], params[:ajax_quotation_detail_large_classification_id])
   
	if @search_records.present?
      @search_records.order(:line_number).each do |qdmc|
	    if qdmc.construction_type.to_i != $INDEX_SUBTOTAL
          if qdmc.construction_type.to_i != $INDEX_DISCOUNT
            #小計・値引き以外？
            quote_price_sum += qdmc.quote_price.to_i
			execution_price_sum += qdmc.execution_price.to_i
			labor_productivity_unit_total_sum += qdmc.labor_productivity_unit_total.to_f
		  end
		else
		#小計？=>更新
		    subtotal_params = {quote_price: quote_price_sum, execution_price: execution_price_sum, labor_productivity_unit_total: labor_productivity_unit_total_sum}
		    qdmc.update(subtotal_params)

			
			#カウンターを初期化
		    quote_price_sum = 0
            execution_price_sum = 0
            labor_productivity_unit_total_sum  = 0
        end
	  end
    end
  end
  
  #add170308
  def recalc_subtotal
  #小計を再計算する
     @search_records = QuotationDetailMiddleClassification.where("quotation_header_id = ? and quotation_detail_large_classification_id = ?", 
                                                                 params[:quotation_detail_middle_classification][:quotation_header_id], 
                                                                 params[:quotation_detail_middle_classification][:quotation_detail_large_classification_id] )
	 if @search_records.present?
		start_line_number = 0
        end_line_number = 0
        current_line_number = params[:quotation_detail_middle_classification][:line_number].to_i
        
		subtotal_exist = false
		id_saved = 0
		@search_records.order(:line_number).each do |qdmc|
           if qdmc.construction_type.to_i != $INDEX_SUBTOTAL &&
              qdmc.construction_type.to_i != $INDEX_DISCOUNT  
			  
			 #小計,値引き以外なら開始行をセット
             if start_line_number == 0
                start_line_number = qdmc.line_number
		     end
		   else 
		     
			 if qdmc.line_number < current_line_number
		       start_line_number = 0   #開始行を初期化
			 elsif qdmc.line_number > current_line_number
             #小計欄に来たら、処理を抜ける。
			   subtotal_exist = true
			   id_saved = qdmc.id
               
			   break
			 end
           end
		   
		   if qdmc.line_number >= current_line_number   
		     end_line_number = qdmc.line_number  #終了行をセット
           end
        end
        #範囲内の計を集計
		if subtotal_exist == true
          subtotal_records = QuotationDetailMiddleClassification.find(id_saved)
    
	      if subtotal_records.present?
		    quote_price = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:quote_price)
            execution_price = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:execution_price)
            labor_productivity_unit_total = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:labor_productivity_unit_total)

            subtotal_records.update_attributes!(:quote_price => quote_price, :execution_price => execution_price, 
                                                :labor_productivity_unit_total => labor_productivity_unit_total)
	      end
		end
     end
  end 
  #
  
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
  
  #固有マスター関連取得 add171106
  def working_specific_middle_item_select
     @working_middle_item_name = WorkingSpecificMiddleItem.where(:id => params[:working_specific_middle_item_id]).where("id is NOT NULL").pluck(:working_middle_item_name).flatten.join(" ")
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
  
  ###
  
  #使用材料id(うまくいかないので保留・・・)
  def material_id_select
     
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
  def quotation_material_name_select
     @quotation_material_name = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:quotation_material_name).flatten.join(" ")
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
  def m_quotation_material_name_select
     @m_quotation_material_name = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_name).flatten.join(" ")
  end
  #材料単価(材料M)
  def m_material_unit_price_select
     @m_material_unit_price = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:last_unit_price).flatten.join(" ")
  end
  
  #見出し→品目絞り込み用
  def quotation_detail_large_classification_id_select
     @quotation_detail_large_classification = QuotationDetailLargeClassification.where(:quotation_header_id => params[:quotation_header_id]).where("id is NOT NULL").pluck(:working_large_item_name, :id)
  end
  
  #単位
  #def quotation_unit_id_select
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
    @labor_productivity_unit = QuotationDetailMiddleClassification.sum_LPU_PipingWiring(params[:quotation_header_id], params[:quotation_detail_large_classification_id])
    @labor_productivity_unit_total = QuotationDetailMiddleClassification.sum_LPUT_PipingWiring(params[:quotation_header_id], params[:quotation_detail_large_classification_id])
    
    #add180105金額計追加
    @quote_price = QuotationDetailMiddleClassification.sum_quote_price_PipingWiring(params[:quotation_header_id], params[:quotation_detail_large_classification_id])
    @execution_price = QuotationDetailMiddleClassification.sum_execution_price_PipingWiring(params[:quotation_header_id], params[:quotation_detail_large_classification_id])
    ###

  end
  #歩掛り(機器取付集計用)
  def LPU_equipment_mounting_select
    @labor_productivity_unit = QuotationDetailMiddleClassification.sum_LPU_equipment_mounting(params[:quotation_header_id], params[:quotation_detail_large_classification_id])
	@labor_productivity_unit_total = QuotationDetailMiddleClassification.sum_LPUT_equipment_mounting(params[:quotation_header_id], params[:quotation_detail_large_classification_id])
  
    #add180105金額計追加
	@quote_price = QuotationDetailMiddleClassification.sum_quote_price_equipment_mounting(params[:quotation_header_id], params[:quotation_detail_large_classification_id])
	@execution_price = QuotationDetailMiddleClassification.sum_execution_price_equipment_mounting(params[:quotation_header_id], params[:quotation_detail_large_classification_id])
    ###
	
	
  end
  #歩掛り(労務費集計用)
  def LPU_labor_cost_select
    @labor_productivity_unit = QuotationDetailMiddleClassification.sum_LPU_labor_cost(params[:quotation_header_id], params[:quotation_detail_large_classification_id])
	@labor_productivity_unit_total = QuotationDetailMiddleClassification.sum_LPUT_labor_cost(params[:quotation_header_id], params[:quotation_detail_large_classification_id])
  
    #add180105金額計追加
	@quote_price = QuotationDetailMiddleClassification.sum_quote_price_labor_cost(params[:quotation_header_id], params[:quotation_detail_large_classification_id])
	@execution_price = QuotationDetailMiddleClassification.sum_execution_price_labor_cost(params[:quotation_header_id], params[:quotation_detail_large_classification_id])
    ###
  end
  
  #歩掛りの集計を最新のもので書き換える。
  def update_labor_productivity_unit_summary
    quotation_header_id = params[:quotation_detail_middle_classification][:quotation_header_id]
    quotation_detail_large_classification_id = params[:quotation_detail_middle_classification][:quotation_detail_large_classification_id]
	
    #配管配線の計を更新(construction_type=x)
    @QDMC_piping_wiring = QuotationDetailMiddleClassification.where(quotation_header_id: quotation_header_id, 
                          quotation_detail_large_classification_id: quotation_detail_large_classification_id, construction_type: $INDEX_PIPING_WIRING_CONSTRUCTION).first
	if @QDMC_piping_wiring.present?
      labor_productivity_unit_total = QuotationDetailMiddleClassification.sum_LPUT_PipingWiring(quotation_header_id, quotation_detail_large_classification_id)
      @QDMC_piping_wiring.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
    end
    
	#機器取付の計を更新(construction_type=x)
    @QDMC_equipment_mounting = QuotationDetailMiddleClassification.where(quotation_header_id: quotation_header_id, 
                          quotation_detail_large_classification_id: quotation_detail_large_classification_id, construction_type: $INDEX_EUIPMENT_MOUNTING).first
    if @QDMC_equipment_mounting.present?
      labor_productivity_unit_total = QuotationDetailMiddleClassification.sum_LPUT_equipment_mounting(quotation_header_id, quotation_detail_large_classification_id)
      @QDMC_equipment_mounting.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
    end
    
     #労務費の計を更新(construction_type=x)
    @QDMC_labor_cost = QuotationDetailMiddleClassification.where(quotation_header_id: quotation_header_id, 
                          quotation_detail_large_classification_id: quotation_detail_large_classification_id, construction_type: $INDEX_LABOR_COST).first
    if @QDMC_labor_cost.present?
      labor_productivity_unit_total = QuotationDetailMiddleClassification.sum_LPUT_labor_cost(quotation_header_id, quotation_detail_large_classification_id)
      @QDMC_labor_cost.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
    end
  
  end
  
  #add180426
  #明細→内訳へのデータ移行
  def move_middle_to_large
  
    q_d_m_cs = 
        QuotationDetailMiddleClassification.where(:quotation_header_id => params[:quotation_header_id]).
             where(:quotation_detail_large_classification_id => params[:quotation_detail_large_classification_id])
    if q_d_m_cs.present?
      success_flag = true
      
      #内訳、行数の最大値を取得する
      line_number = QuotationDetailLargeClassification.
        where(:quotation_header_id => params[:quotation_header_id]).maximum(:line_number)
      
      #内訳が１件しかない場合は、行数１からカウントアップさせるようにする
      if line_number == 1
        line_number = 0
      end
      
      q_d_m_cs.each do |q_d_m_c|
        
        line_number += 1
        
        quotation_detail_large_classification_params = 
          {quotation_header_id: params[:quotation_header_id], quotation_items_division_id: q_d_m_c.quotation_items_division_id,
           working_large_item_id: q_d_m_c.working_middle_item_id, working_specific_middle_item_id: q_d_m_c.working_specific_middle_item_id,
           working_large_item_name: q_d_m_c.working_middle_item_name, working_large_item_short_name: q_d_m_c.working_middle_item_short_name,
           working_middle_item_category_id: q_d_m_c.working_middle_item_category_id, working_middle_item_category_id_call: q_d_m_c.working_middle_item_category_id_call,
           working_middle_item_subcategory_id: q_d_m_c.working_middle_item_subcategory_id, working_middle_item_subcategory_id_call: q_d_m_c.working_middle_item_subcategory_id_call,
           working_large_specification: q_d_m_c.working_middle_specification, line_number: line_number, quantity: q_d_m_c.quantity, execution_quantity: q_d_m_c.execution_quantity,
           working_unit_id: q_d_m_c.working_unit_id, working_unit_name: q_d_m_c.working_unit_name, working_unit_price: q_d_m_c.working_unit_price, 
           quote_price: q_d_m_c.quote_price, execution_unit_price: q_d_m_c.execution_unit_price, execution_price: q_d_m_c.execution_price, labor_productivity_unit: q_d_m_c.labor_productivity_unit, 
           labor_productivity_unit_total: q_d_m_c.labor_productivity_unit_total, remarks: q_d_m_c.remarks, construction_type: q_d_m_c.construction_type, 
           piping_wiring_flag: q_d_m_c.piping_wiring_flag, equipment_mounting_flag: q_d_m_c.equipment_mounting_flag, labor_cost_flag: q_d_m_c.labor_cost_flag
          }
                                                         
        quotation_detail_large_classification = QuotationDetailLargeClassification.new(quotation_detail_large_classification_params)
        unless quotation_detail_large_classification.save!(:validate => false)
          success_flag = false
        end 
      end
      if success_flag == true
        #既存のデータを削除
        #明細データ削除
        q_d_m_cs.destroy_all
        #内訳データ削除
        QuotationDetailLargeClassification.find(params[:quotation_detail_large_classification_id]).destroy
        
        if save_price_to_headers_move(line_number) == true
        #合計値を一覧データへ書き込み
        
          #リダイレクト
          #(これをしないとパラメータが残る)
          respond_to do |format|
            format.html {redirect_to quotation_detail_large_classifications_path(:quotation_header_id => params[:quotation_header_id], 
                    :quotation_header_name => params[:quotation_header_name], :working_large_item_name => params[:working_large_item_name], 
                    :working_large_specification => params[:working_large_specification] )}
          end
        end
      end
    end
     
    
  end
  
  #del180822
  #見積金額トータル
  #def quote_total_price_large
  #   @quote_total_price_large = QuotationDetailLargeClassification.where(["quotation_header_id = ?", params[:quotation_header_id]]).sumpriceQuote
  #end 
  ##実行金額トータル
  #def execution_total_price_Large
  #   @execution_total_price_Large = QuotationDetailLargeClassification.where(["quotation_header_id = ?", 
  #      params[:quotation_header_id]]).sumpriceExecution
  #end
  
  #見出データへ合計保存用
  def save_price_to_headers_move(line_number)
     quotation_header = QuotationHeader.find(params[:quotation_header_id])
     
     status = false
     if quotation_header.present? 
         #請求金額
          quotation_header.quote_price = quote_total_price_large
		  
          #実行金額
          quotation_header.execution_amount = execution_total_price_Large
          
          
          #最終行
          quotation_header.last_line_number = line_number
          
          status = quotation_header.save
          
     end 
     return status
     
  end
  #(ここまで)内訳→明細へのデータ移行
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quotation_detail_middle_classification
      @quotation_detail_middle_classification = QuotationDetailMiddleClassification.find(params[:id])
	end

    #add171016
    def initialize_sort
	  $not_sort_qm = true
    end
	
    #add180210
    #新規か編集かの判定フラグ
    def set_action_flag
	  @action_flag = params[:action]
	end

    #以降のレコードの行番号を全てインクリメントする
    def line_insert
      QuotationDetailMiddleClassification.where(["quotation_header_id = ? and quotation_detail_large_classification_id = ? and line_number >= ? and id != ?", @quotation_detail_middle_classification.quotation_header_id, @quotation_detail_middle_classification.quotation_detail_large_classification_id, @quotation_detail_middle_classification.line_number, @quotation_detail_middle_classification.id]).update_all("line_number = line_number + 1")
       
      #最終行番号も取得しておく
      @max_line_number = QuotationDetailMiddleClassification.
        where(["quotation_header_id = ? and quotation_detail_large_classification_id = ? and line_number >= ? and id != ?", @quotation_detail_middle_classification.quotation_header_id, 
        @quotation_detail_middle_classification.quotation_detail_large_classification_id, @quotation_detail_middle_classification.line_number, 
        @quotation_detail_middle_classification.id]).maximum(:line_number)
    end 

    #見積品目データへ合計保存用　
    def save_price_to_large_classifications
        @quotation_detail_large_classification = QuotationDetailLargeClassification.where(["quotation_header_id = ? and id = ?", 
                @quotation_detail_middle_classification.quotation_header_id,@quotation_detail_middle_classification.quotation_detail_large_classification_id]).first

     if @quotation_detail_large_classification.present?

        #見積金額
        @quotation_detail_large_classification.quote_price = quote_total_price
        
        #実行金額
        @quotation_detail_large_classification.execution_price = execution_total_price
        
        #歩掛り
        @quotation_detail_large_classification.labor_productivity_unit = labor_total
		#歩掛計
        @quotation_detail_large_classification.labor_productivity_unit_total = labor_all_total

        @quotation_detail_large_classification.save
    
        #見出データへも合計保存
        save_price_to_headers
     end

    end

    #見出データへ合計保存用
    def save_price_to_headers
       @quotation_header = QuotationHeader.find(@quotation_detail_large_classification.quotation_header_id)
       
       if @quotation_header.present? 
       #見積金額
          @quotation_header.quote_price = quote_total_price_Large
		  
          #実行金額
          @quotation_header.execution_amount = execution_total_price_Large
          
          @quotation_header.save
       end 
   end

   
   
   #見出しデータへ最終行番号保存用
    def quotation_dlc_set_last_line_number
        @quotation_detail_large_classifiations = QuotationDetailLargeClassification.where(["quotation_header_id = ? and id = ?", 
		   @quotation_detail_middle_classification.quotation_header_id,@quotation_detail_middle_classification.quotation_detail_large_classification_id]).first
		
		check_flag = false
	    if @quotation_detail_large_classifiations.last_line_number.nil? 
          check_flag = true
        else
	      if (@quotation_detail_large_classifiations.last_line_number < @max_line_number) then
           check_flag = true
		  end
	    end
	    if (check_flag == true)
	       quotation_dlc_params = { last_line_number:  @max_line_number}
		   if @quotation_detail_large_classifiations.present?
			 @quotation_detail_large_classifiations.attributes = quotation_dlc_params
             @quotation_detail_large_classifiations.save(:validate => false)
			 
		   end 
        end 
    end
    #行番号を取得し、インクリメントする。（新規用）
    def get_line_number
      @line_number = 1
	  
	  if $sort_qm != "asc"   #add171120
        if @quotation_detail_middle_classification.quotation_header_id.present? && @quotation_detail_middle_classification.quotation_detail_large_classification_id.present?
           @quotation_detail_large_classifiations = QuotationDetailLargeClassification.where(["quotation_header_id = ? and id = ?", @quotation_detail_middle_classification.quotation_header_id,@quotation_detail_middle_classification.quotation_detail_large_classification_id]).first
		 
		   if @quotation_detail_large_classifiations.present?
              if @quotation_detail_large_classifiations.last_line_number.present?
                 @line_number = @quotation_detail_large_classifiations.last_line_number + 1
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
	  
	  @quotation_detail_middle_classification.line_number = @line_number
    end
    
    #カテゴリー保持フラグの取得
    #add180210
    def get_category_save_flag
      if @quotation_detail_middle_classification.quotation_header_id.present?
        @quotation_headers = QuotationHeader.find_by(id: @quotation_detail_middle_classification.quotation_header_id)
        if @quotation_headers.present?
            @category_save_flag = @quotation_headers.category_saved_flag
            #未入力なら、１をセット。
            if @category_save_flag.nil?
              @category_save_flag = 1
            end
            @quotation_detail_middle_classification.category_save_flag_child = @category_save_flag
        end
      end
    end
    #カテゴリー、サブカテゴリーの取得
    #add180210
    def get_category_id
      if @quotation_headers.present? && @category_save_flag == 1
        category_id = @quotation_headers.category_saved_id
        subcategory_id = @quotation_headers.subcategory_saved_id
        @quotation_detail_middle_classification.working_middle_item_category_id_call = category_id
        @quotation_detail_middle_classification.working_middle_item_subcategory_id_call = subcategory_id
      end
    end
    #カテゴリー保持フラグの保存
    #add180210
    def set_category_save_flag
      if @quotation_detail_large_classification.quotation_header_id.present?
        @quotation_headers = QuotationHeader.find_by(id: @quotation_detail_large_classification.quotation_header_id)
        if @quotation_headers.present?
           quotation_header_params = { category_saved_flag: params[:quotation_detail_middle_classification][:category_save_flag_child], 
                                       category_saved_id: params[:quotation_detail_middle_classification][:working_middle_item_category_id_call],
                                       subcategory_saved_id: params[:quotation_detail_middle_classification][:working_middle_item_subcategory_id_call]}
           @quotation_headers.attributes = quotation_header_params
           @quotation_headers.save(:validate => false)
		end
      end
    end
    
	#ストロングパラメータ
	# Never trust parameters from the scary internet, only allow the white list through.
    def quotation_detail_middle_classification_params
      params.require(:quotation_detail_middle_classification).permit(:quotation_header_id, :quotation_detail_large_classification_id, :line_number, 
                                                                     :quotation_items_division_id, :working_middle_item_id, :working_specific_middle_item_id, :working_middle_item_name, 
                                                                     :working_middle_item_short_name, :working_middle_item_category_id, :working_middle_item_category_id_call, 
                                                                     :working_middle_item_subcategory_id, :working_middle_item_subcategory_id_call, :working_middle_specification, :execution_quantity, :quantity,
                                                                     :working_unit_id, :working_unit_name, :working_unit_price, :quote_price, :execution_unit_price,
                                                                     :execution_price, :material_id, :quotation_material_name, :material_unit_price, :labor_unit_price,
                                                                     :labor_productivity_unit, :labor_productivity_unit_total, :material_quantity, :accessory_cost, 
                                                                     :material_cost_total, :labor_cost_total, :other_cost, :remarks, :construction_type, 
                                                                     :piping_wiring_flag, :equipment_mounting_flag, :labor_cost_flag )
    end
    
end
