class QuotationHeadersController < ApplicationController
  before_action :set_quotation_header, only: [:show, :edit, :update, :destroy]

  # GET /quotation_headers
  # GET /quotation_headers.json
  def index
    #@quotation_headers = QuotationHeader.all

    @q = QuotationHeader.ransack(params[:q])  
    @quotation_headers = @q.result(distinct: true)
    @quotation_headers  = @quotation_headers.page(params[:page])
	
  end

  # GET /quotation_headers/1
  # GET /quotation_headers/1.json
  def show
  end

  # GET /quotation_headers/new
  def new
    @quotation_header = QuotationHeader.new
    #顧客Mをビルド
    @quotation_header.build_customer_master
  end

  # GET /quotation_headers/1/edit
  def edit
  
    #顧客Mをビルド
    #@quotation_header.build_customer_master
	
  end

  # POST /quotation_headers
  # POST /quotation_headers.json
  def create
    #住所のパラメータを正常化
    adjust_address_params
	
	#add170809
    #手入力時の顧客マスターの新規登録
  	create_manual_input_customer
	
    @quotation_header = QuotationHeader.new(quotation_header_params)

    respond_to do |format|
      if @quotation_header.save
	    
		#参照コードがあれば内訳マスターをコピー
	    copyBreakDown
		
	    #顧客Mも更新
		if @manual_flag.blank?  #add170809
	      update_params_customer
		end
		
        format.html { redirect_to @quotation_header, notice: 'Quotation header was successfully created.' }
        format.json { render :show, status: :created, location: @quotation_header }
      else
        format.html { render :new }
        format.json { render json: @quotation_header.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quotation_headers/1
  # PATCH/PUT /quotation_headers/1.json
  def update
  
    #住所のパラメータを正常化
    adjust_address_params
    
	#add170809
    #手入力時の顧客マスターの新規登録
  	create_manual_input_customer
	
    respond_to do |format|
      if @quotation_header.update(quotation_header_params)
	  
	    #参照コードがあれば内訳マスターをコピー
	    copyBreakDown
	  
	    #顧客Mも更新
		if @manual_flag.blank?  #add170809
	      update_params_customer
	    end
	  
        format.html { redirect_to @quotation_header, notice: 'Quotation header was successfully updated.' }
        format.json { render :show, status: :ok, location: @quotation_header }
      else
        format.html { render :edit }
        format.json { render json: @quotation_header.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quotation_headers/1
  # DELETE /quotation_headers/1.json
  def destroy
    #ヘッダIDをここで保持(内訳・明細も消すため)
	quotation_header_id = @quotation_header.id
	
	@quotation_header.destroy
    respond_to do |format|
      format.html { redirect_to quotation_headers_url, notice: 'Quotation header was successfully destroyed.' }
      format.json { head :no_content }
    end
	
	#内訳も消す
	QuotationDetailLargeClassification.where(quotation_header_id: quotation_header_id).destroy_all
		
	#明細も消す
	QuotationDetailMiddleClassification.where(quotation_header_id: quotation_header_id).destroy_all
  end
  
  #viewで拡散されたパラメータを、正常更新できるように復元させる。
  def adjust_address_params
    params[:quotation_header][:address] = params[:address]
	
	#add170830
	params[:quotation_header][:construction_place] = params[:construction_place]
  end
  
  #add170809
  def create_manual_input_customer
  #手入力時の顧客マスターの新規登録
    if params[:quotation_header][:customer_id] == "1"
	  
	   @manual_flag = true
	
       customer_params = {customer_name: params[:quotation_header][:customer_name], 
	                    honorific_id: params[:quotation_header][:honorific_id], 
	                    responsible1: params[:quotation_header][:responsible1], 
						responsible2: params[:quotation_header][:responsible2]}
	  
	   @customer_master = CustomerMaster.new(customer_params)
       if @customer_master.save!(:validate => false)
		 @success_flag = true
	   else
		 @success_flag = false
	   end
	   
	   #見積データの顧客IDを登録済みのものにする。
	   if @success_flag == true
         params[:quotation_header][:customer_id] = @customer_master.id
       end
  
    end 
  end
  
  
  def update_params_customer
  #顧客Mの敬称・担当を更新する(未登録の場合)
    
    if params[:quotation_header][:customer_master_attributes].present?
	  id = params[:quotation_header][:customer_id].to_i
      @customer_masters = CustomerMaster.find(id)

	  if @customer_masters.present?
        
		#名称 add170809
        if params[:quotation_header][:customer_name].present?
          params[:quotation_header][:customer_master_attributes][:customer_name] = params[:quotation_header][:customer_name]
        end
		
		#敬称
        if params[:quotation_header][:honorific_id].present?
          params[:quotation_header][:customer_master_attributes][:honorific_id] = params[:quotation_header][:honorific_id]
        end
        #担当1
        if params[:quotation_header][:responsible1].present?
          params[:quotation_header][:customer_master_attributes][:responsible1] = params[:quotation_header][:responsible1]
		end
		#担当2
        if params[:quotation_header][:responsible2].present?
          params[:quotation_header][:customer_master_attributes][:responsible2] = params[:quotation_header][:responsible2]
		end
      
	    #更新する
	    @quotation_header.update(customer_masters_params)
	  end
	  
    end
  end
  
  # ajax
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
  
  #見積書データを複製する(一覧データのみ)
  def duplicate_quotation_header
    #quotation_header = QuotationHeader.where(:quotation_code => params[:quotation_code]).first
	quotation_header = QuotationHeader.where(:quotation_code => params[:quotation_code])
	
	if quotation_header.present?
     
	   #日付はうまくセットできないので保留・・・(datePickerにするしかなさそう)
	   #@quotation_date =
	   #    Array[[quotation_header.pluck(:quotation_date).slice(0).year, quotation_header.pluck(:quotation_date).slice(0).year]]
	
	   #請求コード
	   @invoice_code = quotation_header.pluck(:invoice_code).flatten.join(" ")
	   #納品コード
	   @delivery_slip_code = quotation_header.pluck(:delivery_slip_code).flatten.join(" ")
	   
	   ###工事コード
	   construction_datum_id = quotation_header.pluck(:construction_datum_id).flatten.join(" ")  
	   
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
	   @construction_name = quotation_header.pluck(:construction_name).flatten.join(" ")
	   
	   ###得意先
	   customer_id = quotation_header.pluck(:customer_id).flatten.join(" ")  
	   
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
	   @customer_name = quotation_header.pluck(:customer_name).flatten.join(" ")
	   
	   #敬称
	   honorific_id = quotation_header.pluck(:honorific_id).flatten.join(" ").to_i
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
	   @responsible1 = quotation_header.pluck(:responsible1).flatten.join(" ")
	   #担当者2
	   @responsible2 = quotation_header.pluck(:responsible2).flatten.join(" ")
	   #郵便番号
	   @post = quotation_header.pluck(:post).flatten.join(" ")
	   #住所
	   @address = quotation_header.pluck(:address).flatten.join(" ")
	   #tel
	   @tel = quotation_header.pluck(:tel).flatten.join(" ")
	   #fax
	   @fax = quotation_header.pluck(:fax).flatten.join(" ")
	   #工事期間
	   @construction_period = quotation_header.pluck(:construction_period).flatten.join(" ")
	   #郵便番号（工事場所）
	   @construction_post = quotation_header.pluck(:construction_post).flatten.join(" ")
	   #工事場所
	   @construction_place = quotation_header.pluck(:construction_place).flatten.join(" ")
	   #取引方法
	   @trading_method = quotation_header.pluck(:trading_method).flatten.join(" ")
	   #有効期間
	   @effective_period = quotation_header.pluck(:effective_period).flatten.join(" ")
	   #NET金額
	   @net_amount = quotation_header.pluck(:net_amount).flatten.join(" ")
	   #見積金額
	   @quote_price = quotation_header.pluck(:quote_price).flatten.join(" ")
	   #実行金額
	   @execution_amount = quotation_header.pluck(:execution_amount).flatten.join(" ")
	end 
    
  end
  
  #内訳データを参照元からコピー
  def copyBreakDown
    if @quotation_header.quotation_header_origin_id.present?
  
      #コピー元の一覧テーブルをセット
      quotation_header = QuotationHeader.find(@quotation_header.quotation_header_origin_id)
      
	  new_header_id = @quotation_header.id
	  #内訳データ抹消(コピー先)
	  QuotationDetailLargeClassification.where(quotation_header_id: new_header_id).destroy_all
	  
	  
	  @qdlc = QuotationDetailLargeClassification.where(quotation_header_id: quotation_header.id)
      if @qdlc.present?
        @qdlc.each do |qdlc|
          
		  #内訳データのコピー元をコピー先オブジェクトへセット
		  new_qdlc = qdlc.dup
		  
		  #コピー元の内訳IDを保持しておく
		  old_large_classification_id = qdlc.id
		  
		  
		  #ヘッダIDを新しいものに置き換える
          new_qdlc.quotation_header_id = new_header_id
		  
		  
	      #更新する
		  new_qdlc.save!(:validate => false)
		  
		  
		  #明細用にキーをセット
		  new_large_classification_id = new_qdlc.id
		  
		  #明細のコピー
		  copyDetail(new_header_id, new_large_classification_id,old_large_classification_id)
		  
        end
      end	
    
	end
  end
  
  #明細データを参照元からコピー
  def copyDetail(new_header_id, new_large_classification_id, old_large_classification_id)
    #内訳データ抹消(コピー先)
	QuotationDetailMiddleClassification.where(quotation_header_id: new_header_id, 
	    quotation_detail_large_classification_id: new_large_classification_id).destroy_all
	
	@qdmc = QuotationDetailMiddleClassification.where(quotation_header_id: @quotation_header.quotation_header_origin_id,
	                               quotation_detail_large_classification_id: old_large_classification_id)
	#binding.pry
	
	if @qdmc.present?
      @qdmc.each do |qdmc|
	    
		#明細データのコピー元をコピー先オブジェクトへセット
		new_qdmc = qdmc.dup
		
		#ヘッダIDを新しいものに置き換える
        new_qdmc.quotation_header_id = new_header_id
		#内訳IDを新しいものに置き換える
		new_qdmc.quotation_detail_large_classification_id = new_large_classification_id
		
		#更新する
		new_qdmc.save!(:validate => false)
	    
      end
    end  
	
  end
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quotation_header
      @quotation_header = QuotationHeader.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quotation_header_params
      params.require(:quotation_header).permit(:quotation_code, :invoice_code, :delivery_slip_code, :quotation_header_origin_id, :quotation_date, :construction_datum_id, :construction_name, 
                                               :honorific_id, :responsible1, :responsible2, :customer_id, :customer_name, :post, :address, :tel, :fax, :construction_period, 
                                               :construction_post, :construction_place, :trading_method, :effective_period, :net_amount, :quote_price, :execution_amount, 
                                               :invoice_period_start_date, :invoice_period_end_date )
    end
    
    # 
    def customer_masters_params
	     #upd170809
         params.require(:quotation_header).permit(customer_master_attributes: [:id, :customer_name, :honorific_id, :responsible1, :responsible2 ])
    end

end
