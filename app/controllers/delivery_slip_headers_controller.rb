class DeliverySlipHeadersController < ApplicationController
  before_action :set_delivery_slip_header, only: [:show, :edit, :update, :destroy]

  # GET /delivery_slip_headers
  # GET /delivery_slip_headers.json
  def index
    
    #@delivery_slip_headers = DeliverySlipHeader.all
    
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)  	

    #binding.pry

    #@q = DeliverySlipHeader.ransack(params[:q])  
    #ransack保持用--上記はこれに置き換える
    @q = DeliverySlipHeader.ransack(query)
    
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
    
    @delivery_slip_headers = @q.result(distinct: true)
    @delivery_slip_headers  = @delivery_slip_headers.page(params[:page])

  end

  # GET /delivery_slip_headers/1
  # GET /delivery_slip_headers/1.json
  def show
  end

  # GET /delivery_slip_headers/new
  def new
    @delivery_slip_header = DeliverySlipHeader.new
    #顧客Mをビルド
    @delivery_slip_header.build_customer_master
    
    #add180206
    #顧客Mで絞られている場合は、初期値としてセットする
    if eval(cookies[:recent_search_history].to_s).present?
      if eval(cookies[:recent_search_history].to_s)["customer_id_eq"].present?
        @delivery_slip_header.customer_id = eval(cookies[:recent_search_history].to_s)["customer_id_eq"]
      end
    end
    ##
    
  end

  # GET /delivery_slip_headers/1/edit
  def edit
  end

  # POST /delivery_slip_headers
  # POST /delivery_slip_headers.json
  def create
    #住所のパラメータを正常化
    adjust_address_params
    
	 #add170809
    #手入力時の顧客マスターの新規登録
  	create_manual_input_customer
	 
    #工事集計の確定区分があればセット
    set_final_return_division_params
  
    @delivery_slip_header = DeliverySlipHeader.new(delivery_slip_header_params)
    
    #見出しデータ（コピー元）の補完
    complementCopyHeader
    
    respond_to do |format|
      if @delivery_slip_header.save
        
        #参照コードがあれば内訳マスターをコピー
	      copyBreakDown
        
        #顧客Mも更新
		    if @manual_flag.blank?
          update_params_customer
        end
		    
        #工事担当者を更新
        #add190131
        update_construction_personnel
        
        format.html { redirect_to @delivery_slip_header, notice: 'Delivery slip header was successfully created.' }
        format.json { render :show, status: :created, location: @delivery_slip_header }
      else
        format.html { render :new }
        format.json { render json: @delivery_slip_header.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  # PATCH/PUT /delivery_slip_headers/1
  # PATCH/PUT /delivery_slip_headers/1.json
  def update
    
    #住所のパラメータを正常化
    adjust_address_params
  
    #手入力時の顧客マスターの新規登録
  	create_manual_input_customer
    
    #工事集計の確定区分があればセット
    set_final_return_division_params
    
    #見出しデータ（コピー元）の補完
    #アプデは既存データを書き換えてしまう可能性があるため、保留!
    #complementCopyHeader
  
    respond_to do |format|
      if @delivery_slip_header.update(delivery_slip_header_params)
        
        #参照コードがあれば内訳マスターをコピー
	    #アプデは既存データを書き換えてしまう可能性があるため、保留!
        copyBreakDown
        
		    #顧客Mも更新
		    if @manual_flag.blank?
          update_params_customer
		    end
        
		    #工事担当者を更新
        #add190131
        update_construction_personnel
        
        format.html { redirect_to @delivery_slip_header, notice: 'Delivery slip header was successfully updated.' }
        format.json { render :show, status: :ok, location: @delivery_slip_header }
      else
        format.html { render :edit }
        format.json { render json: @delivery_slip_header.errors, status: :unprocessable_entity }
      end
    end
  end
 
  # DELETE /delivery_slip_headers/1
  # DELETE /delivery_slip_headers/1.json
  def destroy
    #ヘッダIDをここで保持(内訳・明細も消すため)
    delivery_slip_header_id = @delivery_slip_header.id
    
    #確定フラグを取得
    if @delivery_slip_header.fixed_flag == 1
      @status = "fixed"
    else
      @status = "not_fixed"
    end
    
    if @status != "fixed"
    
      @delivery_slip_header.destroy
      
      #respond_to do |format|
      #  format.html { redirect_to delivery_slip_headers_url, notice: 'Delivery slip header was successfully destroyed.' }
      #  format.json { head :no_content }
      #end
	
	    #内訳も消す
	    DeliverySlipDetailLargeClassification.where(delivery_slip_header_id: delivery_slip_header_id).destroy_all
		
	    #明細も消す
	    DeliverySlipDetailMiddleClassification.where(delivery_slip_header_id: delivery_slip_header_id).destroy_all
    end
    
  end
  
   #viewで拡散されたパラメータを、正常更新できるように復元させる。
  def adjust_address_params
    params[:delivery_slip_header][:address] = params[:address]
	
	#add170830
	params[:delivery_slip_header][:construction_place] = params[:construction_place]
  end
  
  
   #add170809
  def create_manual_input_customer
  #手入力時の顧客マスターの新規登録
    
    if params[:delivery_slip_header][:customer_id] == "1"
	
	   @manual_flag = true
	
       customer_params = {customer_name: params[:delivery_slip_header][:customer_name], 
	                    honorific_id: params[:delivery_slip_header][:honorific_id], 
	                    responsible1: params[:delivery_slip_header][:responsible1], 
                        responsible2: params[:delivery_slip_header][:responsible2],
                        post: params[:delivery_slip_header][:post], 
                        address: params[:delivery_slip_header][:address],
                        house_number: params[:delivery_slip_header][:house_number], 
                        address2: params[:delivery_slip_header][:address2], 
                        tel_main: params[:delivery_slip_header][:tel], 
                        fax_main: params[:delivery_slip_header][:fax],
                        closing_date: 0, due_date: 0 }
	  
	   @customer_master = CustomerMaster.new(customer_params)
       if @customer_master.save!(:validate => false)
		 @success_flag = true
	   else
		 @success_flag = false
	   end
	   
	   #納品データの顧客IDを登録済みのものにする。
	   if @success_flag == true
         params[:delivery_slip_header][:customer_id] = @customer_master.id
       end
  
    end 
  end
  
  #add190131
  #工事Mの担当者を更新
  def update_construction_personnel
    #名称 
    if params[:delivery_slip_header][:customer_name].present? && params[:delivery_slip_header][:customer_name] != ""
      id = params[:delivery_slip_header][:construction_datum_id].to_i
      @construction = ConstructionDatum.where(:id => id).first
      
      if @construction.present?    #マスター削除を考慮
        construction_params = { personnel: params[:delivery_slip_header][:responsible1] }
        #更新する
	      @construction.update(construction_params)
      end
      
    end
  end
  
  def update_params_customer
  #顧客Mの敬称・担当を更新する(未登録の場合)
    
    if params[:delivery_slip_header][:customer_master_attributes].present?
	  id = params[:delivery_slip_header][:customer_id].to_i
      @customer_masters = CustomerMaster.find(id)

	  if @customer_masters.present?
	    #名称 add170809
        if params[:delivery_slip_header][:customer_name].present?
          params[:delivery_slip_header][:customer_master_attributes][:customer_name] = params[:delivery_slip_header][:customer_name]
        end
		
        #敬称
        if params[:delivery_slip_header][:honorific_id].present?
          params[:delivery_slip_header][:customer_master_attributes][:honorific_id] = params[:delivery_slip_header][:honorific_id]
        end
        #del190131
        ##担当1
        #if params[:delivery_slip_header][:responsible1].present?
        #  params[:delivery_slip_header][:customer_master_attributes][:responsible1] = params[:delivery_slip_header][:responsible1]
		    #end
		    #担当2
        if params[:delivery_slip_header][:responsible2].present?
          params[:delivery_slip_header][:customer_master_attributes][:responsible2] = params[:delivery_slip_header][:responsible2]
		    end
        
		    #住所関連/tel,fax追加
		    if params[:delivery_slip_header][:post].present?
          params[:delivery_slip_header][:customer_master_attributes][:post] = params[:delivery_slip_header][:post]
		    end
		    if params[:delivery_slip_header][:address].present?
          params[:delivery_slip_header][:customer_master_attributes][:address] = params[:delivery_slip_header][:address]
		    end
		    if params[:delivery_slip_header][:house_number].present?
          params[:delivery_slip_header][:customer_master_attributes][:house_number] = params[:delivery_slip_header][:house_number]
		    end
        if params[:delivery_slip_header][:address2].present?
          params[:delivery_slip_header][:customer_master_attributes][:address2] = params[:delivery_slip_header][:address2]
		    end
		    if params[:delivery_slip_header][:tel].present?
          params[:delivery_slip_header][:customer_master_attributes][:tel_main] = params[:delivery_slip_header][:tel]
		    end
		    if params[:delivery_slip_header][:fax].present?
          params[:delivery_slip_header][:customer_master_attributes][:fax_main] = params[:delivery_slip_header][:fax]
		    end
		#
		
	    #更新する
	     @delivery_slip_header.update(customer_masters_params)
	  end
	  
    end
  end
  
  # ajax
  
  #確定フラグのセット
  def set_fixed
    if params[:delivery_slip_header_id].present?
        delivery_slip_header = DeliverySlipHeader.find_by(id: params[:delivery_slip_header_id])
	    if delivery_slip_header.present?
    	    delivery_slip_header.assign_attributes(:fixed_flag => 1)
			delivery_slip_header.save(validate: false)
		end
    end
  end
    
  def construction_name_select
     @construction_name = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_name).flatten.join(" ")
  end
  
  #def customer_name_select
  def customer_info_select
     @customer_name = CustomerMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:customer_name).flatten.join(" ")
  	 @post = CustomerMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:post).flatten.join(" ")
	 @address = CustomerMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:address).flatten.join(" ")
	 @tel = CustomerMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:tel_main).flatten.join(" ")
	 @fax = CustomerMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:fax_main).flatten.join(" ")
     @responsible1 = CustomerMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:responsible1).flatten.join(" ")
     @responsible2 = CustomerMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:responsible2).flatten.join(" ")
     #敬称
     id  = CustomerMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:honorific_id).flatten.join(" ").to_i
     @honorific_id  = [CustomerMaster.honorific[id]]
	 #あとからも選択できるようにする。
	 for num in 1..CustomerMaster.honorific.length
	   number = num -1
	   if number != id
	     @honorific_id = @honorific_id + [CustomerMaster.honorific[number]]
	   end
	 end
     
  end
  
  #工事集計の確定区分があればセット
  def set_final_return_division_params
    
    if params[:delivery_slip_header][:construction_datum_id].present?
      construction_datum_id = params[:delivery_slip_header][:construction_datum_id].to_i
       
      construction_cost = ConstructionCost.where(:construction_datum_id => construction_datum_id).first
      #工事集計データあり？
      if construction_cost.present?
        #if construction_cost.final_return_division.present? && construction_cost.final_return_division > 0
        #upd210402
        if construction_cost.final_return_division.present?
          params[:delivery_slip_header][:final_return_division] = construction_cost.final_return_division
          #@delivery_slip_header.final_return_division = construction_cost.final_return_division
        end
      end
    end
  end
    
  #コード自動採番
  def set_delivery_slip_code
    
    #パラメーターからコードを作る
    dateStr = format("%04d%02d%02d", params[:year], params[:month], params[:day] ) 
    
    codeMin = dateStr + "00"
    codeMax = dateStr + "98"  #１日99件以上は考慮しない
    
    tmp_delivery_slip_header_code = DeliverySlipHeader.where(delivery_slip_code: codeMin..codeMax).maximum(:delivery_slip_code)
    
    @new_code = nil
    
    if tmp_delivery_slip_header_code.present?
      under = tmp_delivery_slip_header_code[-2, 2].to_i + 1  #下２桁コードに１足す
      @new_code = dateStr + format("%02d", under)
    else
    #指定日のコードが存在しなかった場合  
      @new_code = dateStr + "01"
    end
    
  end
  
  #納品書データを複製する(一覧データのみ。内訳・明細はcreate時に作成)
  def duplicate_delivery_slip_header
    
    delivery_slip_header = DeliverySlipHeader.where(:delivery_slip_code => params[:delivery_slip_code])
    #add190131
    construction_data = ConstructionDatum.where(:id => delivery_slip_header.pluck(:construction_datum_id).flatten.join(" ")).first
    
    if delivery_slip_header.present?
     
       #請求書有効期間開始日
       #@invoice_period_start_date = delivery_slip_header.pluck(:invoice_period_start_date).flatten.join(" ")
       #請求書有効期間終了日
       #@invoice_period_end_date = delivery_slip_header.pluck(:invoice_period_end_date).flatten.join(" ")
	   
	   
       #請求コード
       @invoice_code = delivery_slip_header.pluck(:invoice_code).flatten.join(" ")
       #見積コード
       @quotation_code = delivery_slip_header.pluck(:quotation_code).flatten.join(" ")
       
       ###工事コード
       construction_datum_id = delivery_slip_header.pluck(:construction_datum_id).flatten.join(" ")  
	   
	   @construction_datum_id = ""
	   construction = ConstructionDatum.find(construction_datum_id)
	   if construction.present?
	     construction_code = construction.construction_code
	   
	     @construction_datum_id = Array[[construction_code,construction_datum_id]]
	   end
	   
	   #任意で変更もできるように全ての工事データをセット
       construction_all = ConstructionDatum.all.pluck(:construction_code, :id)
       @construction_datum_id = @construction_datum_id + construction_all
	   #
	   
	   ###工事名
	   @construction_name = delivery_slip_header.pluck(:construction_name).flatten.join(" ")
	   
	   ###得意先
	   customer_id = delivery_slip_header.pluck(:customer_id).flatten.join(" ")  
	   
	   customer = CustomerMaster.find(customer_id)
	   @customer_id = ""
	   if customer.present?
	     customer_name = customer.customer_name
	     @customer_id = Array[[customer_name,customer_id]]
	   end
	   #任意で変更もできるように全ての工事データをセット
       customer_all = CustomerMaster.all.pluck(:customer_name, :id)
       @customer_id = @customer_id + customer_all
	   #
	   
	   #得意先名
	   @customer_name = delivery_slip_header.pluck(:customer_name).flatten.join(" ")
	   
	   #敬称
	   honorific_id = delivery_slip_header.pluck(:honorific_id).flatten.join(" ").to_i
	   @honorific_id = Array[CustomerMaster.honorific[honorific_id]]
	   #あとからも選択できるようにする。
	   for num in 1..CustomerMaster.honorific.length
	     number = num -1
	     if number != honorific_id
	       @honorific_id = @honorific_id + [CustomerMaster.honorific[number]]
	     end
	   end
	   #
     
     #担当者1
     #upd190131
     if construction_data.present? && 
          !construction_data.personnel.blank?
       @responsible1 = construction_data.personnel
     else
       @responsible1 = delivery_slip_header.pluck(:responsible1).flatten.join(" ")
     end
	   #@responsible1 = delivery_slip_header.pluck(:responsible1).flatten.join(" ")
	   #担当者2
	   @responsible2 = delivery_slip_header.pluck(:responsible2).flatten.join(" ")
	   #郵便番号
	   @post = delivery_slip_header.pluck(:post).flatten.join(" ")
	   #住所(得意先)
	   @address = delivery_slip_header.pluck(:address).flatten.join(" ")
	   #add171012
	   @house_number = delivery_slip_header.pluck(:house_number).flatten.join(" ")
	   @address2 = delivery_slip_header.pluck(:address2).flatten.join(" ")
	   #add end
	   #tel
	   @tel = delivery_slip_header.pluck(:tel).flatten.join(" ")
	   #fax
	   @fax = delivery_slip_header.pluck(:fax).flatten.join(" ")
	   #工事期間
	   @construction_period = delivery_slip_header.pluck(:construction_period).flatten.join(" ")
	   #郵便番号（工事場所）
	   @construction_post = delivery_slip_header.pluck(:construction_post).flatten.join(" ")
	   #工事場所
	   @construction_place = delivery_slip_header.pluck(:construction_place).flatten.join(" ")
	   #add171012
	   @construction_house_number = delivery_slip_header.pluck(:construction_house_number).flatten.join(" ")
	   @construction_place2 = delivery_slip_header.pluck(:construction_place2).flatten.join(" ")
	   #add end
	   
	   #取引方法
	   #@trading_method = delivery_slip_header.pluck(:trading_method).flatten.join(" ")
	   #有効期間
	   #@effective_period = delivery_slip_header.pluck(:effective_period).flatten.join(" ")
	   #NET金額
	   #@net_amount = delivery_slip_header.pluck(:net_amount).flatten.join(" ")
	   
       #納品金額
	   @delivery_amount = delivery_slip_header.pluck(:delivery_amount).flatten.join(" ")
	   #実行金額
	   @execution_amount = delivery_slip_header.pluck(:execution_amount).flatten.join(" ")
	end 
    
  end

  #見出しデータ（コピー元）の補完する
  def complementCopyHeader
    if params[:delivery_slip_header][:delivery_slip_header_origin_id].present?
        delivery_slip_header_origin = DeliverySlipHeader.find(params[:delivery_slip_header][:delivery_slip_header_origin_id])
        #if delivery_slip_header_origin.present?
        @delivery_slip_header.last_line_number = delivery_slip_header_origin.last_line_number
        @delivery_slip_header.category_saved_flag = delivery_slip_header_origin.category_saved_flag
        @delivery_slip_header.category_saved_id = delivery_slip_header_origin.category_saved_id
        @delivery_slip_header.subcategory_saved_id = delivery_slip_header_origin.subcategory_saved_id
    end
  end
  
  #内訳データを参照元からコピー
  def copyBreakDown
    if params[:delivery_slip_header][:delivery_slip_header_origin_id].present?
	  #コピー元の一覧テーブルをセット
      delivery_slip_header = DeliverySlipHeader.find(params[:delivery_slip_header][:delivery_slip_header_origin_id])
      new_header_id = @delivery_slip_header.id
	    
      #内訳データ抹消(コピー先)
	    if !DeliverySlipDetailLargeClassification.exists?(delivery_slip_header_id: new_header_id)   #upd190307
        DeliverySlipDetailLargeClassification.where(delivery_slip_header_id: new_header_id).destroy_all
	      @dsdlc = DeliverySlipDetailLargeClassification.where(delivery_slip_header_id: delivery_slip_header.id)
      
        if @dsdlc.present?
          @dsdlc.each do |dsdlc|
            #内訳データのコピー元をコピー先オブジェクトへセット
		        new_dsdlc = dsdlc.dup
		        #コピー元の内訳IDを保持しておく
		        old_large_classification_id = dsdlc.id
		        #ヘッダIDを新しいものに置き換える
            new_dsdlc.delivery_slip_header_id = new_header_id
		        #更新する
		        new_dsdlc.save!(:validate => false)
		        #明細用にキーをセット
		        new_large_classification_id = new_dsdlc.id
		        #明細のコピー
		        copyDetail(new_header_id, new_large_classification_id,old_large_classification_id)
		      end
        end
      end 
    end
  end
  #明細データを参照元からコピー
  def copyDetail(new_header_id, new_large_classification_id, old_large_classification_id)
    #内訳データ抹消(コピー先)
	DeliverySlipDetailMiddleClassification.where(delivery_slip_header_id: new_header_id, 
	    delivery_slip_detail_large_classification_id: new_large_classification_id).destroy_all
	@dsdmc = DeliverySlipDetailMiddleClassification.where(delivery_slip_header_id: params[:delivery_slip_header][:delivery_slip_header_origin_id],
	                               delivery_slip_detail_large_classification_id: old_large_classification_id)
	if @dsdmc.present?
      @dsdmc.each do |dsdmc|
		#明細データのコピー元をコピー先オブジェクトへセット
		new_dsdmc = dsdmc.dup
		#ヘッダIDを新しいものに置き換える
        new_dsdmc.delivery_slip_header_id = new_header_id
		#内訳IDを新しいものに置き換える
		new_dsdmc.delivery_slip_detail_large_classification_id = new_large_classification_id
		#更新する
		new_dsdmc.save!(:validate => false)
	  end
    end  
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivery_slip_header
      @delivery_slip_header = DeliverySlipHeader.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def delivery_slip_header_params
      params.require(:delivery_slip_header).permit(:delivery_slip_code, :quotation_code, :invoice_code, :delivery_slip_date,
                     :construction_datum_id, :construction_name, :customer_id, :customer_name, :honorific_id, :responsible1, :responsible2, 
                     :post, :address, :tel, :house_number, :address2, :fax, :construction_period, 
                     :construction_period_date1, :construction_period_date2, :construction_post, :construction_place, 
                     :construction_house_number, :construction_place2, :delivery_amount, :execution_amount, :last_line_number,
                     :fixed_flag, :final_return_division)
      #Note: "delivery_slip_header_origin_id"は既存データ上書き防止のため、保存させない。
    end
	
	  # 
    def customer_masters_params
      #params.require(:delivery_slip_header).permit(customer_master_attributes: [:id,  :honorific_id, :responsible1, :responsible2 ])
	  #upd170809
	  params.require(:delivery_slip_header).permit(customer_master_attributes: [:id, :customer_name, :honorific_id, :responsible1, :responsible2, 
                                                                            :post, :address, :house_number, :address2, :tel_main, :fax_main ])
    end
end
