class DeliverySlipDetailLargeClassificationsController < ApplicationController
  before_action :set_delivery_slip_detail_large_classification, only: [:show, :edit, :update, :destroy, :copy]

  before_action :initialize_sort, only: [:show, :new, :edit, :update, :destroy ]
  
  before_action :set_action_flag, only: [:new, :edit ]
  
  
  ID_UNIT_SET = 22   #単位が式のID
  
  @@new_flag = []
  max_line_number = 0

  # GET /delivery_slip_detail_large_classifications
  # GET /delivery_slip_detail_large_classifications.json
  def index
    
    #ransack保持用コード
    @null_flag = ""
    
    if params[:delivery_slip_header_id].present?
      @delivery_slip_header_id = params[:delivery_slip_header_id]
    end
	
    if @delivery_slip_header_id.present?
      query = {"delivery_slip_header_id_eq"=>"", "with_header_id"=> @delivery_slip_header_id, "delivery_slip_large_item_name_eq"=>""}

      @null_flag = "1"
    end
	
    if @null_flag == "" 
      query = params[:q]
      query ||= eval(cookies[:recent_search_history].to_s)  	
    end
	
	  #ransack保持用
    @q = DeliverySlipDetailLargeClassification.ransack(query)
    
    if @null_flag == ""
      #ransack保持用コード
      search_history = {
       value: params[:q],
       expires: 480.minutes.from_now
      }
      cookies[:recent_search_history] = search_history if params[:q].present?
    end 
    #

    @delivery_slip_detail_large_classifications = @q.result(distinct: true)
    
    #ビューでのソート処理追加
    if (params[:q].present? && params[:q][:s].present?) || $sort_dl != nil
	    
      #order順のパラメータ(asc/desc)がなぜか１パターンしか入らないので、カラム強制にセットする。
      column_name = "line_number"
	    
      if $not_sort_dl != true
      #ここでにソートを切り替える。（パラメータで入ればベストだが）
      #（モーダル編集、行ソートでこの処理をしないようにしている）
		
        if params[:q].present? 
          if $sort_dl.nil?
	          $sort_dl = "desc"
	        end   
 
          if $sort_dl != "asc"
            $sort_dl = "asc"
          else
            $sort_dl = "desc"
          end
	      end
      else
        $not_sort_dl = false
      end
		
      #並び替えする（降順/昇順）
      if $sort_dl == "asc"
	      @delivery_slip_detail_large_classifications = @delivery_slip_detail_large_classifications.order(column_name + " asc")
      elsif $sort_dl == "desc"
        @delivery_slip_detail_large_classifications = @delivery_slip_detail_large_classifications.order(column_name + " desc")
      end
    end
	
    #
    #内訳データ見出用
    if params[:delivery_slip_header_name].present?
      @delivery_slip_header_name = params[:delivery_slip_header_name]
    end
    #
	
    @print_type = params[:print_type]
    
    if params[:format] == "pdf" then
         
      #見積書PDF発行
      respond_to do |format|
        format.html # index.html.erb
	      #format.any do
        format.pdf do
            
          $print_type = @print_type
			
	        case @print_type
            when "1"
            #納品書
              report = DeliverySlipPDF.create @delivery_slip_detail_large_classifications
            when "2"
            #納品書(横)
              report = DeliverySlipLandscapePDF.create @delivery_slip_detail_large_classifications
            when "3"
            #納品書（印付）
              report = DeliverySlipPDF.create @delivery_slip_detail_large_classifications
          end 
	         
          #現在時刻をセットする
          require "date"
          d = DateTime.now
          now_date_time = d.strftime("%Y%m%d%H%M%S")
		  
		    # ブラウザでPDFを表示する
            # disposition: "inline" によりダウンロードではなく表示させている
            send_data report.generate,
		        filename:    "納品書-" + now_date_time + ".pdf",
              type:        "application/pdf",
              disposition: "inline"
       
		    #	format.html { render :action => "index"}
	      end  #format.pdf do
      end    #respond_to do |format|
      #
    else

      #請求書・見積書のデータ削除＆コピー処理を行う。
      @data_type = params[:data_type]
  
      case @data_type
        when "1"
		      #請求書データ削除
		      delete_invoice
		      #請求書データ作成
		      create_invoice
		    when "2"
          #見積書データ削除
		      delete_quotation
		      #見積書データ作成
		      create_quotation
        when "3"
          #add180423
          #明細へデータ移行
          move_large_to_middle
	    end
	  
	    if @success_flag == true
	      flash[:notice] = "データ作成が完了しました。"
	    end
    end

  end
  
  #ドラッグ＆ドロップによる並び替え機能(seqをセットする)
  def reorder
    
    $not_sort_dl = true               
	
    if $sort_dl != "asc"              
      row = params[:row].split(",").reverse    #ビューの並びが逆のため、パラメータの配列を逆順でセットさせる。
    else                              
	    row = params[:row].split(",")   
    end
    
    #行番号へセットするため、配列は１から開始させる。
    row.each_with_index {|row, i| DeliverySlipDetailLargeClassification.update(row, {:line_number => i + 1})}
    render :text => "OK"

    #小計を全て再計算する
    recalc_subtotal_all

  end
  
  
  # GET /delivery_slip_detail_large_classifications/1
  # GET /delivery_slip_detail_large_classifications/1.json
  def show
  end

  # GET /delivery_slip_detail_large_classifications/new
  def new
    @delivery_slip_detail_large_classification = DeliverySlipDetailLargeClassification.new
	
    if params[:delivery_slip_header_id].present?
      @delivery_slip_header_id = params[:delivery_slip_header_id]
    end
    
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
	
	  ###
    #初期値をセット(見出画面からの遷移時のみ)
    @@new_flag = params[:new_flag]
    if @@new_flag == "1"
      @delivery_slip_detail_large_classification.delivery_slip_header_id ||= @delivery_slip_header_id
    end 
    
    #行番号を取得する
    get_line_number
	
    #カテゴリー保持フラグを取得
    get_category_save_flag
    get_category_id
  end

  # GET /delivery_slip_detail_large_classifications/1/edit
  def edit
    #カテゴリー保持フラグを取得
    get_category_save_flag
    
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

  # POST /delivery_slip_detail_large_classifications
  # POST /delivery_slip_detail_large_classifications.json
  def create
    
    #作業明細マスターの更新
	  update_working_middle_item
    
    @delivery_slip_detail_large_classification = DeliverySlipDetailLargeClassification.create(delivery_slip_detail_large_classification_params)
    
    #歩掛りの集計を最新のもので書き換える。
    update_labor_productivity_unit_summary
    recalc_subtotal
    
    # 見出データを保存 
    save_price_to_headers
    
    @max_line_number = @delivery_slip_detail_large_classification.line_number
    #行挿入する 
    if (params[:delivery_slip_detail_large_classification][:check_line_insert] == 'true')
       line_insert
    end
    
    #行番号の最終を書き込む
    delivery_slip_headers_set_last_line_number

    #カテゴリー保持状態の保存
    set_category_save_flag

    #手入力用IDの場合は、単位マスタへも登録する。
    if @delivery_slip_detail_large_classification.working_unit_id == 1
      #既に登録してないかチェック
      @check_unit = WorkingUnit.find_by(working_unit_name: @delivery_slip_detail_large_classification.working_unit_name)
      if @check_unit.nil?
        unit_params = { working_unit_name:  @delivery_slip_detail_large_classification.working_unit_name }
        @working_unit = WorkingUnit.create(unit_params)
			
        #内訳マスター更用の単位インデックスを取得
		    @working_units = WorkingUnit.find_by(working_unit_name: @delivery_slip_detail_large_classification.working_unit_name)
      else 
		    @working_units = @check_unit
	    end
    end

    @delivery_slip_detail_large_classifications = DeliverySlipDetailLargeClassification.
                   where(:delivery_slip_header_id => @delivery_slip_detail_large_classification.delivery_slip_header_id)
	
  end

  # PATCH/PUT /delivery_slip_detail_large_classifications/1
  # PATCH/PUT /delivery_slip_detail_large_classifications/1.json
  def update
    
    #作業明細マスターの更新
	  update_working_middle_item
  
    @delivery_slip_detail_large_classification.update(delivery_slip_detail_large_classification_params)
    
    
    #歩掛りの集計を最新のもので書き換える。
    update_labor_productivity_unit_summary
    #小計を再計算する
    recalc_subtotal
	
    # 見出データを保存 
    save_price_to_headers
      
    @max_line_number = @delivery_slip_detail_large_classification.line_number
    if (params[:delivery_slip_detail_large_classification][:check_line_insert] == 'true')
       line_insert
    end
      
    #行番号の最終を書き込む
    delivery_slip_headers_set_last_line_number
  
    #カテゴリー保持状態の保存
    set_category_save_flag
  
    #####
    #手入力用IDの場合は、単位マスタへも登録する。
    if @delivery_slip_detail_large_classification.working_unit_id == 1
      #既に登録してないかチェック
      @check_unit = WorkingUnit.find_by(working_unit_name: @delivery_slip_detail_large_classification.working_unit_name)
      if @check_unit.nil?
        unit_params = { working_unit_name:  @delivery_slip_detail_large_classification.working_unit_name }
        @working_unit = WorkingUnit.create(unit_params)
			
		    #内訳マスター更用の単位インデックスを取得
		    @working_units = WorkingUnit.find_by(working_unit_name: @delivery_slip_detail_large_classification.working_unit_name)
	    else
		    @working_units = @check_unit
	    end
    end
      
    @delivery_slip_detail_large_classifications = DeliverySlipDetailLargeClassification.
       where(:delivery_slip_header_id => @delivery_slip_detail_large_classification.delivery_slip_header_id)
      
  end
  
  #レコードをコピーする
  def copy
    
    if params[:delivery_slip_header_id].present?
      #確定済みのものは、変更できないようにする為のフラグを設定
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
      @delivery_slip_detail_large_classification.working_large_item_name += $STRING_COPY  #名前が被るとまずいので、文字を加えておく。
      
      #add210916
      #行番号をインクリメントする
      @delivery_slip_detail_large_classification.line_number += 1
      line_insert  
      #
      
      new_record = @delivery_slip_detail_large_classification.deep_clone include: :delivery_slip_detail_middle_classifications
      status = new_record.save(validate: false)
     
      #respond_to do |format|
      if status == true
        notice = 'Delivery slip detail large classification was successfully copied.'
        
        #見出データの金額を保存 
        @delivery_slip_detail_large_classification = new_record
        save_price_to_headers
      else
        notice = 'Delivery slip detail large classification was unfortunately failed...'
      end
        
      #redirect_to :action => "index", :notice => notice,  :delivery_slip_header_id => params[:delivery_slip_header_id], 
      #      :delivery_slip_header_name => params[:delivery_slip_header_name]
    end
    #end
  end
    
  #作業明細マスターの更新
  def update_working_middle_item
  
    if params[:delivery_slip_detail_large_classification][:working_large_item_id] == "1"
      if params[:delivery_slip_detail_large_classification][:master_insert_flag] == "true"   
        @check_item = WorkingMiddleItem.find_by(working_middle_item_name: params[:delivery_slip_detail_large_classification][:working_large_item_name] , 
        working_middle_specification: params[:delivery_slip_detail_large_classification][:working_large_specification] )
      else
        #固有マスターより検索
        @check_item = WorkingSpecificMiddleItem.find_by(working_middle_item_name: params[:delivery_slip_detail_large_classification][:working_large_item_name] , 
        delivery_slip_header_id: params[:delivery_slip_detail_large_classification][:delivery_slip_header_id] )
      end
    else
      #手入力以外の場合 
      if params[:delivery_slip_detail_large_classification][:master_insert_flag] == "true" 
         @check_item = WorkingMiddleItem.find(params[:delivery_slip_detail_large_classification][:working_large_item_id])
      else
      #固有マスターより検索
        if params[:delivery_slip_detail_large_classification][:working_middle_specific_item_id].present?
          @check_item = WorkingSpecificMiddleItem.find(params[:delivery_slip_detail_large_classification][:working_middle_specific_item_id])
        end 
      end
    end

    @working_unit_id_params = params[:delivery_slip_detail_large_classification][:working_unit_id]
		 
    if @working_units.present?
      @working_unit_id_params = @working_units.id
    end 
 
    large_item_params = nil   
      
    #短縮名（手入力）
    if params[:delivery_slip_detail_large_classification][:working_large_item_short_name_manual] != "<手入力>"
      working_large_item_short_name_manual = params[:delivery_slip_detail_large_classification][:working_large_item_short_name_manual]
    else
      working_large_item_short_name_manual = ""
    end
    ##
		  
    # 全選択の場合
    if params[:delivery_slip_detail_large_classification][:check_update_all] == "true" 
      large_item_params = { working_middle_item_name:  params[:delivery_slip_detail_large_classification][:working_large_item_name], 
                                    working_middle_item_short_name: working_large_item_short_name_manual, 
                                    working_middle_specification:  params[:delivery_slip_detail_large_classification][:working_large_specification] , 
                                    working_middle_item_category_id: params[:delivery_slip_detail_large_classification][:working_middle_item_category_id], 
                                    working_subcategory_id: params[:delivery_slip_detail_large_classification][:working_middle_item_subcategory_id], 
                                    working_unit_id: @working_unit_id_params, 
                                    working_unit_price: params[:delivery_slip_detail_large_classification][:working_unit_price] ,
                                    execution_unit_price: params[:delivery_slip_detail_large_classification][:execution_unit_price] ,
                                    labor_productivity_unit: params[:delivery_slip_detail_large_classification][:labor_productivity_unit] ,
                                    labor_productivity_unit_total: params[:delivery_slip_detail_large_classification][:labor_productivity_unit_total] 
                                  }
    else
       # アイテムのみ更新の場合
       #short_name抹消(無駄に１が入るため)
			 
       if params[:delivery_slip_detail_large_classification][:check_update_item] == "true" 
             large_item_params = { working_middle_item_name: params[:delivery_slip_detail_large_classification][:working_large_item_name] , 
                 working_middle_item_short_name: working_large_item_short_name_manual, 
                 working_middle_item_category_id: params[:delivery_slip_detail_large_classification][:working_middle_item_category_id], 
                 working_subcategory_id: params[:delivery_slip_detail_large_classification][:working_middle_item_subcategory_id], 
                 working_middle_specification: params[:delivery_slip_detail_large_classification][:working_large_specification] ,
                 working_unit_id: @working_unit_id_params } 
       end
    end

    if large_item_params.present?
      if @check_item.nil?
        if params[:delivery_slip_detail_large_classification][:master_insert_flag] == "true"   
          @check_item = WorkingMiddleItem.create(large_item_params)
		     
          #手入力の場合のパラメータを書き換える。
          params[:delivery_slip_detail_large_classification][:working_large_item_id] = @check_item.id
          params[:delivery_slip_detail_large_classification][:working_large_item_short_name] = @check_item.id
        else
          #固有マスターへ登録
          #ヘッダIDを連想配列へ追加
          large_item_params.store(:delivery_slip_header_id, params[:delivery_slip_detail_large_classification][:delivery_slip_header_id])
				 
          @check_item = WorkingSpecificMiddleItem.create(large_item_params)
          #手入力の場合のパラメータを書き換える。
          params[:delivery_slip_detail_large_classification][:working_specific_middle_item_id] = @check_item.id
			   
        end
      else
        @check_item.update(large_item_params)
      end
    end
  end

   # DELETE /delivery_slip_detail_large_classifications/1
  # DELETE /delivery_slip_detail_large_classifications/1.json
  def destroy
    
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
    
    if @status != "fixed"
        @delivery_slip_detail_large_classification.destroy
        
        #del180803
        #確定済みデータに警告を出すため、ここでリダイレクトさせない
        #respond_to do |format|
        #    format.html {redirect_to delivery_slip_detail_large_classifications_path( :delivery_slip_header_id => params[:delivery_slip_header_id],
        #                :delivery_slip_header_name => params[:delivery_slip_header_name] ) }
	  
	        # 見出データを保存 
            save_price_to_headers
        
        #end
    end
  end

  #請求金額トータル
  def delivery_slip_total_price
    @execution_total_price = DeliverySlipDetailLargeClassification.where(["delivery_slip_header_id = ?", @delivery_slip_detail_large_classification.delivery_slip_header_id]).sumpriceDeliverySlip
  end 
  #実行金額トータル
  def execution_total_price
    @execution_total_price = DeliverySlipDetailLargeClassification.where(["delivery_slip_header_id = ?", @delivery_slip_detail_large_classification.delivery_slip_header_id]).sumpriceExecution
  end

  def subtotal_select
  #小計を取得、セットする
    @search_records = DeliverySlipDetailLargeClassification.where("delivery_slip_header_id = ?", params[:delivery_slip_header_id])
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
      @delivery_slip_price = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:delivery_slip_price)
      @execution_price = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:execution_price)
      @labor_productivity_unit_total = @search_records.where("line_number >= ? and line_number <= ?", start_line_number, end_line_number).sum(:labor_productivity_unit_total)
        
    end
  end 
  
  def recalc_subtotal_all
  #すべての小計を再計算する
    delivery_slip_price_sum = 0
    execution_price_sum = 0
    labor_productivity_unit_total_sum  = 0
	
    @search_records = DeliverySlipDetailLargeClassification.where("delivery_slip_header_id = ?", params[:ajax_delivery_slip_header_id])
    
    if @search_records.present?
      @search_records.order(:line_number).each do |dsdlc|
	      if dsdlc.construction_type.to_i != $INDEX_SUBTOTAL
          if dsdlc.construction_type.to_i != $INDEX_DISCOUNT
            #小計・値引き以外？
            delivery_slip_price_sum += dsdlc.delivery_slip_price.to_i
            execution_price_sum += dsdlc.execution_price.to_i
            labor_productivity_unit_total_sum += dsdlc.labor_productivity_unit_total.to_f
          end
        else
          #小計？=>更新
          subtotal_params = {delivery_slip_price: delivery_slip_price_sum, execution_price: execution_price_sum, labor_productivity_unit_total: labor_productivity_unit_total_sum}
          dsdlc.update(subtotal_params)
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
    @search_records = DeliverySlipDetailLargeClassification.where("delivery_slip_header_id = ?", params[:delivery_slip_detail_large_classification][:delivery_slip_header_id])
    if @search_records.present?
      start_line_number = 0
      end_line_number = 0
      current_line_number = params[:delivery_slip_detail_large_classification][:line_number].to_i
        
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
         subtotal_records = DeliverySlipDetailLargeClassification.find(id_saved)
    
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
  
  #行を全て＋１加算する。 
  def increment_line_number

	status = false 
    if params[:delivery_slip_header_id].present?
	
	  @search_records = DeliverySlipDetailLargeClassification.where("delivery_slip_header_id = ?",
            params[:delivery_slip_header_id])
      
	  last_line_number = 0
	  
	  if @search_records.present?
        @search_records.order("line_number desc").each do |ddlc|
	      if ddlc.line_number.present?
	        ddlc.line_number += 1
			
			#ループの初回が、最終レコードのになるので、行を最終行として保存する
			if last_line_number == 0
			  last_line_number = ddlc.line_number
			end
		    #
			ddlc.assign_attributes(:line_number => ddlc.line_number)
			ddlc.save(validate: false)
			
			status = true
		  end
        end
		
		#最終行を書き込む
		if status == true
		  delivery_slip_header = DeliverySlipHeader.find_by(id: params[:delivery_slip_header_id])
		  if delivery_slip_header.present?
		    delivery_slip_header.assign_attributes(:last_line_number => last_line_number)
			delivery_slip_header.save(validate: false)
          end
		end
		
	  end
	end  

	return status
  end
  
  #カテゴリー保持フラグの取得
  def get_category_save_flag
    if @delivery_slip_detail_large_classification.delivery_slip_header_id.present?
        @delivery_slip_headers = DeliverySlipHeader.find_by(id: @delivery_slip_detail_large_classification.delivery_slip_header_id)
        if @delivery_slip_headers.present?
            @category_save_flag = @delivery_slip_headers.category_saved_flag
            #未入力なら、１をセット。
            if @category_save_flag.nil?
              @category_save_flag = 1
            end
            @delivery_slip_detail_large_classification.category_save_flag_child = @category_save_flag
        end
    end
  end
  #カテゴリー、サブカテゴリーの取得
  def get_category_id
      
    if @delivery_slip_headers.present? && @category_save_flag == 1
        category_id = @delivery_slip_headers.category_saved_id
        subcategory_id = @delivery_slip_headers.subcategory_saved_id
        @delivery_slip_detail_large_classification.working_middle_item_category_id_call = category_id
        @delivery_slip_detail_large_classification.working_middle_item_subcategory_id_call = subcategory_id
        
    end
  end
    
  #カテゴリー保持フラグの保存
  def set_category_save_flag
    if @delivery_slip_detail_large_classification.delivery_slip_header_id.present?
      @delivery_slip_headers = DeliverySlipHeader.find_by(id: @delivery_slip_detail_large_classification.delivery_slip_header_id)
        if @delivery_slip_headers.present?
          delivery_slip_header_params = { category_saved_flag: params[:delivery_slip_detail_large_classification][:category_save_flag_child], 
                                       category_saved_id: params[:delivery_slip_detail_large_classification][:working_middle_item_category_id_call],
                                       subcategory_saved_id: params[:delivery_slip_detail_large_classification][:working_middle_item_subcategory_id_call]}
          @delivery_slip_headers.attributes = delivery_slip_header_params
          @delivery_slip_headers.save(:validate => false)
      end
    end
  end
  

 # ajax
  def working_large_item_select
     @working_large_item_name = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_middle_item_name).flatten.join(" ")
  end
  def working_large_specification_select
     @working_large_specification = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_middle_specification).flatten.join(" ")
  
     @working_middle_item_category_id  = WorkingMiddleItem.with_category.where(:id => params[:id]).pluck("working_categories.category_name, working_categories.id")
	 #登録済みと異なるケースもあるので、任意で変更もできるように全て値をセット
	 @working_middle_item_category_id  += WorkingCategory.all.pluck("working_categories.category_name, working_categories.id")
	 #
	 #記号
	 @working_large_item_short_name = WorkingMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_middle_item_short_name).flatten.join(" ")
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
  
  #歩掛り(配管配線集計用)
  def LPU_piping_wiring_select
    @labor_productivity_unit = DeliverySlipDetailLargeClassification.sum_LPU_PipingWiring(params[:delivery_slip_header_id])
    @labor_productivity_unit_total = DeliverySlipDetailLargeClassification.sum_LPUT_PipingWiring(params[:delivery_slip_header_id])
	
	#金額計
    @delivery_slip_price = DeliverySlipDetailLargeClassification.sum_delivery_slip_price_PipingWiring(params[:delivery_slip_header_id])
    @execution_price = DeliverySlipDetailLargeClassification.sum_execution_price_PipingWiring(params[:delivery_slip_header_id])
    ###
  end
  #歩掛り(機器取付集計用)
  def LPU_equipment_mounting_select
    @labor_productivity_unit = DeliverySlipDetailLargeClassification.sum_LPU_equipment_mounting(params[:delivery_slip_header_id])
	@labor_productivity_unit_total = DeliverySlipDetailLargeClassification.sum_LPUT_equipment_mounting(params[:delivery_slip_header_id])
	
	#金額計
	@delivery_slip_price = DeliverySlipDetailLargeClassification.sum_delivery_slip_price_equipment_mounting(params[:delivery_slip_header_id])
	@execution_price = DeliverySlipDetailLargeClassification.sum_execution_price_equipment_mounting(params[:delivery_slip_header_id])
    ###
  end
  #歩掛り(労務費集計用)
  def LPU_labor_cost_select
    @labor_productivity_unit = DeliverySlipDetailLargeClassification.sum_LPU_labor_cost(params[:delivery_slip_header_id])
	@labor_productivity_unit_total = DeliverySlipDetailLargeClassification.sum_LPUT_labor_cost(params[:delivery_slip_header_id])
	
	#金額計
	@delivery_slip_price = DeliverySlipDetailLargeClassification.sum_delivery_slip_price_labor_cost(params[:delivery_slip_header_id])
	@execution_price = DeliverySlipDetailLargeClassification.sum_execution_price_labor_cost(params[:delivery_slip_header_id])
    ###
  end
  
  
  #歩掛りの集計を最新のもので書き換える。
  def update_labor_productivity_unit_summary
    delivery_slip_header_id = params[:delivery_slip_detail_large_classification][:delivery_slip_header_id]
    
    #配管配線の計を更新(construction_type=x)
    @DSDLC_piping_wiring = DeliverySlipDetailLargeClassification.where(delivery_slip_header_id: delivery_slip_header_id, construction_type: $INDEX_PIPING_WIRING_CONSTRUCTION).first
    if @DSDLC_piping_wiring.present?
      labor_productivity_unit_total = DeliverySlipDetailLargeClassification.sum_LPUT_PipingWiring(delivery_slip_header_id)
      @DSDLC_piping_wiring.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
	end
	
	#機器取付の計を更新(construction_type=x)
    @DSDLC_equipment_mounting = DeliverySlipDetailLargeClassification.where(delivery_slip_header_id: delivery_slip_header_id, construction_type: $INDEX_EUIPMENT_MOUNTING).first
	if @DSDLC_equipment_mounting.present?
      labor_productivity_unit_total = DeliverySlipDetailLargeClassification.sum_LPUT_equipment_mounting(delivery_slip_header_id)
      @DSDLC_equipment_mounting.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
	end
    #労務費の計を更新(construction_type=x)
    @DSDLC_labor_cost = DeliverySlipDetailLargeClassification.where(delivery_slip_header_id: delivery_slip_header_id, construction_type: $INDEX_LABOR_COST).first
    if @DSDLC_labor_cost.present?
      labor_productivity_unit_total = DeliverySlipDetailLargeClassification.sum_LPUT_labor_cost(delivery_slip_header_id)
      @DSDLC_labor_cost.update_attributes!(:labor_productivity_unit_total => labor_productivity_unit_total)
	end
  
  end
  #固有マスター関連取得 
  def working_specific_middle_item_select
     @working_large_item_name = WorkingSpecificMiddleItem.where(:id => params[:working_specific_middle_item_id]).where("id is NOT NULL").pluck(:working_middle_item_name).flatten.join(" ")
     @working_large_item_short_name = WorkingSpecificMiddleItem.where(:id => params[:working_specific_middle_item_id]).where("id is NOT NULL").pluck(:working_middle_item_short_name).flatten.join(" ")

	 @working_large_specification = WorkingSpecificMiddleItem.where(:id => params[:working_specific_middle_item_id]).where("id is NOT NULL").pluck(:working_middle_specification).flatten.join(" ")
     
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
  
  ### ajax

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivery_slip_detail_large_classification
      @delivery_slip_detail_large_classification = DeliverySlipDetailLargeClassification.find(params[:id])
    end
    
    def initialize_sort
      $not_sort_dl = true
    end
	
    #新規か編集かの判定フラグ
    def set_action_flag
      @action_flag = params[:action]
    end
    
    #以降のレコードの行番号を全てインクリメントする
    def line_insert
      DeliverySlipDetailLargeClassification.where(["delivery_slip_header_id = ? and line_number >= ? and id != ?", @delivery_slip_detail_large_classification.delivery_slip_header_id,
        @delivery_slip_detail_large_classification.line_number, @delivery_slip_detail_large_classification.id]).update_all("line_number = line_number + 1")
      #最終行番号も取得しておく
      @max_line_number = DeliverySlipDetailLargeClassification.
        where(["delivery_slip_header_id = ? and line_number >= ? and id != ?", @delivery_slip_detail_large_classification.delivery_slip_header_id, 
        @delivery_slip_detail_large_classification.line_number, @delivery_slip_detail_large_classification.id]).maximum(:line_number)
    end
    
    #見出データへ合計保存用　
    def save_price_to_headers
      @delivery_slip_header = DeliverySlipHeader.find(@delivery_slip_detail_large_classification.delivery_slip_header_id)
      #請求金額
      @delivery_slip_header.delivery_amount = delivery_slip_total_price
      #実行金額
      @delivery_slip_header.execution_amount = execution_total_price
      @delivery_slip_header.save
    end
    
  #見出しデータへ最終行番号保存用
  def delivery_slip_headers_set_last_line_number
    @delivery_slip_headers = DeliverySlipHeader.find_by(id: @delivery_slip_detail_large_classification.delivery_slip_header_id)
    check_flag = false
    if @delivery_slip_headers.last_line_number.nil? 
      check_flag = true
    else
      if (@delivery_slip_headers.last_line_number < @max_line_number) then
        check_flag = true
      end
    end
    if (check_flag == true)
      delivery_slip_header_params = { last_line_number:  @max_line_number}
      if @delivery_slip_headers.present?
        @delivery_slip_headers.attributes = delivery_slip_header_params
           @delivery_slip_headers.save(:validate => false)
      end 
    end 
  end
  
  #行番号を取得し、インクリメントする。（新規用）
  def get_line_number
    @line_number = 1
    
    if $sort_dl != "asc"   
      if @delivery_slip_detail_large_classification.delivery_slip_header_id.present?
        @delivery_slip_headers = DeliverySlipHeader.find_by(id: @delivery_slip_detail_large_classification.delivery_slip_header_id)
        if @delivery_slip_headers.present?
          if @delivery_slip_headers.last_line_number.present?
            @line_number = @delivery_slip_headers.last_line_number + 1
          end
        end
      end
    else
      #昇順ソートしている場合は、行を最終ではなく先頭にする。
      #登録済みレコードの行を全て事前に加算する
      status = increment_line_number
		
      #インクリメント失敗していたら、行は０にする。
      if status == false
        @line_number = 0
      end
    end
    
    @delivery_slip_detail_large_classification.line_number = @line_number
  end
    
  #ストロングパラメータ
  # Never trust parameters from the scary internet, only allow the white list through.
  def delivery_slip_detail_large_classification_params
      params.require(:delivery_slip_detail_large_classification).permit(:delivery_slip_header_id, :delivery_slip_items_division_id, :working_large_item_id, :working_specific_middle_item_id,
                     :working_large_item_name, :working_large_item_short_name, :working_middle_item_category_id, :working_middle_item_category_id_call, 
                     :working_middle_item_subcategory_id, :working_middle_item_subcategory_id_call, :working_large_specification, :line_number, :quantity, :execution_quantity, :working_unit_id, :working_unit_name, :working_unit_price, :delivery_slip_price, :execution_unit_price, :execution_price, :labor_productivity_unit, :labor_productivity_unit_total, 
                     :last_line_number, :remarks, :construction_type, :piping_wiring_flag, :equipment_mounting_flag, :labor_cost_flag )
  end

	
  ########  請求書関連データ操作
  def delete_invoice
  #既存の請求書データを全て削除する
    if params[:delivery_slip_code].present?
	  @invoice_header = InvoiceHeader.find_by(delivery_slip_code: params[:delivery_slip_code])
    
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
  #納品書データを請求書データへ丸ごとコピー（もっと単純な方法ない？）
	  @success_flag = true
	 
	  #見出しデータのコピー
	  @delivery_slip_header = nil
	  if params[:delivery_slip_header_id].present?
	    @delivery_slip_header = DeliverySlipHeader.find(params[:delivery_slip_header_id])
	  end
	  
	  if @delivery_slip_header.present?
      if @delivery_slip_header.delivery_slip_code.present?
		
        #upd190307
        #一律で仮コードセット
        invoice_code = $HEADER_CODE_MAX
        
		  ##見出しコードが空の場合は仮番号をセット。
		  #if @delivery_slip_header.invoice_code.blank?
		  #  invoice_code = $HEADER_CODE_MAX
      #else
      #  invoice_code = @delivery_slip_header.invoice_code
		  #end
		  #
		
          invoice_header_params = { invoice_code: invoice_code, delivery_slip_code:  @delivery_slip_header.quotation_code, 
                                  delivery_slip_code:  @delivery_slip_header.delivery_slip_code, 
                                  construction_datum_id: @delivery_slip_header.construction_datum_id, construction_name: @delivery_slip_header.construction_name, 
                                  customer_id: @delivery_slip_header.customer_id, customer_name: @delivery_slip_header.customer_name, honorific_id: @delivery_slip_header.honorific_id,
                                  responsible1: @delivery_slip_header.responsible1, responsible2: @delivery_slip_header.responsible2, post: @delivery_slip_header.post, 
                                  address: @delivery_slip_header.address, house_number: @delivery_slip_header.house_number, address2: @delivery_slip_header.address2,
                                  tel: @delivery_slip_header.tel, fax: @delivery_slip_header.fax, construction_period: @delivery_slip_header.construction_period,
                                  construction_place: @delivery_slip_header.construction_place, 
                                  construction_house_number: @delivery_slip_header.construction_house_number, construction_place2: @delivery_slip_header.construction_place2, 
                                  billing_amount: @delivery_slip_header.delivery_amount, execution_amount: @delivery_slip_header.execution_amount, last_line_number: @delivery_slip_header.last_line_number} 
          #上記、納品日は移行しないものとする。
          @invoice_header = InvoiceHeader.new(invoice_header_params)
          if @invoice_header.save!(:validate => false)
		    @success_flag = true
            
            #ここで追加されたIDを保持する
            @invoice_header_id = @invoice_header.id
            
		  else
		    @success_flag = false
          end 
		else
		  flash[:notice] = "データ作成に失敗しました！納品書コードを登録してください。"
          @success_flag = false
		end
	  end 
	  
	  if @success_flag == true
	    
        if @invoice_header_id.present?   
          
          #内訳データのコピー
	      @d_s_d_l_c = DeliverySlipDetailLargeClassification.where(delivery_slip_header_id: params[:delivery_slip_header_id])
	      if @d_s_d_l_c.present?
	    
		    @d_s_d_l_c.each do |d_s_d_l_c|
              
		      #IDをここでセットしておく（明細で参照するため）
			  @delivery_slip_detail_large_classification_id = d_s_d_l_c.id
			   
		      invoice_detail_large_classification_params = {invoice_header_id: @invoice_header_id, invoice_items_division_id: d_s_d_l_c.delivery_slip_items_division_id, 
                working_large_item_id: d_s_d_l_c.working_large_item_id, working_large_item_name: d_s_d_l_c.working_large_item_name, 
                working_large_item_short_name: d_s_d_l_c.working_large_item_short_name,
                working_large_specification: d_s_d_l_c.working_large_specification, line_number: d_s_d_l_c.line_number, quantity: d_s_d_l_c.quantity, 
                execution_quantity: d_s_d_l_c.execution_quantity, working_unit_id: d_s_d_l_c.working_unit_id, working_unit_name: d_s_d_l_c.working_unit_name, 
                working_unit_price: d_s_d_l_c.working_unit_price, invoice_price: d_s_d_l_c.delivery_slip_price, execution_unit_price: d_s_d_l_c.execution_unit_price, 
                execution_price: d_s_d_l_c.execution_price, labor_productivity_unit: d_s_d_l_c.labor_productivity_unit, 
                labor_productivity_unit_total: d_s_d_l_c.labor_productivity_unit_total, last_line_number: d_s_d_l_c.last_line_number, remarks: d_s_d_l_c.remarks,
                construction_type: d_s_d_l_c.construction_type , piping_wiring_flag: d_s_d_l_c.piping_wiring_flag , equipment_mounting_flag: d_s_d_l_c.equipment_mounting_flag , 
                labor_cost_flag: d_s_d_l_c.labor_cost_flag }
            
			  @invoice_detail_large_classification = InvoiceDetailLargeClassification.new(invoice_detail_large_classification_params)
              if @invoice_detail_large_classification.save!
		      
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
  end
  def create_invoice_detail
    #納品書データを請求書データへ丸ごとコピー（明細）
    #明細データのコピー
	  @d_s_d_m_c = DeliverySlipDetailMiddleClassification.where(delivery_slip_header_id: params[:delivery_slip_header_id], 
	                                                            delivery_slip_detail_large_classification_id: @delivery_slip_detail_large_classification_id )
	  
	  if @d_s_d_m_c.present?
	    
		@d_s_d_m_c.each do |d_s_d_m_c|
          
		   invoice_detail_middle_classification_params = {invoice_header_id: @invoice_header_id, invoice_detail_large_classification_id: @invoice_detail_large_classification_id, 
             invoice_item_division_id: d_s_d_m_c.delivery_slip_item_division_id, working_middle_item_id: d_s_d_m_c.working_middle_item_id, working_middle_item_name: d_s_d_m_c.working_middle_item_name, 
             working_middle_item_short_name: d_s_d_m_c.working_middle_item_short_name, line_number: d_s_d_m_c.line_number, working_middle_specification: d_s_d_m_c.working_middle_specification,
             quantity: d_s_d_m_c.quantity, execution_quantity: d_s_d_m_c.execution_quantity, working_unit_id: d_s_d_m_c.working_unit_id, working_unit_name: d_s_d_m_c.working_unit_name,
             working_unit_price: d_s_d_m_c.working_unit_price, invoice_price: d_s_d_m_c.delivery_slip_price, execution_unit_price: d_s_d_m_c.execution_unit_price, execution_price: d_s_d_m_c.execution_price, 
             material_id: d_s_d_m_c.material_id, working_material_name: d_s_d_m_c.working_material_name, material_unit_price: d_s_d_m_c.material_unit_price, 
			 labor_unit_price: d_s_d_m_c.labor_unit_price, labor_productivity_unit: d_s_d_m_c.labor_productivity_unit, labor_productivity_unit_total: d_s_d_m_c.labor_productivity_unit_total,
			 material_quantity: d_s_d_m_c.material_quantity, accessory_cost: d_s_d_m_c.accessory_cost, material_cost_total: d_s_d_m_c.material_cost_total, 
			 labor_cost_total: d_s_d_m_c.labor_cost_total, other_cost: d_s_d_m_c.other_cost, remarks: d_s_d_m_c.remarks,
             construction_type: d_s_d_m_c.construction_type , piping_wiring_flag: d_s_d_m_c.piping_wiring_flag , equipment_mounting_flag: d_s_d_m_c.equipment_mounting_flag , 
             labor_cost_flag: d_s_d_m_c.labor_cost_flag } 
          	
          @invoice_detail_middle_classification = InvoiceDetailMiddleClassification.new(invoice_detail_middle_classification_params)
          if @invoice_detail_middle_classification.save!
		  else
		    @success_flag = false
		  end 
	    end
	  end
  end
  
