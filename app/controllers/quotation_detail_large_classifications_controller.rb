class QuotationDetailLargeClassificationsController < ApplicationController
  before_action :set_quotation_detail_large_classification, only: [:show, :edit, :update, :destroy]

  @@new_flag = []
  max_line_number = 0
  
  
  # GET /quotation_detail_large_classifications
  # GET /quotation_detail_large_classifications.json
  def index
    #ransack保持用コード
    @null_flag = ""
    
	if params[:quotation_header_id].present?
      $quotation_header_id = params[:quotation_header_id]
    end
  
  
    if $quotation_header_id.present?
	  query = {"quotation_header_id_eq"=>"", "with_header_id"=> $quotation_header_id, "working_large_item_name_eq"=>""}
	  
	  @null_flag = "1"
	end
	
	
	#if query.nil?
    if @null_flag == "" 
      query = params[:q]
      query ||= eval(cookies[:recent_search_history].to_s)  	
      
	end
    
    #binding.pry

    #@q = QuotationDetailLargeClassification.ransack(params[:q]) 
    #ransack保持用--上記はこれに置き換える
    @q = QuotationDetailLargeClassification.ransack(query)   
    
	if @null_flag == ""
      #ransack保持用コード
      search_history = {
       value: params[:q],
       #expires: 24.hours.from_now
       expires: 480.minutes.from_now
      }
      cookies[:recent_search_history] = search_history if params[:q].present?
    end 
	#

    @quotation_detail_large_classifications = @q.result(distinct: true)
	#
    #global set
	$quotation_detail_large_classifications = @quotation_detail_large_classifications
    
	#add170412
    #@quotation_detail_large_classifications  = @quotation_detail_large_classifications.order('line_number DESC')
	
	#内訳データ見出用
    if params[:quotation_header_name].present?
      $quotation_header_name = params[:quotation_header_name]
    end
    #
	
    @print_type = params[:print_type]
	
	
    if  params[:format] == "pdf" then
	
      #見積書PDF発行
      respond_to do |format|
        format.html # index.html.erb
        format.pdf do
          
		  $print_type = @print_type
		  
    	  case @print_type
		  when "1"
		  #見積書
		    report = EstimationSheetPDF.create @estimation_sheet 
          when "2"
		  #見積書(横)
            report = EstimationSheetLandscapePDF.create @estimation_sheet_landscape
          when "3"
		  #見積書(印あり）
		    report = EstimationSheetPDF.create @estimation_sheet 
            #report = InvoicePDF.create @invoice
		  when "4"
		  #請求書(横)
		     report = InvoiceLandscapePDF.create @invoice_landscape
		  when "5"
		  #納品書
            report = DeliverySlipPDF.create @delivery_slip
		  when "6"
		  #納品書(横)
		     report = DeliverySlipLandscapePDF.create @delivery_slip_landscape
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
      #請求書・納品書のデータ削除＆コピー処理を行う。
      @data_type = params[:data_type]
      case @data_type
        when "1"
		  #請求書データ削除
		  delete_invoice
		  #請求書データ作成
		  create_invoice
		when "2"
          #納品書データ削除
		  delete_delivery_slip
		  #納品書データ作成
		  create_delivery_slip
	  end
	  
	  if @success_flag == true
	    flash[:notice] = "データ作成が完了しました。"
	  end
	end
    #
  end
  
  #add170412
  #ドラッグ＆ドロップによる並び替え機能(seqをセットする)
  def reorder
    
	row = params[:row].split(",").reverse    #ビューの並びが逆のため、パラメータの配列を逆順でセットさせる。
    #row.each_with_index {|row, i| QuotationDetailLargeClassification.update(row, {:seq => i})}
	#行番号へセットするため、配列は１から開始させる。
	row.each_with_index {|row, i| QuotationDetailLargeClassification.update(row, {:line_number => i + 1})}
    render :text => "OK"

    #小計を全て再計算する
    recalc_subtotal_all

  end
  
  # GET /quotation_detail_large_classifications/1
  # GET /quotation_detail_large_classifications/1.json
  def show
  end

  # GET /quotation_detail_large_classifications/new
  def new
    @quotation_detail_large_classification = QuotationDetailLargeClassification.new
    
    #初期値をセット(見出画面からの遷移時のみ)
    @@new_flag = params[:new_flag]
    if @@new_flag == "1"
       @quotation_detail_large_classification.quotation_header_id ||= $quotation_header_id
	   
	end 
    
	#行番号を取得する
	get_line_number
    
  end

  # GET /quotation_detail_large_classifications/1/edit
  def edit
  end

  # POST /quotation_detail_large_classifications
  # POST /quotation_detail_large_classifications.json
  def create
  	  @quotation_detail_large_classification = QuotationDetailLargeClassification.create(quotation_detail_large_classification_params)
	  
	  #add170223
	  #歩掛りの集計を最新のもので書き換える。
	  update_labor_productivity_unit_summary
	  #add170308
	  recalc_subtotal
	  
      # 見出データを保存 
      save_price_to_headers
      
	  
	  @max_line_number = @quotation_detail_large_classification.line_number
      #行挿入する 
      if (params[:quotation_detail_large_classification][:check_line_insert] == 'true')
         line_insert
      end

      #行番号の最終を書き込む
      quotation_headers_set_last_line_number
	  
      
      #手入力用IDの場合は、単位マスタへも登録する。
      #if @quotation_detail_large_classification.quotation_unit_id == 1
	  if @quotation_detail_large_classification.working_unit_id == 1
         #既に登録してないかチェック
         @check_unit = WorkingUnit.find_by(working_unit_name: @quotation_detail_large_classification.working_unit_name)
         if @check_unit.nil?
            unit_params = { working_unit_name:  @quotation_detail_large_classification.working_unit_name }
            @working_unit = WorkingUnit.create(unit_params)
			
			#内訳マスター更用の単位インデックスを取得
			@working_units = WorkingUnit.find_by(working_unit_name: @quotation_detail_large_classification.working_unit_name)
         else 
		   @working_units = @check_unit
		 end
	  end
      
	  #単位のIDをセット
	  if @working_units.present?
	    unit_id = @working_units.id
	  else
	    unit_id = @quotation_detail_large_classification.working_unit_id
	  end
	  
      #同様に手入力用IDの場合、内訳(大分類)マスターへ登録する。
      if @quotation_detail_large_classification.working_large_item_id == 1
         @check_item = WorkingMiddleItem.find_by(working_middle_item_name: @quotation_detail_large_classification.working_large_item_name , 
                                                  working_middle_specification: @quotation_detail_large_classification.working_large_specification)
         if @check_item.nil?
           
		   #全選択の場合
		   if params[:quotation_detail_large_classification][:check_update_all] == "true" 
		     large_item_params = { working_middle_item_name:  @quotation_detail_large_classification.working_large_item_name, 
		                         working_middle_specification:  @quotation_detail_large_classification.working_large_specification,
                                 working_unit_id:  unit_id,
                                 working_unit_price:  @quotation_detail_large_classification.working_unit_price,
                                 execution_unit_price:  @quotation_detail_large_classification.execution_unit_price,
                                 labor_productivity_unit:  @quotation_detail_large_classification.labor_productivity_unit,
                                 labor_productivity_unit_total:  @quotation_detail_large_classification.labor_productivity_unit_total }
			
			 @quotation_large_item = WorkingMiddleItem.create(large_item_params)
		   else
		      #アイテム,仕様,単位のみ場合
		     if params[:quotation_detail_large_classification][:check_update_item] == "true" 
		         large_item_params = { working_middle_item_name:  @quotation_detail_large_classification.working_large_item_name, 
		                         working_middle_specification:  @quotation_detail_large_classification.working_large_specification,
                                 working_unit_id:  unit_id
                                  }
                 @quotation_large_item = WorkingMiddleItem.create(large_item_params)
		     end
		   end
         end
      end
      
   #end
   
   #add
   #@quotation_detail_large_classifications = QuotationDetailLargeClassification.all
   @quotation_detail_large_classifications = QuotationDetailLargeClassification.where(:quotation_header_id => $quotation_header_id)
   
  end

  # PATCH/PUT /quotation_detail_large_classifications/1
  # PATCH/PUT /quotation_detail_large_classifications/1.json
  def update
  
      @quotation_detail_large_classification.update(quotation_detail_large_classification_params)
	  
	  #add170223
	  #歩掛りの集計を最新のもので書き換える。
	  update_labor_productivity_unit_summary
	  #add170308
	  recalc_subtotal
	  
      # 見出データを保存 
      save_price_to_headers
      
	  @max_line_number = @quotation_detail_large_classification.line_number
	  if (params[:quotation_detail_large_classification][:check_line_insert] == 'true')
         line_insert
      end
	  
	  
	  
      #行番号の最終を書き込む
      quotation_headers_set_last_line_number
      
      #####
      #手入力用IDの場合は、単位マスタへも登録する。
      #if @quotation_detail_large_classification.quotation_unit_id == 1
	  
	  if @quotation_detail_large_classification.working_unit_id == 1
         #既に登録してないかチェック
         @check_unit = WorkingUnit.find_by(working_unit_name: @quotation_detail_large_classification.working_unit_name)
         if @check_unit.nil?
            unit_params = { working_unit_name:  @quotation_detail_large_classification.working_unit_name }
            @working_unit = WorkingUnit.create(unit_params)
			
			#内訳マスター更用の単位インデックスを取得
			@working_units = WorkingUnit.find_by(working_unit_name: @quotation_detail_large_classification.working_unit_name)
		 else
		   @working_units = @check_unit
		 end
	  end
      
	  #単位のIDをセット
	  if @working_units.present?
	    unit_id = @working_units.id
	  else
	    unit_id = @quotation_detail_large_classification.working_unit_id
	  end
	  
      #同様に手入力用IDの場合、内訳(大分類)マスターへ登録する。
      if @quotation_detail_large_classification.working_large_item_id == 1
         @check_item = WorkingMiddleItem.find_by(working_middle_item_name: @quotation_detail_large_classification.working_large_item_name , 
		                      working_middle_specification: @quotation_detail_large_classification.working_large_specification)
         if @check_item.nil?
		   #全選択の場合
		   if params[:quotation_detail_large_classification][:check_update_all] == "true" 
		     large_item_params = { working_middle_item_name:  @quotation_detail_large_classification.working_large_item_name,
		                         working_middle_specification:  @quotation_detail_large_classification.working_large_specification,
                                 working_unit_id:  unit_id,
                                 working_unit_price:  @quotation_detail_large_classification.working_unit_price,
                                 execution_unit_price:  @quotation_detail_large_classification.execution_unit_price,
                                 labor_productivity_unit:  @quotation_detail_large_classification.labor_productivity_unit,
                                 labor_productivity_unit_total:  @quotation_detail_large_classification.labor_productivity_unit_total }
               
               @quotation_large_item = WorkingMiddleItem.create(large_item_params)
		   else
		     #アイテム,仕様,単位のみ場合
		     if params[:quotation_detail_large_classification][:check_update_item] == "true" 
		         large_item_params = { working_middle_item_name:  @quotation_detail_large_classification.working_large_item_name, 
                                 working_middle_specification:  @quotation_detail_large_classification.working_large_specification,
                                 working_unit_id:  unit_id
                                  }
                 @quotation_large_item = WorkingMiddleItem.create(large_item_params)
				 
				 
		     end
		   end
		 end
      end
	  #####
	  
      @quotation_detail_large_classifications = QuotationDetailLargeClassification.where(:quotation_header_id => $quotation_header_id)
  end

  # DELETE /quotation_detail_large_classifications/1
  # DELETE /quotation_detail_large_classifications/1.json
  def destroy
    
    #binding.pry
	
    if params[:quotation_header_id].present?
      $quotation_header_id = params[:quotation_header_id]
    end
    
  
    @quotation_detail_large_classification.destroy
    respond_to do |format|
      format.html { redirect_to quotation_detail_large_classifications_url, notice: 'Quotation detail large classification was successfully destroyed.' }
      format.json { head :no_content }
    
      # 見出データを保存 
      save_price_to_headers
    end
	
	
  end
  
  #見積金額トータル
  def quote_total_price
     @execution_total_price = QuotationDetailLargeClassification.where(["quotation_header_id = ?", @quotation_detail_large_classification.quotation_header_id]).sumpriceQuote
  end 
  #実行金額トータル
  def execution_total_price
     @execution_total_price = QuotationDetailLargeClassification.where(["quotation_header_id = ?", @quotation_detail_large_classification.quotation_header_id]).sumpriceExecution
  end


 # ajax
 
  #add170308
  def subtotal_select
  #小計を取得、セットする
     @search_records = QuotationDetailLargeClassification.where("quotation_header_id = ?", params[:quotation_header_id])
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
	
	@search_records = QuotationDetailLargeClassification.where("quotation_header_id = ?", params[:ajax_quotation_header_id])
    
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
  
  #add170308
  def recalc_subtotal
  #小計を再計算する
     @search_records = QuotationDetailLargeClassification.where("quotation_header_id = ?", params[:quotation_detail_large_classification][:quotation_header_id])
	 
	 if @search_records.present?
		start_line_number = 0
        end_line_number = 0
	  
        current_line_number = params[:quotation_detail_large_classification][:line_number].to_i
        
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
          subtotal_records = QuotationDetailLargeClassification.find(id_saved)
    
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
 
  def working_large_item_select
     @working_large_item_name = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_middle_item_name).flatten.join(" ")
  end
  def working_large_specification_select
     @working_large_specification = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_middle_specification).flatten.join(" ")
  end
  def working_unit_name_select
     #@quotation_unit_name = QuotationUnit.where(:id => params[:id]).where("id is NOT NULL").pluck(:quotation_unit_name).flatten.join(" ")
	 @working_unit_name = WorkingUnit.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_unit_name).flatten.join(" ")
  end
  #単位(未使用？)
  def working_unit_id_select
     @working_unit_id  = WorkingMiddleItem.with_unit.where(:id => params[:id]).pluck("working_units.working_unit_name, working_units.id")
	 #登録済み単位と異なるケースもあるので、任意で変更もできるように全ての単位をセット
     unit_all = WorkingUnit.all.pluck("working_units.working_unit_name, working_units.id")
     @working_unit_id = @working_unit_id + unit_all
	 
	 #@quotation_unit_id  = WorkingMiddleItem.with_unit.where(:id => params[:id]).pluck("quotation_units.quotation_unit_name, quotation_units.id")
	 #登録済み単位と異なるケースもあるので、任意で変更もできるように全ての単位をセット
     #unit_all = QuotationUnit.all.pluck("quotation_units.quotation_unit_name, quotation_units.id")
     #@quotation_unit_id = @quotation_unit_id + unit_all
  end
  #見積単価
  def working_unit_price_select
     @working_unit_price = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_unit_price).flatten.join(" ")
  end
  #実行単価
  def execution_unit_price_select
     @execution_unit_price = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:execution_unit_price).flatten.join(" ")
  end
  #歩掛り
  def labor_productivity_unit_select
     @labor_productivity_unit = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:labor_productivity_unit).flatten.join(" ")
  end
  #歩掛計
  def labor_productivity_unit_total_select
     @labor_productivity_unit_total = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:labor_productivity_unit_total).flatten.join(" ")
  end
  
  #add170223
  #歩掛り(配管配線集計用)
  def LPU_piping_wiring_select
    @labor_productivity_unit = QuotationDetailLargeClassification.sum_LPU_PipingWiring(params[:quotation_header_id])
    @labor_productivity_unit_total = QuotationDetailLargeClassification.sum_LPUT_PipingWiring(params[:quotation_header_id])
  end
  #歩掛り(機器取付集計用)
  def LPU_equipment_mounting_select
    @labor_productivity_unit = QuotationDetailLargeClassification.sum_LPU_equipment_mounting(params[:quotation_header_id])
	@labor_productivity_unit_total = QuotationDetailLargeClassification.sum_LPUT_equipment_mounting(params[:quotation_header_id])
  end
  #歩掛り(労務費集計用)
  def LPU_labor_cost_select
  
    @labor_productivity_unit = QuotationDetailLargeClassification.sum_LPU_labor_cost(params[:quotation_header_id])
	@labor_productivity_unit_total = QuotationDetailLargeClassification.sum_LPUT_labor_cost(params[:quotation_header_id])
  end
  
  
  #歩掛りの集計を最新のもので書き換える。
  def update_labor_productivity_unit_summary
    quotation_header_id = params[:quotation_detail_large_classification][:quotation_header_id]
    
    #upd170308 construction_typeを定数化・順番変更
	
    #配管配線の計を更新(construction_type=constant)
    @QDLC_piping_wiring = QuotationDetailLargeClassification.where(quotation_header_id: quotation_header_id, construction_type: $INDEX_PIPING_WIRING_CONSTRUCTION).first
    if @QDLC_piping_wiring.present?
      #del170307
	  #labor_productivity_unit = QuotationDetailLargeClassification.sum_LPU_PipingWiring(quotation_header_id)
      labor_productivity_unit_total = QuotationDetailLargeClassification.sum_LPUT_PipingWiring(quotation_header_id)
      #@QDLC_piping_wiring.update_attributes!(:labor_productivity_unit => labor_productivity_unit, :labor_productivity_unit_total => labor_productivity_unit_total)
	  @QDLC_piping_wiring.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
	end
	
	#機器取付の計を更新(construction_type=)
    @QDLC_equipment_mounting = QuotationDetailLargeClassification.where(quotation_header_id: quotation_header_id, construction_type: $INDEX_EUIPMENT_MOUNTING).first
	if @QDLC_equipment_mounting.present?
      #labor_productivity_unit = QuotationDetailLargeClassification.sum_LPU_equipment_mounting(quotation_header_id)
      labor_productivity_unit_total = QuotationDetailLargeClassification.sum_LPUT_equipment_mounting(quotation_header_id)
	  #@QDLC_equipment_mounting.update_attributes!(:labor_productivity_unit => labor_productivity_unit, :labor_productivity_unit_total => labor_productivity_unit_total)
	  @QDLC_equipment_mounting.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
	end
    #労務費の計を更新(construction_type=x)
    @QDLC_labor_cost = QuotationDetailLargeClassification.where(quotation_header_id: quotation_header_id, construction_type: $INDEX_LABOR_COST).first
	if @QDLC_labor_cost.present?
      #labor_productivity_unit = QuotationDetailLargeClassification.sum_LPU_labor_cost(quotation_header_id)
      labor_productivity_unit_total = QuotationDetailLargeClassification.sum_LPUT_labor_cost(quotation_header_id)
	  #@QDLC_labor_cost.update_attributes!(:labor_productivity_unit => labor_productivity_unit, :labor_productivity_unit_total => labor_productivity_unit_total)
	  @QDLC_labor_cost.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
	end
  
  end
  
  #add end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quotation_detail_large_classification
	   
	   @quotation_detail_large_classification = QuotationDetailLargeClassification.find(params[:id])
    end
    
    # ストロングパラメータ
    # Never trust parameters from the scary internet, only allow the white list through.
    def quotation_detail_large_classification_params
      params.require(:quotation_detail_large_classification).permit(:quotation_header_id, :quotation_items_division_id, :working_large_item_id, 
                     :working_large_item_name, :working_large_item_short_name, :working_large_specification, :line_number, :quantity, :execution_quantity,
                     :working_unit_id, :working_unit_name, :working_unit_price, :execution_unit_price, :quote_price, :execution_price, 
                     :execution_material_unit_price, :material_unit_price, :execution_labor_unit_price, :labor_unit_price, :labor_productivity_unit, 
                     :labor_productivity_unit_total, :remarks, :construction_type, :piping_wiring_flag, :equipment_mounting_flag, :labor_cost_flag)
    end
   
    #以降のレコードの行番号を全てインクリメントする
    def line_insert
      QuotationDetailLargeClassification.where(["quotation_header_id = ? and line_number >= ? and id != ?", @quotation_detail_large_classification.quotation_header_id, @quotation_detail_large_classification.line_number, @quotation_detail_large_classification.id]).update_all("line_number = line_number + 1")
      #最終行番号も取得しておく
      @max_line_number = QuotationDetailLargeClassification.
        where(["quotation_header_id = ? and line_number >= ? and id != ?", @quotation_detail_large_classification.quotation_header_id, 
        @quotation_detail_large_classification.line_number, @quotation_detail_large_classification.id]).maximum(:line_number)
    end
   
     #見出データへ合計保存用　
    def save_price_to_headers
        @quotation_header = QuotationHeader.find(@quotation_detail_large_classification.quotation_header_id)
        #見積金額
        @quotation_header.quote_price = quote_total_price
        #実行金額
        @quotation_header.execution_amount = execution_total_price
        @quotation_header.save
    end
	#見出しデータへ最終行番号保存用
    def quotation_headers_set_last_line_number
        @quotation_headers = QuotationHeader.find_by(id: @quotation_detail_large_classification.quotation_header_id)
		
        check_flag = false
	    if @quotation_headers.last_line_number.nil? 
          check_flag = true
        else
	      if (@quotation_headers.last_line_number < @max_line_number) then
           check_flag = true
		  end
	    end
	    if (check_flag == true)
	       quotation_header_params = { last_line_number:  @max_line_number}
		   if @quotation_headers.present?
		     #@quotation_headers.update(quotation_header_params,)
			 #upd170412
			 @quotation_headers.attributes = quotation_header_params
             @quotation_headers.save(:validate => false)
		   end 
        end 
    end
    #行番号を取得し、インクリメントする。（新規用）
    def get_line_number
      @line_number = 1
      if @quotation_detail_large_classification.quotation_header_id.present?
         @quotation_headers = QuotationHeader.find_by(id: @quotation_detail_large_classification.quotation_header_id)
         if @quotation_headers.present?
            if @quotation_headers.last_line_number.present?
               @line_number = @quotation_headers.last_line_number + 1
            end
         end
      end
	  
	  @quotation_detail_large_classification.line_number = @line_number
    end


