class InvoiceDetailMiddleClassificationsController < ApplicationController
  before_action :set_invoice_detail_middle_classification, only: [:show, :edit, :update, :destroy]
  
  #add171016
  before_action :initialize_sort, only: [:show, :new, :edit, :update, :destroy ]
  
  @@new_flag = []
  
  # GET /invoice_detail_middle_classifications
  # GET /invoice_detail_middle_classifications.json
  def index
    
    @null_flag = ""
    
    @number = 1
	
    #ransack保持用コード
    if params[:invoice_header_id].present?
      #$invoice_header_id = params[:invoice_header_id]
	  #upd170626
	  @invoice_header_id = params[:invoice_header_id]
      
	  if params[:working_large_item_name].present?
          #$working_large_item_name = [params[:working_large_item_name], params[:working_large_specification]]
		  #upd170626
		  @working_large_item_name = [params[:working_large_item_name], params[:working_large_specification]]
      end
	  if params[:invoice_detail_large_classification_id].present?
        #$invoice_detail_large_classification_id = params[:invoice_detail_large_classification_id]
		#upd170626
		@invoice_detail_large_classification_id = params[:invoice_detail_large_classification_id]
	  end
	end
    
  
    #明細データ見出用
    if params[:invoice_header_name].present?
      #$invoice_header_name = params[:invoice_header_name]
	  #upd170626
	  @invoice_header_name = params[:invoice_header_name]
    end
    #
	
    #if $invoice_header_id.present?
	#upd170626
	if @invoice_header_id.present?
      #query = {"invoice_header_id_eq"=>"", "with_header_id"=> $invoice_header_id, "with_large_item"=> $working_large_item_name , "working_middle_item_name_eq"=>""}
	  #upd170626
      query = {"invoice_header_id_eq"=>"", "with_header_id"=> @invoice_header_id, 
            "with_large_item"=> @working_large_item_name , "working_middle_item_name_eq"=>""}
	  
      @null_flag = "1"
    end 

    #if query.nil?
    if @null_flag == "" 
      #ransack保持用コード
      query = params[:q]
      query ||= eval(cookies[:recent_search_history].to_s)  	
    end
	
	
    #@q = InvoiceDetailMiddleClassification.ransack(params[:q]) 
    #ransack保持用--上記はこれに置き換える
    @q = InvoiceDetailMiddleClassification.ransack(query)   
    
    #ransack保持用コード
    if @null_flag == "" 
	  search_history = {
       value: params[:q],
       expires: 480.minutes.from_now
      }
      cookies[:recent_search_history] = search_history if params[:q].present?
    end
	#

    @invoice_detail_middle_classifications = @q.result(distinct: true)
	
	#add171016 ソート処理（ビュー）追加
	#ビューでのソート処理追加
	if (params[:q].present? && params[:q][:s].present?) || $sort_im != nil
	    
		#order順のパラメータ(asc/desc)がなぜか１パターンしか入らないので、カラム強制にセットする。
	    column_name = "line_number"
	    
		if $not_sort_im != true
		#ここでにソートを切り替える。（パラメータで入ればベストだが）
		#（モーダル編集、行ソートでこの処理をしないようにしている）
		
		  if params[:q].present? 
            if $sort_im.nil?
	           $sort_im = "desc"
	        end   
 
		    if $sort_im != "asc"
		      $sort_im = "asc"
		    else
		      $sort_im = "desc"
		    end
	      end
		else
		  $not_sort_im = false
		end
		
		#並び替えする（降順/昇順）
		if $sort_im == "asc"
	      @invoice_detail_middle_classifications = @invoice_detail_middle_classifications.order(column_name + " asc")
		elsif $sort_im == "desc"
	      @invoice_detail_middle_classifications = @invoice_detail_middle_classifications.order(column_name + " desc")
		end
	end
	#add end 
	
	#global set
	#del170626
	#$invoice_detail_middle_classifications = @invoice_detail_middle_classifications
	
	#del below 170626
	#明細画面からの印刷機能は抹消する
	#@print_type = params[:print_type]
    
    #デフォルトの頁番号→グローバルに格納
    #$default_page_number = params[:default_page_number].to_i
    
    #内訳書PDF発行
    #respond_to do |format|
    #  format.html # index.html.erb
    #  format.pdf do
    #     if @print_type == "1"
    #      report = DetailedStatementPDF.create @detailed_statement
    #     else
    #      report = DetailedStatementLandscapePDF.create @detailed_statement_landscape
    #     end 
    #    # ブラウザでPDFを表示する
    #    # disposition: "inline" によりダウンロードではなく表示させている
    #    send_data(
    #      report.generate,
    #      filename:  "detailed_statatement.pdf",
    #      type:        "application/pdf",
    #      disposition: "inline")
    #    end
    #end
    #
	
	
  end
  
  #add170412
  #ドラッグ＆ドロップによる並び替え機能(seqをセットする)
  def reorder
  	
	$not_sort_im = true               #add171016 ソート処理（ビュー）追加
	
    if $sort_im != "asc"              #add171016 ソート処理（ビュー）追加
  	  row = params[:row].split(",").reverse    #ビューの並びが逆のため、パラメータの配列を逆順でセットさせる。
    else                              #add171016 ソート処理（ビュー）追加
	  row = params[:row].split(",")   #add171016 ソート処理（ビュー）追加
	end
	 
	  
	#row.each_with_index {|row, i| QuotationDetailLargeClassification.update(row, {:seq => i})}
	#行番号へセットするため、配列は１から開始させる。
	row.each_with_index {|row, i| InvoiceDetailMiddleClassification.update(row, {:line_number => i + 1})}
    render :text => "OK"

    #小計を全て再計算する
    recalc_subtotal_all

  end
  
  # GET /invoice_detail_middle_classifications/1
  # GET /invoice_detail_middle_classifications/1.json
  def show
  end

  # GET /invoice_detail_middle_classifications/new
  def new
    @invoice_detail_middle_classification = InvoiceDetailMiddleClassification.new
  
    @invoice_detail_large_classification = InvoiceDetailLargeClassification.all
    
    
    ###
    #初期値をセット(見出画面からの遷移時のみ)
    @@new_flag = params[:new_flag]
	
	#add170626
	if params[:invoice_header_id].present?
      @invoice_header_id = params[:invoice_header_id]
    end
	
    if @@new_flag == "1"
       #@invoice_detail_middle_classification.invoice_header_id ||= $invoice_header_id
	   #upd170626
	   @invoice_detail_middle_classification.invoice_header_id ||= @invoice_header_id
	   if params[:invoice_detail_large_classification_id].present?
         @invoice_detail_middle_classification.invoice_detail_large_classification_id ||= params[:invoice_detail_large_classification_id]
	   else
         #@invoice_detail_middle_classification.invoice_detail_large_classification_id ||= $invoice_detail_large_classification_id
         #upd170626
         @invoice_detail_middle_classification.invoice_detail_large_classification_id ||= 
                                 @invoice_detail_large_classification_id
       end
    end 
    
    #行番号を取得する
    get_line_number
    ###
  end

  # GET /invoice_detail_middle_classifications/1/edit
  def edit
   
  end

  # POST /invoice_detail_middle_classifications
  # POST /invoice_detail_middle_classifications.json
  def create
    
	#作業明細マスターの更新
	update_working_middle_item
	
	
    ###モーダル化対応
    @invoice_detail_middle_classification = InvoiceDetailMiddleClassification.create(invoice_detail_middle_classification_params)
    
	#add170223
    #歩掛りの集計を最新のもので書き換える。
    update_labor_productivity_unit_summary
	#add170308
    recalc_subtotal
	
     #手入力用IDの場合は、単位マスタへも登録する。
    #@invoice_unit = nil
    @working_unit = nil
    if @invoice_detail_middle_classification.working_unit_id == 1
       
	   #既に登録してないかチェック
       @check_unit = WorkingUnit.find_by(working_unit_name: @invoice_detail_middle_classification.working_unit_name)
       
	   if @check_unit.nil?
          unit_params = { working_unit_name:  @invoice_detail_middle_classification.working_unit_name }
          @working_unit = WorkingUnit.create(unit_params)
		else
		  @working_unit = @check_unit
	   end
    end
 