########  見積書関連データ操作

  def delete_quotation
    #既存の見積書データを全て削除する
    if params[:delivery_slip_code].present?
      @quotation_header = QuotationHeader.find_by(delivery_slip_code: params[:delivery_slip_code])
    
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
  #納品書データを見積書データへ丸ごとコピー（もっと単純な方法ない？）
	  @success_flag = true
	 
	  #見出しデータのコピー
	  @delivery_slip_header = DeliverySlipHeader.find(params[:delivery_slip_header_id])
	 
	  if @delivery_slip_header.present? 
	    if @delivery_slip_header.delivery_slip_code.present?
		    
        #仮番号をセット。
        #(昨年時などの古いコードがそのまま入っていると、わからなくなるため、一律で仮番号を入れることにする。)
        quotation_code = $HEADER_CODE_MAX
        
        #upd(del)190307
        #見出しコードが空の場合は仮番号をセット。
		    #if @delivery_slip_header.quotation_code.blank?
		    #  quotation_code = $HEADER_CODE_MAX
        #else
        #  quotation_code = @delivery_slip_header.quotation_code
		    #end
		    #
				
          quotation_header_params = { quotation_code: quotation_code, invoice_code:  @delivery_slip_header.invoice_code, 
                                  delivery_slip_code:  @delivery_slip_header.delivery_slip_code, 
                                  construction_datum_id: @delivery_slip_header.construction_datum_id, construction_name: @delivery_slip_header.construction_name, 
                                  customer_id: @delivery_slip_header.customer_id, customer_name: @delivery_slip_header.customer_name, honorific_id: @delivery_slip_header.honorific_id,
                                  responsible1: @delivery_slip_header.responsible1, responsible2: @delivery_slip_header.responsible2, post: @delivery_slip_header.post, construction_period: @delivery_slip_header.construction_period,
                                  construction_period_date1: @delivery_slip_header.construction_period_date1, construction_period_date2: @delivery_slip_header.construction_period_date2,
                                  address: @delivery_slip_header.address, house_number: @delivery_slip_header.house_number, address2: @delivery_slip_header.address2,
                                  tel: @delivery_slip_header.tel, fax: @delivery_slip_header.fax, 
                                  construction_post: @delivery_slip_header.construction_post,  construction_place: @delivery_slip_header.construction_place, 
                                  construction_house_number: @delivery_slip_header.construction_house_number, construction_place2: @delivery_slip_header.construction_place2, 
                                  quote_price: @delivery_slip_header.delivery_amount, execution_amount: @delivery_slip_header.execution_amount, 
								  last_line_number: @delivery_slip_header.last_line_number} 
          #上記、納品日は移行しないものとする。
		  @quotation_header = QuotationHeader.new(quotation_header_params)
          if @quotation_header.save!(:validate => false)
		    @success_flag = true
            
            #ここで追加されたIDを保持する
            @quotation_header_id = @quotation_header.id
            
		  else
		    @success_flag = false
          end
        else 
           flash[:notice] = "データ作成に失敗しました！納品書コードを登録してください。"
           @success_flag = false
		end
	  end 
	  
	  if @success_flag == true
	    
        if @quotation_header_id.present?   
          #内訳データのコピー
	      @d_s_d_l_c = DeliverySlipDetailLargeClassification.where(delivery_slip_header_id: params[:delivery_slip_header_id])
	      if @d_s_d_l_c.present?
	    
		    @d_s_d_l_c.each do |d_s_d_l_c|
              
		      #IDをここでセットしておく（明細で参照するため）
			  @delivery_slip_detail_large_classification_id = d_s_d_l_c.id
			
			
            quotation_detail_large_classification_params = {quotation_header_id: @quotation_header_id, quotation_items_division_id: d_s_d_l_c.delivery_slip_items_division_id, 
              working_large_item_id: d_s_d_l_c.working_large_item_id, working_large_item_name: d_s_d_l_c.working_large_item_name, 
              working_large_item_short_name: d_s_d_l_c.working_large_item_short_name,
              working_middle_item_category_id: d_s_d_l_c.working_middle_item_category_id,
              working_middle_item_category_id_call: d_s_d_l_c.working_middle_item_category_id_call,
              working_middle_item_subcategory_id: d_s_d_l_c.working_middle_item_subcategory_id,
              working_middle_item_subcategory_id_call: d_s_d_l_c.working_middle_item_subcategory_id_call,
              working_large_specification: d_s_d_l_c.working_large_specification, 
              line_number: d_s_d_l_c.line_number, quantity: d_s_d_l_c.quantity, 
              execution_quantity: d_s_d_l_c.execution_quantity, working_unit_id: d_s_d_l_c.working_unit_id, working_unit_name: d_s_d_l_c.working_unit_name, 
              working_unit_price: d_s_d_l_c.working_unit_price, quote_price: d_s_d_l_c.delivery_slip_price, execution_unit_price: d_s_d_l_c.execution_unit_price, 
              execution_price: d_s_d_l_c.execution_price, labor_productivity_unit: d_s_d_l_c.labor_productivity_unit, 
              labor_productivity_unit_total: d_s_d_l_c.labor_productivity_unit_total, last_line_number: d_s_d_l_c.last_line_number, remarks: d_s_d_l_c.remarks, 
              construction_type: d_s_d_l_c.construction_type , piping_wiring_flag: d_s_d_l_c.piping_wiring_flag , equipment_mounting_flag: d_s_d_l_c.equipment_mounting_flag , 
              labor_cost_flag: d_s_d_l_c.labor_cost_flag }
			
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
	  #
	  end
	  
	  #
  end
  def create_quotation_detail
    #納品書データを見積書データへ丸ごとコピー（明細）
    #明細データのコピー
	  @d_s_d_m_c = DeliverySlipDetailMiddleClassification.where(delivery_slip_header_id: params[:delivery_slip_header_id], 
	                                                            delivery_slip_detail_large_classification_id: @delivery_slip_detail_large_classification_id )
	  
	  if @d_s_d_m_c.present?
	    
		@d_s_d_m_c.each do |d_s_d_m_c|
          
           quotation_detail_middle_classification_params = {quotation_header_id: @quotation_header_id, quotation_detail_large_classification_id: @quotation_detail_large_classification_id, 
             quotation_items_division_id: d_s_d_m_c.delivery_slip_item_division_id, working_middle_item_id: d_s_d_m_c.working_middle_item_id, working_middle_item_name: d_s_d_m_c.working_middle_item_name, 
             working_middle_item_short_name: d_s_d_m_c.working_middle_item_short_name, 
             working_middle_item_category_id: d_s_d_m_c.working_middle_item_category_id,
             working_middle_item_category_id_call: d_s_d_m_c.working_middle_item_category_id_call,
             working_middle_item_subcategory_id: d_s_d_m_c.working_middle_item_subcategory_id,
             working_middle_item_subcategory_id_call: d_s_d_m_c.working_middle_item_subcategory_id_call,
             line_number: d_s_d_m_c.line_number, working_middle_specification: d_s_d_m_c.working_middle_specification,
             quantity: d_s_d_m_c.quantity, execution_quantity: d_s_d_m_c.execution_quantity, working_unit_id: d_s_d_m_c.working_unit_id, working_unit_name: d_s_d_m_c.working_unit_name,
             working_unit_price: d_s_d_m_c.working_unit_price, quote_price: d_s_d_m_c.delivery_slip_price, execution_unit_price: d_s_d_m_c.execution_unit_price, execution_price: d_s_d_m_c.execution_price,
             material_id: d_s_d_m_c.material_id, quotation_material_name: d_s_d_m_c.working_material_name, material_unit_price: d_s_d_m_c.material_unit_price, 
			 labor_unit_price: d_s_d_m_c.labor_unit_price, labor_productivity_unit: d_s_d_m_c.labor_productivity_unit, labor_productivity_unit_total: d_s_d_m_c.labor_productivity_unit_total,
			 material_quantity: d_s_d_m_c.material_quantity, accessory_cost: d_s_d_m_c.accessory_cost, material_cost_total: d_s_d_m_c.material_cost_total, 
			 labor_cost_total: d_s_d_m_c.labor_cost_total, other_cost: d_s_d_m_c.other_cost, remarks: d_s_d_m_c.remarks,
             construction_type: d_s_d_m_c.construction_type , piping_wiring_flag: d_s_d_m_c.piping_wiring_flag , equipment_mounting_flag: d_s_d_m_c.equipment_mounting_flag , 
             labor_cost_flag: d_s_d_m_c.labor_cost_flag } 
          	
          @quotation_detail_middle_classification = QuotationDetailMiddleClassification.new(quotation_detail_middle_classification_params)
          if @quotation_detail_middle_classification.save!(:validate => false)
		  else
		    @success_flag = false
		  end 
	    end
	  end
  end
  
  ###add end
  
  
  #内訳→明細へのデータ移行
  def move_large_to_middle
    
    #まず行を全て加算
    status = increment_line_number
    if status == true
      
      #１つに束ねる為の、内訳データを１行分だけつくる
      delivery_slip_detail_large_classificasion_params = {delivery_slip_header_id: params[:delivery_slip_header_id], delivery_slip_items_division_id: 1,
                        working_large_item_id: 1, working_large_item_name: "※入力してください※", working_large_item_short_name: 1, working_large_specification: "",
                        line_number: 1, quantity: 1, execution_quantity: 1, working_unit_id: ID_UNIT_SET, working_unit_name: "式" , construction_type: 0, piping_wiring_flag: 0, 
                        equipment_mounting_flag: 0, labor_cost_flag: 0 }
    
      @d_s_d_l_c_new_records = DeliverySlipDetailLargeClassification.new(delivery_slip_detail_large_classificasion_params)
    
      if @d_s_d_l_c_new_records.save!(:validate => false)
          #内訳データのコピー(行番号１以外）
	      d_s_d_l_cs = DeliverySlipDetailLargeClassification.where(delivery_slip_header_id: params[:delivery_slip_header_id]).where.not( line_number: 1 )
          if d_s_d_l_cs.present?
            
            success_flag = true
            line_number = 0
            
	        d_s_d_l_cs.each do |d_s_d_l_c|
              
              line_number = d_s_d_l_c.line_number - 1   #行番号は加算されているのでマイナスする
              
              #明細へコピー
              delivery_slip_detail_middle_classification_params = {delivery_slip_header_id: params[:delivery_slip_header_id], delivery_slip_detail_large_classification_id: @d_s_d_l_c_new_records.id, 
              delivery_slip_item_division_id: d_s_d_l_c.delivery_slip_items_division_id, working_middle_item_id: d_s_d_l_c.working_large_item_id, working_middle_item_name: d_s_d_l_c.working_large_item_name, 
              working_middle_item_short_name: d_s_d_l_c.working_large_item_short_name, line_number: line_number, working_middle_specification: d_s_d_l_c.working_large_specification,
              working_middle_item_category_id: d_s_d_l_c.working_middle_item_category_id, working_middle_item_category_id_call: d_s_d_l_c.working_middle_item_category_id_call, 
              working_middle_item_subcategory_id: d_s_d_l_c.working_middle_item_subcategory_id, working_middle_item_subcategory_id_call: d_s_d_l_c.working_middle_item_subcategory_id_call, 
              quantity: d_s_d_l_c.quantity, execution_quantity: d_s_d_l_c.execution_quantity, working_unit_id: d_s_d_l_c.working_unit_id, working_unit_name: d_s_d_l_c.working_unit_name,
              working_unit_price: d_s_d_l_c.working_unit_price, delivery_slip_price: d_s_d_l_c.delivery_slip_price, execution_unit_price: d_s_d_l_c.execution_unit_price, execution_price: d_s_d_l_c.execution_price, 
              labor_productivity_unit: d_s_d_l_c.labor_productivity_unit, labor_productivity_unit_total: d_s_d_l_c.labor_productivity_unit_total, remarks: d_s_d_l_c.remarks,
              construction_type: d_s_d_l_c.construction_type , piping_wiring_flag: d_s_d_l_c.piping_wiring_flag , equipment_mounting_flag: d_s_d_l_c.equipment_mounting_flag , 
              labor_cost_flag: d_s_d_l_c.labor_cost_flag } 
          
              delivery_slip_detail_middle_classification = DeliverySlipDetailMiddleClassification.new(delivery_slip_detail_middle_classification_params)
              
              unless delivery_slip_detail_middle_classification.save!(:validate => false)
                success_flag = false
              end 
            end
            
            if success_flag == true
            
                #最終行を書き込む
                @d_s_d_l_c_new_records.last_line_number = line_number
                
                #合計値を親データへ書き込み
                #納品金額
                @d_s_d_l_c_new_records.delivery_slip_price = delivery_slip_middle_total_price(@d_s_d_l_c_new_records)
                #実行金額
                @d_s_d_l_c_new_records.execution_price = execution_middle_total_price(@d_s_d_l_c_new_records)
                
                #歩掛り
                @d_s_d_l_c_new_records.labor_productivity_unit = labor_middle_total(@d_s_d_l_c_new_records)
		        #歩掛計
                @d_s_d_l_c_new_records.labor_productivity_unit_total = labor_middle_all_total(@d_s_d_l_c_new_records)

                if @d_s_d_l_c_new_records.save!(:validate => false)
                  
                  #既存の２〜のデータを削除
                  d_s_d_l_cs.destroy_all
                  
                  #見出しデータへ合計保存
                  save_price_to_headers_move
                  
                  
                  #一覧データの最終行を１とする
                  delivery_slip_header = DeliverySlipHeader.find_by(id: params[:delivery_slip_header_id])
		          if delivery_slip_header.present?
		            delivery_slip_header.assign_attributes(:last_line_number => 1)
			        delivery_slip_header.save(validate: false)
                  end
                  
                  #リダイレクトしないとパラメータが残る
                  respond_to do |format|
                    format.html {redirect_to delivery_slip_detail_large_classifications_path(:delivery_slip_header_id => params[:delivery_slip_header_id], 
                     :delivery_slip_header_name => params[:delivery_slip_header_name])}
                  end
                end
            end
          end
      end
    end
    
    
  end
  #納品金額トータル(明細)
  def delivery_slip_middle_total_price(d_s_d_l_c)
    
    @delivery_slip_middle_total_price = DeliverySlipDetailMiddleClassification.where(["delivery_slip_header_id = ? and delivery_slip_detail_large_classification_id = ?", 
        params[:delivery_slip_header_id], d_s_d_l_c.id]).sumpriceDeliverySlip
  end 
  #実行金額トータル(明細)
  def execution_middle_total_price(d_s_d_l_c)
    @execution_total_price = DeliverySlipDetailMiddleClassification.where(["delivery_slip_header_id = ? and delivery_slip_detail_large_classification_id = ?", 
      params[:delivery_slip_header_id], d_s_d_l_c.id]).sumpriceExecution
  end
  #歩掛りトータル(明細)
  def labor_middle_total(d_s_d_l_c)
    @labor_total = DeliverySlipDetailMiddleClassification.where(["delivery_slip_header_id = ? and delivery_slip_detail_large_classification_id = ?", 
      params[:delivery_slip_header_id], d_s_d_l_c.id]).sumLaborProductivityUnit 
  end
  #歩掛計トータル(明細)
  def labor_middle_all_total(d_s_d_l_c)
    @labor_all_total = DeliverySlipDetailMiddleClassification.where(["delivery_slip_header_id = ? and delivery_slip_detail_large_classification_id = ?", 
      params[:delivery_slip_header_id], d_s_d_l_c.id]).sumLaborProductivityUnitTotal 
  end
  #請求金額トータル
  def delivery_slip_total_price_Large
     @execution_total_price_Large = DeliverySlipDetailLargeClassification.where(["delivery_slip_header_id = ?",
         params[:delivery_slip_header_id]]).sumpriceDeliverySlip
         
  end 
  #実行金額トータル
  def execution_total_price_Large
     @execution_total_price_Large = DeliverySlipDetailLargeClassification.where(["delivery_slip_header_id = ?",
       params[:delivery_slip_header_id]]).sumpriceExecution
  end
  #見出データへ合計保存用
  def save_price_to_headers_move
     delivery_slip_header = DeliverySlipHeader.find(params[:delivery_slip_header_id])
       
     if delivery_slip_header.present? 
         #請求金額
          delivery_slip_header.delivery_amount = delivery_slip_total_price_Large
		  
          #実行金額
          delivery_slip_header.execution_amount = execution_total_price_Large
          delivery_slip_header.save
       
          
     end 
  end
  #(ここまで)内訳→明細へのデータ移行
end
