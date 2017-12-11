class QuotationBreakdownHistoriesController < ApplicationController
  before_action :set_quotation_breakdown_history, only: [:show, :edit, :update, :destroy]

  # GET /quotation_breakdown_histories
  # GET /quotation_breakdown_histories.json
  def index
    
	if params[:quotation_header_history_id].present?
      @quotation_header_history_id = params[:quotation_header_history_id]
	  
	  @quotation_breakdown_histories = QuotationBreakdownHistory.where(quotation_header_history_id: params[:quotation_header_history_id])
	  
	else
      @quotation_breakdown_histories = QuotationBreakdownHistory.all
	end
     
	#内訳データ見出用
    if params[:quotation_header_name].present?
      @quotation_header_name = params[:quotation_header_name]
    end
    #
    
    #pdf出力用として、履歴データを複製する
    @quotation_detail_large_classifications = @quotation_breakdown_histories

	@print_type = params[:print_type]
	
    if  params[:format] == "pdf" then
	
      #見積書PDF発行
      respond_to do |format|
        format.html # index.html.erb
        format.pdf do
          
		  $print_type = @print_type
		  
    	  case @print_type
		  when "51"
		  #見積書
			report = EstimationSheetPDF.create @quotation_detail_large_classifications
          when "52"
		  #見積書(印あり）
            report = EstimationSheetPDF.create @quotation_detail_large_classifications
		  when "53"
		  #見積書(横)
			report = EstimationSheetLandscapePDF.create @quotation_detail_large_classifications
          end 	
         
          #現在時刻をセットする
          require "date"
          d = DateTime.now
          now_date_time = d.strftime("%Y%m%d%H%M%S")



          # ブラウザでPDFを表示する
          # disposition: "inline" によりダウンロードではなく表示させている
          send_data report.generate,
		    filename:    "見積書-" + now_date_time + ".pdf",
            type:        "application/pdf",
            disposition: "inline"
        end
      end
    
	else
	
	  if params[:data_type] == "1"
	  #オリジナルデータへ復元させる処理
	    
	    delete_quotation
		restore_quotation
		
		if @success_flag == true
		  flash[:notice] = "データ作成が完了しました。"
		end
		
	  end
	
	end
    #
    
  end

  #ドラッグ＆ドロップによる並び替え機能(seqをセットする)
  def reorder
    
	row = params[:row].split(",").reverse    #ビューの並びが逆のため、パラメータの配列を逆順でセットさせる。
	#行番号へセットするため、配列は１から開始させる。
	row.each_with_index {|row, i| QuotationBreakdownHistory.update(row, {:line_number => i + 1})}
    render :text => "OK"

    #小計を全て再計算する
    recalc_subtotal_all

  end

  # GET /quotation_breakdown_histories/1
  # GET /quotation_breakdown_histories/1.json
  def show
  end

  # GET /quotation_breakdown_histories/new
  def new
    @quotation_breakdown_history = QuotationBreakdownHistory.new
	
	#add170626
	if params[:quotation_header_history_id].present?
      @quotation_header_history_id = params[:quotation_header_history_id]
    end
	
	#初期値をセット(見出画面からの遷移時のみ)
    @@new_flag = params[:new_flag]
    if @@new_flag == "1"
       #@quotation_detail_large_classification.quotation_header_id ||= $quotation_header_id
	   #upd170626
       @quotation_breakdown_history.quotation_header_history_id ||= @quotation_header_history_id
	   
	end 
    
	#行番号を取得する
	get_line_number
  end

  # GET /quotation_breakdown_histories/1/edit
  def edit
  end

  # POST /quotation_breakdown_histories
  # POST /quotation_breakdown_histories.json
  def create
    #@quotation_breakdown_history = QuotationBreakdownHistory.new(quotation_breakdown_history_params)
    #@quotation_detail_large_classification = QuotationDetailLargeClassification.create(quotation_detail_large_classification_params)
	
    @quotation_breakdown_history = QuotationBreakdownHistory.create(quotation_breakdown_history_params)
     
	#add170223
	#歩掛りの集計を最新のもので書き換える。
    update_labor_productivity_unit_summary
    
    recalc_subtotal
	  
    # 見出データを保存 
    save_price_to_headers
      
	  
	@max_line_number = @quotation_breakdown_history.line_number
    #行挿入する 
    #if (params[:quotation_detail_large_classification][:check_line_insert] == 'true')
    if (params[:quotation_breakdown_history][:check_line_insert] == 'true')
       line_insert
    end

    #行番号の最終を書き込む
    quotation_headers_set_last_line_number
	  
      
    #手入力用IDの場合は、単位マスタへも登録する。
	if @quotation_breakdown_history.working_unit_id == 1
         #既に登録してないかチェック
         @check_unit = WorkingUnit.find_by(working_unit_name: @quotation_breakdown_history.working_unit_name)
         if @check_unit.nil?
            unit_params = { working_unit_name:  @quotation_breakdown_history.working_unit_name }
            @working_unit = WorkingUnit.create(unit_params)
			
			#内訳マスター更用の単位インデックスを取得
			@working_units = WorkingUnit.find_by(working_unit_name: @quotation_breakdown_history.working_unit_name)
         else 
		   @working_units = @check_unit
		 end
	  end
      
	  #単位のIDをセット
	  if @working_units.present?
	    unit_id = @working_units.id
	  else
	    unit_id = @quotation_breakdown_history.working_unit_id
	  end
	  
      #同様に、内訳(大分類)マスターへ登録する。
      if @quotation_breakdown_history.working_large_item_id == 1
	    #手入力用IDの場合
        @check_item = WorkingMiddleItem.find_by(working_middle_item_name: @quotation_breakdown_history.working_large_item_name , 
                                                  working_middle_specification: @quotation_breakdown_history.working_large_specification)
      else
        #手入力以外の場合
		@check_item = WorkingMiddleItem.find(@quotation_breakdown_history.working_large_item_id)
      end
         #if @check_item.nil?
           
		   large_item_params = nil   #add170714
		   
		   #全選択の場合
		   if params[:quotation_breakdown_history][:check_update_all] == "true" 
		     large_item_params = { working_middle_item_name:  @quotation_breakdown_history.working_large_item_name, 
		                         working_middle_specification:  @quotation_breakdown_history.working_large_specification,
                                 working_unit_id:  unit_id,
                                 working_unit_price:  @quotation_breakdown_history.working_unit_price,
                                 execution_unit_price:  @quotation_breakdown_history.execution_unit_price,
                                 labor_productivity_unit:  @quotation_breakdown_history.labor_productivity_unit,
                                 labor_productivity_unit_total:  @quotation_breakdown_history.labor_productivity_unit_total }
			
			  #@quotation_large_item = WorkingMiddleItem.create(large_item_params)
		   else
		      #アイテム,仕様,単位のみ場合
		     if params[:quotation_breakdown_history][:check_update_item] == "true" 
		         large_item_params = { working_middle_item_name:  @quotation_breakdown_history.working_large_item_name, 
		                         working_middle_specification:  @quotation_breakdown_history.working_large_specification,
                                 working_unit_id:  unit_id
                                  }
                 #@quotation_large_item = WorkingMiddleItem.create(large_item_params)
		     end
		   end
		   
		   #upd170714
		   if large_item_params.present?
		     if @check_item.nil?
		       @quotation_large_item = WorkingMiddleItem.create(large_item_params)
		     else
		       @quotation_large_item = @check_item.update(large_item_params)
		     end
		   end
         #end
      
      #end  del170714
      
   #end
   
   #upd170626
   @quotation_breakdown_histories = QuotationBreakdownHistory.where(:quotation_header_history_id => @quotation_header_history_id)
   
  end

  # PATCH/PUT /quotation_breakdown_histories/1
  # PATCH/PUT /quotation_breakdown_histories/1.json
  def update
    #  if @quotation_breakdown_history.update(quotation_breakdown_history_params)
    @quotation_breakdown_history.update(quotation_breakdown_history_params)
    
    #歩掛りの集計を最新のもので書き換える。
    update_labor_productivity_unit_summary
    recalc_subtotal
	  
    # 見出データを保存 
    save_price_to_headers
      
	@max_line_number = @quotation_breakdown_history.line_number
	if (params[:quotation_breakdown_history][:check_line_insert] == 'true')
      line_insert
    end
	  
	#binding.pry
	
      #行番号の最終を書き込む
      quotation_headers_set_last_line_number
      
      #####
      #手入力用IDの場合は、単位マスタへも登録する。
      #if @quotation_detail_large_classification.quotation_unit_id == 1
	  
	  if @quotation_breakdown_history.working_unit_id == 1
         #既に登録してないかチェック
         @check_unit = WorkingUnit.find_by(working_unit_name: @quotation_breakdown_history.working_unit_name)
         if @check_unit.nil?
            unit_params = { working_unit_name:  @quotation_breakdown_history.working_unit_name }
            @working_unit = WorkingUnit.create(unit_params)
			
			#内訳マスター更用の単位インデックスを取得
			@working_units = WorkingUnit.find_by(working_unit_name: @quotation_breakdown_history.working_unit_name)
		 else
		   @working_units = @check_unit
		 end
	  end
      
	  #単位のIDをセット
	  if @working_units.present?
	    unit_id = @working_units.id
	  else
	    unit_id = @quotation_breakdown_history.working_unit_id
	  end
	  
      #同様に、内訳(大分類)マスターへ登録する。
      if @quotation_breakdown_history.working_large_item_id == 1
      #手入力用IDの場合
        @check_item = WorkingMiddleItem.find_by(working_middle_item_name: @quotation_breakdown_history.working_large_item_name , 
		                      working_middle_specification: @quotation_breakdown_history.working_large_specification)
	  else
	  #手入力以外の場合
		@check_item = WorkingMiddleItem.find(@quotation_breakdown_history.working_large_item_id)
	  end
	
         #if @check_item.nil?
		   
           large_item_params = nil   #add170714
		   
		   #全選択の場合
		   if params[:quotation_breakdown_history][:check_update_all] == "true" 
		     large_item_params = { working_middle_item_name:  @quotation_breakdown_history.working_large_item_name,
		                         working_middle_specification:  @quotation_breakdown_history.working_large_specification,
                                 working_unit_id:  unit_id,
                                 working_unit_price:  @quotation_breakdown_history.working_unit_price,
                                 execution_unit_price:  @quotation_breakdown_history.execution_unit_price,
                                 labor_productivity_unit:  @quotation_breakdown_history.labor_productivity_unit,
                                 labor_productivity_unit_total:  @quotation_breakdown_history.labor_productivity_unit_total }
               
               #@quotation_large_item = WorkingMiddleItem.create(large_item_params)
		   else
		     #アイテム,仕様,単位のみ場合
		     if params[:quotation_breakdown_history][:check_update_item] == "true" 
		         large_item_params = { working_middle_item_name:  @quotation_breakdown_history.working_large_item_name, 
                                 working_middle_specification:  @quotation_breakdown_history.working_large_specification,
                                 working_unit_id:  unit_id
                                  }
                 #@quotation_large_item = WorkingMiddleItem.create(large_item_params)
		     end
		   end
		   
		   #upd170714
		   if large_item_params.present?
		     if @check_item.nil?
		       @quotation_large_item = WorkingMiddleItem.create(large_item_params)
		     else
		       @quotation_large_item = @check_item.update(large_item_params)
		     end
		   end
		 #end
      #end
	  #####
	  
      @quotation_breakdown_histories = QuotationBreakdownHistory.where(:quotation_header_history_id => @quotation_header_history_id)
	  
	  
  end

  # DELETE /quotation_breakdown_histories/1
  # DELETE /quotation_breakdown_histories/1.json
  def destroy
    
    if params[:quotation_header_history_id].present?
      @quotation_header_history_id = params[:quotation_header_history_id]
    end
	
	
	@quotation_breakdown_history.destroy
	
	respond_to do |format|
      #format.html { redirect_to quotation_breakdown_histories_url, notice: 'Quotation breakdown history was successfully destroyed.' }
      #format.json { head :no_content }
      #upd170626
      format.html {redirect_to quotation_breakdown_histories_path( :quotation_header_history_id => params[:quotation_header_history_id], 
                                                                   :quotation_header_name => params[:quotation_header_name],
                                                                   :quotation_header_id => params[:quotation_header_id] )}
    end
	# 見出データを保存 
    save_price_to_headers

  end
  
  
  #行番号を取得し、インクリメントする。（新規用）
  def get_line_number
    @line_number = 1
    if @quotation_breakdown_history.quotation_header_history_id.present?
       @quotation_header_history = QuotationHeaderHistory.find_by(id: @quotation_breakdown_history.quotation_header_history_id)
       if @quotation_header_history.present?
          if @quotation_header_history.last_line_number.present?
             @line_number = @quotation_header_history.last_line_number + 1
          end
       end
    end
	  
	@quotation_breakdown_history.line_number = @line_number
  end
  
  #見積金額トータル
  def quote_total_price
     @execution_total_price = QuotationBreakdownHistory.where(["quotation_header_history_id = ?", @quotation_breakdown_history.quotation_header_history_id]).sumpriceQuote
  end 
  #実行金額トータル
  def execution_total_price
     @execution_total_price = QuotationBreakdownHistory.where(["quotation_header_history_id = ?", @quotation_breakdown_history.quotation_header_history_id]).sumpriceExecution
  end
  
  #歩掛り(配管配線集計用)
  def LPU_piping_wiring_select
    @labor_productivity_unit = QuotationBreakdownHistory.sum_LPU_PipingWiring(params[:quotation_header_history_id])
    @labor_productivity_unit_total = QuotationBreakdownHistory.sum_LPUT_PipingWiring(params[:quotation_header_history_id])
  end
  #歩掛り(機器取付集計用)
  def LPU_equipment_mounting_select
    @labor_productivity_unit = QuotationBreakdownHistory.sum_LPU_equipment_mounting(params[:quotation_header_history_id])
	@labor_productivity_unit_total = QuotationBreakdownHistory.sum_LPUT_equipment_mounting(params[:quotation_header_history_id])
  end
  
  #歩掛り(労務費集計用)
  def LPU_labor_cost_select
    @labor_productivity_unit = QuotationBreakdownHistory.sum_LPU_labor_cost(params[:quotation_header_history_id])
	@labor_productivity_unit_total = QuotationBreakdownHistory.sum_LPUT_labor_cost(params[:quotation_header_history_id])
  end
  
  #以降のレコードの行番号を全てインクリメントする
  def line_insert
    QuotationBreakdownHistory.where(["quotation_header_history_id = ? and line_number >= ? and id != ?", @quotation_breakdown_history.quotation_header_history_id, 
                                 @quotation_breakdown_history.line_number, @quotation_breakdown_history.id]).update_all("line_number = line_number + 1")
    #最終行番号も取得しておく
    @max_line_number = QuotationBreakdownHistory.
        where(["quotation_header_history_id = ? and line_number >= ? and id != ?", @quotation_breakdown_history.quotation_header_history_id, 
    @quotation_breakdown_history.line_number, @quotation_breakdown_history.id]).maximum(:line_number)
  end
	
  #見出データへ合計保存用
  def save_price_to_headers
  
    @quotation_header_history = QuotationHeaderHistory.find(@quotation_breakdown_history.quotation_header_history_id)
    #見積金額
    @quotation_header_history.quote_price = quote_total_price
    #実行金額
    @quotation_header_history.execution_amount = execution_total_price
    @quotation_header_history.save
  end
  
  #見出しデータへ最終行番号保存用
  def quotation_headers_set_last_line_number
    @quotation_header_history = QuotationHeaderHistory.find_by(id: @quotation_breakdown_history.quotation_header_history_id)
		
    check_flag = false
	if @quotation_header_history.last_line_number.nil? 
      check_flag = true
    else
	  if (@quotation_header_history.last_line_number < @max_line_number) then
        check_flag = true
	  end
	end
	if (check_flag == true)
	  quotation_header_params = { last_line_number:  @max_line_number}
	  if @quotation_header_history.present?
		@quotation_header_history.attributes = quotation_header_params
        @quotation_header_history.save(:validate => false)
	  end 
    end 
  end
  
   #歩掛りの集計を最新のもので書き換える。
  def update_labor_productivity_unit_summary
    quotation_header_history_id = params[:quotation_breakdown_history][:quotation_header_history_id]
    
    #配管配線の計を更新(construction_type=constant)
    @QDLC_piping_wiring = QuotationBreakdownHistory.where(quotation_header_history_id: quotation_header_history_id, construction_type: $INDEX_PIPING_WIRING_CONSTRUCTION).first
    if @QDLC_piping_wiring.present?
      labor_productivity_unit_total = QuotationBreakdownHistory.sum_LPUT_PipingWiring(quotation_header_history_id)
      @QDLC_piping_wiring.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
	end
	
	#機器取付の計を更新(construction_type=)
    @QDLC_equipment_mounting = QuotationBreakdownHistory.where(quotation_header_history_id: quotation_header_history_id, construction_type: $INDEX_EUIPMENT_MOUNTING).first
	if @QDLC_equipment_mounting.present?
      labor_productivity_unit_total = QuotationBreakdownHistory.sum_LPUT_equipment_mounting(quotation_header_history_id)
	  @QDLC_equipment_mounting.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
	end
    #労務費の計を更新(construction_type=x)
    @QDLC_labor_cost = QuotationBreakdownHistory.where(quotation_header_history_id: quotation_header_history_id, construction_type: $INDEX_LABOR_COST).first
	if @QDLC_labor_cost.present?
      labor_productivity_unit_total = QuotationBreakdownHistory.sum_LPUT_labor_cost(quotation_header_history_id)
	  @QDLC_labor_cost.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
	end
  
  end
  
  def subtotal_select
  #小計を取得、セットする
     @search_records = QuotationBreakdownHistory.where("quotation_header_history_id = ?", params[:quotation_header_history_id])
     if @search_records.present?
        
        
        start_line_number = 0
        end_line_number = 0
        
        current_line_number = params[:line_number].to_i
        
		@search_records.order(:line_number).each do |qdlc|
           if qdlc.construction_type.to_i != $INDEX_SUBTOTAL &&
              qdlc.construction_type.to_i != $INDEX_DISCOUNT  
			  #小計,値引き以外なら開始行をセット
             if start_line_number == 0
                start_line_number = qdlc.line_number
		     end
		   else 
		     if qdlc.line_number < current_line_number
		       start_line_number = 0   #開始行を初期化
			 end
           end
		   
		   if qdlc.line_number < current_line_number   #更新の場合もあるので現在の行はカウントしない。
		     end_line_number = qdlc.line_number  #終了行をセット
           end
        end
        
        #範囲内の計を集計
        @quote_price = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:quote_price)
        @execution_price = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:execution_price)
        @labor_productivity_unit_total = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:labor_productivity_unit_total)
        
     end
  end 
  
  def recalc_subtotal_all
  #すべての小計を再計算する
    quote_price_sum = 0
    execution_price_sum = 0
    labor_productivity_unit_total_sum  = 0
	
	@search_records = QuotationBreakdownHistory.where("quotation_header_history_id = ?", params[:ajax_quotation_header_history_id])
    
	if @search_records.present?
      @search_records.order(:line_number).each do |qdlc|
	    if qdlc.construction_type.to_i != $INDEX_SUBTOTAL
          if qdlc.construction_type.to_i != $INDEX_DISCOUNT
            #小計・値引き以外？
            quote_price_sum += qdlc.quote_price.to_i
			execution_price_sum += qdlc.execution_price.to_i
			labor_productivity_unit_total_sum += qdlc.labor_productivity_unit_total.to_f
		  end
		else
		#小計？=>更新
		    subtotal_params = {quote_price: quote_price_sum, execution_price: execution_price_sum, labor_productivity_unit_total: labor_productivity_unit_total_sum}
		    qdlc.update(subtotal_params)

			
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
     @search_records = QuotationBreakdownHistory.where("quotation_header_history_id = ?", params[:quotation_breakdown_history][:quotation_header_history_id])
	 
	 if @search_records.present?
		start_line_number = 0
        end_line_number = 0
	  
        current_line_number = params[:quotation_breakdown_history][:line_number].to_i
        
        subtotal_exist = false
        id_saved = 0
		@search_records.order(:line_number).each do |qdlc|
           if qdlc.construction_type.to_i != $INDEX_SUBTOTAL &&
              qdlc.construction_type.to_i != $INDEX_DISCOUNT  
			  
			 #小計,値引き以外なら開始行をセット
             if start_line_number == 0
                start_line_number = qdlc.line_number
		     end
		   else 
		     
			 if qdlc.line_number < current_line_number
		       start_line_number = 0   #開始行を初期化
			 elsif qdlc.line_number > current_line_number
             #小計欄に来たら、処理を抜ける。
			   #binding.pry
			 
			   subtotal_exist = true
			   id_saved = qdlc.id
               
			   break
			 end
           end
		   
		   if qdlc.line_number >= current_line_number   
		     end_line_number = qdlc.line_number  #終了行をセット
           end
        end
		
		
        #範囲内の計を集計
		if subtotal_exist == true
          subtotal_records = QuotationBreakdownHistory.find(id_saved)
    
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

  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quotation_breakdown_history
      @quotation_breakdown_history = QuotationBreakdownHistory.find(params[:id])
    end
    
	#ストロングパラメータ
    # Never trust parameters from the scary internet, only allow the white list through.
    def quotation_breakdown_history_params
      params.require(:quotation_breakdown_history).permit(:quotation_header_history_id, :quotation_items_division_id, :working_large_item_id, :working_large_item_name,
                                :working_large_item_short_name, :working_large_specification, :line_number, :quantity, :execution_quantity, :working_unit_id, :working_unit_name, :working_unit_price, :quote_price, :execution_unit_price, :execution_price, :labor_productivity_unit, :labor_productivity_unit_total, :last_line_number, :remarks, :construction_type, :piping_wiring_flag, :equipment_mounting_flag, :labor_cost_flag)
    end
  
  
  
  ########  見積書オリジナルデータ復元処理
  
  def delete_quotation
  #既存の見積書データを全て削除する
    if params[:quotation_header_id].present?
	  @quotation_header = QuotationHeader.find(params[:quotation_header_id])
    
	  if @quotation_header.present?
	    quotation_header_id = @quotation_header.id
		
		#明細データ抹消
        QuotationDetailMiddleClassification.where(quotation_header_id: quotation_header_id).destroy_all
        #内訳データ抹消
        QuotationDetailLargeClassification.where(quotation_header_id: quotation_header_id).destroy_all
        #見出データ抹消
        #QuotationHeader.where(id: quotation_header_id).destroy_all
	  end
	end
  end
  
  
  
  def restore_quotation
  #見積書履歴データを見積書データへ丸ごとコピー
	  @success_flag = true
	 
	  #見出しデータのコピー
	  @quotation_header_history = QuotationHeaderHistory.find(params[:quotation_header_history_id])   #ここは履歴IDで取る！
	 
	  if @quotation_header_history.present?
	    if @quotation_header_history.quotation_code.present?
          
          quotation_header_params = { quotation_code:  @quotation_header_history.quotation_code, quotation_date:  @quotation_header_history.quotation_date,
                                  invoice_code:  @quotation_header_history.invoice_code, 
                                  delivery_slip_code:  @quotation_header_history.delivery_slip_code, 
                                  construction_datum_id: @quotation_header_history.construction_datum_id, construction_name: @quotation_header_history.construction_name, 
                                  customer_id: @quotation_header_history.customer_id, customer_name: @quotation_header_history.customer_name,
                                    honorific_id: @quotation_header_history.honorific_id,
                                  responsible1: @quotation_header_history.responsible1, responsible2: @quotation_header_history.responsible2, post: @quotation_header_history.post, 
                                  address: @quotation_header_history.address, tel: @quotation_header_history.tel, fax: @quotation_header_history.fax, 
                                  construction_period: @quotation_header_history.construction_period, construction_place: @quotation_header_history.construction_place, 
                                  quote_price: @quotation_header_history.quote_price, execution_amount: @quotation_header_history.execution_amount, 
								  last_line_number: @quotation_header_history.last_line_number} 
          
		  #@quotation_header = QuotationHeader.new(quotation_header_params)
		  @quotation_header = QuotationHeader.find(params[:quotation_header_id])
		  
		  if @quotation_header.update(quotation_header_params)    #見出しは更新とする（履歴を引き継がせるため）
		  #if @quotation_header.save!(:validate => false)
		    @success_flag = true
		  else
		    @success_flag = false
          end 
		else
		  flash[:notice] = "データ作成に失敗しました！。"
          @success_flag = false
		end
	  end 
	  
	  if @success_flag == true
	    ##見出しIDをここで取得
	    #@quotation_header = nil
	  
	    @quotation_header_id = nil
		  
	    if @quotation_header.present?
		
	      @quotation_header_id = @quotation_header.id
	  
          #内訳データのコピー
	      @quotation_breakdown_histories = QuotationBreakdownHistory.where(quotation_header_history_id: params[:quotation_header_history_id])  #ここは履歴IDで取得する
	      
		  	
		  if @quotation_breakdown_histories.present?
	    
		    @quotation_breakdown_histories.each do |quotation_breakdown_history|
              
		      #IDをここでセットしておく（明細で参照するため）
			  @quotation_breakdown_history_id = quotation_breakdown_history.id
			
			
              quotation_detail_large_classification_params = {quotation_header_id: @quotation_header_id, quotation_items_division_id: quotation_breakdown_history.quotation_items_division_id, 
                working_large_item_id: quotation_breakdown_history.working_large_item_id, working_large_item_name: quotation_breakdown_history.working_large_item_name, 
                working_large_item_short_name: quotation_breakdown_history.working_large_item_short_name,
                working_large_specification: quotation_breakdown_history.working_large_specification, line_number: quotation_breakdown_history.line_number, 
                quantity: quotation_breakdown_history.quantity, execution_quantity: quotation_breakdown_history.execution_quantity, 
                working_unit_id: quotation_breakdown_history.working_unit_id, working_unit_name: quotation_breakdown_history.working_unit_name, 
                working_unit_price: quotation_breakdown_history.working_unit_price, quote_price: quotation_breakdown_history.quote_price, execution_unit_price: quotation_breakdown_history.execution_unit_price, 
                execution_price: quotation_breakdown_history.execution_price, labor_productivity_unit: quotation_breakdown_history.labor_productivity_unit, 
                labor_productivity_unit_total: quotation_breakdown_history.labor_productivity_unit_total, last_line_number: quotation_breakdown_history.last_line_number, 
                remarks: quotation_breakdown_history.remarks, construction_type: quotation_breakdown_history.construction_type , piping_wiring_flag: quotation_breakdown_history.piping_wiring_flag , 
                equipment_mounting_flag: quotation_breakdown_history.equipment_mounting_flag , 
                labor_cost_flag: quotation_breakdown_history.labor_cost_flag }

              @quotation_detail_large_classification = QuotationDetailLargeClassification.new(quotation_detail_large_classification_params)
              if @quotation_detail_large_classification.save!(:validate => false)
		      
                 #IDをここでセットしておく（明細で参照するため）
			     @quotation_detail_large_classification_id = @quotation_detail_large_classification.id
		       
			     #明細データのコピー(サブルーチン)
			     restore_quotation_detail
		      else
		        @success_flag = false
              end 
	        end
	      end
	    end
	  end
	  #
	  
	  
	  #
  end
  def restore_quotation_detail
    #見積履歴データを見積書データへ丸ごとコピー（明細）
    #明細データのコピー
	  @quotation_details_histories = QuotationDetailsHistory.where(quotation_header_history_id: params[:quotation_header_history_id], 
	                                                quotation_breakdown_history_id: @quotation_breakdown_history_id )
	  
	  if @quotation_details_histories.present?
	    
		@quotation_details_histories.each do |quotation_details_history|
          
         quotation_detail_middle_classification_params = {quotation_header_id: @quotation_header_id, quotation_detail_large_classification_id: @quotation_detail_large_classification_id, 
           quotation_items_division_id: "1", working_middle_item_id: quotation_details_history.working_middle_item_id, working_middle_item_name: quotation_details_history.working_middle_item_name, 
           working_middle_item_short_name: quotation_details_history.working_middle_item_short_name, line_number: quotation_details_history.line_number, working_middle_specification: quotation_details_history.working_middle_specification,
           quantity: quotation_details_history.quantity, execution_quantity: quotation_details_history.execution_quantity, working_unit_id: quotation_details_history.working_unit_id, working_unit_name: quotation_details_history.working_unit_name,
           working_unit_price: quotation_details_history.working_unit_price, quote_price: quotation_details_history.quote_price, execution_unit_price: quotation_details_history.execution_unit_price, execution_price: quotation_details_history.execution_price,
           labor_productivity_unit: quotation_details_history.labor_productivity_unit, labor_productivity_unit_total: quotation_details_history.labor_productivity_unit_total,
		   remarks: quotation_details_history.remarks, construction_type: quotation_details_history.construction_type , piping_wiring_flag: quotation_details_history.piping_wiring_flag , equipment_mounting_flag: quotation_details_history.equipment_mounting_flag , 
           labor_cost_flag: quotation_details_history.labor_cost_flag } 
          	
          @quotation_detail_middle_classification = QuotationDetailMiddleClassification.new(quotation_detail_middle_classification_params)
          if @quotation_detail_middle_classification.save!(:validate => false)
		  else
		    @success_flag = false
		  end 
	    end
	  end
  end
  
  
  
  
end