########  請求書関連データ操作
  def delete_invoice
  #既存の請求書データを全て削除する
    if params[:quotation_code].present?
	  @invoice_header = InvoiceHeader.find_by(quotation_code: params[:quotation_code])
    
	  if @invoice_header.present?
	    invoice_header_id = @invoice_header.id

	    #明細データ抹消
	    InvoiceDetailMiddleClassification.where(invoice_header_id: invoice_header_id).destroy_all
        #内訳データ抹消
	    InvoiceDetailLargeClassification.where(invoice_header_id: invoice_header_id).destroy_all
	    #見出データ抹消
	    InvoiceHeader.where(id: invoice_header_id).destroy_all
	  end
	end
  end
  
  def create_invoice
  #見積書データを請求書データへ丸ごとコピー（もっと単純な方法ない？）
	  @success_flag = true
	 
	  #見出しデータのコピー
	  @quotation_header = nil
	  if params[:quotation_header_id].present?
	    @quotation_header = QuotationHeader.find(params[:quotation_header_id])
	  end
	  
	  if @quotation_header.present?
        if @quotation_header.quotation_code.present?
		  
		  #add170310 見出しコードが空の場合は仮番号をセット。
		  if @quotation_header.invoice_code.blank?
		    invoice_code = $HEADER_CODE_MAX
          else
            invoice_code = @quotation_header.invoice_code
		  end
		  #
		  
          invoice_header_params = { invoice_code: invoice_code, quotation_code:  @quotation_header.quotation_code, 
                                  delivery_slip_code:  @quotation_header.delivery_slip_code, 
                                  construction_datum_id: @quotation_header.construction_datum_id, construction_name: @quotation_header.construction_name, 
                                  customer_id: @quotation_header.customer_id, customer_name: @quotation_header.customer_name, honorific_id: @quotation_header.honorific_id,
                                  responsible1: @quotation_header.responsible1, responsible2: @quotation_header.responsible2, post: @quotation_header.post, 
                                  address: @quotation_header.address, tel: @quotation_header.tel, fax: @quotation_header.fax, 
                                  construction_period: @quotation_header.construction_period, construction_place: @quotation_header.construction_place, 
                                  invoice_period_start_date: @quotation_header.invoice_period_start_date, invoice_period_end_date: @quotation_header.invoice_period_end_date, 
                                  billing_amount: @quotation_header.quote_price, execution_amount: @quotation_header.execution_amount, last_line_number: @quotation_header.last_line_number} 
          #上記、見積日は移行しないものとする。
          @invoice_header = InvoiceHeader.new(invoice_header_params)
          if @invoice_header.save!(:validate => false)
		  else
		    @success_flag = false
		  end
		else 
          flash[:notice] = "データ作成に失敗しました！見積書コードを登録してください。"
          @success_flag = false
		end
	  end 
	  
	  if @success_flag == true
	    ##見出しIDをここで取得
	    @invoice_header = InvoiceHeader.find_by(quotation_code: params[:quotation_code])
	    @invoice_header_id = nil
	    if @invoice_header.present?
	      @invoice_header_id = @invoice_header.id
	  
	     #binding.pry
	  
          #内訳データのコピー
	      @q_d_l_c = QuotationDetailLargeClassification.where(quotation_header_id: params[:quotation_header_id])
	      if @q_d_l_c.present?
	    
		    @q_d_l_c.each do |q_d_l_c|
              
		      #IDをここでセットしておく（明細で参照するため）
		      @quotation_detail_large_classification_id = q_d_l_c.id
			   
		      invoice_detail_large_classification_params = {invoice_header_id: @invoice_header_id, invoice_items_division_id: q_d_l_c.quotation_items_division_id, 
                working_large_item_id: q_d_l_c.working_large_item_id, working_large_item_name: q_d_l_c.working_large_item_name, 
                working_large_item_short_name: q_d_l_c.working_large_item_short_name,
                working_large_specification: q_d_l_c.working_large_specification, line_number: q_d_l_c.line_number, quantity: q_d_l_c.quantity, 
                execution_quantity: q_d_l_c.execution_quantity, working_unit_id: q_d_l_c.working_unit_id, working_unit_name: q_d_l_c.working_unit_name, 
                working_unit_price: q_d_l_c.working_unit_price, invoice_price: q_d_l_c.quote_price, execution_unit_price: q_d_l_c.execution_unit_price, 
                execution_price: q_d_l_c.execution_price, labor_productivity_unit: q_d_l_c.labor_productivity_unit, 
                labor_productivity_unit_total: q_d_l_c.labor_productivity_unit_total, last_line_number: q_d_l_c.remarks, last_line_number: q_d_l_c.remarks,
                construction_type: q_d_l_c.construction_type , piping_wiring_flag: q_d_l_c.piping_wiring_flag , equipment_mounting_flag: q_d_l_c.equipment_mounting_flag , 
                labor_cost_flag: q_d_l_c.labor_cost_flag }
            
			  @invoice_detail_large_classification = InvoiceDetailLargeClassification.new(invoice_detail_large_classification_params)
              if @invoice_detail_large_classification.save!(:validate => false)
		      
                 #IDをここでセットしておく（明細で参照するため）
			     @invoice_detail_large_classification_id = InvoiceDetailLargeClassification.maximum("id")
		       
			     #明細データのコピー(サブルーチン)
			     create_invoice_detail
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
  def create_invoice_detail
    #見積書データを請求書データへ丸ごとコピー（明細）
    #明細データのコピー
	  @q_d_m_c = QuotationDetailMiddleClassification.where(quotation_header_id: params[:quotation_header_id], 
	                                                            quotation_detail_large_classification_id: @quotation_detail_large_classification_id )
	  
	  if @q_d_m_c.present?
	    
		@q_d_m_c.each do |q_d_m_c|
          
		   invoice_detail_middle_classification_params = {invoice_header_id: @invoice_header_id, invoice_detail_large_classification_id: @invoice_detail_large_classification_id, 
             invoice_item_division_id: q_d_m_c.quotation_items_division_id, working_middle_item_id: q_d_m_c.working_middle_item_id, working_middle_item_name: q_d_m_c.working_middle_item_name, 
             working_middle_item_short_name: q_d_m_c.working_middle_item_short_name, line_number: q_d_m_c.line_number, working_middle_specification: q_d_m_c.working_middle_specification,
             quantity: q_d_m_c.quantity, execution_quantity: q_d_m_c.execution_quantity, working_unit_id: q_d_m_c.working_unit_id, working_unit_name: q_d_m_c.working_unit_name,
             working_unit_price: q_d_m_c.working_unit_price, invoice_price: q_d_m_c.quote_price, execution_unit_price: q_d_m_c.execution_unit_price, execution_price: q_d_m_c.execution_price,
             material_id: q_d_m_c.material_id, working_material_name: q_d_m_c.quotation_material_name, material_unit_price: q_d_m_c.material_unit_price, 
             labor_unit_price: q_d_m_c.labor_unit_price, labor_productivity_unit: q_d_m_c.labor_productivity_unit, labor_productivity_unit_total: q_d_m_c.labor_productivity_unit_total,
             material_quantity: q_d_m_c.material_quantity, accessory_cost: q_d_m_c.accessory_cost, material_cost_total: q_d_m_c.material_cost_total, 
             labor_cost_total: q_d_m_c.labor_cost_total, other_cost: q_d_m_c.other_cost, remarks: q_d_m_c.remarks,
             construction_type: q_d_m_c.construction_type , piping_wiring_flag: q_d_m_c.piping_wiring_flag , equipment_mounting_flag: q_d_m_c.equipment_mounting_flag , 
             labor_cost_flag: q_d_m_c.labor_cost_flag } 
          	
          @invoice_detail_middle_classification = InvoiceDetailMiddleClassification.new(invoice_detail_middle_classification_params)
          if @invoice_detail_middle_classification.save!(:validate => false)
		  else
		    @success_flag = false
			flash[:notice] = "データ作成に失敗しました！再度行ってください。"
		  end 
	    end
	  end
  end

