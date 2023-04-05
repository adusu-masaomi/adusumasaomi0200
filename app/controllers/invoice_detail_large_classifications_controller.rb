class InvoiceDetailLargeClassificationsController < ApplicationController
  before_action :set_invoice_detail_large_classification, only: [:show, :edit, :update, :destroy]
  
  #add171016
  before_action :initialize_sort, only: [:show, :new, :edit, :update, :destroy ]
  
  
  @@new_flag = []
  max_line_number = 0

  # GET /invoice_detail_large_classifications
  # GET /invoice_detail_large_classifications.json
  def index
    
	#ransack保持用コード
    @null_flag = ""
    
    if params[:invoice_header_id].present?
      @invoice_header_id = params[:invoice_header_id]
    end
	
    if @invoice_header_id.present?
      #query = {"invoice_header_id_eq"=>"", "with_header_id"=> $invoice_header_id, "invoice_large_item_name_eq"=>""}
	    #upd170626
	    query = {"invoice_header_id_eq"=>"", "with_header_id"=> @invoice_header_id, "invoice_large_item_name_eq"=>""}
	  
      @null_flag = "1"
    end
	
    #if query.nil?
    if @null_flag == "" 
      query = params[:q]
      query ||= eval(cookies[:recent_search_history].to_s)  	
    end
	
    #ransack保持用
    @q = InvoiceDetailLargeClassification.ransack(query)
    
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

    @invoice_detail_large_classifications = @q.result(distinct: true)
    
	
	#add171016
	#ビューでのソート処理追加
	if (params[:q].present? && params[:q][:s].present?) || $sort_il != nil
	    
		#order順のパラメータ(asc/desc)がなぜか１パターンしか入らないので、カラム強制にセットする。
	    column_name = "line_number"
	    
		if $not_sort_il != true
		#ここでにソートを切り替える。（パラメータで入ればベストだが）
		#（モーダル編集、行ソートでこの処理をしないようにしている）
		
		  if params[:q].present? 
            if $sort_il.nil?
	           $sort_il = "desc"
	        end   
 
		    if $sort_il != "asc"
		      $sort_il = "asc"
		    else
		      $sort_il = "desc"
		    end
	      end
		else
		  $not_sort_il = false
		end
		
		#並び替えする（降順/昇順）
		if $sort_il == "asc"
	      @invoice_detail_large_classifications = @invoice_detail_large_classifications.order(column_name + " asc")
		elsif $sort_il == "desc"
	      @invoice_detail_large_classifications = @invoice_detail_large_classifications.order(column_name + " desc")
		end
	end
	#add end 
	
    #
    #global set
	#del170626
	#$invoice_detail_large_classifications = @invoice_detail_large_classifications
	
	#内訳データ見出用
    if params[:invoice_header_name].present?
      #$invoice_header_name = params[:invoice_header_name]
	  #upd170626
	  @invoice_header_name = params[:invoice_header_name]
    end
    #
	
    @print_type = params[:print_type]
 
    if  params[:format] == "pdf" then
	
      #見積書PDF発行
      respond_to do |format|
        format.html # index.html.erb
        
        format.pdf do
          $print_type = @print_type

          #官公庁・学校の判定
          get_public_flag
      
          case @print_type
		      when "1"
		      #請求書
            report = InvoicePDF.create @invoice_detail_large_classifications
		      when "2"
		      #請求書(横)
		        report = InvoiceLandscapePDF.create @invoice_detail_large_classifications
		      when "3"
		      #請求書（印鑑有）
            report = InvoicePDF.create @invoice_detail_large_classifications
		      when "4"
          #請求書（印鑑有-旧様式）
            report = InvoicePDF.create @invoice_detail_large_classifications
            
		      #when "4"
		      ##納品書(横)
		      #  report = DeliverySlipLandscapePDF.create @delivery_slip_landscape
		      #when "5"
		      ##見積書
              #  report = EstimationSheetPDF.create @estimation_sheet 
          #when "6"
		      ##見積書(横)
          #  report = EstimationSheetLandscapePDF.create @estimation_sheet_landscape
          end 	
	      
		      #現在時刻をセットする
          require "date"
          d = DateTime.now
          now_date_time = d.strftime("%Y%m%d%H%M%S")
		  
          # ブラウザでPDFを表示する
          # disposition: "inline" によりダウンロードではなく表示させている
          send_data report.generate,
            filename:    "請求書-" + now_date_time + ".pdf",
            type:        "application/pdf",
            disposition: "inline"
        end
      end  #respond end
      
      #
      #入金マスターへ書き込み
      upsert_deposit_amount
      #日次入出金マスターへ書き込み
      #upsert_daily_cash_flow
      app_upsert_daily_cash_flow
      #
      
    else  #PDF以外

	    #納品書・見積書のデータ削除＆コピー処理を行う。
	    @data_type = params[:data_type]
	    case @data_type
      when "1"
		  #納品書データ削除
		    delete_delivery_slip
		  #納品書データ作成
		    create_delivery_slip
		  when "2"
      #見積書データ削除
		    delete_quotation
		    #見積書データ作成
		    create_quotation
	    end
	  
	    if @success_flag == true
	      flash[:notice] = "データ作成が完了しました。"
	    end
	
    end
	  #
	
  end

  #入金・管理マスターへ書き込み
  def upsert_deposit_amount
    
    @invoice_header = InvoiceHeader.find(@invoice_header_id)
    
    #binding.pry
    #@invoice_header.customer_master.payment_bank_id
    
    if @invoice_header.present?
      
      #deposit = Deposit.find_by(invoice_header_id: @invoice_header.id)
      deposit = Deposit.find_by(table_id: @invoice_header.id)
      
      ##
      #入金額の計算
      @billing_amount_with_tax = @invoice_header.billing_amount * $consumption_tax_include_per_ten
      @billing_amount_with_tax = @billing_amount_with_tax.to_i #(整数化)
      
      #入金予定日の計算(戻り:@payment_due_date)
      app_get_income_due_date(@invoice_header.customer_id, 
                              @invoice_header.invoice_date, true)
      
      #送金先の銀行IDをセット
      source_bank_id = $BANK_ID_DAISHI_HOKUETSU  #デフォルトは第四とする
      if @invoice_header.customer_master.payment_bank_id.present?
        source_bank_id = set_source_bank_id(@invoice_header.customer_master.payment_bank_id)
      end
      
      table_type_id = 1  #テーブル種類ID(1で固定)
      #得意先名を保存
      customer_name = nil
      if @invoice_header.customer_master.present?
        if @invoice_header.customer_master.customer_name.present?
          customer_name = @invoice_header.customer_master.customer_name
        end
      end
      #
      
      @differ_date = nil
      
      if deposit.nil?
        #新規
        
        #差異数量
        @differ_amount = @billing_amount_with_tax
        #
        
        #deposit_params = { table_id: @invoice_header.id, deposit_due_date: @payment_due_date,
        #                   deposit_amount: @billing_amount_with_tax, deposit_source_id: source_bank_id}
        
        deposit_params = { table_type_id: table_type_id, table_id: @invoice_header.id, 
                           deposit_due_date: @payment_due_date, name: customer_name, 
                           deposit_amount: @billing_amount_with_tax, deposit_source_id: source_bank_id}
        
        
        @check = Deposit.create(deposit_params)
      else
        #更新
        
        #差異数量をここで求める
        @differ_amount = @billing_amount_with_tax - deposit.deposit_amount
        #
        
        #日付違う場合のフラグ
        if deposit.deposit_due_date != @payment_due_date
          @differ_date = deposit.deposit_due_date
          @differ_amount = @billing_amount_with_tax #変更後の数量(加算必要なため)
        end
        #
        
        #honban
        #deposit_params = { deposit_due_date: @payment_due_date, name: customer_name,
        #                   deposit_amount: @billing_amount_with_tax, deposit_source_id: source_bank_id}
        
        deposit_params = { table_type_id: table_type_id, deposit_due_date: @payment_due_date, name: customer_name,
                           deposit_amount: @billing_amount_with_tax, deposit_source_id: source_bank_id}
                           
        deposit.update(deposit_params)
      end
      
    end
  
  end
  
  #送金先の銀行IDをセットする
  #1:第四 3:さんしん 9:現金
  def set_source_bank_id(bank_id)
    
    source_bank_id = bank_id
     
    case bank_id
    when $BANK_ID_SANSHIN_TSUKANOME, $BANK_ID_SANSHIN_MAIN
      #さんしんは塚野目にまとめる
      source_bank_id = $BANK_ID_SANSHIN_TSUKANOME
    end
    
    return source_bank_id
    
  end
    
  #(app.controllerへ移行)
  #日次入出金マスターへの書き込み
  #@differ_amount, @differ_date, @payment_due_dateが事前取得されていること
  def upsert_daily_cash_flow
  
    daily_cash_flow = DailyCashFlow.find_by(cash_flow_date: @payment_due_date)
    if daily_cash_flow.nil?
    #データ無しの場合
          
      #前日までの残高を取得(保留)
      #get_pre_balance
          
      #前日残をセット(保留)
      #pre_balance = 0
      #if @pre_balance.present?
      #  pre_balance += @pre_balance
      #end
      
      #残高をセット(保留)
      #balance = pre_balance + @differ_amount
      #
      
      
      #daily_cash_flow_params = { cash_flow_date: @payment_due_date, income: @differ_amount,
      #                          previous_balance: pre_balance, balance: balance }
      
      daily_cash_flow_params = { cash_flow_date: @payment_due_date, income: @differ_amount }
      
          
      @check = DailyCashFlow.create(daily_cash_flow_params)
    else
    #データ存在している場合
          
      if @differ_amount.abs > 0
        #残高をセット
        income = daily_cash_flow.income.to_i + @differ_amount
        #daily_cash_flow_params = { income: income, income_completed_flag: 0}  #追加を考慮し、完了フラグは0にする
        daily_cash_flow_params = { income: income }  #upd230327 再発行でリセットされてしまうため 完了フラグは操作しない
        daily_cash_flow.update(daily_cash_flow_params)
      end
    end
        
    #日付変わった場合、差異をマイナスする
    if @differ_date.present?
      delete_daily_cash_flow
    end
    #
  
    #end
    
    #同月内の、前日残高へ加算(保留)
    #add_pre_balance_to_end_month
    
  end
  
    
  #入出金データからマイナスする
  #@differ_date, @differ_amountが取得されている事
  def delete_daily_cash_flow
    daily_cash_flow = DailyCashFlow.find_by(cash_flow_date: @differ_date)
    
    if daily_cash_flow.present?
      #daily_cash_flow.income -= @billing_amount_with_tax
      daily_cash_flow.income -= @differ_amount
      
      #binding.pry
      
      #残高も要計算(保留)
      #daily_cash_flow.balance = daily_cash_flow.previous_balance - daily_cash_flow.income - daily_cash_flow.expence.to_i
      
      daily_cash_flow.save!(:validate => false)
    end
    
  end
  
  def destroy_deposit
  
    @deposit = Deposit.find_by(invoice_header_id: @invoice_header_id)
    
    #binding.pry
    
    if @deposit.present?
      #日次入出金ファイルを減算するために値取得
      @differ_date = @deposit.deposit_due_date
      @differ_amount = @deposit.deposit_amount
      #delete_daily_cash_flow
      #
      @deposit.destroy
    end
  
  end
  
  #同月内の、前日残高へ加算(保留)
  #@differ_amountが計算されていること
  def add_pre_balance_to_end_month
    
    if @differ_amount.abs > 0
    
      #1日後の日付
      start_date = @payment_due_date + 1
      #その月の末日
      end_date = Date.new(@payment_due_date.year, @payment_due_date.month, -1)
    
      #@differ_amount
      (start_date..end_date).each do|date|
      
        daily_cash_flow = DailyCashFlow.find_by(cash_flow_date: date)
      
        if daily_cash_flow.present?
          daily_cash_flow.previous_balance += @differ_amount
          daily_cash_flow.balance += @differ_amount
          
          daily_cash_flow.save!(:validate => false)
        end
        
      end
    
    end
    
  end

  #前日までの残高を取得(保留)
  def get_pre_balance
    #その月の1日を求める
    day_start = @payment_due_date.beginning_of_month
    
    #whereの".."は〜以上〜未満の意味。
    daily_cash_flow_before = DailyCashFlow.where(cash_flow_date: DailyCashFlow.where(cash_flow_date: day_start..@payment_due_date).
                        maximum('cash_flow_date')).first
    
    @pre_balance = daily_cash_flow_before.balance
    
    #daily_cash_flow_before = DailyCahFlow.where(
    #result = Article.where(site_id:1).maximum(:created_at)
  end
    
  #官公庁・学校のフラグを判定(add221105)
  def get_public_flag
    
    $public_flag = false
    
    invoice_header = InvoiceHeader.find(params[:invoice_header_id])
    if invoice_header.customer_master.public_flag == 1
      $public_flag = true
    end
    
  end

  #ドラッグ＆ドロップによる並び替え機能(seqをセットする)
  def reorder
    
	$not_sort_il = true               #add171016
	
	if $sort_il != "asc"              #add171016
	  row = params[:row].split(",").reverse    #ビューの並びが逆のため、パラメータの配列を逆順でセットさせる。
	else                              #add171016
	  row = params[:row].split(",")   #add171016
	end
	
	#row.each_with_index {|row, i| QuotationDetailLargeClassification.update(row, {:seq => i})}
	#行番号へセットするため、配列は１から開始させる。
	row.each_with_index {|row, i| InvoiceDetailLargeClassification.update(row, {:line_number => i + 1})}
    render :text => "OK"

    #小計を全て再計算する
    recalc_subtotal_all

  end

  # GET /invoice_detail_large_classifications/1
  # GET /invoice_detail_large_classifications/1.json
  def show
  end

  # GET /invoice_detail_large_classifications/new
  def new
    @invoice_detail_large_classification = InvoiceDetailLargeClassification.new
	
    #add170626
    if params[:invoice_header_id].present?
      @invoice_header_id = params[:invoice_header_id]
    end
	
	###
    #初期値をセット(見出画面からの遷移時のみ)
    @@new_flag = params[:new_flag]

	if @@new_flag == "1"
       #@invoice_detail_large_classification.invoice_header_id ||= $invoice_header_id
	   #upd170626
	   @invoice_detail_large_classification.invoice_header_id ||= @invoice_header_id
	end 
    
	#行番号を取得する
	get_line_number
	
	
  end

  # GET /invoice_detail_large_classifications/1/edit
  def edit
  end

  # POST /invoice_detail_large_classifications
  # POST /invoice_detail_large_classifications.json
  def create
  
    #作業明細マスターの更新
    #add170822
    update_working_middle_item
  
    @invoice_detail_large_classification = InvoiceDetailLargeClassification.create(invoice_detail_large_classification_params)
    
    #歩掛りの集計を最新のもので書き換える。
    update_labor_productivity_unit_summary
    #小計を再計算
    recalc_subtotal
      
    # 見出データを保存 
    save_price_to_headers
    
    @max_line_number = @invoice_detail_large_classification.line_number
    #行挿入する 
    if (params[:invoice_detail_large_classification][:check_line_insert] == 'true')
       line_insert
    end
    
    #行番号の最終を書き込む
    invoice_headers_set_last_line_number
    
    #工事集計の確定区分があれば見出しへZセット
    set_final_return_division_params
  
    
    #手入力用IDの場合は、単位マスタへも登録する。
    if @invoice_detail_large_classification.working_unit_id == 1
       #既に登録してないかチェック
       @check_unit = WorkingUnit.find_by(working_unit_name: @invoice_detail_large_classification.working_unit_name)
       if @check_unit.nil?
          unit_params = { working_unit_name:  @invoice_detail_large_classification.working_unit_name }
          @working_unit = WorkingUnit.create(unit_params)
			
		  #内訳マスター更用の単位インデックスを取得
		  @working_units = WorkingUnit.find_by(working_unit_name: @invoice_detail_large_classification.working_unit_name)
       else 
		 @working_units = @check_unit
	   end
    end
	