#   #同様に手入力用IDの場合、明細(中分類)マスターへ登録する。
#    if @invoice_detail_middle_classification.working_middle_item_id == 1
#		 @check_item = WorkingMiddleItem.find_by(working_middle_item_name: @invoice_detail_middle_classification.working_middle_item_name , working_middle_specification: @invoice_detail_middle_classification.working_middle_specification)
#		 @working_unit_id_params = @invoice_detail_middle_classification.working_unit_id
#         if @working_unit.present?
#           @working_unit_all_params = WorkingUnit.find_by(working_unit_name: @invoice_detail_middle_classification.working_unit_name)
#		   @working_unit_id_params = @working_unit_all_params.id
#		 end 
#         if @check_item.nil?
#		  # 全選択の場合
#		  if params[:invoice_detail_middle_classification][:check_update_all] == "true" 
#		      large_item_params = { working_middle_item_name:  @invoice_detail_middle_classification.working_middle_item_name, 
#working_middle_item_short_name: @invoice_detail_middle_classification.working_middle_item_short_name, 
#working_middle_specification:  @invoice_detail_middle_classification.working_middle_specification, 
#working_unit_id: @working_unit_id_params, 
#working_unit_price: @invoice_detail_middle_classification.working_unit_price,
#execution_unit_price: @invoice_detail_middle_classification.execution_unit_price,
#material_id: @invoice_detail_middle_classification.material_id,
#working_material_name: @invoice_detail_middle_classification.working_material_name,
#material_unit_price: @invoice_detail_middle_classification.material_unit_price,
#labor_unit_price: @invoice_detail_middle_classification.labor_unit_price,
#labor_productivity_unit: @invoice_detail_middle_classification.labor_productivity_unit,
#labor_productivity_unit_total: @invoice_detail_middle_classification.labor_productivity_unit_total,
#material_quantity: @invoice_detail_middle_classification.material_quantity,
#accessory_cost: @invoice_detail_middle_classification.accessory_cost,
#material_cost_total: @invoice_detail_middle_classification.material_cost_total,
#labor_cost_total: @invoice_detail_middle_classification.labor_cost_total,
#other_cost: @invoice_detail_middle_classification.other_cost
# }
#               @working_middle_item = WorkingMiddleItem.create(large_item_params)
#          else
#		     # アイテムのみ更新の場合
#		     if params[:invoice_detail_middle_classification][:check_update_item] == "true" 
#		         large_item_params = { working_middle_item_name:  @invoice_detail_middle_classification.working_middle_item_name, 
#                 working_middle_item_short_name: @invoice_detail_middle_classification.working_middle_item_short_name, 
#                 working_middle_specification:  @invoice_detail_middle_classification.working_middle_specification,
#                 working_unit_id: @working_unit_id_params } 
#		          @working_middle_item = WorkingMiddleItem.create(large_item_params)
#		     end
#          end
#         end
#    end



     #品目データの金額を更新
    save_price_to_large_classifications
    #行挿入する 
	@max_line_number = @invoice_detail_middle_classification.line_number
    if (params[:invoice_detail_middle_classification][:check_line_insert] == 'true')
      line_insert
    end
    
    #行番号の最終を書き込む
    invoice_dlc_set_last_line_number
	
	#add170626
	if params[:invoice_detail_middle_classification][:invoice_header_id].present?
      @invoice_header_id = params[:invoice_detail_middle_classification][:invoice_header_id]
    end
	if params[:invoice_detail_middle_classification][:invoice_detail_large_classification_id].present?
      @invoice_detail_large_classification_id = params[:invoice_detail_middle_classification][:invoice_detail_large_classification_id]
    end
	#
		
    #@invoice_detail_middle_classifications = InvoiceDetailMiddleClassification.where(:invoice_header_id => $invoice_header_id).where(:invoice_detail_large_classification_id => $invoice_detail_large_classification_id)
	#upd170626
	@invoice_detail_middle_classifications = InvoiceDetailMiddleClassification.where(:invoice_header_id => 
          @invoice_header_id).where(:invoice_detail_large_classification_id => @invoice_detail_large_classification_id)
	
    ###
  end
  
  
  
  # PATCH/PUT /invoice_detail_middle_classifications/1
  # PATCH/PUT /invoice_detail_middle_classifications/1.json
  def update
    
	#作業明細マスターの更新
	update_working_middle_item
	
    @invoice_detail_middle_classification.update(invoice_detail_middle_classification_params)
    
	#add170223
    #歩掛りの集計を最新のもので書き換える。
    update_labor_productivity_unit_summary
    #add170308
    recalc_subtotal
	
    #品目データの金額を更新
	save_price_to_large_classifications
	
	#行挿入する 
	@max_line_number = @invoice_detail_middle_classification.line_number
    if (params[:invoice_detail_middle_classification][:check_line_insert] == 'true')
       line_insert
    end
    
	#行番号の最終を書き込む
    invoice_dlc_set_last_line_number

    #手入力用IDの場合は、単位マスタへも登録する。
    @working_unit = nil
	
    if @invoice_detail_middle_classification.working_unit_id == 1
       
       #既に登録してないかチェック
       @check_unit = WorkingUnit.find_by(working_unit_name: @invoice_detail_middle_classification.working_unit_name)
       
	   if @check_unit.nil?
          unit_params = { working_unit_name:  @invoice_detail_middle_classification.working_unit_name }
		  
          @working_unit = WorkingUnit.create(unit_params)
	   else
	      @working_unit = @check_unit
	   end
    end
	
	
