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
	if params[:pdf_id].present?
	#  @quotation_material_header = QuotationMaterialHeader.find(params[:pdf_id])
	  
	#  $quotation_material_header = @quotation_material_header
    
    #  respond_to do |format|
    #    format.html
    #    format.pdf do
    #      report = BidComparisonListPDF.create @bid_comparison_list 
        
    #      # ブラウザでPDFを表示する
    #      # disposition: "inline" によりダウンロードではなく表示させている
    #      send_data(
    #        report.generate,
    #        filename:  "bid_comparison_list.pdf",
    #        type:        "application/pdf",
    #        disposition: "inline")
    #    end
    #  end
	#  #~~~
	end
	
	
	
  end
  
  #pdf発行
  def set_pdf(format)
    #if params[:quotation_material_header][:sent_flag] == "3" then
      
  	  
	  $quotation_material_header = @quotation_material_header
    
        format.pdf do
          report = BidComparisonListPDF.create @bid_comparison_list 
        
          # ブラウザでPDFを表示する
          # disposition: "inline" によりダウンロードではなく表示させている
          send_data report.generate,
		      filename:    "見積比較表.pdf",
              type:        "application/pdf",
              disposition: "inline"
		  
		  #send_data(
          #  report.generate,
          #  filename:  "bid_comparison_list.pdf",
          #  type:        "application/pdf",
          #  disposition: "inline")
        end
	#end
  end


  # GET /quotation_material_headers/1
  # GET /quotation_material_headers/1.json
  def show
  end

  # GET /quotation_material_headers/new
  def new
    
	#画面の並びは昇順にする
	#新規は昇順、編集は降順。
	#add171024
	@form_detail_order = "sequential_id ASC"
	
	
	#コード参照元がある場合、セットする。
	if $quotation_material_header.present?
	  
	  #レコード毎のメール送信済みフラグを初期化するためのフラグをセット
	  $new_flag = 1
	  
	  @quotation_material_header = $quotation_material_header

      #連番の最大値を取る(フォーム用)
	  get_max_seq

      #@quotation_material_header.quotation_material_details = 
	  #    $quotation_material_header.quotation_material_details.dup
	  
	  ###新規作成用なので、不要なパラメータはリセットする。
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
	  
	 # binding.pry
  end

  # GET /quotation_material_headers/1/edit
  def edit
    #画面の並びは昇順にする
	#新規は昇順、編集は降順。
	#add171024
	@form_detail_order = "sequential_id DESC"
	
    $new_flag = 0
    
	#レコード毎のメール送信済みフラグを初期化するためのフラグをセット(一時用)
	reset_mail_sent_flag
	
	#連番の最大値を取る(フォーム用)
	 get_max_seq
	 
	 #注文NOの頭文字を定数ファイルから取得する
	 #add171023
	 @last_header_number = Constant.where(:id => 1).
           where("id is NOT NULL").pluck(:purchase_order_last_header_code).flatten.join(" ")
	 
  end
  
  def reset_mail_sent_flag
    
	exist_flag = false
	
	#binding.pry
	
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
	  #仕入先３で送信済？→未検証、未設定。
      end
	end
	
	#binding.pry
	
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
		##
  
  end
  
  
  #連番が登録と逆順になっているので、みやすいように正しい順に（逆に）する
  #うまくいかないため、現在未使用
  def reverse_seq
    #連番を割り振る処理
	@details = nil
	if @quotation_material_header.quotation_material_details.present?
	  @details = @quotation_material_header.quotation_material_details
	end
		
	if  @details.present?
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
		  #binding.pry
		  if @details[num].present?
			@quotation_material_header.quotation_material_details[num][:sequential_id] = reverse_num
		    reverse_num -= 1
		  end
		end
		
	  end
      
    #end
    end
    ##
  end
  
   
  
  #既存のデータを取得する(日付・仕入先指定後。)
  def get_data
     #
	 $quotation_material_header = QuotationMaterialHeader.find(params[:quotation_header_origin_id])
  end
  
  
  #商品名などを取得
  def material_select
  
     @material_code = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_code).flatten.join(" ")
	 @material_name = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_name).flatten.join(" ")
	 @list_price = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:list_price).flatten.join(" ")
     @maker_id = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:maker_id).flatten.join(" ")
	 
	 @unit_id = PurchaseUnitPrice.where(["supplier_id = ? and material_id = ?", 
                 params[:supplier_master_id], params[:id] ]).pluck(:unit_id).flatten.join(" ")
	 #add170914 該当なければひとまず”個”にする
	 if @unit_id.blank?
	   @unit_id = "3"
	 end
     
     #add180509
     @notes = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:notes).flatten.join(" ")
  end
  
  #見積コードの最終番号(+1)を取得する
  def get_last_quotation_code_select
     
	 #当日を取得
	 require 'date'
     now_date =Date.today.to_time
	 now_date = now_date.strftime("%Y%m%d")
     
	 
	 #quotation_new_code_temp = QuotationMaterialHeader.all.maximum(:quotation_code)
     quotation_new_code_temp = QuotationMaterialHeader.where("LEFT(quotation_code,8) = ?", now_date).maximum(:quotation_code) 
	 
	 #binding.pry
	 
	 ###
	 #当日の日付になっていなければ、数をリセットさせる
	 if quotation_new_code_temp.present? 
       quotation_date = quotation_new_code_temp[0, 8]
	 else 
       quotation_date = ""
     end
	 
	 
	 if quotation_date != now_date
	   quotation_new_code_temp = now_date + "00"
	 end
	 
	 ###
	 
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
   
    #add180928
    #備考１〜３のいずれかへセット
    set_notes_before_save
    
    #add190422
    #仕入先未登録の場合にセット
    set_supplier_before_save
   
    #パラーメータ補完＆メール送信する
    set_params_complement

    #連番を逆にする！！！
    #reverse_seq

    @quotation_material_header = QuotationMaterialHeader.new(quotation_material_header_params)

    #170911 moved
    #メール送信済みフラグをセット
	  #set_mail_sent_flag 
	
    respond_to do |format|
      #if @quotation_material_header.save
	    if @quotation_material_header.save!(:validate => false)
        
		    #upd170911
		    #メール送信する
		    send_email
		
		    if params[:format] == "pdf"  
		    #pdf発行
          set_pdf(format)
		    else
	  	  #通常の更新の場合
		      format.html {redirect_to quotation_material_header_path( @quotation_material_header,
                 :construction_id => params[:construction_id] , :move_flag => params[:move_flag] )}
		    end
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
	  
      #add180928
      #備考１〜３のいずれかへセット
      set_notes_before_save
	    
      #仕入先未登録の場合にセット
      set_supplier_before_save
    
      #すでに登録していた注文データは一旦抹消する。
	    destroy_before_update
	
      #パラーメータ補完＆メール送信する
      set_params_complement
      
	    #del170911
	    #メール送信済みフラグをセット
	    #set_mail_sent_flag
	  
      respond_to do |format|
        if @quotation_material_header.update(quotation_material_header_params)
        
		      #メール送信する
		      send_email
		  
		      if params[:format] == "pdf"  
		      #pdf発行
            set_pdf(format) 
		
		      else
		      #通常の更新の場合
            format.html {redirect_to quotation_material_header_path( 
                   :construction_id => params[:construction_id] , :move_flag => params[:move_flag] )}
				   
		      end
	      
		  #format.json { render :show, status: :ok, location: @quotation_material_header }
		  
		  
		  #format.html { redirect_to @quotation_material_header, notice: 'Quotation material header was successfully updated.' }
          #format.json { render :show, status: :ok, location: @quotation_material_header }
        else
          format.html { render :edit }
          format.json { render json: @quotation_material_header.errors, status: :unprocessable_entity }
        end
      end
	  else
	  #コードが新規コードの場合は、参照コードからの新規登録とみなす
      ####
	    create

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
	
      #format.html {redirect_to quotation_material_header_path( @quotation_material_header,
      #             :construction_id => params[:construction_id] , :move_flag => params[:move_flag] )}
	  #format.html { redirect_to quotation_material_headers_url, notice: 'Quotation material header was successfully destroyed.' }
      #format.json { head :no_content }
    end
  end

  
  def set_params_complement
    
	  if params[:quotation_material_header][:construction_datum_id].nil?
	    if params[:construction_id].present?
	      params[:quotation_material_header][:construction_datum_id] = params[:construction_id]
	    end
	  end
	
	  ##変数に最終のパラメータをセットする！！
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
	
	#binding.pry
	
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
      ####
          
      #あくまでもメール送信用のパラメータとしてのみ、メーカー名をセットしている
		  if @maker_master.present?
        item[:maker_name] = @maker_master.maker_name
      end
		  
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
                 (item[:notes] != @material_master.notes)
			    #↑フィールド追加時注意！
              #マスター情報変更した場合は、商品マスターへ反映させる。
                
			    materials = MaterialMaster.where(:id => @material_master.id).first
			    if materials.present?
                  #品名・メーカーID・定価・備考を更新
                  materials.update_attributes!(:material_name => item[:material_name], :maker_id => item[:maker_id], 
                                               :list_price => item[:list_price], :notes => item[:notes])
           end 
			  end
			  
			  
			  #仕入単価マスターの単位も更新する
			  if params[:quotation_material_header][:supplier_master_id] != "1"   #手入力仕入先以外
			    purchase_unit_price = PurchaseUnitPrice.where(["supplier_id = ? and material_id = ?", 
                   params[:quotation_material_header][:supplier_master_id], item[:material_id] ]).first
			  
			     if item[:unit_master_id].present?
			       purchase_unit_price_params = {material_id: item[:material_id], supplier_id: params[:quotation_material_header][:supplier_master_id], 
			                                     unit_id: item[:unit_master_id]}
				     if purchase_unit_price.present?
			         purchase_unit_price.update(purchase_unit_price_params)
				     else
				     #新規登録も考慮する。
			         purchase_unit_price = PurchaseUnitPrice.create(purchase_unit_price_params)
				     end
			  	 end
			  end
		
      else
		  #手入力した場合も、商品＆単価マスターへ新規登録する
		    if item[:_destroy] != "1"
			
			  
			  #if params[:material_code][i] != ""     #商品CD有りのものだけ登録する(バリデーションで引っかかるため)
			    if item[:material_code] != ""     #商品CD有りのものだけ登録する(バリデーションで引っかかるため)
			    
				    @material_master = MaterialMaster.find_by(material_code: item[:material_code])
			      #商品マスターへセット(商品コード存在しない場合)
			      if @material_master.nil?
				      material_master_params = {material_code: item[:material_code], material_name: item[:material_name], 
                                        maker_id: item[:maker_id], list_price: item[:list_price], :notes => item[:notes] }
                                        
			        @material_master = MaterialMaster.create(material_master_params)
			      end
			  
                #仕入先単価マスターへも登録。
              @material_master = MaterialMaster.find_by(material_code: item[:material_code])
			      if @material_master.present?
			        material_id = @material_master.id
                  
              item[:material_id] = material_id  #資材マスターのIDも更新 add180508
                  
				      supplier_id = params[:quotation_material_header][:supplier_master_id]
				  
				      supplier_material_code = item[:material_code]
				  
				      if supplier_id.present? && ( supplier_id.to_i == $SUPPLIER_MASER_ID_OKADA_DENKI_SANGYO )
				      #岡田電気の場合のみ、品番のハイフンは抹消する
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
			    end
			  
			  end
			
		    
		  end 
		  
		    i = i + 1
		   
		  end # do end

        #del170911
	    ##メール送信する(メール送信ボタン押した場合)
        #if params[:quotation_material_header][:sent_flag] == "1" then
	  	#  $detail_parameters = params[:quotation_material_header][:quotation_material_details_attributes]
        #  #画面のメアドをグローバルへセット
        #  $email_responsible = params[:quotation_material_header][:email]
		#  PostMailer.send_quotation_material(@quotation_material_header).deliver
        #end

    end  
  end

  def send_email
   #メール送信する(メール送信ボタン押した場合)
     
	 if params[:quotation_material_header][:sent_flag] == "1" || params[:quotation_material_header][:sent_flag] == "2" 
	   $detail_parameters = params[:quotation_material_header][:quotation_material_details_attributes]
	   
	   if $seq_exists > 0
	     #昇順になっている場合は、本来の降順にしておく。
	     $tmp_detail_parameters = Hash[$detail_parameters.sort.reverse]
	   else
	     $tmp_detail_parameters = $detail_parameters
	   end
	 end
	   
     #add181002
     #備考(全体)をセット
     $notes = nil
     if params[:quotation_material_header][:notes].present?
       $notes = "※" + params[:quotation_material_header][:notes]
     end
     
     #画面のメアドをグローバルへセット
     $email_responsible = params[:quotation_material_header][:email]
     
     #add180405
     #CC用に担当者２のアドレスもグローバルへセット
     $email_responsible2 = nil
     if params[:quotation_material_header][:supplier_master_id].present?
       supplier = SupplierMaster.where(id: params[:quotation_material_header][:supplier_master_id]).first
         
       if supplier.present? && supplier.email2.present?
         $email_responsible2 = supplier.email2
       end
     end
     #add end
     
     #仕入先（１〜３）の判定
     setSupplier

	 
	 if params[:quotation_material_header][:sent_flag] == "1" then
	 #見積メールの場合
	   
	   PostMailer.send_quotation_material(@quotation_material_header).deliver
	 
	   
	 elsif params[:quotation_material_header][:sent_flag] == "2" then
	 #注文メールの場合
	   
	   #画面の注文Noをグローバルへセット（メール用）
	   $purchase_order_code = nil
	   if params[:quotation_material_header][:purchase_order_code].present?
	     $purchase_order_code = params[:quotation_material_header][:purchase_order_code]
	   end
	   
	   PostMailer.send_order_after_quotation(@quotation_material_header).deliver
	   
	   
	end
	 
  #各種更新処理
	
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
	     #if params[:quotation_material_header][:quotation_email_flag_1] == 0 && params[:quotation_material_header][:order_email_flag_1] == 0
		   params[:quotation_material_header][:quotation_material_details_attributes] = 
	        Hash[params[:quotation_material_header][:quotation_material_details_attributes].sort.reverse]
		 #end
	   end
	   
       #メール送信フラグ(明細用)をセット＆データ更新
       set_mail_sent_flag
	end
	
	if params[:quotation_material_header][:sent_flag] == "2" 
	#注文番号が新規の場合に、更新させる
      set_new_purchase_order_code
    end
	 
  end
  
  #仕入先（１〜３）の判定
  def setSupplier
    $supplier = 0
	   
	#仕入先判定
	if params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_1] 
	#仕入先１？
	  $supplier = 1
	elsif params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_2]
	#仕入先２？
	  $supplier = 2
	elsif params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_3]
	 #仕入先３？
	  $supplier = 3
	end
	   
	#見積をせず、いきなり注文をする場合もあり得る？為、以下の判定も行う。
	#--但し、依頼先が４社以上になった場合は考慮しない
	if $supplier == 0
	  if params[:quotation_material_header][:supplier_master_id].present?
		if params[:quotation_material_header][:supplier_id_1].blank?
	      $supplier = 1
		elsif params[:quotation_material_header][:supplier_id_2].blank?
		  $supplier = 2
		elsif params[:quotation_material_header][:supplier_id_3].blank?
		  $supplier = 3
		end
	  end
	end
  
  end
  
  #メールの各種送信フラグをセット（見積比較用として）
  def set_quotation_mail_flag_for_comparison
    
	
	  if params[:quotation_material_header][:supplier_id_1].blank?  ||
	   params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_1]
      #if params[:quotation_material_header][:supplier_id_1].blank?
	  #仕入先１へセット
	  #仕入先１がブランク又は、手入力や注文先行（？）などですでに仕入先１に入力がある場合。
	    params[:quotation_material_header][:supplier_id_1] = params[:quotation_material_header][:supplier_master_id]
		params[:quotation_material_header][:quotation_email_flag_1] = 1
	  else
	    
		#if params[:quotation_material_header][:supplier_id_2].blank?
	    if params[:quotation_material_header][:supplier_id_2].blank?  || 
	       params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_2]
          #仕入先２へセット
          if params[:quotation_material_header][:supplier_master_id] != params[:quotation_material_header][:supplier_id_1] 
		    params[:quotation_material_header][:supplier_id_2] = params[:quotation_material_header][:supplier_master_id]
		    params[:quotation_material_header][:quotation_email_flag_2] = 1
		  end
		else
		  #仕入先３へセット(仕入先１・２とも非該当の場合)
		  if params[:quotation_material_header][:supplier_master_id] != params[:quotation_material_header][:supplier_id_1] && 
		     params[:quotation_material_header][:supplier_master_id] != params[:quotation_material_header][:supplier_id_2]
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
    if params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_1]
      #仕入先１へセット
	  params[:quotation_material_header][:order_email_flag_1] = 1
	elsif params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_2]
	  #仕入先２へセット
	  params[:quotation_material_header][:order_email_flag_2] = 1
    elsif params[:quotation_material_header][:supplier_master_id] == params[:quotation_material_header][:supplier_id_3]
	  #仕入先３へセット
      params[:quotation_material_header][:order_email_flag_3] = 1
	else
	
	#見積をせず、いきなり注文をする場合もあり得る？為、以下の判定も行う。
	  if params[:quotation_material_header][:supplier_master_id].present?
	    if params[:quotation_material_header][:supplier_id_1].blank?
		  params[:quotation_material_header][:supplier_id_1] = params[:quotation_material_header][:supplier_master_id]
		  params[:quotation_material_header][:order_email_flag_1] = 1
		elsif params[:quotation_material_header][:supplier_id_2].blank?
		  params[:quotation_material_header][:supplier_id_2] = params[:quotation_material_header][:supplier_master_id]
		  params[:quotation_material_header][:order_email_flag_2] = 1
		elsif params[:quotation_material_header][:supplier_id_3].blank?
		  params[:quotation_material_header][:supplier_id_3] = params[:quotation_material_header][:supplier_master_id]
		  params[:quotation_material_header][:order_email_flag_3] = 1
		end
	  end
	end
	##
	
  end
  
  #レコード毎にメール送信済みフラグをセットする
  def set_mail_sent_flag
    if params[:quotation_material_header][:sent_flag] == "1" || params[:quotation_material_header][:sent_flag] == "2" 
      if params[:quotation_material_header][:quotation_material_details_attributes].present?
        params[:quotation_material_header][:quotation_material_details_attributes].values.each do |item|
		#ここは、仕入先別と見積・注文別のフラグをセット
		  case $supplier
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
             
        # item[:mail_sent_flag] = 1
        end
		
		#再度ここで更新をかける(削除後)
		destroy_before_update
		@quotation_material_header.update(quotation_material_header_params)
		
      end
	end
  end

  #注文番号が新規の場合に、更新させる
  def set_new_purchase_order_code
    
    #binding.pry
	
	purchase_order_code = PurchaseOrderDatum.where(:construction_datum_id => params[:quotation_material_header][:construction_datum_id]).
           where(:supplier_master_id => params[:quotation_material_header][:supplier_master_id]).
           where("id is NOT NULL").pluck(:purchase_order_code).flatten.join(" ")

    if purchase_order_code.blank?
      
	  #定数ファイルへ頭文字のアルファベットも保存
	  @constant = Constant.find(1)   #id=１に定数ファイルが保管されている
	  
	  #binding.pry
	  if @constant.present?
	    tmp_code = params[:quotation_material_header][:purchase_order_code] 
	    
		if tmp_code.present?
		  #header = tmp_code[0, 1]
          
          #upd180411
          #新コードの年(Axx)が最終コード以上の場合のみ更新。(古い年でテストするケースもあるため）
          new_year = tmp_code[1,2].to_i
          current_year = @constant.purchase_order_last_header_code[1,2].to_i
          
          #if new_year >= current_year
          if new_year > current_year   #upd180919
          
            constant_params = { purchase_order_last_header_code: tmp_code}
            @constant.update(constant_params)
          end
		end
	  end
	  #
	  
	  construction_name = ConstructionDatum.where(:id => params[:quotation_material_header][:construction_datum_id]).
           where("id is NOT NULL").pluck(:construction_name).flatten.join(" ")
	  
	  
      purchase_order_data_params = { purchase_order_code:  params[:quotation_material_header][:purchase_order_code], 
	                                 construction_datum_id:  params[:quotation_material_header][:construction_datum_id], 
                                     supplier_master_id: params[:quotation_material_header][:supplier_master_id], alias_name: construction_name, 
                                     purchase_order_date:  params[:quotation_material_header][:requested_date] }
									 
	  
      @purchase_order_data = PurchaseOrderDatum.create(purchase_order_data_params)
		  
	end
	
  end

  #add190422
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
      
    end
    
  end

  #保存前に、備考１〜３のいずれかへセット
  def set_notes_before_save
    
    #
    exist = false
    
    #if params[:quotation_material_header][:notes].present?
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
	 
    #quotation_material_header = QuotationMaterialHeader.find(params[:id]) #add181002
    #upd181126
    quotation_material_header = QuotationMaterialHeader.where(params[:id]).first
   
	  exist = false
	 
    #add180919
     
	  if params[:supplier_id_1].present?
	    if params[:supplier_id] == params[:supplier_id_1]
        
        #add181002
        #備考をセット
        if quotation_material_header.present?
          @notes = quotation_material_header.notes_1
        end
        
        
        if params[:quotation_email_flag_1] == "true" #add180919
	        exist = true 
        end
	    end
    end 
	  if params[:supplier_id_2].present?
	    if params[:supplier_id] == params[:supplier_id_2]
         
         #add181002
         #備考をセット
         if quotation_material_header.present?
           @notes = quotation_material_header.notes_2
         end
                 
         
         if params[:quotation_email_flag_2] == "true" #add180919
	         exist = true 
         end
	    end
	  end
	  if params[:supplier_id_3].present?
	     #add181002
       #備考をセット
       if quotation_material_header.present?
         @notes = quotation_material_header.notes_3
       end
       
       if params[:supplier_id] == params[:supplier_id_3]
         if params[:quotation_email_flag_3] == "true" #add180919
	         exist = true 
	       end
       end
    end
     
    #not yet
    #該当なし---業者１として扱う
    if exist == false
     
    end
     
    #upd180919
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
	
	if $seq_exists == 0
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
	
	#add1710124
	#$seq_exists += 1
	
  end
 
  
  #ajax
  def get_purchase_order_code
     
	 if params[:supplier_master_id].present? && params[:supplier_master_id].to_i > 1
	 
       #まず既存の注文コードがあれば、セット。
	   @purchase_order_code = PurchaseOrderDatum.where(:construction_datum_id => params[:construction_datum_id]).
           where(:supplier_master_id => params[:supplier_master_id]).
           where("id is NOT NULL").pluck(:purchase_order_code).flatten.join(" ")
	 
	   ###
       
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
	 
	     @purchase_order_code = header + newNum.to_s
	   end
	   ###
	 end
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
      #params.require(:quotation_material_header).permit(:quotation_code, :requested_date, :construction_datum_id, 
	  #               :supplier_master_id, :responsible, :email)
					 
					 
	  params.require(:quotation_material_header).permit(:quotation_code, :quotation_header_origin_id, :requested_date, :construction_datum_id, 
	                 :supplier_master_id, :responsible, :email, :notes_1, :notes_2, :notes_3,
                     :total_quotation_price_1, :total_quotation_price_2, :total_quotation_price_3,
                     :total_order_price_1, :total_order_price_2, :total_order_price_3,
                     :supplier_id_1, :supplier_id_2, :supplier_id_3, :quotation_email_flag_1, 
                     :quotation_email_flag_2, :quotation_email_flag_3, :order_email_flag_1, :order_email_flag_2, :order_email_flag_3, 
                      quotation_material_details_attributes: [:id, :material_id, :material_code, :material_name, :maker_id, :maker_name, 
                      :quantity, :unit_master_id, :list_price, :quotation_unit_price_1, :quotation_unit_price_2, :quotation_unit_price_3, 
                      :quotation_price_1, :quotation_price_2, :quotation_price_3, 
                      :bid_flag_1, :bid_flag_2, :bid_flag_3, :mail_sent_flag, :quotation_email_flag_1, :quotation_email_flag_2, 
                      :quotation_email_flag_3, :order_email_flag_1, :order_email_flag_2, :order_email_flag_3,
                      :_destroy])
					 
    end
end