#170822 moved
#    #単位のIDをセット
#    if @working_units.present?
#      unit_id = @working_units.id
#    else
#      unit_id = @invoice_detail_large_classification.working_unit_id
#	end
#    #同様に手入力用IDの場合、内訳(大分類)マスターへ登録する。
#    if @invoice_detail_large_classification.working_large_item_id == 1
#       @check_item = WorkingMiddleItem.find_by(working_middle_item_name: @invoice_detail_large_classification.working_large_item_name , 
#                                                working_middle_specification: @invoice_detail_large_classification.working_large_specification)
#       if @check_item.nil?
#         #全選択の場合
#		 if params[:invoice_detail_large_classification][:check_update_all] == "true" 
#		   large_item_params = { working_middle_item_name:  @invoice_detail_large_classification.working_large_item_name, 
#		                       working_middle_specification:  @invoice_detail_large_classification.working_large_specification,
#                               working_unit_id:  unit_id,
#                               working_unit_price:  @invoice_detail_large_classification.working_unit_price,
#                               execution_unit_price:  @invoice_detail_large_classification.execution_unit_price,
#                               labor_productivity_unit:  @invoice_detail_large_classification.labor_productivity_unit,
#                               labor_productivity_unit_total:  @invoice_detail_large_classification.labor_productivity_unit_total }
#           @working_large_item = WorkingMiddleItem.create(large_item_params)
#		 else
#		   #アイテムのみ場合
#		   if params[:invoice_detail_large_classification][:check_update_item] == "true" 
#		       large_item_params = { working_middle_item_name:  @invoice_detail_large_classification.working_large_item_name, 
#		                       working_middle_specification:  @invoice_detail_large_classification.working_large_specification,
#                               working_unit_id:  unit_id
#                                }
#               @working_large_item = WorkingMiddleItem.create(large_item_params)
#		   end
#  	     end
#       end
#    end
	
	#@invoice_detail_large_classifications = InvoiceDetailLargeClassification.where(:invoice_header_id => $invoice_header_id)
    #upd170626
    @invoice_detail_large_classifications = InvoiceDetailLargeClassification.
       where(:invoice_header_id => @invoice_header_id)
	
  end

    # PATCH/PUT /invoice_detail_large_classifications/1
  # PATCH/PUT /invoice_detail_large_classifications/1.json
  def update
    
    #作業明細マスターの更新
	#add170822
    update_working_middle_item
	
    @invoice_detail_large_classification.update(invoice_detail_large_classification_params)
      
	#歩掛りの集計を最新のもので書き換える。
	update_labor_productivity_unit_summary
    #add170308
    recalc_subtotal
	  
    # 見出データを保存 
    save_price_to_headers
      
    @max_line_number = @invoice_detail_large_classification.line_number
    if (params[:invoice_detail_large_classification][:check_line_insert] == 'true')
       line_insert
    end
      
    #行番号の最終を書き込む
    invoice_headers_set_last_line_number
    
    #工事集計の確定区分があれば見出しへZセット
    set_final_return_division_params
    
    #手入力用IDの場合は、単位マスタへも登録する。
    if @invoice_detail_large_classification.working_unit_id == 1
       #既に登録してないかチェック
       @check_unit = WorkingUnit.find_by(working_unit_name: @invoice_detail_large_classification.working_unit_name)
       if @check_unit.nil?
          unit_params = { working_unit_name:  @invoice_detail_large_classification.working_unit_name }
          @working_unit = WorkingUnit.create(unit_params)
			
		  #内訳マスター更用の単位インデックスを取得
		  @working_units = WorkingUnit.find_by(working_unit_name: @invoice_detail_large_classification.working_unit_name)
	   else
		 @working_units = @check_unit
	   end
    end
      
