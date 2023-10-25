class QuotationMaterialHeadersController < ApplicationController
  before_action :set_quotation_material_header, only: [:show, :edit, :update, :destroy]
  #before_action :set_quotation_material_header, only: [:show, :update, :destroy]

  #サブフォームの描写速度を上げるため、メモリへ貯める
  before_action :set_masters


  # GET /quotation_material_headers
  # GET /quotation_material_headers.json
  def index
    #@quotation_material_headers = QuotationMaterialHeader.all
    #フォーム連番用
    $seq  = 0        #フォーム用(追加時)
    $seq_exists = 0  #フォーム用
    session[:seq_exists] = 0  #add231006
    
    $seq_max = 0  #最大値取得用
    
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)  
    
    case params[:move_flag] 
    when "1"
    #工事一覧画面から遷移した場合
       construction_id = params[:construction_id]
       query = {"construction_datum_id_eq"=> construction_id }
    end
  
    #@q = QuotationMaterialHeader.ransack(params[:q])   
    #ransack保持用--上記はこれに置き換える
    @q = QuotationMaterialHeader.ransack(query)   
     #ransack保持用コード
     search_history = {
     value: params[:q],
     expires: 24.hours.from_now
     }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
    
    @quotation_material_headers  = @q.result(distinct: true)
    @quotation_material_headers  = @quotation_material_headers.page(params[:page])
    
	
    #~~~比較表PDF作成
    #if params[:pdf_id].present?
    #end

  end
  
  #pdf(見積比較表)発行
  def set_quotation_compare_pdf(format)
    if params[:format] == "pdf"
    
      #$quotation_material_header = @quotation_material_header
    
      format.pdf do
        #report = BidComparisonListPDF.create @bid_comparison_list
        report = BidComparisonListPDF.create @quotation_material_header
        
        # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data report.generate,
        filename:    "見積比較表.pdf",
            type:        "application/pdf",
            disposition: "inline"
      end
    end
  end

  #pdf(見積ｆａｘ)発行
  def set_quotation_fax_pdf(format)
    
    if params[:format] == "pdf"
      #binding.pry
      #担当者/Emailをメール送信用にセット・更新フラグをセット
      #upd230508
      @responsible, @email_responsible = app_set_responsible(params[:quotation_material_header][:responsible],
                                        params[:quotation_material_header][:email],
                                        params[:quotation_material_header][:supplier_master_id])
                                        
      
      #$quotation_material_header = @quotation_material_header
      format.pdf do
        #report = QuotationFaxPDF.create @quotation_fax
        #upd230509
        report = QuotationFaxPDF.create(@quotation_material_header, @responsible)
 
        
        # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data report.generate,
        filename:    "見積ＦＡＸ.pdf",
            type:        "application/pdf",
            disposition: "inline"
    
      end
    end
  end

  #pdf(注文ｆａｘ)発行
  def set_quotation_order_fax_pdf(format)
    if params[:format] == "pdf"
      #担当者/Emailをメール送信用にセット・更新フラグをセット
      #upd230508
      @responsible, @email_responsible = app_set_responsible(params[:quotation_material_header][:responsible],
                                        params[:quotation_material_header][:email],
                                        params[:quotation_material_header][:supplier_master_id])
    
      #$quotation_material_header = @quotation_material_header
      #$purchase_order_code = params[:quotation_material_header][:purchase_order_code]
      purchase_order_code = params[:quotation_material_header][:purchase_order_code]
      #仕入先（１〜３）の判定 "$supplier"にセットされる
      setSupplier
       
      #binding.pry
       
      format.pdf do
        #report = QuotationOrderFaxPDF.create @quotation_order_fax
        report = QuotationOrderFaxPDF.create(@quotation_material_header, purchase_order_code, @supplier, @responsible)
        
        # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data report.generate,
        filename:    "見積注文ＦＡＸ.pdf",
          type:        "application/pdf",
          disposition: "inline"
      end
    end
	end


  # GET /quotation_material_headers/1
  # GET /quotation_material_headers/1.json
  def show
  end

  # GET /quotation_material_headers/new
  def new
    
    #画面の並びは昇順にする
    #新規は昇順、編集は降順。
    @form_detail_order = "sequential_id ASC"
  
    #コード参照元がある場合、セットする。
    if $quotation_material_header.present?
      #ここは現在通らない??(カットしても良い?)
      #binding.pry
      
      #レコード毎のメール送信済みフラグを初期化するためのフラグをセット
      $new_flag = 1
  
      @quotation_material_header = $quotation_material_header

      #連番の最大値を取る(フォーム用)
      get_max_seq
      
      #新規作成用なので、不要なパラメータはリセットする。
      @quotation_material_header.quotation_code = nil
  
      @quotation_material_header.quotation_header_origin_id = $quotation_material_header.id
  
      #グローバルを空に戻す
      $quotation_material_header = nil
    else
      @quotation_material_header = QuotationMaterialHeader.new
    end

    #工事画面から遷移した場合、予めIDをセットする
    if params[:construction_id].present?
      @quotation_material_header.construction_datum_id = params[:construction_id]
    end

    #見積コードの自動採番
    get_last_quotation_code_select

  end

  #レコード毎のメール送信済みフラグを初期化する
  def reset_mail_sent_flag
    if $quotation_material_header.quotation_material_details.present?
      $quotation_material_header.quotation_material_details.each do |item|
        item.mail_sent_flag = nil
      end
    end
  end

  # GET /quotation_material_headers/1/edit
  def edit
    #画面の並びは昇順にする
    #新規は昇順、編集は降順。
    #@form_detail_order = "sequential_id DESC"
    @form_detail_order = "sequential_id ASC"  #upd230926
  
    $new_flag = 0
    
    #レコード毎のメール送信済みフラグを初期化するためのフラグをセット(一時用)
    reset_mail_sent_flag

    #連番の最大値を取る(フォーム用)
    get_max_seq
  
    #注文NOの頭文字を定数ファイルから取得する
    @last_header_number = Constant.where(:id => 1).
           where("id is NOT NULL").pluck(:purchase_order_last_header_code).flatten.join(" ")

  end
  
  def reset_mail_sent_flag
    
    exist_flag = false
  
    if params[:quotation_material_header].present?
      if params[:quotation_material_header][:supplier_id_1].present?
   	  #仕入先１で送信済？
        if params[:quotation_material_header][:supplier_master_id] ==  params[:quotation_material_header][:supplier_id_1]
	        exist_flag = true
	      end
      elsif params[:quotation_material_header][:supplier_id_2].present?
	    #仕入先２で送信済？
	      if params[:quotation_material_header][:supplier_master_id] ==  params[:quotation_material_header][:supplier_id_2]
	        exist_flag = true
	      end
	    elsif params[:quotation_material_header][:supplier_id_3].present?
	    #仕入先３で送信済？→未検証
        if params[:quotation_material_header][:supplier_master_id] ==  params[:quotation_material_header][:supplier_id_3]
	        exist_flag = true
	      end
      end
    end
  
    #フォーム側で使用、現在未使用の模様..	
    if exist_flag == true
      $new_flag = 1
    end
  end
  
  def get_max_seq
    
    @details = nil
    if @quotation_material_header.quotation_material_details.present?
      @details = @quotation_material_header.quotation_material_details
    end
  
    if @form_detail_order != "sequential_id DESC"
    #編集時（昇順）はのぞく
      if  @details.present?
        if @details.maximum(:sequential_id).present?
          $seq_exists = @details.maximum(:sequential_id)
          $seq_max = $seq_exists
        end
        #SEQが逆になっているのでみやすいよう再び逆にする
        #reverse_seq
      end
    else 
    #昇順の場合
      $seq_exists = 1
      if @details.present?
        $seq_max = @details.maximum(:sequential_id)
      else
        $seq_max = 1
      end
    end
    
    session[:seq_exists] = $seq_max  #add231006
    #
  end
  
  
  #連番が登録と逆順になっているので、みやすいように正しい順に（逆に）する
  #うまくいかないため、現在未使用
  def reverse_seq
    #連番を割り振る処理
    @details = nil
    if @quotation_material_header.quotation_material_details.present?
      @details = @quotation_material_header.quotation_material_details
    end
  
    if @details.present?
      if @details.maximum(:sequential_id).present?
        $seq = @details.maximum(:sequential_id)
      end
      
      #連番が登録と逆順になっているので、みやすいように正しい順に（逆に）する
      #reverse_seq
      #if $max.present?
  
      max = $seq 
      reverse_num = max 
      
      for num in 0..max do
	    
        if @details.present?
          if @details[num].present?
            @quotation_material_header.quotation_material_details[num][:sequential_id] = reverse_num
            reverse_num -= 1
          end
        end
      end
    end
    #  @details.present?
  end
  
  #ajax -- 現在未使用??
  #既存のデータを取得する(日付・仕入先指定後。)
  def get_data
    
    $quotation_material_header = QuotationMaterialHeader.find(params[:quotation_header_origin_id])
  end
  
  
  #商品名などを取得
  def material_select
    @material_code = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_code).flatten.join(" ")
    @material_name = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_name).flatten.join(" ")
    @list_price = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:list_price).flatten.join(" ")
    @maker_id = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:maker_id).flatten.join(" ")
  
    #単位はまず商品マスターから取得する(ここは見積・注文時のみ更新)、なければ仕入単価Mより取得
    @unit_id = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:unit_id).flatten.join(" ")
    
    if @unit_id.blank?  #ここは基本的に起こり得ない
 	    @unit_id = PurchaseUnitPrice.where(["supplier_id = ? and material_id = ?", 
                 params[:supplier_master_id], params[:id] ]).pluck(:unit_id).flatten.join(" ")
    end
    
    #どちらも該当なければひとまず”個”にする
    if @unit_id.blank?
      @unit_id = "3"
    end
     
    @notes = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:notes).flatten.join(" ")
  
    @material_category_id = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_category_id).flatten.join(" ")
    
  end
  
  #見積コードの最終番号(+1)を取得する
  def get_last_quotation_code_select
     
    #当日を取得
    require 'date'
    now_date =Date.today.to_time
    now_date = now_date.strftime("%Y%m%d")
     
    #quotation_new_code_temp = QuotationMaterialHeader.all.maximum(:quotation_code)
    quotation_new_code_temp = QuotationMaterialHeader.where("LEFT(quotation_code,8) = ?", now_date).maximum(:quotation_code) 

    #
    #当日の日付になっていなければ、数をリセットさせる
    if quotation_new_code_temp.present? 
      quotation_date = quotation_new_code_temp[0, 8]
    else 
      quotation_date = ""
    end

    if quotation_date != now_date
      quotation_new_code_temp = now_date + "00"
    end
    #
  
    #最終番号に１を足す。
    newNum = quotation_new_code_temp.to_i + 1

    quotation_new_code = newNum.to_s
	 
    if quotation_new_code.present?
      @quotation_material_header.quotation_code = quotation_new_code
    end

  end
  
  # POST /quotation_material_headers
  # POST /quotation_material_headers.json
  def create
  
    @quotation_material_header = QuotationMaterialHeader.new(quotation_material_header_params)
   
    #備考１〜３のいずれかへセット
    set_notes_before_save
    
    #仕入先未登録の場合にセット
    set_supplier_before_save
   
    #パラーメータ補完＆メール送信する
    set_params_complement

    #連番を逆にする！！！
    #reverse_seq
    
    @quotation_material_header = QuotationMaterialHeader.new(quotation_material_header_params)
    
    #add230922
    #注文書を2回押した場合等、データ2重登録しないようにする
    get_data_on_create_twice
    
    #binding.pry
    
    respond_to do |format|
      if @quotation_material_header.save!(:validate => false)
        
        #比較表・ＦＡＸ
        if params[:quotation_material_header][:sent_flag] == "4"
          #見積比較表
          set_quotation_compare_pdf(format) 
        elsif params[:quotation_material_header][:sent_flag] == "5"
          #見積ＦＡＸ
          set_quotation_fax_pdf(format)
        elsif params[:quotation_material_header][:sent_flag] == "6"
          #注文ＦＡＸ
          set_quotation_order_fax_pdf(format)
        end
        #
        
        #見積依頼書・注文書の発行
        set_purchase_order_and_estimate(format)
                
        #メール送信する
        send_email
        
        #メール送信の場合、見積／注文書を後から発行する場合もあるため、画面遷移させない
        if params[:quotation_material_header][:sent_flag] == "1" || params[:quotation_material_header][:sent_flag] == "2"
          
          #redirect_to request.referer, alert: "Successfully sending message"  #ここでalertを適当に入れないと下部のflashメッセージが出ない。
          #redirect_to :back, alert: "Successfully sending message"  #ここでalertを適当に入れないと下部のflashメッセージが出ない。
          redirect_to edit_quotation_material_header_path(@quotation_material_header, :id => @quotation_material_header.id,
                                :construction_id => params[:construction_id] , :move_flag => params[:move_flag] ), 
                                alert: "Successfully sending message"
          
          flash[:notice] = "メールを送信しました。"
          
          break
        end
        #
		      
        format.html {redirect_to quotation_material_headers_path( @quotation_material_header,
                 :construction_id => params[:construction_id] , :move_flag => params[:move_flag] )}
		  else
        format.html { render :new }
        format.json { render json: @quotation_material_header.errors, status: :unprocessable_entity }
      end
    
    end
  end

  # PATCH/PUT /quotation_material_headers/1
  # PATCH/PUT /quotation_material_headers/1.json
  def update
     
	  if @quotation_material_header.quotation_code == params[:quotation_material_header][:quotation_code]
  
      #備考１〜３のいずれかへセット
      set_notes_before_save
	    
      #仕入先未登録の場合にセット
      set_supplier_before_save
    
      #すでに登録していた注文データは一旦抹消する。
	    destroy_before_update
	
      #パラーメータ補完＆メール送信する
      set_params_complement
      
      #binding.pry
      
      respond_to do |format|
        
        if @quotation_material_header.update(quotation_material_header_params)
        
          #比較表・ＦＡＸ
          if params[:quotation_material_header][:sent_flag] == "4"
            #見積比較表
            set_quotation_compare_pdf(format) 
          elsif params[:quotation_material_header][:sent_flag] == "5"
            #見積ＦＡＸ
            set_quotation_fax_pdf(format)
          elsif params[:quotation_material_header][:sent_flag] == "6"
            #注文ＦＡＸ
            set_quotation_order_fax_pdf(format)
          end
          #
          
          #見積依頼書・注文書の発行
          set_purchase_order_and_estimate(format)
          
          #メール送信
          send_email
		      
          #メール送信の場合、見積／注文書を後から発行する場合もあるため、画面遷移させない
          if params[:quotation_material_header][:sent_flag] == "1" || params[:quotation_material_header][:sent_flag] == "2"
            
            redirect_to request.referer, alert: "Successfully sending message"  #ここでalertを適当に入れないと下部のflashメッセージが出ない。
            flash[:notice] = "メールを送信しました。"
            
            break
          end
          #
          
          
          #format.html {redirect_to quotation_material_header_path( 
          #         :construction_id => params[:construction_id] , :move_flag => params[:move_flag] )}
          format.html {redirect_to quotation_material_headers_path( 
                   :construction_id => params[:construction_id] , :move_flag => params[:move_flag] )}
         
        else
          format.html { render :edit }
          format.json { render json: @quotation_material_header.errors, status: :unprocessable_entity }
        end
      end  #end do
    else
    #コードが新規コードの場合は、参照コードからの新規登録とみなす
      #
     create

    end
  end
  
  #add230922
  #注文書を2回押した場合等、データ2重登録しないようにする
  def get_data_on_create_twice
    tmp_header = QuotationMaterialHeader.where(quotation_code: params[:quotation_material_header][:quotation_code]).first
    
    if tmp_header.present?
      @quotation_material_header = tmp_header
      #すでに登録していた注文データは一旦抹消する。
      destroy_before_update
      #
      #@purchase_order_history.attributes = purchase_order_history_params
      @quotation_material_header.attributes = quotation_material_header_params
    end
  end
  
  def destroy_before_update
    #すでに登録していた注文データは一旦抹消する。
    quotation_material_header_id = @quotation_material_header.id
    QuotationMaterialDetail.where(quotation_material_header_id: quotation_material_header_id).destroy_all
  end
  
  # DELETE /quotation_material_headers/1
  # DELETE /quotation_material_headers/1.json
  def destroy
    @quotation_material_header.destroy
    respond_to do |format|
      format.html {redirect_to quotation_material_headers_path( :construction_id => params[:construction_id], 
         :move_flag => params[:move_flag])}
    end
  end

  
  def set_params_complement
    if params[:quotation_material_header][:construction_datum_id].nil?
      if params[:construction_id].present?
        params[:quotation_material_header][:construction_datum_id] = params[:construction_id]
      end
    end

    #変数に最終のパラメータをセットする
    #仕入先をセット
    if @quotation_material_header.present?
  
      if params[:construction_id].present?
        @quotation_material_header.construction_datum_id = params[:construction_id]
      end
  
      if params[:quotation_material_header][:supplier_master_id].present?
        @quotation_material_header.supplier_master_id = params[:quotation_material_header][:supplier_master_id]
      end
      #担当者をセット
      if params[:quotation_material_header][:responsible].present?
        @quotation_material_header.responsible = params[:quotation_material_header][:responsible]
      end
    end

    i = 0
   
    if params[:quotation_material_header][:quotation_material_details_attributes].present?
    
      params[:quotation_material_header][:quotation_material_details_attributes].values.each do |item|
      
        # 数値は全角入力の場合、半角に変換する
        if  item[:quantity].to_i == 0
          item[:quantity] = item[:quantity].tr('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z')
        end
      
        @maker_master = MakerMaster.where(:id => item[:maker_id]).first
          
        #メーカーを手入力した場合の新規登録
        if @maker_master.nil?
          #名称にID(カテゴリー名が入ってくる--やや強引？)をセット。
          maker_params = {maker_name: item[:maker_id] }
          @maker_master = MakerMaster.new(maker_params)
          @maker_master.save!(:validate => false)
                     
          if @maker_master.present?
            #メーカーIDを更新（パラメータ）
            item[:maker_id] = @maker_master.id
          end
        end
        #
          
        #あくまでもメール送信用のパラメータとしてのみ、メーカー名をセットしている
        if @maker_master.present?
          item[:maker_name] = @maker_master.maker_name
        end
    
        #分類手入力の場合の新規登録
        @material_category = MaterialCategory.where(:id => item[:material_category_id]).first
      
        if @material_category.nil?
          #名称にID(カテゴリー名が入ってくる--やや強引？)をセット。
          material_category_params = {name: item[:material_category_id] }
          @material_category = MaterialCategory.new(material_category_params)
          @material_category.save!(:validate => false)
                     
          if @material_category.present?
            #メーカーIDを更新（パラメータ）
            item[:material_category_id] = @material_category.id
          end
        end
        #
      
        id = item[:material_id].to_i
           
        #手入力以外なら、商品CD・IDをセットする。
        if id != 1 then
          @material_master = MaterialMaster.find(id)
          item[:material_code] = @material_master.material_code
              
          if item[:list_price].nil?  
            if @material_master.list_price != 0  
              #資材マスターの定価をセット
              #(マスター側未登録を考慮。但しアプデは考慮していない）
              item[:list_price] = @material_master.list_price
            end
          end
      
          if (item[:material_name] != @material_master.material_name) || 
                 (item[:maker_id] != @material_master.maker_id)  || 
                 (item[:list_price] != @material_master.list_price)  ||
                 (item[:notes] != @material_master.notes) ||
                 (item[:material_category_id] != @material_master.material_category_id) || 
                 (item[:unit_master_id] != @material_master.unit_id )
              #↑フィールド追加時注意！
              #マスター情報変更した場合は、商品マスターへ反映させる。
                
            materials = MaterialMaster.where(:id => @material_master.id).first
            if materials.present?
                #品名・メーカーID・定価・備考・分類を更新
                materials.update_attributes!(:material_name => item[:material_name], :maker_id => item[:maker_id], 
                                               :list_price => item[:list_price], :notes => item[:notes], 
                                               :material_category_id => item[:material_category_id], 
                                               :unit_id => item[:unit_master_id])
            end
          end
      
      
          #仕入単価マスターも更新する
          if params[:quotation_material_header][:supplier_master_id] != "1"   #手入力仕入先以外
            purchase_unit_price = PurchaseUnitPrice.where(["supplier_id = ? and material_id = ?", 
                   params[:quotation_material_header][:supplier_master_id], item[:material_id] ]).first
            
            if item[:unit_master_id].present?
              #単位は更新しない
              purchase_unit_price_params = {material_id: item[:material_id], supplier_id: params[:quotation_material_header][:supplier_master_id]}
             
              if purchase_unit_price.present?
                purchase_unit_price.update(purchase_unit_price_params)
              else
              #新規登録も考慮する。
                purchase_unit_price = PurchaseUnitPrice.create(purchase_unit_price_params)
              end
            end
          end
      
        else  #id != 1(else)
          #手入力した場合も、商品＆単価マスターへ新規登録する
          if item[:_destroy] != "1"
            if item[:material_code] != ""     #商品CD有りのものだけ登録する(バリデーションで引っかかるため)
              @material_master = MaterialMaster.find_by(material_code: item[:material_code])
              #商品マスターへセット(商品コード存在しない場合)
              if @material_master.nil?
                #単位追加
                material_master_params = {material_code: item[:material_code], material_name: item[:material_name], 
                                        maker_id: item[:maker_id], list_price: item[:list_price], notes: item[:notes],
                                        material_category_id: item[:material_category_id],
                                        unit_id: item[:unit_master_id] }
                                        
                @material_master = MaterialMaster.create(material_master_params)
              end
            
              #仕入先単価マスターへも登録。
              @material_master = MaterialMaster.find_by(material_code: item[:material_code])
              if @material_master.present?
                material_id = @material_master.id
                item[:material_id] = material_id  #資材マスターのIDも更新 add180508
                supplier_id = params[:quotation_material_header][:supplier_master_id]
                supplier_material_code = item[:material_code]
        
                if supplier_id.present? && ( supplier_id.to_i == $SUPPLIER_MASER_ID_OKADA_DENKI_SANGYO  || 
                                               supplier_id.to_i == $SUPPLIER_MASER_ID_OST)
                  #岡田・オストの場合のみ、品番のハイフンは抹消する
                  no_hyphen_code = supplier_material_code.delete('-')  
                  if no_hyphen_code.present?
                    supplier_material_code = no_hyphen_code
                  end
                end
        
                purchase_unit_price_params = {material_id: material_id, supplier_id: supplier_id, 
                                        supplier_material_code: supplier_material_code, unit_price: 0 ,
                                        unit_id: item[:unit_master_id]}
			          @purchase_unit_prices = PurchaseUnitPrice.create(purchase_unit_price_params)
                
              end
            end  #item[:material_code] != ""
          end    #item[:_destroy] != "1"
        end      #id != 1
      
        i = i + 1
    
      end #do end
    end   #params[:quotation_material_header]~present?
  end

  def send_email
   #メール送信する(メール送信ボタン押した場合)
     
    if params[:quotation_material_header][:sent_flag] == "1" || params[:quotation_material_header][:sent_flag] == "2" 
      #$detail_parameters = params[:quotation_material_header][:quotation_material_details_attributes]
      detail_parameters = params[:quotation_material_header][:quotation_material_details_attributes]
      
      if $seq_exists > 0
        #昇順になっている場合は、本来の降順にしておく。
        #$tmp_detail_parameters = Hash[$detail_parameters.sort.reverse]
        @detail_parameters = Hash[detail_parameters.sort.reverse]
      else
	      #$tmp_detail_parameters = $detail_parameters
        @detail_parameters = detail_parameters
	    end
    end
	   
    #備考(全体)をセット
    #$notes = nil
    @notes = nil
    if params[:quotation_material_header][:notes].present?
      #$notes = "※" + params[:quotation_material_header][:notes]
      @notes = "※" + params[:quotation_material_header][:notes]
    end
     
    #画面のメアドをグローバルへセット
    #$email_responsible = params[:quotation_material_header][:email]
     
    #担当者・Emailコンボ化による変更
    @supplier_update_flag = 0  # 1:new  2:upd
      
    #app.contollerで処理
    #担当者/Emailをメール送信用にセット・更新フラグをセット
    #upd230508
    @responsible, @email_responsible = app_set_responsible(params[:quotation_material_header][:responsible],
                                        params[:quotation_material_header][:email],
                                        params[:quotation_material_header][:supplier_master_id])
    
    #app_set_responsible(params[:quotation_material_header][:responsible],
    #                                    params[:quotation_material_header][:email],
    #                                    params[:quotation_material_header][:supplier_master_id])
    
    #CC用に担当者２のアドレスもグローバルへセット
    #$email_responsible2 = nil
    @email_responsible2 = nil
    if params[:quotation_material_header][:supplier_master_id].present?
      supplier = SupplierMaster.where(id: params[:quotation_material_header][:supplier_master_id]).first
         
      if supplier.present? && supplier.email_cc.present?
        #$email_responsible2 = supplier.email_cc
        @email_responsible2 = supplier.email_cc
      end
    end
     
    #仕入先（１〜３）の判定
    setSupplier
    
    mail_flag = false
    
    if params[:quotation_material_header][:sent_flag] == "1" then
    #見積メールの場合
      mail_flag = true
      #PostMailer.send_quotation_material(@quotation_material_header).deliver
      PostMailer.send_quotation_material(@quotation_material_header, @responsible, @email_responsible, 
                                            @email_responsible2, @notes, @attachment).deliver
    elsif params[:quotation_material_header][:sent_flag] == "2" then
    #注文メールの場合
      mail_flag = true
      #画面の注文Noをグローバルへセット（メール用）
      #$purchase_order_code = nil
      #$new_code_flag = false
      @purchase_order_code = nil
      @new_code_flag = false
      
      
      if params[:quotation_material_header][:purchase_order_code].present?
	      #$purchase_order_code = params[:quotation_material_header][:purchase_order_code]
        @purchase_order_code = params[:quotation_material_header][:purchase_order_code]
        
        #新規の注番ならフラグをつける
        #purchase_order_code = PurchaseOrderDatum.where(:purchase_order_code => $purchase_order_code).first
        purchase_order_code = PurchaseOrderDatum.where(:purchase_order_code => @purchase_order_code).first
        if purchase_order_code.nil?
          #$new_code_flag = true
          @new_code_flag = true
        end
        #
	    end
	   
      #PostMailer.send_order_after_quotation(@quotation_material_header).deliver
      PostMailer.send_order_after_quotation(@quotation_material_header, @responsible, @email_responsible, 
                                            @email_responsible2, @notes, @new_code_flag, @purchase_order_code,
                                            @supplier, @attachment).deliver
      
    end
	 
    #各種更新処理
    @update_supplier_flag = 0	

    if params[:quotation_material_header][:sent_flag] == "1" 
      #見積メールの場合
      #メールの各種送信フラグをセット（ヘッダ・見積比較用）
      set_quotation_mail_flag_for_comparison
    elsif params[:quotation_material_header][:sent_flag] == "2" 
      #メールの各種送信フラグをセット（ヘッダ・注文用）
      set_order_mail_flag_for_comparison
    end
   
    if params[:quotation_material_header][:sent_flag] == "1" || params[:quotation_material_header][:sent_flag] == "2" 
      if $seq_exists > 0
      #昇順(編集時)になっている場合は、明細パラメータを本来の降順にしておく。
        params[:quotation_material_header][:quotation_material_details_attributes] = 
          Hash[params[:quotation_material_header][:quotation_material_details_attributes].sort.reverse]
      end
  
      #メール送信フラグ(明細用)をセット＆データ更新
      set_mail_sent_flag
    end
  
    #仕入担当者の追加・更新
    if mail_flag  #誤更新の場合もあったため、メール送信時にのみ行う
      #app_update_responsible(params[:quotation_material_header][:supplier_master_id],
      #                     params[:quotation_material_header][:responsible], 0, 1)
      #upd230508
      app_update_responsible(params[:quotation_material_header][:supplier_master_id],
                           params[:quotation_material_header][:responsible], 0, 1, 
                           @responsible, @email_responsible)
    end
  
    if params[:quotation_material_header][:sent_flag] == "2" 
      #注文番号が新規の場合に、更新させる
      set_new_purchase_order_code
      #注文データの登録・更新
      set_purchase_order_history
    
    elsif params[:quotation_material_header][:sent_flag] == "1" 
      #見積の場合でも、担当者変更あり＆注文データがあれば担当者を更新
      purchase_order_data = PurchaseOrderDatum.where(:construction_datum_id => params[:quotation_material_header][:construction_datum_id]).
                                where(:supplier_master_id => params[:quotation_material_header][:supplier_master_id]).
                                where("id is NOT NULL").first
      
      if purchase_order_data.present?
        if @supplier_update_flag > 0
          purchase_order_data_params = { supplier_responsible_id: @supplier_responsible_id }
          purchase_order_data.update(purchase_order_data_params)
        end
      end
    end
	  
    #仕入先担当者(1~3)のパラメータも更新
    if mail_flag 
      set_quotation_responsible_for_comparison
    end
  end
  
  #見積依頼書・注文書の発行
  def set_purchase_order_and_estimate(format)
    
    check = false
    mail_flag = false
    
    #$request_type = 0
    request_type = 0
    
    if params[:quotation_material_header][:sent_flag] == "1" ||
       params[:quotation_material_header][:sent_flag] == "2"
    #メール送信した場合
      check = true
      mail_flag = true
      #$request_type = params[:quotation_material_header][:sent_flag].to_i  # 1 or 2
      request_type = params[:quotation_material_header][:sent_flag].to_i  # 1 or 2
    elsif params[:quotation_material_header][:sent_flag] == "7" ||
       params[:quotation_material_header][:sent_flag] == "8"
    #見積/注文書発行した場合
      check = true
      #$request_type = params[:quotation_material_header][:sent_flag].to_i - 6 # 1 or 2
      request_type = params[:quotation_material_header][:sent_flag].to_i - 6 # 1 or 2
    end
    
    #$attachment = nil
    @attachment = nil
    
    if check 
      if params[:format] == "pdf"
        #注文書の発行
        #save_only_flag = false
        #global set
        #$purchase_order_history = @purchase_order_history 
        #del230509
        #$quotation_material_header = @quotation_material_header 
        
        #$mail_flag = false
        
        #注文の場合
        #if params[:quotation_material_header][:sent_flag] == "8"
        #if $request_type == 2
        if request_type == 2
          #$purchase_order_code = params[:quotation_material_header][:purchase_order_code]
          purchase_order_code = params[:quotation_material_header][:purchase_order_code]
        end
        #仕入先（１〜３）の判定 "@supplier"にセットされる
        setSupplier
        
        #送信済み・削除判定が必要なので現在のパラメータをセット
        #$order_parameters = params[:purchase_order_history][:orders_attributes]
        detail_parameters = params[:quotation_material_header][:quotation_material_details_attributes]
	   
        if $seq_exists > 0
          #昇順になっている場合は、本来の降順にしておく。
	        #$detail_parameters = Hash[detail_parameters.sort.reverse]
          @detail_parameters = Hash[detail_parameters.sort.reverse]
        else
	        #$detail_parameters = detail_parameters
          @detail_parameters = detail_parameters
        end
        #
        
        if !mail_flag
          format.pdf do
            #report = PurchaseOrderAndEstimatePDF.create @purchase_order
            #report = PurchaseOrderAndEstimatePDF.create @quotation_material
            report = PurchaseOrderAndEstimatePDF.create(@quotation_material_header, @detail_parameters, 
                                                        @supplier, request_type, purchase_order_code, mail_flag)
            
            # ブラウザでPDFを表示する
            # disposition: "inline" によりダウンロードではなく表示させている
            send_data(
              report.generate,
              filename:  "estimate_request.pdf",
              type:        "application/pdf",
              disposition: "inline")
          end
        else
        #メール送信し添付する場合
          
          #$mail_flag = true
          #ＰＤＦを作成
          #report = PurchaseOrderAndEstimatePDF.create @purchase_order
          #report = PurchaseOrderAndEstimatePDF.create @quotation_material
          report = PurchaseOrderAndEstimatePDF.create(@quotation_material_header, @detail_parameters, 
                                                      @supplier, request_type, purchase_order_code, mail_flag)
            
          # PDFファイルのバイナリデータを生成する
          #$attachment = report.generate
          @attachment = report.generate
          
        end
    #  end
      end
    end  #check
  end
  
  #注文データに保存する
  def set_purchase_order_history
    purchase_order_date = params[:quotation_material_header][:requested_date]
    
    purchase_order_history = PurchaseOrderHistory.where(purchase_order_date: purchase_order_date, 
                                                        purchase_order_datum_id: @purchase_order_datum_id).first
    
    #create or update
    if purchase_order_history.blank?
    #新規
      
      #ex. mail_sent_flagは現在使用してないので、1のセットは不要かもしれない...
      purchase_order_history_params = { purchase_order_date: purchase_order_date, 
                                        supplier_master_id: params[:quotation_material_header][:supplier_master_id],
                                        purchase_order_datum_id: @purchase_order_datum_id, mail_sent_flag: 1,
                                        delivery_place_flag: params[:quotation_material_header][:delivery_place_flag]}
      
      @purchase_order_history = PurchaseOrderHistory.create(purchase_order_history_params)
      
    else
    #更新(そのまま)
      @purchase_order_history = purchase_order_history
    end
    
    ##
    #明細データもここで登録
    
    #すでに登録していた注文データは一旦抹消する。(見積注文のみ)
    #あとから追加注文の場合もあるので、二重登録のリスクはあるが、消せない.
    #Order.where(purchase_order_history_id: @purchase_order_history.id, quotation_flag: 1).destroy_all
    
    #$tmp_detail_parameters.values.each_with_index.reverse_each do |item, index|
    #$tmp_detail_parameters.values.each_with_index.each do |item, index|
    @detail_parameters.values.each_with_index.each do |item, index|
    
      #仕入先１〜３の判定
      order_unit_price = 0
      order_price = 0
      
      #case $supplier
      case @supplier
      when 1
        @bid_flag = item[:bid_flag_1].to_i
        order_unit_price = item[:quotation_unit_price_1].to_i
        order_price = item[:quotation_price_1].to_i
	    when 2
        @bid_flag = item[:bid_flag_2].to_i
        order_unit_price = item[:quotation_unit_price_2].to_i
        order_price = item[:quotation_price_2].to_i
	    when 3
	      @bid_flag = item[:bid_flag_3].to_i
        order_unit_price = item[:quotation_unit_price_3].to_i
        order_price = item[:quotation_price_3].to_i
	    end
      
      if item[:_destroy] != "1" && @bid_flag == 1
      
        purchase_order_history_id = @purchase_order_history.id
        material_id = item[:material_id]
        material_code = item[:material_code]
        material_name = item[:material_name]
        maker_id = item[:maker_id]
        maker_name = item[:maker_name]
        quantity = item[:quantity]
        unit_master_id = item[:unit_master_id]
        list_price = item[:list_price]
        #material_category_id = xxx フィールド無し
        #quotation_flag = 1  #見積フラグ
        mail_sent_flag = 1  #送信済みにする
        sequential_id = index + 1
        
        order_params = {purchase_order_history_id: purchase_order_history_id, material_id: material_id,
                      material_code: material_code, material_name: material_name, maker_id: maker_id, 
                      maker_name: maker_name, quantity: quantity, unit_master_id: unit_master_id,
                      order_unit_price: order_unit_price, order_price: order_price, 
                      list_price: list_price, mail_sent_flag: mail_sent_flag, 
                      sequential_id: sequential_id}
      
        @order = Order.where(["purchase_order_history_id = ? and sequential_id = ?", 
           purchase_order_history_id, sequential_id]).first
        if @order.present?  #上書き(メール異常等で再送信の場合もあり得るため)
          @order.update(order_params)
        else
          @order = Order.create(order_params)
        end
        
      end
    end  #loop end
  end
  
  #仕入先（１〜３）の判定
  def setSupplier
    #$supplier = 0
    @supplier = 0
  
    #仕入先判定
    if params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_1] 
      #仕入先１？
      #$supplier = 1
      @supplier = 1
    elsif params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_2]
      #仕入先２？
      #$supplier = 2
      @supplier = 2
    elsif params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_3]
      #仕入先３？
      #$supplier = 3
      @supplier = 3
    end
   
    #見積をせず、いきなり注文をする場合もあり得る？為、以下の判定も行う。
    #--但し、依頼先が４社以上になった場合は考慮しない
    if @supplier == 0
      if params[:quotation_material_header][:supplier_master_id].present?
        if params[:quotation_material_header][:supplier_id_1].blank?
          @supplier = 1
        elsif params[:quotation_material_header][:supplier_id_2].blank?
          @supplier = 2
        elsif params[:quotation_material_header][:supplier_id_3].blank?
          @supplier = 3
        end
      end
    end
  
  end
  
  #担当者を見積担当として埋め込む
  def set_quotation_responsible_for_comparison
    
    supplier_responsible_id_1 = @quotation_material_header.supplier_responsible_id_1
    supplier_responsible_id_2 = @quotation_material_header.supplier_responsible_id_2
    supplier_responsible_id_3 = @quotation_material_header.supplier_responsible_id_3
    
    if @update_supplier_flag == 1
      #仕入先１へセット
      #仕入先１がブランク又は、手入力や注文先行（？）などですでに仕入先１に入力がある場合。
      supplier_responsible_id_1 = @supplier_responsible_id
    elsif @update_supplier_flag == 2
      #仕入先２へセット
      supplier_responsible_id_2 = @supplier_responsible_id
    elsif @update_supplier_flag == 3
      #仕入先３へセット(仕入先１・２とも非該当の場合)
      supplier_responsible_id_3 = @supplier_responsible_id
    end
    
    if @update_supplier_flag > 0
      tmp_quotation_material_header_params = { supplier_responsible_id_1: supplier_responsible_id_1, 
                                               supplier_responsible_id_2: supplier_responsible_id_2, 
                                               supplier_responsible_id_3: supplier_responsible_id_3 }
      @quotation_material_header.update(tmp_quotation_material_header_params)
    end
  end
  
  #メールの各種送信フラグをセット（見積比較用として）
  def set_quotation_mail_flag_for_comparison
    
	  @update_supplier_flag = 0
    
    if params[:quotation_material_header][:supplier_id_1].blank?  ||
      params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_1]
      #仕入先１へセット
      #仕入先１がブランク又は、手入力や注文先行（？）などですでに仕入先１に入力がある場合。
      @update_supplier_flag = 1
      params[:quotation_material_header][:supplier_id_1] = params[:quotation_material_header][:supplier_master_id]
  	  params[:quotation_material_header][:quotation_email_flag_1] = 1
    else
      
      if params[:quotation_material_header][:supplier_id_2].blank?  || 
	       params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_2]
          #仕入先２へセット
        if params[:quotation_material_header][:supplier_master_id] != params[:quotation_material_header][:supplier_id_1] 
          @update_supplier_flag = 2
          params[:quotation_material_header][:supplier_id_2] = params[:quotation_material_header][:supplier_master_id]
          params[:quotation_material_header][:quotation_email_flag_2] = 1
        end
      else
        #仕入先３へセット(仕入先１・２とも非該当の場合)
        if params[:quotation_material_header][:supplier_master_id] != params[:quotation_material_header][:supplier_id_1] && 
           params[:quotation_material_header][:supplier_master_id] != params[:quotation_material_header][:supplier_id_2]
          
          @update_supplier_flag = 3
          params[:quotation_material_header][:supplier_id_3] = params[:quotation_material_header][:supplier_master_id]
          params[:quotation_material_header][:quotation_email_flag_3] = 1
        end
      end
    end
    
    #params[:quotation_material_header][:quotation_email_flag_1]
  #end
  end
  
  #メールの各種送信フラグをセット（注文用）
  def set_order_mail_flag_for_comparison
    
    @update_supplier_flag = 0
  
    if params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_1]
      #仕入先１へセット
      @update_supplier_flag = 1
      params[:quotation_material_header][:order_email_flag_1] = 1
    elsif params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_2]
      #仕入先２へセット
      @update_supplier_flag = 2
      params[:quotation_material_header][:order_email_flag_2] = 1
    elsif params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_3]
      #仕入先３へセット
      @update_supplier_flag = 3
      params[:quotation_material_header][:order_email_flag_3] = 1
    else
      #見積をせず、いきなり注文をする場合もあり得る？為、以下の判定も行う。
      if params[:quotation_material_header][:supplier_master_id].present?
        if params[:quotation_material_header][:supplier_id_1].blank?
          @update_supplier_flag = 1
          params[:quotation_material_header][:supplier_id_1] = params[:quotation_material_header][:supplier_master_id]
          params[:quotation_material_header][:order_email_flag_1] = 1
        elsif params[:quotation_material_header][:supplier_id_2].blank?
          @update_supplier_flag = 2
          params[:quotation_material_header][:supplier_id_2] = params[:quotation_material_header][:supplier_master_id]
          params[:quotation_material_header][:order_email_flag_2] = 1
        elsif params[:quotation_material_header][:supplier_id_3].blank?
          @update_supplier_flag = 3
          params[:quotation_material_header][:supplier_id_3] = params[:quotation_material_header][:supplier_master_id]
          params[:quotation_material_header][:order_email_flag_3] = 1
        end
      end
    end
  #
  end
  
  #レコード毎にメール送信済みフラグをセットする
  def set_mail_sent_flag
    if params[:quotation_material_header][:sent_flag] == "1" || params[:quotation_material_header][:sent_flag] == "2" 
      if params[:quotation_material_header][:quotation_material_details_attributes].present?
        
        params[:quotation_material_header][:quotation_material_details_attributes].values.each do |item|
        #ここは、仕入先別と見積・注文別のフラグをセット
        
          #case $supplier
          case @supplier
          when 1
          #仕入先１の場合
            if params[:quotation_material_header][:sent_flag] == "1"
              #見積依頼時
              item[:quotation_email_flag_1] = 1
            elsif params[:quotation_material_header][:sent_flag] == "2"
              #注文依頼時
              if item[:bid_flag_1] == "1"  #落札されている？
                item[:order_email_flag_1] = 1
              end
            end
          when 2
          #仕入先２の場合
            if params[:quotation_material_header][:sent_flag] == "1"
            #見積依頼時
              item[:quotation_email_flag_2] = 1
            elsif params[:quotation_material_header][:sent_flag] == "2"
            #注文依頼時
              if item[:bid_flag_2] == "1"  #落札されている？
                item[:order_email_flag_2] = 1
              end
            end
          when 3
            #仕入先３の場合
            if params[:quotation_material_header][:sent_flag] == "1"
            #見積依頼時
              item[:quotation_email_flag_3] = 1
            elsif params[:quotation_material_header][:sent_flag] == "2"
            #注文依頼時
              if item[:bid_flag_3] == "1"  #落札されている？
                item[:order_email_flag_3] = 1
              end
            end
          end
             
        end  #do end
  
        #再度ここで更新をかける(削除後)
        destroy_before_update
        @quotation_material_header.update(quotation_material_header_params)
      
      end  #params[:quotation_material_header][:quotation_material_details_attributes].present?
    end    #params[:quotation_material_header][:sent_flag]~present?
  end
  
  
  #注文番号が新規の場合に、更新させる
  def set_new_purchase_order_code
    
    purchase_order_code = PurchaseOrderDatum.where(:construction_datum_id => params[:quotation_material_header][:construction_datum_id]).
           where(:supplier_master_id => params[:quotation_material_header][:supplier_master_id]).
           where("id is NOT NULL").pluck(:purchase_order_code).flatten.join(" ")

    #履歴保存用
    tmp_purchase_order_data = PurchaseOrderDatum.where(:construction_datum_id => params[:quotation_material_header][:construction_datum_id]).
                                where(:supplier_master_id => params[:quotation_material_header][:supplier_master_id]).
                                where("id is NOT NULL").first
    @purchase_order_datum_id = nil
    if tmp_purchase_order_data.present?
      @purchase_order_datum_id = tmp_purchase_order_data.id
    end
    #
    
    if purchase_order_code.blank?
      
      #定数ファイルへ頭文字のアルファベットも保存
      @constant = Constant.find(1)   #id=１に定数ファイルが保管されている
    
      if @constant.present?
        tmp_code = params[:quotation_material_header][:purchase_order_code] 
    
        if tmp_code.present?
          #header = tmp_code[0, 1]
          
          #新コードの年(Axx)が最終コード以上の場合のみ更新。(古い年でテストするケースもあるため）
          new_year = tmp_code[1,2].to_i
          current_year = @constant.purchase_order_last_header_code[1,2].to_i
          
          update_flag = false
          
          if new_year > current_year   
            update_flag = true
          else
            #注文コード下２桁でも比較
            if tmp_code[3,2].to_i >=
              @constant.purchase_order_last_header_code[3,2].to_i 
              update_flag = true
            
            elsif tmp_code[1,2] == @constant.purchase_order_last_header_code[1,2]
              #年代が同じ場合で、アルファベットが上回った場合も更新
              if tmp_code[0,1].ord >
                @constant.purchase_order_last_header_code[0,1].ord 
                update_flag = true
              end
            end
            
            #以下は未検証で保留(起こり得ない....)
            #(先頭３桁が同じ場合)  upd220115
            #if tmp_code[0,3] == @constant.purchase_order_last_header_code[0,3]
            #  if tmp_code[3,2].to_i >=
            #    @constant.purchase_order_last_header_code[3,2].to_i 
            #    update_flag = true
            #  end
            #end
            
          end
          
          if update_flag
            constant_params = { purchase_order_last_header_code: tmp_code}
            @constant.update(constant_params)
          end
          
        end  #tmp_code.present?
      end    #@constant.present?
      #
    
      construction_name = ConstructionDatum.where(:id => params[:quotation_material_header][:construction_datum_id]).
           where("id is NOT NULL").pluck(:construction_name).flatten.join(" ")
  
      purchase_order_data_params = { purchase_order_code:  params[:quotation_material_header][:purchase_order_code], 
                                   construction_datum_id:  params[:quotation_material_header][:construction_datum_id], 
                                   supplier_master_id: params[:quotation_material_header][:supplier_master_id], 
                                   supplier_responsible_id: @supplier_responsible_id,
                                   alias_name: construction_name, 
                                   purchase_order_date:  params[:quotation_material_header][:requested_date] }
      
      @purchase_order_data = PurchaseOrderDatum.create(purchase_order_data_params)
      @purchase_order_datum_id = @purchase_order_data.id
    else
      
      #新規・更新フラグ(担当者変更)があれば更新する
      if @supplier_update_flag > 0
        purchase_order_data_params = { supplier_responsible_id: @supplier_responsible_id }
        tmp_purchase_order_data.update(purchase_order_data_params)
      end
    end
	
  end

  #保存前に、選択した仕入先をセット
  def set_supplier_before_save
    
    supplier_set = false
    
    if params[:quotation_material_header][:supplier_master_id] != "1" && 
       !params[:quotation_material_header][:supplier_master_id].blank?
    #画面左上の仕入先が選択されていたらor１以外
    
       #既存ならそのまま
      if params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_1] || 
          params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_2] ||
          params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_3]
         
        supplier_set = true
      end
    
      #仕入先１
      if !supplier_set
        if params[:quotation_material_header][:supplier_id_1].blank?
          if params[:quotation_material_header][:supplier_master_id] != params[:quotation_material_header][:supplier_id_1]
            supplier_set = true
            params[:quotation_material_header][:supplier_id_1] = params[:quotation_material_header][:supplier_master_id]
          end
        end
      end
    
      #仕入先２
      if !supplier_set
        if params[:quotation_material_header][:supplier_id_2].blank?
	        if params[:quotation_material_header][:supplier_master_id] != params[:quotation_material_header][:supplier_id_2]
            supplier_set = true
            params[:quotation_material_header][:supplier_id_2] = params[:quotation_material_header][:supplier_master_id]
          end
        end 
      end
      #仕入先３
      if !supplier_set
        if params[:quotation_material_header][:supplier_id_3].blank?
          if params[:quotation_material_header][:supplier_master_id] != params[:quotation_material_header][:supplier_id_3]
            supplier_set = true
            params[:quotation_material_header][:supplier_id_3] = params[:quotation_material_header][:supplier_master_id]
          end
        end 
      end
      
    end  #params[:quotation_material_header][:supplier_master_id] != "1"~
    
  end

  #保存前に、備考１〜３のいずれかへセット
  def set_notes_before_save
    
    #
    exist = false
    
    if params[:quotation_material_header][:supplier_id_1].present?
      if params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_1]
        #exist = true 
        params[:quotation_material_header][:notes_1] = params[:quotation_material_header][:notes]
      end
    end 
    
    if params[:quotation_material_header][:supplier_id_2].present?
      if params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_2]
        #exist = true 
        params[:quotation_material_header][:notes_2] = params[:quotation_material_header][:notes]
      end
    end
    if params[:quotation_material_header][:supplier_id_3].present?
      if params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_3]
        #exist = true 
        params[:quotation_material_header][:notes_3] = params[:quotation_material_header][:notes]
      end
    end
    #end

  end


  # ajax
  def email_select
    
    @email = SupplierMaster.where(:id => params[:supplier_id]).where("id is NOT NULL").pluck(:email1).flatten.join(" ")
	  @responsible = SupplierMaster.where(:id => params[:supplier_id]).where("id is NOT NULL").pluck(:responsible1).flatten.join(" ")
	  
    purchase_order_data = PurchaseOrderDatum.where(:supplier_master_id => params[:supplier_id]).
                               where(:construction_datum_id => params[:construction_id]).first
    
    if purchase_order_data.present?
      
      #
      @supplier_responsibles = SupplierResponsible.where(:id => purchase_order_data.supplier_responsible_id).
               pluck("responsible_name, id")
      
      @supplier_responsibles += SupplierResponsible.where(:supplier_master_id => params[:supplier_id]).
                                               where.not(:id => purchase_order_data.supplier_responsible_id).
                                            pluck("responsible_name, id")
      #
      #email
      @supplier_responsible_emails = SupplierResponsible.where(:id => purchase_order_data.supplier_responsible_id).
               pluck("responsible_email, id")
      
      @supplier_responsible_emails += SupplierResponsible.where(:supplier_master_id => params[:supplier_id]).
                                               where.not(:id => purchase_order_data.supplier_responsible_id).
                                            pluck("responsible_email, id")
      #
    else
      
      #見積データ存在する場合
      quotation_material_header = QuotationMaterialHeader.where(:id => params[:id]).first
      supplier_responsible_id = 0
      
      if params[:supplier_id_1].present? && (params[:supplier_id] == params[:supplier_id_1])
        #responsibleと照合
        supplier_responsible_id = quotation_material_header.supplier_responsible_id_1
      elsif params[:supplier_id_2].present? && (params[:supplier_id] == params[:supplier_id_2])
        supplier_responsible_id = quotation_material_header.supplier_responsible_id_2
      elsif params[:supplier_id_3].present? && (params[:supplier_id] == params[:supplier_id_3])
        supplier_responsible_id = quotation_material_header.supplier_responsible_id_3
      end
      
      if supplier_responsible_id > 0
        
        #
        @supplier_responsibles = SupplierResponsible.where(:id => supplier_responsible_id).
               pluck("responsible_name, id")
      
        @supplier_responsibles += SupplierResponsible.where(:supplier_master_id => params[:supplier_id]).
                                               where.not(:id => supplier_responsible_id).
                                            pluck("responsible_name, id")
        #
        #email
        @supplier_responsible_emails = SupplierResponsible.where(:id => supplier_responsible_id).
               pluck("responsible_email, id")
      
        @supplier_responsible_emails += SupplierResponsible.where(:supplier_master_id => params[:supplier_id]).
                                               where.not(:id => supplier_responsible_id).
                                          pluck("responsible_email, id")
      else
      #該当なし => all
        @supplier_responsibles = SupplierResponsible.where(:supplier_master_id => params[:supplier_id]).
                                               pluck("responsible_name, id")
        @supplier_responsible_emails = SupplierResponsible.where(:supplier_master_id => params[:supplier_id]).
                                               pluck("responsible_email, id")
      end
    end
    #
    
    quotation_material_header = QuotationMaterialHeader.where(params[:id]).first
   
    exist = false
   
    if params[:supplier_id_1].present?
      if params[:supplier_id] == params[:supplier_id_1]
        
        #備考をセット
        if quotation_material_header.present?
          @notes = quotation_material_header.notes_1
        end
        
        if params[:quotation_email_flag_1] == "true" 
          exist = true 
        end
      end
    end 
    if params[:supplier_id_2].present?
      if params[:supplier_id] == params[:supplier_id_2]
         
         #備考をセット
         if quotation_material_header.present?
           @notes = quotation_material_header.notes_2
         end
         
         if params[:quotation_email_flag_2] == "true"
           exist = true 
         end
      end
    end
    if params[:supplier_id_3].present?
      #備考をセット
      if quotation_material_header.present?
        @notes = quotation_material_header.notes_3
      end
       
      if params[:supplier_id] == params[:supplier_id_3]
        if params[:quotation_email_flag_3] == "true" 
          exist = true 
        end
      end
    end
     
    #not yet
    #該当なし---業者１として扱う
    #if exist == false
    #end
     
    @quotation_email_flag = exist
     
    #if exist == true
    #  @quotation_email_flag = 1
    #else 
    #  @quotation_email_flag = 0
    #end 
  end

  def set_sequence
    
    if $seq.blank?
      $seq = 0
    end

    #if $seq_exists == 0
    if session[:seq_exists] == 0  #upd231006
    #降順とみなす
      @sort_order = "DESC"
    else
    #昇順とみなす
      @sort_order = "ASC"
    end

    #@form_detail_order

    #すでに登録済みのアイテムがあった場合
    if $seq_max > 0 && $seq == 0
      $seq = $seq_max 
    end

    $seq += 1

  end
 
  
  #ajax
  def get_purchase_order_code
     
    if params[:supplier_master_id].present? && params[:supplier_master_id].to_i > 1
  
       #まず既存の注文コードがあれば、セット。
	    @purchase_order_code = PurchaseOrderDatum.where(:construction_datum_id => params[:construction_datum_id]).
           where(:supplier_master_id => params[:supplier_master_id]).
           where("id is NOT NULL").pluck(:purchase_order_code).flatten.join(" ")

      #
       
      if @purchase_order_code.blank?
	      #既存のものがなければ新規にコード生成する。
        if @last_header_number.blank?
	         @last_header_number = Constant.where(:id => 1).
             where("id is NOT NULL").pluck(:purchase_order_last_header_code).flatten.join(" ")
        end
     
        @last_header_number = @last_header_number[0,1]   #下記の判定用に1文字だけ抜き取る
     
        #crescent = "%" + params[:last_header_number] + "%"
        crescent = "%" + @last_header_number + "%"
       
        @purchase_order_code = PurchaseOrderDatum.where('purchase_order_code LIKE ?', crescent).all.maximum(:purchase_order_code) 
         
        #最終番号に１を足す。
        newStr = @purchase_order_code[1, 4]
        header = @purchase_order_code[0, 1]
	      newNum = newStr.to_i + 1
	     
        #アルファベットの最終の場合は、繰り上げる
        if @purchase_order_code[3, 2].to_i == 99
          newNum = @purchase_order_code[1, 2] + "00"
          header = (header.ord + 1).chr
        end
       
        #新年になるタイミングの切り替えは考慮していない...
        @purchase_order_code = header + newNum.to_s
      end
      #
    end  #params[:supplier_master_id].present?~
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quotation_material_header
      @quotation_material_header = QuotationMaterialHeader.find(params[:id])
    end
    
    #サブフォームの描写速度を上げるため、メモリへ貯める
    def set_masters
      @material_masters = MaterialMaster.all
      @unit_masters = UnitMaster.all
      @maker_masters = MakerMaster.all
    
      #@seq = 0 #画面の連番用
    end
	
    # Never trust parameters from the scary internet, only allow the white list through.
    def quotation_material_header_params
      #230926 sequential_id追加..ソート狂うのはこれが原因??
      params.require(:quotation_material_header).permit(:quotation_code, :quotation_header_origin_id, :requested_date, :construction_datum_id, 
                     :supplier_master_id, :responsible, :email, :delivery_place_flag, :notes_1, :notes_2, :notes_3,
                     :total_quotation_price_1, :total_quotation_price_2, :total_quotation_price_3,
                     :total_order_price_1, :total_order_price_2, :total_order_price_3,
                     :supplier_id_1, :supplier_id_2, :supplier_id_3,
                     :supplier_responsible_id_1, :supplier_responsible_id_2, :supplier_responsible_id_3,
                     :quotation_email_flag_1, 
                     :quotation_email_flag_2, :quotation_email_flag_3, :order_email_flag_1, :order_email_flag_2, :order_email_flag_3, 
                      quotation_material_details_attributes: [:id, :material_id, :material_code, :material_name, :maker_id, :maker_name, 
                      :quantity, :unit_master_id, :list_price, :quotation_unit_price_1, :quotation_unit_price_2, :quotation_unit_price_3, 
                      :quotation_price_1, :quotation_price_2, :quotation_price_3, 
                      :bid_flag_1, :bid_flag_2, :bid_flag_3, :mail_sent_flag, :quotation_email_flag_1, :quotation_email_flag_2, 
                      :quotation_email_flag_3, :order_email_flag_1, :order_email_flag_2, :order_email_flag_3, :sequential_id, 
                      :_destroy])
        
    end
end