########  納品書関連データ操作
  def delete_delivery_slip
  #既存の納品書データを全て削除する
    if params[:quotation_code].present?
	  @delivery_slip_header = DeliverySlipHeader.find_by(quotation_code: params[:quotation_code])
    
	  if @delivery_slip_header.present?
	    delivery_slip_header_id = @delivery_slip_header.id
		
		
	    #明細データ抹消
	    DeliverySlipDetailMiddleClassification.where(delivery_slip_header_id: delivery_slip_header_id).destroy_all
        #内訳データ抹消
	    DeliverySlipDetailLargeClassification.where(delivery_slip_header_id: delivery_slip_header_id).destroy_all
	    #見出データ抹消
	    DeliverySlipHeader.where(id: delivery_slip_header_id).destroy_all
	  end
	end
  end
  
  def create_delivery_slip
  #見積書データを納品書データへ丸ごとコピー（もっと単純な方法ない？）
	  @success_flag = true
	 
	  #見出しデータのコピー
	  @quotation_header = nil
	  if params[:quotation_header_id].present?
	    @quotation_header = QuotationHeader.find(params[:quotation_header_id])
	  end
	  
	  #add170310 見出しコードが空の場合は仮番号をセット。
	   if @quotation_header.delivery_slip_code.blank?
	     delivery_slip_code = $HEADER_CODE_MAX
       else
         delivery_slip_code = @quotation_header.delivery_slip_code
	   end
	   #
		  
	  if @quotation_header.present?
        if @quotation_header.quotation_code.present?
          delivery_slip_header_params = { delivery_slip_code:  delivery_slip_code, quotation_code:  @quotation_header.quotation_code, 
                                  invoice_code:  @quotation_header.invoice_code,
                                  construction_datum_id: @quotation_header.construction_datum_id, construction_name: @quotation_header.construction_name, 
                                  customer_id: @quotation_header.customer_id, customer_name: @quotation_header.customer_name, honorific_id: @quotation_header.honorific_id,
                                  responsible1: @quotation_header.responsible1, responsible2: @quotation_header.responsible2, post: @quotation_header.post, 
                                  address: @quotation_header.address, tel: @quotation_header.tel, fax: @quotation_header.fax, construction_period: @quotation_header.construction_period, 
                                  construction_place: @quotation_header.construction_place, 
                                  delivery_amount: @quotation_header.quote_price, execution_amount: @quotation_header.execution_amount, last_line_number: @quotation_header.last_line_number} 
          #上記、見積日は移行しないものとする。
          @deliver_slip_header = DeliverySlipHeader.new(delivery_slip_header_params)
          if @deliver_slip_header.save!(:validate => false)
		  else
            flash[:notice] = "データ作成に失敗しました！見積書コードを登録してください。"
            @success_flag = false
		  end
        else
        end 
	  end 
	  
      if @success_flag == true
	    ##見出しIDをここで取得
	    @delivery_slip_header = DeliverySlipHeader.find_by(quotation_code: params[:quotation_code])
	    @delivery_slip_header_id = nil
	    if @delivery_slip_header.present?
	      @delivery_slip_header_id = @delivery_slip_header.id
	  
          #内訳データのコピー
	      @q_d_l_c = QuotationDetailLargeClassification.where(quotation_header_id: params[:quotation_header_id])
	      if @q_d_l_c.present?
	    
		    @q_d_l_c.each do |q_d_l_c|
              
		      #IDをここでセットしておく（明細で参照するため）
			  @quotation_detail_large_classification_id = q_d_l_c.id
			   
		      delivery_slip_detail_large_classification_params = {delivery_slip_header_id: @delivery_slip_header_id, delivery_slip_items_division_id: q_d_l_c.quotation_items_division_id, 
                working_large_item_id: q_d_l_c.working_large_item_id, working_large_item_name: q_d_l_c.working_large_item_name, 
                working_large_item_short_name: q_d_l_c.working_large_item_short_name,
                working_large_specification: q_d_l_c.working_large_specification, line_number: q_d_l_c.line_number, quantity: q_d_l_c.quantity, 
                execution_quantity: q_d_l_c.execution_quantity, working_unit_id: q_d_l_c.working_unit_id, working_unit_name: q_d_l_c.working_unit_name, 
                working_unit_price: q_d_l_c.working_unit_price, delivery_slip_price: q_d_l_c.quote_price, execution_unit_price: q_d_l_c.execution_unit_price, 
                execution_price: q_d_l_c.execution_price, labor_productivity_unit: q_d_l_c.labor_productivity_unit, 
                labor_productivity_unit_total: q_d_l_c.labor_productivity_unit_total, last_line_number: q_d_l_c.last_line_number, remarks: q_d_l_c.remarks,
                construction_type: q_d_l_c.construction_type , piping_wiring_flag: q_d_l_c.piping_wiring_flag , equipment_mounting_flag: q_d_l_c.equipment_mounting_flag , 
                labor_cost_flag: q_d_l_c.labor_cost_flag }
            
			  @delivery_slip_detail_large_classification = DeliverySlipDetailLargeClassification.new(delivery_slip_detail_large_classification_params)
              if @delivery_slip_detail_large_classification.save!(:validate => false)
		      
                 #IDをここでセットしておく（明細で参照するため）
			     @delivery_slip_detail_large_classification_id = DeliverySlipDetailLargeClassification.maximum("id")
		         #明細データのコピー(サブルーチン)
			     create_delivery_slip_detail
		      else
		        @success_flag = false
              end 
	        end
	      end
	    end
      end
	  #
  end
  
  
  def create_delivery_slip_detail
    #見積書データを納品書データへ丸ごとコピー（明細）
    #明細データのコピー
	  @q_d_m_c = QuotationDetailMiddleClassification.where(quotation_header_id: params[:quotation_header_id], 
	                                                            quotation_detail_large_classification_id: @quotation_detail_large_classification_id )
	  
	  if @q_d_m_c.present?
	    
		@q_d_m_c.each do |q_d_m_c|
          
		   delivery_slip_detail_middle_classification_params = {delivery_slip_header_id: @delivery_slip_header_id, delivery_slip_detail_large_classification_id: @delivery_slip_detail_large_classification_id, 
             delivery_slip_item_division_id: q_d_m_c.quotation_items_division_id, working_middle_item_id: q_d_m_c.working_middle_item_id, working_middle_item_name: q_d_m_c.working_middle_item_name, 
             working_middle_item_short_name: q_d_m_c.working_middle_item_short_name, line_number: q_d_m_c.line_number, working_middle_specification: q_d_m_c.working_middle_specification,
             quantity: q_d_m_c.quantity, execution_quantity: q_d_m_c.execution_quantity, working_unit_id: q_d_m_c.working_unit_id, working_unit_name: q_d_m_c.working_unit_name,
             working_unit_price: q_d_m_c.working_unit_price, delivery_slip_price: q_d_m_c.quote_price, execution_unit_price: q_d_m_c.execution_unit_price, execution_price: q_d_m_c.execution_price, 
             material_id: q_d_m_c.material_id, working_material_name: q_d_m_c.quotation_material_name, material_unit_price: q_d_m_c.material_unit_price, 
			 labor_unit_price: q_d_m_c.labor_unit_price, labor_productivity_unit: q_d_m_c.labor_productivity_unit, labor_productivity_unit_total: q_d_m_c.labor_productivity_unit_total,
			 material_quantity: q_d_m_c.material_quantity, accessory_cost: q_d_m_c.accessory_cost, material_cost_total: q_d_m_c.material_cost_total, 
			 labor_cost_total: q_d_m_c.labor_cost_total, other_cost: q_d_m_c.other_cost, remarks: q_d_m_c.remarks,
             construction_type: q_d_m_c.construction_type , piping_wiring_flag: q_d_m_c.piping_wiring_flag , equipment_mounting_flag: q_d_m_c.equipment_mounting_flag , 
             labor_cost_flag: q_d_m_c.labor_cost_flag } 
          
          
          @delivery_slip_detail_middle_classification = DeliverySlipDetailMiddleClassification.new(delivery_slip_detail_middle_classification_params)
          if @delivery_slip_detail_middle_classification.save!(:validate => false)
		  else
		    @success_flag = false
		  end 
	    end
	  end
  end

end