#170822 moved
#	  #単位のIDをセット
#	  if @working_units.present?
#	    unit_id = @working_units.id
#	  else
#	    unit_id = @invoice_detail_large_classification.working_unit_id
#	  end
	  
#      #同様に手入力用IDの場合、内訳(大分類)マスターへ登録する。
#      if @invoice_detail_large_classification.working_large_item_id == 1
#         @check_item = WorkingMiddleItem.find_by(working_middle_item_name: @invoice_detail_large_classification.working_large_item_name , 
#                                                 working_middle_specification: @invoice_detail_large_classification.working_large_specification)
#         if @check_item.nil?
#		   #全選択の場合
#		   if params[:invoice_detail_large_classification][:check_update_all] == "true" 
#		     large_item_params = { working_middle_item_name:  @invoice_detail_large_classification.working_large_item_name, 
#		                         working_middle_specification:  @invoice_detail_large_classification.working_large_specification,
#                                 working_unit_id:  unit_id,
#                                 working_unit_price:  @invoice_detail_large_classification.working_unit_price,
#                                 execution_unit_price:  @invoice_detail_large_classification.execution_unit_price,
#                                 labor_productivity_unit:  @invoice_detail_large_classification.labor_productivity_unit,
#                                 labor_productivity_unit_total:  @invoice_detail_large_classification.labor_productivity_unit_total }
#               
#               @working_large_item = WorkingMiddleItem.create(large_item_params)
#		   else
#		     #アイテム,仕様,単位のみ場合
#		     if params[:invoice_detail_large_classification][:check_update_item] == "true" 
#		         large_item_params = { working_middle_item_name:  @invoice_detail_large_classification.working_large_item_name, 
#		                         working_middle_specification:  @invoice_detail_large_classification.working_large_specification,
#                                 working_unit_id:  unit_id
#                                  }
#                 @working_large_item = WorkingMiddleItem.create(large_item_params)
#		     end
#		   end
#		 end
#      end
	  #####
	   
      #@invoice_detail_large_classifications = InvoiceDetailLargeClassification.where(:invoice_header_id => $invoice_header_id)
      #upd170626
      @invoice_detail_large_classifications = InvoiceDetailLargeClassification.
                    where(:invoice_header_id => @invoice_header_id)
	  
  end


 #add170823
  #作業明細マスターの更新
  def update_working_middle_item
  
      if params[:invoice_detail_large_classification][:working_large_item_id] == "1"
         
		 @check_item = WorkingMiddleItem.find_by(working_middle_item_name: params[:invoice_detail_large_classification][:working_large_item_name] , 
		   working_middle_specification: params[:invoice_detail_large_classification][:working_large_specification] )
      else
	    #手入力以外の場合   #add170714
		 @check_item = WorkingMiddleItem.find(params[:invoice_detail_large_classification][:working_large_item_id])
      end
		
		 @working_unit_id_params = params[:invoice_detail_large_classification][:working_unit_id]
		 
         #if @working_unit.present?
		 if @working_units.present?
           #@working_unit_all_params = WorkingUnit.find_by(working_unit_name: params[:invoice_detail_large_classification][:working_unit_name] )
		   #@working_unit_id_params = @working_unit_all_params.id
		   @working_unit_id_params = @working_units.id
		 end 
 
         #if @check_item.nil?
		  
          large_item_params = nil   #add170714
		  
		  #add170823
		  #短縮名（手入力）
		  if params[:invoice_detail_large_classification][:working_large_item_short_name_manual] != "<手入力>"
		    working_large_item_short_name_manual = params[:invoice_detail_large_classification][:working_large_item_short_name_manual]
		  else
		    working_large_item_short_name_manual = ""
		  end
		  ##
		  
		  # 全選択の場合
		  #upd170823 短縮名追加
		  if params[:invoice_detail_large_classification][:check_update_all] == "true" 
		      large_item_params = { working_middle_item_name:  params[:invoice_detail_large_classification][:working_large_item_name], 
                                    working_middle_item_short_name: working_large_item_short_name_manual, 
                                    working_middle_specification:  params[:invoice_detail_large_classification][:working_large_specification] , 
                                    working_unit_id: @working_unit_id_params, 
                                    working_unit_price: params[:invoice_detail_large_classification][:working_unit_price] ,
                                    execution_unit_price: params[:invoice_detail_large_classification][:execution_unit_price] ,
                                    labor_productivity_unit: params[:invoice_detail_large_classification][:labor_productivity_unit] ,
                                    labor_productivity_unit_total: params[:invoice_detail_large_classification][:labor_productivity_unit_total] 
                                  }
               #del170714 
               #@quotation_middle_item = WorkingMiddleItem.create(large_item_params)
          else
		     # アイテムのみ更新の場合
			 #upd170626 short_name抹消(無駄に１が入るため)
			 
		     if params[:invoice_detail_large_classification][:check_update_item] == "true" 
		         large_item_params = { working_middle_item_name: params[:invoice_detail_large_classification][:working_large_item_name] , 
                 working_middle_item_short_name: working_large_item_short_name_manual, 
                 working_middle_specification: params[:invoice_detail_large_classification][:working_large_specification] ,
                 working_unit_id: @working_unit_id_params } 
		   
		     end
		   
          end

          #upd170714
		  if large_item_params.present?
		     if @check_item.nil?
		       #@quotation_middle_item = WorkingMiddleItem.create(large_item_params)
			   @check_item = WorkingMiddleItem.create(large_item_params)
		     
			   #手入力の場合のパラメータを書き換える。
			   params[:invoice_detail_large_classification][:working_large_item_id] = @check_item.id
			   params[:invoice_detail_large_classification][:working_large_item_short_name] = @check_item.id
			 
			 else
			 
			   #@quotation_middle_item = @check_item.update(large_item_params)
			   @check_item.update(large_item_params)
		     end
			 
		  end
  
  end


   # DELETE /invoice_detail_large_classifications/1
  # DELETE /invoice_detail_large_classifications/1.json
  def destroy
    
    if params[:invoice_header_id].present?
      #$invoice_header_id = params[:invoice_header_id]
      #upd170626
      @invoice_header_id = params[:invoice_header_id]
    end
    
    #入出金ファイルを抹消
    #destroy_deposit
	  #delete_daily_cash_flow
    #
	  
    @invoice_detail_large_classification.destroy
    respond_to do |format|
      #format.html { redirect_to invoice_detail_large_classifications_url, notice: 'Invoice detail large classification was successfully destroyed.' }
      #format.json { head :no_content }
	  
	  #upd170626
	  format.html {redirect_to invoice_detail_large_classifications_path( :invoice_header_id => params[:invoice_header_id],
                        :invoice_header_name => params[:invoice_header_name] ) }
	  
	  # 見出データを保存 
      save_price_to_headers
    end
  end

  #請求金額トータル
  def invoice_total_price
     @execution_total_price = InvoiceDetailLargeClassification.where(["invoice_header_id = ?", @invoice_detail_large_classification.invoice_header_id]).sumpriceInvoice
  end 
  #実行金額トータル
  def execution_total_price
     @execution_total_price = InvoiceDetailLargeClassification.where(["invoice_header_id = ?", @invoice_detail_large_classification.invoice_header_id]).sumpriceExecution
  end

  #add170308
  def subtotal_select
  #小計を取得、セットする
     @search_records = InvoiceDetailLargeClassification.where("invoice_header_id = ?", params[:invoice_header_id])
     if @search_records.present?
        
        
        start_line_number = 0
        end_line_number = 0
        
        current_line_number = params[:line_number].to_i
        
		@search_records.order(:line_number).each do |idlc|
           if idlc.construction_type.to_i != $INDEX_SUBTOTAL &&
              idlc.construction_type.to_i != $INDEX_DISCOUNT  
			  #小計,値引き以外なら開始行をセット
             if start_line_number == 0
                start_line_number = idlc.line_number
		     end
		   else 
		     if idlc.line_number < current_line_number
		       start_line_number = 0   #開始行を初期化
			 end
           end
		   
		   if idlc.line_number < current_line_number   #更新の場合もあるので現在の行はカウントしない。
		     end_line_number = idlc.line_number  #終了行をセット
           end
        end
        
        #範囲内の計を集計
        @invoice_price = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:invoice_price)
        @execution_price = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:execution_price)
        @labor_productivity_unit_total = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:labor_productivity_unit_total)
        
     end
  end 
  
  def recalc_subtotal_all
  #すべての小計を再計算する
    invoice_price_sum = 0
    execution_price_sum = 0
    labor_productivity_unit_total_sum  = 0
    
    @search_records = InvoiceDetailLargeClassification.where("invoice_header_id = ?", params[:ajax_invoice_header_id])
    
	
    if @search_records.present?
      @search_records.order(:line_number).each do |idlc|
	    if idlc.construction_type.to_i != $INDEX_SUBTOTAL
          if idlc.construction_type.to_i != $INDEX_DISCOUNT
            #小計・値引き以外？
            invoice_price_sum += idlc.invoice_price.to_i
			execution_price_sum += idlc.execution_price.to_i
			labor_productivity_unit_total_sum += idlc.labor_productivity_unit_total.to_f
		  end
		else
		#小計？=>更新
		    subtotal_params = {invoice_price: invoice_price_sum, execution_price: execution_price_sum, labor_productivity_unit_total: labor_productivity_unit_total_sum}
		    idlc.update(subtotal_params)

			
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
     @search_records = InvoiceDetailLargeClassification.where("invoice_header_id = ?", params[:invoice_detail_large_classification][:invoice_header_id])
     if @search_records.present?
		start_line_number = 0
        end_line_number = 0
        current_line_number = params[:invoice_detail_large_classification][:line_number].to_i
        
		subtotal_exist = false
		id_saved = 0
		@search_records.order(:line_number).each do |idlc|
           if idlc.construction_type.to_i != $INDEX_SUBTOTAL &&
              idlc.construction_type.to_i != $INDEX_DISCOUNT  
			  
			 #小計,値引き以外なら開始行をセット
             if start_line_number == 0
                start_line_number = idlc.line_number
		     end
		   else 
		     
			 if idlc.line_number < current_line_number
		       start_line_number = 0   #開始行を初期化
			 elsif idlc.line_number > current_line_number
             #小計欄に来たら、処理を抜ける。
			   subtotal_exist = true
			   id_saved = idlc.id
               
			   break
			 end
           end
		   
		   if idlc.line_number >= current_line_number   
		     end_line_number = idlc.line_number  #終了行をセット
           end
        end
        #範囲内の計を集計
		if subtotal_exist == true
          subtotal_records = InvoiceDetailLargeClassification.find(id_saved)
    
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
  
 # ajax
  def working_large_item_select
     @working_large_item_name = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_middle_item_name).flatten.join(" ")
  end
  def working_large_specification_select
     @working_large_specification = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_middle_specification).flatten.join(" ")
  end
  def working_unit_name_select
     @working_unit_name = WorkingUnit.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_unit_name).flatten.join(" ")
  end
  #単位(未使用？)
  def working_unit_id_select
     @working_unit_id  = WorkingMiddleItem.with_unit.where(:id => params[:id]).pluck("working_units.working_unit_name, working_units.id")
	 #登録済み単位と異なるケースもあるので、任意で変更もできるように全ての単位をセット
     unit_all = WorkingUnit.all.pluck("working_units.working_unit_name, working_units.id")
     @working_unit_id = @working_unit_id + unit_all
  end
  #単価
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
  
  #納品書番号
  def deliery_slip_header_id_select
    @working_large_item_name = "納品書No." + DeliverySlipHeader.where(:id => params[:delivery_slip_header_id]).
          where("id is NOT NULL").pluck(:delivery_slip_code).flatten.join(" ")
	@working_large_specification = DeliverySlipHeader.where(:id => params[:delivery_slip_header_id]).
          where("id is NOT NULL").pluck(:construction_name).flatten.join(" ")
    @invoice_price = DeliverySlipHeader.where(:id => params[:delivery_slip_header_id]).
          where("id is NOT NULL").pluck(:delivery_amount).flatten.join(" ")
    #@execution_price = DeliverySlipHeader.where(:id => params[:delivery_slip_header_id]).
    #      where("id is NOT NULL").pluck(:execution_amount).flatten.join(" ")
    
  end
  ### ajax
  
  #add170223
  #歩掛り(配管配線集計用)
  def LPU_piping_wiring_select
    @labor_productivity_unit = InvoiceDetailLargeClassification.sum_LPU_PipingWiring(params[:invoice_header_id])
    @labor_productivity_unit_total = InvoiceDetailLargeClassification.sum_LPUT_PipingWiring(params[:invoice_header_id])
  end
  #歩掛り(機器取付集計用)
  def LPU_equipment_mounting_select
    @labor_productivity_unit = InvoiceDetailLargeClassification.sum_LPU_equipment_mounting(params[:invoice_header_id])
	@labor_productivity_unit_total = InvoiceDetailLargeClassification.sum_LPUT_equipment_mounting(params[:invoice_header_id])
  end
  #歩掛り(労務費集計用)
  def LPU_labor_cost_select
  
    @labor_productivity_unit = InvoiceDetailLargeClassification.sum_LPU_labor_cost(params[:invoice_header_id])
	@labor_productivity_unit_total = InvoiceDetailLargeClassification.sum_LPUT_labor_cost(params[:invoice_header_id])
  end
  
  #歩掛りの集計を最新のもので書き換える。
  def update_labor_productivity_unit_summary
    invoice_header_id = params[:invoice_detail_large_classification][:invoice_header_id]
    
    #upd170308 construction_typeを定数化・順番変更
    
    #配管配線の計を更新(construction_type=x)
    @IDLC_piping_wiring = InvoiceDetailLargeClassification.where(invoice_header_id: invoice_header_id, construction_type: $INDEX_PIPING_WIRING_CONSTRUCTION).first
    if @IDLC_piping_wiring.present?
      labor_productivity_unit_total = InvoiceDetailLargeClassification.sum_LPUT_PipingWiring(invoice_header_id)
      @IDLC_piping_wiring.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
    end
	
	#機器取付の計を更新(construction_type=x)
    @IDLC_equipment_mounting = InvoiceDetailLargeClassification.where(invoice_header_id: invoice_header_id, construction_type: $INDEX_EUIPMENT_MOUNTING).first
	if @IDLC_equipment_mounting.present?
      labor_productivity_unit_total = InvoiceDetailLargeClassification.sum_LPUT_equipment_mounting(invoice_header_id)
      @IDLC_equipment_mounting.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
    end
    #労務費の計を更新(construction_type=x)
    @IDLC_labor_cost = InvoiceDetailLargeClassification.where(invoice_header_id: invoice_header_id, construction_type: $INDEX_LABOR_COST).first
    if @IDLC_labor_cost.present?
      labor_productivity_unit_total = InvoiceDetailLargeClassification.sum_LPUT_labor_cost(invoice_header_id)
      @IDLC_labor_cost.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
    end
  
  end
  #add end
  
  #工事集計の確定区分があれば見出しへZセット
  def set_final_return_division_params
    #納品書コード有り？
    if params[:invoice_detail_large_classification][:delivery_slip_header_id].present?
      delivery_slip_header_id = params[:invoice_detail_large_classification][:delivery_slip_header_id].to_i
      delivery_slip_header = DeliverySlipHeader.where(:id => delivery_slip_header_id).first
      #納品書データに工事IDあり？
      if delivery_slip_header.present?
        if delivery_slip_header.construction_datum_id.present?
          construction_datum_id = delivery_slip_header.construction_datum_id
          construction_cost = ConstructionCost.where(:construction_datum_id => construction_datum_id).first
          #工事集計データあり？
          if construction_cost.present?
            #確定申告区分あり？
            if construction_cost.final_return_division.present? && construction_cost.final_return_division > 0
              invoice_header_id = params[:invoice_detail_large_classification][:invoice_header_id]
              invoice_header = InvoiceHeader.where(:id => invoice_header_id).first
              
              #請求書見出しの確定申告区分へZをセット(未入力またはゼロの場合)
              if invoice_header.present?
                if invoice_header.final_return_division.nil? || invoice_header.final_return_division == 0
                  invoice_header.final_return_division = $FINAL_RETURN_DIVISION_Z
                  invoice_header.save!(:validate => false)
                end
              end
            end
          end
        end
      end
    end
  end
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice_detail_large_classification
      @invoice_detail_large_classification = InvoiceDetailLargeClassification.find(params[:id])
    end
    
	#add171016
    def initialize_sort
	  $not_sort_il = true
    end
	
    #以降のレコードの行番号を全てインクリメントする
    def line_insert
      InvoiceDetailLargeClassification.where(["invoice_header_id = ? and line_number >= ? and id != ?", @invoice_detail_large_classification.invoice_header_id,
        @invoice_detail_large_classification.line_number, @invoice_detail_large_classification.id]).update_all("line_number = line_number + 1")
      #最終行番号も取得しておく
      @max_line_number = InvoiceDetailLargeClassification.
        where(["invoice_header_id = ? and line_number >= ? and id != ?", @invoice_detail_large_classification.invoice_header_id, 
        @invoice_detail_large_classification.line_number, @invoice_detail_large_classification.id]).maximum(:line_number)
    end
    
    #見出データへ合計保存用　
    def save_price_to_headers
        @invoice_header = InvoiceHeader.find(@invoice_detail_large_classification.invoice_header_id)
        #請求金額
        @invoice_header.billing_amount = invoice_total_price
        #add 230119
        #税込金額をここで保存
        #@invoice_header.billing_amount_tac_inc = invoice_total_price * $consumption_tax_include_per_ten
        
        #実行金額
        @invoice_header.execution_amount = execution_total_price
        @invoice_header.save
    end
    
	#見出しデータへ最終行番号保存用
    def invoice_headers_set_last_line_number
        @invoice_headers = InvoiceHeader.find_by(id: @invoice_detail_large_classification.invoice_header_id)
        check_flag = false
	    if @invoice_headers.last_line_number.nil? 
          check_flag = true
        else
	      if (@invoice_headers.last_line_number < @max_line_number) then
           check_flag = true
		  end
	    end
	    if (check_flag == true)
	       invoice_header_params = { last_line_number:  @max_line_number}
		   if @invoice_headers.present?
		      
			 #@invoice_headers.update(invoice_header_params)
			 #upd170412
			 @invoice_headers.attributes = invoice_header_params
             @invoice_headers.save(:validate => false)
			 
		   end 
        end 
    end
    #行番号を取得し、インクリメントする。（新規用）
    def get_line_number
      @line_number = 1
      if @invoice_detail_large_classification.invoice_header_id.present?
         @invoice_headers = InvoiceHeader.find_by(id: @invoice_detail_large_classification.invoice_header_id)
         if @invoice_headers.present?
            if @invoice_headers.last_line_number.present?
               @line_number = @invoice_headers.last_line_number + 1
            end
         end
      end
	  
	  @invoice_detail_large_classification.line_number = @line_number
    end
    
    # ストロングパラメータ
    # Never trust parameters from the scary internet, only allow the white list through.
    def invoice_detail_large_classification_params
      params.require(:invoice_detail_large_classification).permit(:invoice_header_id, :invoice_items_division_id, :working_large_item_id, :working_large_item_name, 
                     :working_large_item_short_name, :working_large_specification, :line_number, :quantity, :execution_quantity, :working_unit_id, :working_unit_name, :working_unit_price, :invoice_price, 
                     :execution_unit_price, :execution_price, :labor_productivity_unit, :labor_productivity_unit_total, :last_line_number, :remarks, :delivery_slip_header_id,
                     :construction_type, :piping_wiring_flag, :equipment_mounting_flag, :labor_cost_flag )
    end


 ########  納品書関連データ操作
  def delete_delivery_slip
  #既存の納品書データを全て削除する
    if params[:invoice_code].present?
	  @delivery_slip_header = DeliverySlipHeader.find_by(invoice_code: params[:invoice_code])
    
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
  #請求書データを納品書データへ丸ごとコピー（もっと単純な方法ない？）
	  @success_flag = true
	 
	  #見出しデータのコピー
	  @invoice_header = nil
	  if params[:invoice_header_id].present?
	    @invoice_header = InvoiceHeader.find(params[:invoice_header_id])
	  end

	  if @invoice_header.present?
        if @invoice_header.invoice_code.present?
          
          #upd190307
          #一律で仮番号をセット
          delivery_slip_code = $HEADER_CODE_MAX
          
          #add170310 見出しコードが空の場合は仮番号をセット。
          #if @invoice_header.delivery_slip_code.blank?
          #  delivery_slip_code = $HEADER_CODE_MAX
          #else
          #  delivery_slip_code = @invoice_header.delivery_slip_code
          #end
          #
		 
          delivery_slip_header_params = { delivery_slip_code:  delivery_slip_code, quotation_code:  @invoice_header.quotation_code, 
                                  invoice_code:  @invoice_header.invoice_code,
                                  construction_datum_id: @invoice_header.construction_datum_id, construction_name: @invoice_header.construction_name, 
                                  customer_id: @invoice_header.customer_id, customer_name: @invoice_header.customer_name, honorific_id: @invoice_header.honorific_id,
                                  responsible1: @invoice_header.responsible1, responsible2: @invoice_header.responsible2, post: @invoice_header.post, 
                                  address: @invoice_header.address, house_number: @invoice_header.house_number, address2: @invoice_header.address2,
                                  tel: @invoice_header.tel, fax: @invoice_header.fax, construction_place: @invoice_header.construction_place, 
                                  construction_house_number: @invoice_header.construction_house_number, construction_place2: @invoice_header.construction_place2, 
                                  delivery_amount: @invoice_header.billing_amount, execution_amount: @invoice_header.execution_amount, last_line_number: @invoice_header.last_line_number} 
          #上記、請求日は移行しないものとする。
          @deliver_slip_header = DeliverySlipHeader.new(delivery_slip_header_params)
          if @deliver_slip_header.save!(:validate => false)
		    #add170629
            @success_flag = true
		  else
		    @success_flag = false
          end 
        else
          flash[:notice] = "データ作成に失敗しました！請求書コードを登録してください。"
          @success_flag = false
		end
	  end 
	  
	  if @success_flag == true
	    ##見出しIDをここで取得
	    @delivery_slip_header = DeliverySlipHeader.find_by(invoice_code: params[:invoice_code])
	    @delivery_slip_header_id = nil
	    if @delivery_slip_header.present?
	      @delivery_slip_header_id = @delivery_slip_header.id
	  
	  
          #内訳データのコピー
	      @i_d_l_c = InvoiceDetailLargeClassification.where(invoice_header_id: params[:invoice_header_id])
	      if @i_d_l_c.present?
	    
		    @i_d_l_c.each do |i_d_l_c|
              
		      #IDをここでセットしておく（明細で参照するため）
			  @invoice_detail_large_classification_id = i_d_l_c.id
			   
		      delivery_slip_detail_large_classification_params = {delivery_slip_header_id: @delivery_slip_header_id, delivery_slip_items_division_id: i_d_l_c.invoice_items_division_id, 
                working_large_item_id: i_d_l_c.working_large_item_id, working_large_item_name: i_d_l_c.working_large_item_name, 
                working_large_item_short_name: i_d_l_c.working_large_item_short_name, 
                working_large_specification: i_d_l_c.working_large_specification, line_number: i_d_l_c.line_number, quantity: i_d_l_c.quantity, 
                execution_quantity: i_d_l_c.execution_quantity, working_unit_id: i_d_l_c.working_unit_id, working_unit_name: i_d_l_c.working_unit_name, 
                working_unit_price: i_d_l_c.working_unit_price, delivery_slip_price: i_d_l_c.invoice_price, execution_unit_price: i_d_l_c.execution_unit_price, 
                execution_price: i_d_l_c.execution_price, labor_productivity_unit: i_d_l_c.labor_productivity_unit, 
                labor_productivity_unit_total: i_d_l_c.labor_productivity_unit_total, last_line_number: i_d_l_c.last_line_number, remarks: i_d_l_c.remarks,
                construction_type: i_d_l_c.construction_type , piping_wiring_flag: i_d_l_c.piping_wiring_flag , equipment_mounting_flag: i_d_l_c.equipment_mounting_flag , 
                labor_cost_flag: i_d_l_c.labor_cost_flag }
            
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
    #請求書データを納品書データへ丸ごとコピー（明細）
    #明細データのコピー
	  @i_d_m_c = InvoiceDetailMiddleClassification.where(invoice_header_id: params[:invoice_header_id], 
	                                                            invoice_detail_large_classification_id: @invoice_detail_large_classification_id )
	  
	  if @i_d_m_c.present?
	    
		@i_d_m_c.each do |i_d_m_c|
          
		   delivery_slip_detail_middle_classification_params = {delivery_slip_header_id: @delivery_slip_header_id, delivery_slip_detail_large_classification_id: @delivery_slip_detail_large_classification_id, 
             delivery_slip_item_division_id: i_d_m_c.invoice_item_division_id, working_middle_item_id: i_d_m_c.working_middle_item_id, working_middle_item_name: i_d_m_c.working_middle_item_name, 
             working_middle_item_short_name: i_d_m_c.working_middle_item_short_name, line_number: i_d_m_c.line_number, working_middle_specification: i_d_m_c.working_middle_specification,
             quantity: i_d_m_c.quantity, execution_quantity: i_d_m_c.execution_quantity, working_unit_id: i_d_m_c.working_unit_id, working_unit_name: i_d_m_c.working_unit_name,
             working_unit_price: i_d_m_c.working_unit_price, delivery_slip_price: i_d_m_c.invoice_price, execution_unit_price: i_d_m_c.execution_unit_price, execution_price: i_d_m_c.execution_price, 
             material_id: i_d_m_c.material_id, working_material_name: i_d_m_c.working_material_name, material_unit_price: i_d_m_c.material_unit_price, 
			 labor_unit_price: i_d_m_c.labor_unit_price, labor_productivity_unit: i_d_m_c.labor_productivity_unit, labor_productivity_unit_total: i_d_m_c.labor_productivity_unit_total,
			 material_quantity: i_d_m_c.material_quantity, accessory_cost: i_d_m_c.accessory_cost, material_cost_total: i_d_m_c.material_cost_total, 
			 labor_cost_total: i_d_m_c.labor_cost_total, other_cost: i_d_m_c.other_cost, remarks: i_d_m_c.remarks,
             construction_type: i_d_m_c.construction_type , piping_wiring_flag: i_d_m_c.piping_wiring_flag , equipment_mounting_flag: i_d_m_c.equipment_mounting_flag , 
             labor_cost_flag: i_d_m_c.labor_cost_flag } 
          
          #binding.pry
	
          @delivery_slip_detail_middle_classification = DeliverySlipDetailMiddleClassification.new(delivery_slip_detail_middle_classification_params)
          if @delivery_slip_detail_middle_classification.save!(:validate => false)
		  else
		    @success_flag = false
		  end 
	    end
	  end
  end

  ########  見積書関連データ操作

  def delete_quotation
  #既存の見積書データを全て削除する
    if params[:invoice_code].present?
	  @quotation_header = QuotationHeader.find_by(invoice_code: params[:invoice_code])
    
	  if @quotation_header.present?
	    quotation_header_id = @quotation_header.id
		
		#明細データ抹消
	    QuotationDetailMiddleClassification.where(quotation_header_id: quotation_header_id).destroy_all
        #内訳データ抹消
	    QuotationDetailLargeClassification.where(quotation_header_id: quotation_header_id).destroy_all
	    #見出データ抹消
	    QuotationHeader.where(id: quotation_header_id).destroy_all
	  end
	end
  end
  
  
  
  def create_quotation
  #請求書データを見積書データへ丸ごとコピー（もっと単純な方法ない？）
	  @success_flag = true
	 
	  #見出しデータのコピー
	  @invoice_header = InvoiceHeader.find(params[:invoice_header_id])
	 
	  if @invoice_header.present?
	    if @invoice_header.invoice_code.present?
          
          #upd190307
          #一律で仮コードをセット
          quotation_code = $HEADER_CODE_MAX
          
          #add170310 見出しコードが空の場合は仮番号をセット。
          #if @invoice_header.quotation_code.blank?
          #  quotation_code = $HEADER_CODE_MAX
          #else
          #  quotation_code = @invoice_header.quotation_code
          #end
		  #

          quotation_header_params = { quotation_code:  quotation_code, invoice_code:  @invoice_header.invoice_code, 
                                  delivery_slip_code:  @invoice_header.delivery_slip_code, 
                                  construction_datum_id: @invoice_header.construction_datum_id, construction_name: @invoice_header.construction_name, 
                                  customer_id: @invoice_header.customer_id, customer_name: @invoice_header.customer_name, honorific_id: @invoice_header.honorific_id,
                                  responsible1: @invoice_header.responsible1, responsible2: @invoice_header.responsible2, post: @invoice_header.post, 
                                  address: @invoice_header.address, house_number: @invoice_header.house_number, address2: @invoice_header.address2,
                                  tel: @invoice_header.tel, fax: @invoice_header.fax, construction_period: @invoice_header.construction_period,
                                  construction_place: @invoice_header.construction_place, construction_house_number: @invoice_header.construction_house_number,
                                  construction_place2: @invoice_header.construction_place2,
                                  quote_price: @invoice_header.billing_amount, execution_amount: @invoice_header.execution_amount, 
								  last_line_number: @invoice_header.last_line_number} 
          #上記、見積日は移行しないものとする。
		  @quotation_header = QuotationHeader.new(quotation_header_params)
          if @quotation_header.save!(:validate => false)
		    #add170629
            @success_flag = true
		  else
		    @success_flag = false
          end 
		else
		  flash[:notice] = "データ作成に失敗しました！請求書コードを登録してください。"
          @success_flag = false
		end
	  end 
	  
	  if @success_flag == true
	    ##見出しIDをここで取得
	    @quotation_header = nil
	  
	    if params[:invoice_code].present?
	      @quotation_header = QuotationHeader.find_by(invoice_code: params[:invoice_code])
	    end
	  
	    @quotation_header_id = nil
	    if @quotation_header.present?
	      @quotation_header_id = @quotation_header.id
	  
          #内訳データのコピー
	      @i_d_l_c = InvoiceDetailLargeClassification.where(invoice_header_id: params[:invoice_header_id])
	      
		  	
		  if @i_d_l_c.present?
	    
		    @i_d_l_c.each do |i_d_l_c|
              
		      #IDをここでセットしておく（明細で参照するため）
			  @invoice_detail_large_classification_id = i_d_l_c.id
			
			
              quotation_detail_large_classification_params = {quotation_header_id: @quotation_header_id, quotation_items_division_id: i_d_l_c.invoice_items_division_id, 
                working_large_item_id: i_d_l_c.working_large_item_id, working_large_item_name: i_d_l_c.working_large_item_name, 
                working_large_item_short_name: i_d_l_c.working_large_item_short_name,
                working_large_specification: i_d_l_c.working_large_specification, line_number: i_d_l_c.line_number, quantity: i_d_l_c.quantity, 
                execution_quantity: i_d_l_c.execution_quantity, working_unit_id: i_d_l_c.working_unit_id, working_unit_name: i_d_l_c.working_unit_name, 
                working_unit_price: i_d_l_c.working_unit_price, quote_price: i_d_l_c.invoice_price, execution_unit_price: i_d_l_c.execution_unit_price, 
                execution_price: i_d_l_c.execution_price, labor_productivity_unit: i_d_l_c.labor_productivity_unit, 
                labor_productivity_unit_total: i_d_l_c.labor_productivity_unit_total, last_line_number: i_d_l_c.last_line_number, remarks: i_d_l_c.remarks,
                construction_type: i_d_l_c.construction_type , piping_wiring_flag: i_d_l_c.piping_wiring_flag , equipment_mounting_flag: i_d_l_c.equipment_mounting_flag , 
                labor_cost_flag: i_d_l_c.labor_cost_flag }
			
              @quotation_detail_large_classification = QuotationDetailLargeClassification.new(quotation_detail_large_classification_params)
              if @quotation_detail_large_classification.save!(:validate => false)
		      
                 #IDをここでセットしておく（明細で参照するため）
			     @quotation_detail_large_classification_id = QuotationDetailLargeClassification.maximum("id")
		       
			     #明細データのコピー(サブルーチン)
			     create_quotation_detail
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
  def create_quotation_detail
    #請求書データを見積書データへ丸ごとコピー（明細）
    #明細データのコピー
	  @i_d_m_c = InvoiceDetailMiddleClassification.where(invoice_header_id: params[:invoice_header_id], 
	                                                            invoice_detail_large_classification_id: @invoice_detail_large_classification_id )
	  
	  if @i_d_m_c.present?
	    
		@i_d_m_c.each do |i_d_m_c|
          
           quotation_detail_middle_classification_params = {quotation_header_id: @quotation_header_id, quotation_detail_large_classification_id: @quotation_detail_large_classification_id, 
             quotation_items_division_id: i_d_m_c.invoice_item_division_id, working_middle_item_id: i_d_m_c.working_middle_item_id, working_middle_item_name: i_d_m_c.working_middle_item_name, 
             working_middle_item_short_name: i_d_m_c.working_middle_item_short_name, line_number: i_d_m_c.line_number, working_middle_specification: i_d_m_c.working_middle_specification,
             quantity: i_d_m_c.quantity, execution_quantity: i_d_m_c.execution_quantity, working_unit_id: i_d_m_c.working_unit_id, working_unit_name: i_d_m_c.working_unit_name,
             working_unit_price: i_d_m_c.working_unit_price, quote_price: i_d_m_c.invoice_price, execution_unit_price: i_d_m_c.execution_unit_price, execution_price: i_d_m_c.execution_price,
             material_id: i_d_m_c.material_id, quotation_material_name: i_d_m_c.working_material_name, material_unit_price: i_d_m_c.material_unit_price, 
			 labor_unit_price: i_d_m_c.labor_unit_price, labor_productivity_unit: i_d_m_c.labor_productivity_unit, labor_productivity_unit_total: i_d_m_c.labor_productivity_unit_total,
			 material_quantity: i_d_m_c.material_quantity, accessory_cost: i_d_m_c.accessory_cost, material_cost_total: i_d_m_c.material_cost_total, 
			 labor_cost_total: i_d_m_c.labor_cost_total, other_cost: i_d_m_c.other_cost, remarks: i_d_m_c.remarks,
             construction_type: i_d_m_c.construction_type , piping_wiring_flag: i_d_m_c.piping_wiring_flag , equipment_mounting_flag: i_d_m_c.equipment_mounting_flag , 
             labor_cost_flag: i_d_m_c.labor_cost_flag } 
          	
          @quotation_detail_middle_classification = QuotationDetailMiddleClassification.new(quotation_detail_middle_classification_params)
          if @quotation_detail_middle_classification.save!(:validate => false)
		  else
		    @success_flag = false
		  end 
	    end
	  end
  end


end
