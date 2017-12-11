class QuotationDetailsHistoriesController < ApplicationController
  before_action :set_quotation_details_history, only: [:show, :edit, :update, :destroy]

  # GET /quotation_details_histories
  # GET /quotation_details_histories.json
  def index
    
	if params[:quotation_header_history_id].present? && params[:quotation_breakdown_history_id].present?
      @quotation_details_histories = QuotationDetailsHistory.where(quotation_header_history_id: params[:quotation_header_history_id], 
                                 quotation_breakdown_history_id: params[:quotation_breakdown_history_id])
	else
      @quotation_details_histories = QuotationDetailsHistory.all
	end
	
     #明細データ見出用
	if params[:quotation_header_history_id].present?
      #$quotation_header_history_id = params[:quotation_header_history_id]
	  @quotation_header_history_id = params[:quotation_header_history_id]
      if params[:working_large_item_name].present?
        #$working_large_item_name = [params[:working_large_item_name], params[:working_large_specification]]
		@working_large_item_name = [params[:working_large_item_name], params[:working_large_specification]]
      end
	  if params[:quotation_breakdown_history_id].present?
        #$quotation_breakdown_history_id = params[:quotation_breakdown_history_id]
		@quotation_breakdown_history_id = params[:quotation_breakdown_history_id]
	  end
	end
     if params[:quotation_header_name].present?
      #$quotation_header_name = params[:quotation_header_name]
	  @quotation_header_name = params[:quotation_header_name]
    end
    #
	
  end

  #ドラッグ＆ドロップによる並び替え機能(seqをセットする)
  def reorder
  	row = params[:row].split(",").reverse    #ビューの並びが逆のため、パラメータの配列を逆順でセットさせる。
    #row.each_with_index {|row, i| QuotationDetailLargeClassification.update(row, {:seq => i})}
	#行番号へセットするため、配列は１から開始させる。
	row.each_with_index {|row, i| QuotationDetailsHistory.update(row, {:line_number => i + 1})}
    render :text => "OK"

    #小計を全て再計算する
    recalc_subtotal_all

  end

  # GET /quotation_details_histories/1
  # GET /quotation_details_histories/1.json
  def show
  end

  # GET /quotation_details_histories/new
  def new
  #  @quotation_details_history = QuotationDetailsHistory.new
    
    @quotation_details_history = QuotationDetailsHistory.new
  
    #need?
    @quotation_breakdown_history = QuotationBreakdownHistory.all
    
    
    #初期値をセット
    @@new_flag = params[:new_flag]
	if params[:quotation_header_history_id].present?
      @quotation_header_history_id = params[:quotation_header_history_id]
    end
	if params[:quotation_breakdown_history_id].present?
      @quotation_breakdown_history_id = params[:quotation_breakdown_history_id]
    end
	
	#binding.pry
	
	if @@new_flag == "1"
       @quotation_details_history.quotation_header_history_id ||= @quotation_header_history_id
	   
	   @quotation_details_history.quotation_breakdown_history_id ||= @quotation_breakdown_history_id
	   
	   #if params[:quotation_breakdown_history_id].present?
       #  @quotation_details_history.quotation_breakdown_history_id ||= params[:quotation_breakdown_history_id]
	   #else
       #  @quotation_details_history.quotation_breakdown_history_id ||= @quotation_breakdown_history_id
       #end
    end 
    
    #行番号を取得する
    get_line_number
    ###
  end

  # GET /quotation_details_histories/1/edit
  def edit
  end

  # POST /quotation_details_histories
  # POST /quotation_details_histories.json
  def create
    @quotation_details_history = QuotationDetailsHistory.new(quotation_details_history_params)

    #respond_to do |format|
    #  if @quotation_details_history.save
    #    format.html { redirect_to @quotation_details_history, notice: 'Quotation details history was successfully created.' }
    #    format.json { render :show, status: :created, location: @quotation_details_history }
    #  else
    #    format.html { render :new }
    #    format.json { render json: @quotation_details_history.errors, status: :unprocessable_entity }
    #  end
    #end

	@quotation_details_history = QuotationDetailsHistory.create(quotation_details_history_params)
    
    #add170223
    #歩掛りの集計を最新のもので書き換える。
    update_labor_productivity_unit_summary
	
	recalc_subtotal  
	
     #手入力用IDの場合は、単位マスタへも登録する。
    #@quotation_unit = nil
    @working_unit = nil
    if @quotation_details_history.working_unit_id == 1
       
	   #既に登録してないかチェック
       @check_unit = WorkingUnit.find_by(working_unit_name: @quotation_details_history.working_unit_name)
       
	   if @check_unit.nil?
          unit_params = { working_unit_name:  @quotation_details_history.working_unit_name }
          @working_unit = WorkingUnit.create(unit_params)
		else
		  @working_unit = @check_unit
	   end
    end
	
	
      #同様に、明細(中分類)マスターへ登録する。
      if @quotation_details_history.working_middle_item_id == 1
      #手入力用IDの場合
         @check_item = WorkingMiddleItem.find_by(working_middle_item_name: @quotation_details_history.working_middle_item_name ,
                 working_middle_specification: @quotation_details_history.working_middle_specification)
      else
      #手入力以外の場合
        @check_item = WorkingMiddleItem.find(@quotation_details_history.working_middle_item_id)
      end
	  
		 @working_unit_id_params = @quotation_details_history.working_unit_id
		
         if @working_unit.present?
           @working_unit_all_params = WorkingUnit.find_by(working_unit_name: @quotation_details_history.working_unit_name)
		   @working_unit_id_params = @working_unit_all_params.id
		 end 
 
         #if @check_item.nil?
		  
		  large_item_params = nil   #add170714
          
		  # 全選択の場合
		  #upd170626 short_name抹消(無駄に１が入るため)
		  if params[:quotation_details_history][:check_update_all] == "true" 
		      large_item_params = { working_middle_item_name:  @quotation_details_history.working_middle_item_name, 
working_middle_specification:  @quotation_details_history.working_middle_specification, 
working_unit_id: @working_unit_id_params, 
working_unit_price: @quotation_details_history.working_unit_price,
execution_unit_price: @quotation_details_history.execution_unit_price,
labor_productivity_unit: @quotation_details_history.labor_productivity_unit,
labor_productivity_unit_total: @quotation_details_history.labor_productivity_unit_total
 }
            #@quotation_middle_item = WorkingMiddleItem.create(large_item_params)
          else
		     # アイテムのみ更新の場合
			 #upd170626 short_name抹消(無駄に１が入るため)
		     if params[:quotation_details_history][:check_update_item] == "true" 
		         large_item_params = { working_middle_item_name:  @quotation_details_history.working_middle_item_name, 
                 working_middle_specification:  @quotation_details_history.working_middle_specification,
                 working_unit_id: @working_unit_id_params } 
		   
		          #@quotation_middle_item = WorkingMiddleItem.create(large_item_params)
		     end
          end

          #upd170714
		  if large_item_params.present?
		     if @check_item.nil?
		       @quotation_middle_item = WorkingMiddleItem.create(large_item_params)
		     else
			 
			   @quotation_middle_item = @check_item.update(large_item_params)
		     end
		  end
		  
		 #end
    #end

     #品目データの金額を更新
    save_price_to_breakdown_history
    #行挿入する 
	@max_line_number = @quotation_details_history.line_number
    if (params[:quotation_details_history][:check_line_insert] == 'true')
      line_insert
    end
    
    #行番号の最終を書き込む
    quotation_dlc_set_last_line_number
	  
    #@quotation_details_historys = QuotationDetailMiddleClassification.where(:quotation_header_id => $quotation_header_id).where(:quotation_detail_large_classification_id => $quotation_detail_large_classification_id)
	@quotation_details_histories = 
        QuotationDetailsHistory.where(:quotation_header_history_id => @quotation_header_history_id).
             where(:quotation_breakdown_history_id => @quotation_breakdown_history_id)
    ###

	
	
	
  end

  # PATCH/PUT /quotation_details_histories/1
  # PATCH/PUT /quotation_details_histories/1.json
  def update
    #respond_to do |format|
    #  if @quotation_details_history.update(quotation_details_history_params)
    #    format.html { redirect_to @quotation_details_history, notice: 'Quotation details history was successfully updated.' }
    #    format.json { render :show, status: :ok, location: @quotation_details_history }
    #  else
    #    format.html { render :edit }
    #    format.json { render json: @quotation_details_history.errors, status: :unprocessable_entity }
    #  end
    #end
	
	@quotation_details_history.update(quotation_details_history_params)
    
    #歩掛りの集計を最新のもので書き換える。
    update_labor_productivity_unit_summary
	recalc_subtotal
	
    #品目データの金額を更新
	save_price_to_breakdown_history
	
	#行挿入する 
	@max_line_number = @quotation_details_history.line_number
    if (params[:quotation_details_history][:check_line_insert] == 'true')
       line_insert
    end
    
	#行番号の最終を書き込む
    quotation_dlc_set_last_line_number

    #手入力用IDの場合は、単位マスタへも登録する。
    @working_unit = nil
	
    if @quotation_details_history.working_unit_id == 1
       
       #既に登録してないかチェック
       @check_unit = WorkingUnit.find_by(working_unit_name: @quotation_details_history.working_unit_name)
       
	   if @check_unit.nil?
          unit_params = { working_unit_name:  @quotation_details_history.working_unit_name }
		  
          @working_unit = WorkingUnit.create(unit_params)
	   else
	      @working_unit = @check_unit
	   end
    end
	
	
      #同様に、明細(中分類)マスターへ登録する。
      if @quotation_details_history.working_middle_item_id == 1
      #手入力用IDの場合
        @check_item = WorkingMiddleItem.find_by(working_middle_item_name: @quotation_details_history.working_middle_item_name , working_middle_specification: @quotation_details_history.working_middle_specification)
      else
      #手入力以外の場合
        @check_item = WorkingMiddleItem.find(@quotation_details_history.working_middle_item_id)
      end 
		 @working_unit_id_params = @quotation_details_history.working_unit_id
		 
         if @working_unit.present?
		   
		   @working_unit_all_params = WorkingUnit.find_by(working_unit_name: @quotation_details_history.working_unit_name)
		   @working_unit_id_params = @working_unit_all_params.id
		 end 
 
         #if @check_item.nil?  del170714
		   
		  large_item_params = nil   #add170714
		   
		  # 全選択の場合
		  #upd170626 short_name抹消(無駄に１が入るため)
		  if params[:quotation_details_history][:check_update_all] == "true" 
		      large_item_params = { working_middle_item_name:  @quotation_details_history.working_middle_item_name, 
working_middle_specification:  @quotation_details_history.working_middle_specification, 
working_unit_id: @working_unit_id_params, 
working_unit_price: @quotation_details_history.working_unit_price,
execution_unit_price: @quotation_details_history.execution_unit_price,
labor_productivity_unit: @quotation_details_history.labor_productivity_unit,
labor_productivity_unit_total: @quotation_details_history.labor_productivity_unit_total
 }
            
               #@quotation_middle_item = WorkingMiddleItem.create(large_item_params)
          else
		     # アイテムのみ更新の場合
			 #upd170626 short_name抹消(無駄に１が入るため)
		     if params[:quotation_details_history][:check_update_item] == "true"
		       large_item_params = { working_middle_item_name:  @quotation_details_history.working_middle_item_name, 
                 working_middle_specification:  @quotation_details_history.working_middle_specification,
                 working_unit_id: @working_unit_id_params } 
			   
			     #@quotation_middle_item = WorkingMiddleItem.create(large_item_params)
		     end
          end
		 
          #upd170714
		  if large_item_params.present?
		     if @check_item.nil?
		       @quotation_middle_item = WorkingMiddleItem.create(large_item_params)
		     else
			 
			   @quotation_middle_item = @check_item.update(large_item_params)
		     end
		  end
 
         #end  del170714
    #end  del170714
    ######################
    
    
    @quotation_details_histories = QuotationDetailsHistory.where(:quotation_header_history_id => @quotation_header_history_id).
            where(:quotation_breakdown_history_id => @quotation_breakdown_history_id)

  end

  # DELETE /quotation_details_histories/1
  # DELETE /quotation_details_histories/1.json
  def destroy
    
    if params[:quotation_header_history_id].present?
      @quotation_header_history_id = params[:quotation_header_history_id]
    end
    #if params[:quotation_breakdown_history_id].present?
    #  @quotation_breakdown_history_id = params[:quotation_breakdown_history_id]
    #end
  
    @quotation_details_history.destroy
    respond_to do |format|
      #format.html { redirect_to quotation_details_histories_url, notice: 'Quotation details history was successfully destroyed.' }
      #format.json { head :no_content }
	  format.html {redirect_to quotation_details_histories_path( :quotation_header_history_id => params[:quotation_header_history_id],
	                                                             :quotation_breakdown_history_id => params[:quotation_breakdown_history_id],
                                                                 :quotation_header_id => params[:quotation_header_id], 
                                                                 :quotation_header_name => params[:quotation_header_name], 
                                                                 :working_large_item_name => params[:working_large_item_name], 
                                                                 :working_large_specification => params[:working_large_specification] )}
    end
  end
  
  #行番号を取得し、インクリメントする。（新規用）
  def get_line_number
    @line_number = 1
	
	#binding.pry
	
    if @quotation_details_history.quotation_header_history_id.present? && @quotation_details_history.quotation_breakdown_history_id.present?
      
	  @quotation_details_histories = QuotationBreakdownHistory.
	     where(["quotation_header_history_id = ? and id = ?", @quotation_details_history.quotation_header_history_id, 
                @quotation_details_history.quotation_breakdown_history_id]).first
	  
	  if @quotation_details_histories.present?
        if @quotation_details_histories.last_line_number.present?
          @line_number = @quotation_details_histories.last_line_number + 1
        end
      end
    end
	  
	@quotation_details_history.line_number = @line_number
  end

  #歩掛りの集計を最新のもので書き換える。
  def update_labor_productivity_unit_summary
    quotation_header_history_id = params[:quotation_details_history][:quotation_header_history_id]
    quotation_breakdown_history_id = params[:quotation_details_history][:quotation_breakdown_history_id]
	
    #配管配線の計を更新(construction_type=x)
    @QDMC_piping_wiring = QuotationDetailsHistory.where(quotation_header_history_id: quotation_header_history_id, 
                          quotation_breakdown_history_id: quotation_breakdown_history_id, construction_type: $INDEX_PIPING_WIRING_CONSTRUCTION).first
	if @QDMC_piping_wiring.present?
      labor_productivity_unit_total = QuotationDetailsHistory.sum_LPUT_PipingWiring(quotation_header_history_id, quotation_breakdown_history_id)
      @QDMC_piping_wiring.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
    end
    
	#機器取付の計を更新(construction_type=x)
    @QDMC_equipment_mounting = QuotationDetailsHistory.where(quotation_header_history_id: quotation_header_history_id, 
                          quotation_breakdown_history_id: quotation_breakdown_history_id, construction_type: $INDEX_EUIPMENT_MOUNTING).first
    if @QDMC_equipment_mounting.present?
      labor_productivity_unit_total = QuotationDetailsHistory.sum_LPUT_equipment_mounting(quotation_header_history_id, quotation_breakdown_history_id)
      @QDMC_equipment_mounting.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
    end
    
     #労務費の計を更新(construction_type=x)
    @QDMC_labor_cost = QuotationDetailsHistory.where(quotation_header_history_id: quotation_header_history_id, 
                          quotation_breakdown_history_id: quotation_breakdown_history_id, construction_type: $INDEX_LABOR_COST).first
    if @QDMC_labor_cost.present?
      labor_productivity_unit_total = QuotationDetailsHistory.sum_LPUT_labor_cost(quotation_header_history_id, quotation_breakdown_history_id)
      @QDMC_labor_cost.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
    end
  
  end
  
  #ajax
  #歩掛り(配管配線集計用)
  def LPU_piping_wiring_select
    @labor_productivity_unit = QuotationDetailsHistory.sum_LPU_PipingWiring(params[:quotation_header_history_id], params[:quotation_breakdown_history_id])
    @labor_productivity_unit_total = QuotationDetailsHistory.sum_LPUT_PipingWiring(params[:quotation_header_history_id], params[:quotation_breakdown_history_id])
  end
  
  #歩掛り
  def labor_productivity_unit_select
     @labor_productivity_unit = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:labor_productivity_unit).flatten.join(" ")
  end
  #歩掛計
  def labor_productivity_unit_total_select
     @labor_productivity_unit_total = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:labor_productivity_unit_total).flatten.join(" ")
  end
  
  
  def subtotal_select
  #小計を取得、セットする
     @search_records = QuotationDetailsHistory.where("quotation_header_history_id = ? and quotation_breakdown_history_id = ?", 
                                                                 params[:quotation_header_history_id], params[:quotation_breakdown_history_id] )
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
	
	@search_records = QuotationDetailsHistory.where("quotation_header_history_id = ? and quotation_quotation_breakdown_history_id = ?", 
                                                       params[:ajax_quotation_header_history_id], params[:ajax_quotation_breakdown_history_id])
   
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
  
  def recalc_subtotal
  #小計を再計算する
     @search_records = QuotationDetailsHistory.where("quotation_header_history_id = ? and quotation_breakdown_history_id = ?", 
                                                                 params[:quotation_details_history][:quotation_header_history_id], 
                                                                 params[:quotation_details_history][:quotation_breakdown_history_id] )
	 if @search_records.present?
		start_line_number = 0
        end_line_number = 0
        current_line_number = params[:quotation_details_history][:line_number].to_i
        
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
          subtotal_records = QuotationDetailsHistory.find(id_saved)
    
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
  
  #見出しデータへ最終行番号保存用
  def quotation_dlc_set_last_line_number
    @quotation_breakdown_histories = QuotationBreakdownHistory.where(["quotation_header_history_id = ? and id = ?",
       @quotation_details_history.quotation_header_history_id,@quotation_details_history.quotation_breakdown_history_id]).first
      
	 # binding.pry

		
		check_flag = false
	    if @quotation_breakdown_histories.last_line_number.nil? 
          check_flag = true
        else
	      if (@quotation_breakdown_histories.last_line_number < @max_line_number) then
           check_flag = true
		  end
	    end
	    if (check_flag == true)
	       quotation_dlc_params = { last_line_number:  @max_line_number}
		   if @quotation_breakdown_histories.present?
		     @quotation_breakdown_histories.attributes = quotation_dlc_params
             @quotation_breakdown_histories.save(:validate => false)
			 
		   end 
        end 
  end
  
 
  ########

  #見積金額トータル
  def quote_total_price
    @execution_total_price = QuotationDetailsHistory.where(["quotation_header_history_id = ? and quotation_breakdown_history_id = ?", 
               @quotation_details_history.quotation_header_history_id, @quotation_details_history.quotation_breakdown_history_id]).sumpriceQuote
  end 
  #実行金額トータル
  def execution_total_price
    @execution_total_price = QuotationDetailsHistory.where(["quotation_header_history_id = ? and quotation_breakdown_history_id = ?", 
              @quotation_details_history.quotation_header_history_id, @quotation_details_history.quotation_breakdown_history_id]).sumpriceExecution
  end

  #歩掛りトータル
  def labor_total
    @labor_total = QuotationDetailsHistory.where(["quotation_header_history_id = ? and quotation_breakdown_history_id = ?", 
              @quotation_details_history.quotation_header_history_id, @quotation_details_history.quotation_breakdown_history_id]).sumLaborProductivityUnit 
  end
  #歩掛計トータル
  def labor_all_total
    @labor_all_total = QuotationDetailsHistory.where(["quotation_header_history_id = ? and quotation_breakdown_history_id = ?", 
              @quotation_details_history.quotation_header_history_id, @quotation_details_history.quotation_breakdown_history_id]).sumLaborProductivityUnitTotal 
  end

  #トータル(品目→見出保存用)
  
  #見積金額トータル
  def quote_total_price_Large
     @execution_total_price_Large = QuotationBreakdownHistory.where(["quotation_header_history_id = ?", 
         @quotation_details_history.quotation_header_history_id]).sumpriceQuote
  end 
  #実行金額トータル
  def execution_total_price_Large
     @execution_total_price_Large = QuotationBreakdownHistory.where(["quotation_header_history_id = ?", 
        @quotation_details_history.quotation_header_history_id]).sumpriceExecution
  end

  #######
  
  #見積品目データへ合計保存用　
  def save_price_to_breakdown_history
    @quotation_breakdown_history = QuotationBreakdownHistory.where(["quotation_header_history_id = ? and id = ?", 
            @quotation_details_history.quotation_header_history_id,@quotation_details_history.quotation_breakdown_history_id]).first

    if @quotation_breakdown_history.present?

        #見積金額
        @quotation_breakdown_history.quote_price = quote_total_price
        #実行金額
        @quotation_breakdown_history.execution_price = execution_total_price
        #歩掛り
        @quotation_breakdown_history.labor_productivity_unit = labor_total
		#歩掛計
        @quotation_breakdown_history.labor_productivity_unit_total = labor_all_total

        @quotation_breakdown_history.save
    
        #見出データへも合計保存
        save_price_to_headers
    end
  end
  
  #見出データへ合計保存用
  def save_price_to_headers
    @quotation_header_history = QuotationHeaderHistory.find(@quotation_breakdown_history.quotation_header_history_id)
    
	if @quotation_header_history.present? 
      #見積金額
      @quotation_header_history.quote_price = quote_total_price_Large
		  
      #実行金額
      @quotation_header_history.execution_amount = execution_total_price_Large
      @quotation_header_history.save
    end 
  end
   
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quotation_details_history
      @quotation_details_history = QuotationDetailsHistory.find(params[:id])
    end

    #以降のレコードの行番号を全てインクリメントする
    def line_insert
      QuotationDetailsHistory.where(["quotation_header_history_id = ? and quotation_breakdown_history_id = ? 
                   and line_number >= ? and id != ?", @quotation_details_history.quotation_header_history_id,
                   @quotation_details_history.quotation_breakdown_history_id, 
                   @quotation_details_history.line_number, @quotation_details_history.id]).update_all("line_number = line_number + 1")
       
      #最終行番号も取得しておく
      @max_line_number = QuotationDetailsHistory.
        where(["quotation_header_history_id = ? and quotation_breakdown_history_id = ? and line_number >= ? and id != ?", @quotation_details_history.quotation_header_history_id, 
        @quotation_details_history.quotation_breakdown_history_id, @quotation_details_history.line_number, 
        @quotation_details_history.id]).maximum(:line_number)
    end 

    # Never trust parameters from the scary internet, only allow the white list through.
    def quotation_details_history_params
      params.require(:quotation_details_history).permit(:quotation_header_history_id, :quotation_breakdown_history_id, :working_middle_item_id, 
           :working_middle_item_name, :working_middle_item_short_name, :line_number, :working_middle_specification, :quantity, :execution_quantity, :working_unit_id, 
           :working_unit_name, :working_unit_price, :quote_price, :execution_unit_price, :execution_price, :labor_productivity_unit, :labor_productivity_unit_total, :remarks, :construction_type, :piping_wiring_flag, :equipment_mounting_flag, :labor_cost_flag)
    end
end