#    #同様に手入力用IDの場合、明細(中分類)マスターへ登録する。
#    if @invoice_detail_middle_classification.working_middle_item_id == 1
#		 @check_item = WorkingMiddleItem.find_by(working_middle_item_name: @invoice_detail_middle_classification.working_middle_item_name , working_middle_specification: @invoice_detail_middle_classification.working_middle_specification)
#		 @working_unit_id_params = @invoice_detail_middle_classification.working_unit_id
#         if @working_unit.present?
#		   @working_unit_all_params = WorkingUnit.find_by(working_unit_name: @invoice_detail_middle_classification.working_unit_name)
#		   @working_unit_id_params = @working_unit_all_params.id
#		 end 
#         if @check_item.nil?
#		  # 全選択の場合
#		  if params[:invoice_detail_middle_classification][:check_update_all] == "true" 
#		      large_item_params = { working_middle_item_name:  @invoice_detail_middle_classification.working_middle_item_name, 
#working_middle_item_short_name: @invoice_detail_middle_classification.working_middle_item_short_name, 
#working_middle_specification:  @invoice_detail_middle_classification.working_middle_specification, 
#working_unit_id: @working_unit_id_params, 
#working_unit_price: @invoice_detail_middle_classification.working_unit_price,
#execution_unit_price: @invoice_detail_middle_classification.execution_unit_price,
#material_id: @invoice_detail_middle_classification.material_id,
#working_material_name: @invoice_detail_middle_classification.working_material_name,
#material_unit_price: @invoice_detail_middle_classification.material_unit_price,
#labor_unit_price: @invoice_detail_middle_classification.labor_unit_price,
#labor_productivity_unit: @invoice_detail_middle_classification.labor_productivity_unit,
#labor_productivity_unit_total: @invoice_detail_middle_classification.labor_productivity_unit_total,
#material_quantity: @invoice_detail_middle_classification.material_quantity,
#accessory_cost: @invoice_detail_middle_classification.accessory_cost,
#material_cost_total: @invoice_detail_middle_classification.material_cost_total,
#labor_cost_total: @invoice_detail_middle_classification.labor_cost_total,
#other_cost: @invoice_detail_middle_classification.other_cost
# }
#               @working_middle_item = WorkingMiddleItem.create(large_item_params)
#          else
#		     # アイテムのみ更新の場合
#		     if params[:invoice_detail_middle_classification][:check_update_item] == "true"
#		       large_item_params = { working_middle_item_name:  @invoice_detail_middle_classification.working_middle_item_name, 
#                 working_middle_item_short_name: @invoice_detail_middle_classification.working_middle_item_short_name, 
#                 working_middle_specification:  @invoice_detail_middle_classification.working_middle_specification,
#                 working_unit_id: @working_unit_id_params } 
#			     @working_middle_item = WorkingMiddleItem.create(large_item_params)
#		     end
#          end
#         end
#    end
	#add170626
	if params[:invoice_detail_middle_classification][:invoice_header_id].present?
      @invoice_header_id = params[:invoice_detail_middle_classification][:invoice_header_id]
    end
	if params[:invoice_detail_middle_classification][:invoice_detail_large_classification_id].present?
      @invoice_detail_large_classification_id = params[:invoice_detail_middle_classification][:invoice_detail_large_classification_id]
    end
	#
	
    #@invoice_detail_middle_classifications = InvoiceDetailMiddleClassification.where(:invoice_header_id => $invoice_header_id).where(:invoice_detail_large_classification_id => $invoice_detail_large_classification_id)
    #upd170616
    @invoice_detail_middle_classifications = InvoiceDetailMiddleClassification.
       where(:invoice_header_id => @invoice_header_id).where(:invoice_detail_large_classification_id => @invoice_detail_large_classification_id)
	
  end


   #add170823
  #作業明細マスターの更新
  def update_working_middle_item
  
      if params[:invoice_detail_middle_classification][:working_middle_item_id] == "1"
         
		 @check_item = WorkingMiddleItem.find_by(working_middle_item_name: params[:invoice_detail_middle_classification][:working_middle_item_name] , 
		   working_middle_specification: params[:invoice_detail_middle_classification][:working_middle_specification] )
      else
	    #手入力以外の場合   #add170714
		 @check_item = WorkingMiddleItem.find(params[:invoice_detail_middle_classification][:working_middle_item_id])
      end
		
		 @working_unit_id_params = params[:invoice_detail_middle_classification][:working_unit_id]
		 
         if @working_unit.present?
           @working_unit_all_params = WorkingUnit.find_by(working_unit_name: params[:invoice_detail_middle_classification][:working_unit_name] )
		   @working_unit_id_params = @working_unit_all_params.id
		 end 
 
         #if @check_item.nil?
		  
          large_item_params = nil   #add170714
		  
		  #add170823
		  #短縮名（手入力）
		  if params[:invoice_detail_middle_classification][:working_middle_item_short_name_manual] != "<手入力>"
		    working_middle_item_short_name_manual = params[:invoice_detail_middle_classification][:working_middle_item_short_name_manual]
		  else
		    working_middle_item_short_name_manual = ""
		  end
		  ##
		  
		  # 全選択の場合
		  #upd170823 短縮名追加
		  if params[:invoice_detail_middle_classification][:check_update_all] == "true" 
		      large_item_params = { working_middle_item_name:  params[:invoice_detail_middle_classification][:working_middle_item_name], 
                                    working_middle_item_short_name: working_middle_item_short_name_manual, 
                                    working_middle_specification:  params[:invoice_detail_middle_classification][:working_middle_specification] , 
                                    working_unit_id: @working_unit_id_params, 
                                    working_unit_price: params[:invoice_detail_middle_classification][:working_unit_price] ,
                                    execution_unit_price: params[:invoice_detail_middle_classification][:execution_unit_price] ,
                                    material_id: params[:invoice_detail_middle_classification][:material_id] ,
                                    working_material_name: params[:invoice_detail_middle_classification][:quotation_material_name],
                                    material_unit_price: params[:invoice_detail_middle_classification][:material_unit_price] ,
                                    labor_unit_price: params[:invoice_detail_middle_classification][:labor_unit_price] ,
                                    labor_productivity_unit: params[:invoice_detail_middle_classification][:labor_productivity_unit] ,
                                    labor_productivity_unit_total: params[:invoice_detail_middle_classification][:labor_productivity_unit_total] ,
                                    material_quantity: params[:invoice_detail_middle_classification][:material_quantity] ,
                                    accessory_cost: params[:invoice_detail_middle_classification][:accessory_cost] ,
                                    material_cost_total: params[:invoice_detail_middle_classification][:material_cost_total] ,
                                    labor_cost_total: params[:invoice_detail_middle_classification][:labor_cost_total],
                                    other_cost: params[:invoice_detail_middle_classification][:other_cost] 
                                  }
          else
		     # アイテムのみ更新の場合
		     if params[:invoice_detail_middle_classification][:check_update_item] == "true" 
		         large_item_params = { working_middle_item_name: params[:invoice_detail_middle_classification][:working_middle_item_name] , 
                 working_middle_item_short_name: working_middle_item_short_name_manual, 
                 working_middle_specification: params[:invoice_detail_middle_classification][:working_middle_specification] ,
                 working_unit_id: @working_unit_id_params } 
		     end
          end
          #upd170714
		  if large_item_params.present?
		     if @check_item.nil?
		       #@quotation_middle_item = WorkingMiddleItem.create(large_item_params)
			   @check_item = WorkingMiddleItem.create(large_item_params)
			   #手入力の場合のパラメータを書き換える。
			   params[:invoice_detail_middle_classification][:working_middle_item_id] = @check_item.id
			   params[:invoice_detail_middle_classification][:working_middle_item_short_name] = @check_item.id
			 
			 else
			   @check_item.update(large_item_params)
		     end
		  end
  end


  # DELETE /invoice_detail_middle_classifications/1
  # DELETE /invoice_detail_middle_classifications/1.json
  def destroy
    if params[:invoice_header_id].present?
	
      #$invoice_header_id = params[:invoice_header_id]
	  #upd170626
	  @invoice_header_id = params[:invoice_header_id]
	  
      if params[:invoice_detail_large_classification_id].present?
          #$invoice_detail_large_classification_id = params[:invoice_detail_large_classification_id]
		  #upd170626
		  @invoice_detail_large_classification_id = params[:invoice_detail_large_classification_id]
	  end
	end
  
    @invoice_detail_middle_classification.destroy
    respond_to do |format|
      #format.html { redirect_to invoice_detail_middle_classifications_url, notice: 'Invoice detail middle classification was successfully destroyed.' }
      #format.json { head :no_content }
	  
	  #upd170626
	  format.html {redirect_to invoice_detail_middle_classifications_path( :invoice_header_id => params[:invoice_header_id],
                    :invoice_detail_large_classification_id => params[:invoice_detail_large_classification_id], 
	                :invoice_header_name => params[:invoice_header_name],
                    :working_large_item_name => params[:working_large_item_name], :working_large_specification => params[:working_large_specification]
                   )}
	  
	  #品目データの金額を更新
      save_price_to_large_classifications
	  
    end
  end
 
  #請求金額トータル
  def invoice_total_price
    #@execution_total_price = InvoiceDetailMiddleClassification.where(["invoice_detail_large_classification_id = ?", @invoice_detail_middle_classification.invoice_detail_large_classification_id]).sumpriceInvoice
    #upd170511
    @execution_total_price = InvoiceDetailMiddleClassification.where(["invoice_header_id = ? and invoice_detail_large_classification_id = ?", 
       @invoice_detail_middle_classification.invoice_header_id, @invoice_detail_middle_classification.invoice_detail_large_classification_id]).sumpriceInvoice
  end 
  #実行金額トータル
  def execution_total_price
    #@execution_total_price = InvoiceDetailMiddleClassification.where(["invoice_detail_large_classification_id = ?", @invoice_detail_middle_classification.invoice_detail_large_classification_id]).sumpriceExecution
    #upd170511
    @execution_total_price = InvoiceDetailMiddleClassification.where(["invoice_header_id = ? and invoice_detail_large_classification_id = ?", 
       @invoice_detail_middle_classification.invoice_header_id, @invoice_detail_middle_classification.invoice_detail_large_classification_id]).sumpriceExecution
  end

  #歩掛りトータル
  def labor_total
    #@labor_total = InvoiceDetailMiddleClassification.where(["invoice_detail_large_classification_id = ?", @invoice_detail_middle_classification.invoice_detail_large_classification_id]).sumLaborProductivityUnit
    #upd170511
    @labor_total = InvoiceDetailMiddleClassification.where(["invoice_header_id = ? and invoice_detail_large_classification_id = ?", 
      @invoice_detail_middle_classification.invoice_header_id, @invoice_detail_middle_classification.invoice_detail_large_classification_id]).sumLaborProductivityUnit
  end
  #歩掛計トータル
  def labor_all_total
    #@labor_all_total = InvoiceDetailMiddleClassification.where(["invoice_detail_large_classification_id = ?", @invoice_detail_middle_classification.invoice_detail_large_classification_id]).sumLaborProductivityUnitTotal 
    #upd170511
    @labor_all_total = InvoiceDetailMiddleClassification.where(["invoice_header_id = ? and invoice_detail_large_classification_id = ?", 
      @invoice_detail_middle_classification.invoice_header_id, @invoice_detail_middle_classification.invoice_detail_large_classification_id]).sumLaborProductivityUnitTotal 
  end
  
  #トータル(品目→見出保存用)
  
  #請求金額トータル
  def invoice_total_price_Large
     @execution_total_price_Large = InvoiceDetailLargeClassification.where(["invoice_header_id = ?", @invoice_detail_middle_classification.invoice_header_id]).sumpriceInvoice
  end 
  #実行金額トータル
  def execution_total_price_Large
     @execution_total_price_Large = InvoiceDetailLargeClassification.where(["invoice_header_id = ?", @invoice_detail_middle_classification.invoice_header_id]).sumpriceExecution
  end

   #歩掛りトータル
  #def labor_total_Large
  #   @labor_total_Large = InvoiceDetailLargeClassification.where(["id = ?", @invoice_detail_middle_classification.invoice_detail_large_classification_id]).sumLaborProductivityUnit 
  #end
  #

  # ajax
  #add170308
  def subtotal_select
  #小計を取得、セットする
     @search_records = InvoiceDetailMiddleClassification.where("invoice_header_id = ? and invoice_detail_large_classification_id = ?", 
                                                                 params[:invoice_header_id], params[:invoice_detail_large_classification_id] )
     if @search_records.present?
        start_line_number = 0
        end_line_number = 0
        current_line_number = params[:line_number].to_i
        
		@search_records.order(:line_number).each do |idmc|
           if idmc.construction_type.to_i != $INDEX_SUBTOTAL &&
              idmc.construction_type.to_i != $INDEX_DISCOUNT  
			  #小計,値引き以外なら開始行をセット
             if start_line_number == 0
                start_line_number = idmc.line_number
		     end
		   else 
		     if idmc.line_number < current_line_number
		       start_line_number = 0   #開始行を初期化
			 end
           end
		   
		   if idmc.line_number < current_line_number   #更新の場合もあるので現在の行はカウントしない。
		     end_line_number = idmc.line_number  #終了行をセット
           end
        end
        
        #範囲内の計を集計
        @invoice_price = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:invoice_price)
        @execution_price = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:execution_price)
        @labor_productivity_unit_total = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:labor_productivity_unit_total)
        
     end
  end 
  
  def recalc_subtotal_all
  #すべての小計を再計算する(ajax用)
    invoice_price_sum = 0
    execution_price_sum = 0
    labor_productivity_unit_total_sum  = 0
	
	@search_records = InvoiceDetailMiddleClassification.where("invoice_header_id = ? and invoice_detail_large_classification_id = ?", 
                                                       params[:ajax_invoice_header_id], params[:ajax_invoice_detail_large_classification_id])
   
	if @search_records.present?
      @search_records.order(:line_number).each do |idmc|
	    if idmc.construction_type.to_i != $INDEX_SUBTOTAL
          if idmc.construction_type.to_i != $INDEX_DISCOUNT
            #小計・値引き以外？
            invoice_price_sum += idmc.invoice_price.to_i
			execution_price_sum += idmc.execution_price.to_i
			labor_productivity_unit_total_sum += idmc.labor_productivity_unit_total.to_f
		  end
		else
		#小計？=>更新
		    subtotal_params = {invoice_price: invoice_price_sum, execution_price: execution_price_sum, labor_productivity_unit_total: labor_productivity_unit_total_sum}
		    idmc.update(subtotal_params)

			
			#カウンターを初期化
		    invoice_price_sum = 0
            execution_price_sum = 0
            labor_productivity_unit_total_sum  = 0
        end
	  end
    end
  end
  
  #add170308
  def recalc_subtotal
  #小計を再計算する
     @search_records = InvoiceDetailMiddleClassification.where("invoice_header_id = ? and invoice_detail_large_classification_id = ?", 
                                                                 params[:invoice_detail_middle_classification][:invoice_header_id], 
                                                                 params[:invoice_detail_middle_classification][:invoice_detail_large_classification_id] )
	 if @search_records.present?
		start_line_number = 0
        end_line_number = 0
        current_line_number = params[:invoice_detail_middle_classification][:line_number].to_i
        
		subtotal_exist = false
		id_saved = 0
		@search_records.order(:line_number).each do |idmc|
           if idmc.construction_type.to_i != $INDEX_SUBTOTAL &&
              idmc.construction_type.to_i != $INDEX_DISCOUNT  
			  
			 #小計,値引き以外なら開始行をセット
             if start_line_number == 0
                start_line_number = idmc.line_number
		     end
		   else 
		     
			 if idmc.line_number < current_line_number
		       start_line_number = 0   #開始行を初期化
			 elsif idmc.line_number > current_line_number
             #小計欄に来たら、処理を抜ける。
			   subtotal_exist = true
			   id_saved = idmc.id
               
			   break
			 end
           end
		   
		   if idmc.line_number >= current_line_number   
		     end_line_number = idmc.line_number  #終了行をセット
           end
        end
        #範囲内の計を集計
		if subtotal_exist == true
          subtotal_records = InvoiceDetailMiddleClassification.find(id_saved)
    
	      if subtotal_records.present?
		    invoice_price = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:invoice_price)
            execution_price = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:execution_price)
            labor_productivity_unit_total = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:labor_productivity_unit_total)

            subtotal_records.update_attributes!(:invoice_price => invoice_price, :execution_price => execution_price, 
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
  def invoice_detail_large_classification_id_select
     @invoice_detail_large_classification = InvoiceDetailLargeClassification.where(:invoice_header_id => params[:invoice_header_id]).where("id is NOT NULL").pluck(:working_large_item_name, :id)
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
    @labor_productivity_unit = InvoiceDetailMiddleClassification.sum_LPU_PipingWiring(params[:invoice_header_id], params[:invoice_detail_large_classification_id])
    @labor_productivity_unit_total = InvoiceDetailMiddleClassification.sum_LPUT_PipingWiring(params[:invoice_header_id], params[:invoice_detail_large_classification_id])
  end
  #歩掛り(機器取付集計用)
  def LPU_equipment_mounting_select
    @labor_productivity_unit = InvoiceDetailMiddleClassification.sum_LPU_equipment_mounting(params[:invoice_header_id], params[:invoice_detail_large_classification_id])
	@labor_productivity_unit_total = InvoiceDetailMiddleClassification.sum_LPUT_equipment_mounting(params[:invoice_header_id], params[:invoice_detail_large_classification_id])
  end
  #歩掛り(労務費集計用)
  def LPU_labor_cost_select
    @labor_productivity_unit = InvoiceDetailMiddleClassification.sum_LPU_labor_cost(params[:invoice_header_id], params[:invoice_detail_large_classification_id])
	@labor_productivity_unit_total = InvoiceDetailMiddleClassification.sum_LPUT_labor_cost(params[:invoice_header_id], params[:invoice_detail_large_classification_id])
  end
  
  #歩掛りの集計を最新のもので書き換える。
  def update_labor_productivity_unit_summary
    invoice_header_id = params[:invoice_detail_middle_classification][:invoice_header_id]
    invoice_detail_large_classification_id = params[:invoice_detail_middle_classification][:invoice_detail_large_classification_id]

    #upd170308 construction_typeを定数化・順番変更

    #配管配線の計を更新(construction_type=1)
    @IDMC_piping_wiring = InvoiceDetailMiddleClassification.where(invoice_header_id: invoice_header_id, 
                          invoice_detail_large_classification_id: invoice_detail_large_classification_id, construction_type: $INDEX_PIPING_WIRING_CONSTRUCTION).first
	if @IDMC_piping_wiring.present?
      #del170307
      #labor_productivity_unit = InvoiceDetailMiddleClassification.sum_LPU_PipingWiring(invoice_header_id, invoice_detail_large_classification_id)
      labor_productivity_unit_total = InvoiceDetailMiddleClassification.sum_LPUT_PipingWiring(invoice_header_id, invoice_detail_large_classification_id)
      #@IDMC_piping_wiring.update_attributes!(:labor_productivity_unit => labor_productivity_unit, :labor_productivity_unit_total => labor_productivity_unit_total)
      #upd170307
      @IDMC_piping_wiring.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
    end
    
	#機器取付の計を更新(construction_type=2)
    @IDMC_equipment_mounting = InvoiceDetailMiddleClassification.where(invoice_header_id: invoice_header_id, 
                          invoice_detail_large_classification_id: invoice_detail_large_classification_id, construction_type: $INDEX_EUIPMENT_MOUNTING).first
    if @IDMC_equipment_mounting.present?
      #del170307
      #labor_productivity_unit = InvoiceDetailMiddleClassification.sum_LPU_equipment_mounting(invoice_header_id, invoice_detail_large_classification_id)
      labor_productivity_unit_total = InvoiceDetailMiddleClassification.sum_LPUT_equipment_mounting(invoice_header_id, invoice_detail_large_classification_id)
      #@IDMC_equipment_mounting.update_attributes!(:labor_productivity_unit => labor_productivity_unit, :labor_productivity_unit_total => labor_productivity_unit_total)
      #upd170307
      @IDMC_equipment_mounting.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
    end
    
     #労務費の計を更新(construction_type=3)
    @IDMC_labor_cost = InvoiceDetailMiddleClassification.where(invoice_header_id: invoice_header_id, 
                          invoice_detail_large_classification_id: invoice_detail_large_classification_id, construction_type: $INDEX_LABOR_COST).first
    if @IDMC_labor_cost.present?
      #del170307
      #labor_productivity_unit = InvoiceDetailMiddleClassification.sum_LPU_labor_cost(invoice_header_id, invoice_detail_large_classification_id)
      labor_productivity_unit_total = InvoiceDetailMiddleClassification.sum_LPUT_labor_cost(invoice_header_id, invoice_detail_large_classification_id)
      #@IDMC_labor_cost.update_attributes!(:labor_productivity_unit => labor_productivity_unit, :labor_productivity_unit_total => labor_productivity_unit_total)
      #upd170307
      @IDMC_labor_cost.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
    end
  
  end
  #add end
  
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice_detail_middle_classification
      @invoice_detail_middle_classification = InvoiceDetailMiddleClassification.find(params[:id])
    end
    
	#add171016 ソート処理（ビュー）追加
    def initialize_sort
	  $not_sort_im = true
    end
	
    #以降のレコードの行番号を全てインクリメントする
    def line_insert
      InvoiceDetailMiddleClassification.where(["invoice_header_id = ? and invoice_detail_large_classification_id = ? and line_number >= ? and id != ?", @invoice_detail_middle_classification.invoice_header_id, @invoice_detail_middle_classification.invoice_detail_large_classification_id, @invoice_detail_middle_classification.line_number, @invoice_detail_middle_classification.id]).update_all("line_number = line_number + 1")
       
      #最終行番号も取得しておく
      @max_line_number = InvoiceDetailMiddleClassification.
        where(["invoice_header_id = ? and invoice_detail_large_classification_id = ? and line_number >= ? and id != ?", @invoice_detail_middle_classification.invoice_header_id, 
        @invoice_detail_middle_classification.invoice_detail_large_classification_id, @invoice_detail_middle_classification.line_number, 
        @invoice_detail_middle_classification.id]).maximum(:line_number)
    end 

    #見積品目データへ合計保存用　
    def save_price_to_large_classifications
        #@invoice_detail_large_classification = InvoiceDetailLargeClassification.where(:invoice_header_id => params[:invoice_header_id]).where(:invoice_detail_large_classification_id => params[:invoice_detail_large_classification_id])
        @invoice_detail_large_classification = InvoiceDetailLargeClassification.where(["invoice_header_id = ? and id = ?", @invoice_detail_middle_classification.invoice_header_id,@invoice_detail_middle_classification.invoice_detail_large_classification_id]).first

     if @invoice_detail_large_classification.present?

        #見積金額
        @invoice_detail_large_classification.invoice_price = invoice_total_price
        #実行金額
        @invoice_detail_large_classification.execution_price = execution_total_price
        #歩掛り
        @invoice_detail_large_classification.labor_productivity_unit = labor_total
		#歩掛計
        @invoice_detail_large_classification.labor_productivity_unit_total = labor_all_total

        @invoice_detail_large_classification.save
    
        #見出データへも合計保存
        save_price_to_headers
     end

    end

    #見出データへ合計保存用
    def save_price_to_headers
       @invoice_header = InvoiceHeader.find(@invoice_detail_large_classification.invoice_header_id)
       
       if @invoice_header.present? 
       #見積金額
          @invoice_header.billing_amount = invoice_total_price_Large
		  
		  #binding.pry
		  
          #実行金額
          @invoice_header.execution_amount = execution_total_price_Large
          @invoice_header.save
       end 
   end

   
   
   #見出しデータへ最終行番号保存用
    def invoice_dlc_set_last_line_number
        @invoice_detail_large_classifiations = InvoiceDetailLargeClassification.where(["invoice_header_id = ? and id = ?", @invoice_detail_middle_classification.invoice_header_id,@invoice_detail_middle_classification.invoice_detail_large_classification_id]).first
		
        check_flag = false
	    if @invoice_detail_large_classifiations.last_line_number.nil? 
          check_flag = true
        else
	      if (@invoice_detail_large_classifiations.last_line_number < @max_line_number) then
           check_flag = true
		  end
	    end
	    if (check_flag == true)
	       invoice_dlc_params = { last_line_number:  @max_line_number}
		   if @invoice_detail_large_classifiations.present?
		     #@invoice_detail_large_classifiations.update(invoice_dlc_params)
			 
			 #upd170412
			 @invoice_detail_large_classifiations.attributes = invoice_dlc_params
             @invoice_detail_large_classifiations.save(:validate => false)
			 
		   end 
        end 
    end
    #行番号を取得し、インクリメントする。（新規用）
    def get_line_number
      @line_number = 1
      if @invoice_detail_middle_classification.invoice_header_id.present? && @invoice_detail_middle_classification.invoice_detail_large_classification_id.present?
         @invoice_detail_large_classifiations = InvoiceDetailLargeClassification.where(["invoice_header_id = ? and id = ?", @invoice_detail_middle_classification.invoice_header_id,@invoice_detail_middle_classification.invoice_detail_large_classification_id]).first
		 
		 if @invoice_detail_large_classifiations.present?
            if @invoice_detail_large_classifiations.last_line_number.present?
               @line_number = @invoice_detail_large_classifiations.last_line_number + 1
            end
         end
      end
	  
	  @invoice_detail_middle_classification.line_number = @line_number
    end
	
	#ストロングパラメータ
	# Never trust parameters from the scary internet, only allow the white list through.
    def invoice_detail_middle_classification_params
      params.require(:invoice_detail_middle_classification).permit(:invoice_header_id, :invoice_detail_large_classification_id,
            :invoice_item_division_id, :working_middle_item_id, :working_middle_item_name, :working_middle_item_short_name,
            :line_number, :working_middle_specification, :quantity, :execution_quantity, :working_unit_id, :working_unit_name,
            :working_unit_price, :invoice_price, :execution_unit_price, :execution_price, :material_id, :working_material_name, 
            :material_unit_price, :labor_unit_price, :labor_productivity_unit, :labor_productivity_unit_total, :material_quantity, 
            :accessory_cost, :material_cost_total, :labor_cost_total, :other_cost, :remarks, :construction_type, 
            :piping_wiring_flag, :equipment_mounting_flag, :labor_cost_flag)
    end
end
