class ConstructionDataController < ApplicationController
  
  #binding.pry
  
  before_action :set_construction_datum, only: [:show, :edit, :edit2, :update, :destroy]

  # GET /construction_data
  # GET /construction_data.json
  def index
    
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)  	
		
   
	#@q = ConstructionDatum.ransack(params[:q])
    #ransack保持用--上記はこれに置き換える
    @q = ConstructionDatum.ransack(query)   
    
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
	
    @construction_data  = @q.result(distinct: true)
    
    #kaminari用設定
    @construction_data  = @construction_data .page(params[:page])

    @customer_masters = CustomerMaster.all
    
	
	$construction_data = @construction_data
	
	respond_to do |format|
	  format.html
		
	  format.pdf do
       
	    
        report = ConstructionListPDF.create @construction_list 
        
        # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data(
          report.generate,
          filename:  "construction_list.pdf",
          type:        "application/pdf",
          disposition: "inline")
      end
	end
  end

  # GET /construction_data/1
  # GET /construction_data/1.json
  def show
  end

  # GET /construction_data/new
  def new
    @construction_datum = ConstructionDatum.new
    Time.zone = "Tokyo"

    #工事コードの最終番号を取得
    get_last_construction_code_select
    @construction_datum.construction_code = @@construction_new_code
	
	
  end

  # GET /construction_data/1/edit
  def edit
  end
  
  # GET /construction_data/1/edit2
  def edit2
     Time.zone = "Tokyo"
	 @construction_datum.issue_date = Date.today
  end

  # POST /construction_data
  # POST /construction_data.json
  def create
  
    #住所のパラメータ変換
    params[:construction_datum][:address] = params[:addressX]
	
    @construction_datum = ConstructionDatum.new(construction_datum_params)
    
        #工事開始日・終了日（実績）の初期値をセットする
    @construction_datum.construction_start_date = '3000-01-01'
    @construction_datum.construction_end_date = '2000-01-01'
	
    respond_to do |format|

	
      if @construction_datum.save
        
        #工事費集計表データも空で作成
        #add170330
        construction_cost_params = {construction_datum_id: @construction_datum.id, purchase_amount: 0, 
                       execution_amount: 0, purchase_order_amount: ""}
        @construction_cost = ConstructionCost.create(construction_cost_params)
        #
	  
        format.html { redirect_to @construction_datum, notice: 'Construction datum was successfully created.' }
        format.json { render :show, status: :created, location: @construction_datum }
      else
  
        format.html { render :new }
        format.json { render json: @construction_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /construction_data/1
  # PATCH/PUT /construction_data/1.json
  def update
   
    
    #住所のパラメータ変換
    params[:construction_datum][:address] = params[:addressX]
    
    if params[:directions].present?
	  
	  #手入力用IDの場合は、安全事項マスタへも登録する。
      @matter_name = nil
      if @construction_datum.working_safety_matter_id == 1
         
       #既に登録してないかチェック
	   new_name =  params[:construction_datum][:working_safety_matter_name]
	   
	   if new_name != "" then
             @check_matter = WorkingSafetyMatter.find_by(working_safety_matter_name: new_name)
             if @check_matter.nil?
	        matter_params = { working_safety_matter_name:  new_name }
               @matter_name = WorkingSafetyMatter.create(matter_params)
             end
          end 
      end
      
	  
	end
	
   
    respond_to do |format|
	
	  
	  if @construction_datum.update(construction_datum_params)
        
        #工事費集計表データも空で作成(データ存在しない場合のみ)
        #add170330
        construction_cost = ConstructionCost.where(:construction_datum_id => @construction_datum.id).first
        if construction_cost.blank?
            construction_cost_params = {construction_datum_id: @construction_datum.id, purchase_amount: 0, 
                       execution_amount: 0, purchase_order_amount: ""}
		
            @construction_cost = ConstructionCost.create(construction_cost_params)
        end
        #
		
		
		format.html { redirect_to @construction_datum, notice: 'Construction datum was successfully updated.' }
		
	  	  
		if params[:directions].present?
		  #指示書の発行
		  
		  #global set
          $construction_datum = @construction_datum 
		  
		  #作業日をグローバルへセット
		  #$working_date = params[:construction_datum][:working_date]
		  
		  $working_date = params[:construction_datum]["working_date(1i)"] + "/" + 
                          params[:construction_datum]["working_date(2i)"] + "/" + params[:construction_datum]["working_date(3i)"]
		  
		  #add170601
		  #発行日をグローバルへセット
          $issue_date = params[:construction_datum][:issue_date]
		
		  #作業者をグローバルへセット
		  staff_id = params[:construction_datum][:staff_id]
		  @staff = Staff.find_by(id: staff_id)
		  $staff_name = ""
		  if @staff.present?
		   $staff_name = @staff.staff_name
		  end
		  
		  format.pdf do
            report = WorkingDirectionsPDF.create @working_dirctions
		    # ブラウザでPDFを表示する
            # disposition: "inline" によりダウンロードではなく表示させている
            send_data(
              report.generate,
              filename:  "working_directions.pdf",
              type:        "application/pdf",
              disposition: "inline")
          end
		 end
		
        format.json { render :show, status: :ok, location: @construction_datum }
      else
        format.html { render :edit }
        format.json { render json: @construction_datum.errors, status: :unprocessable_entity }
      end
	  
	
    end
    
    
  end
  
  #作業指示書PDF発行
  def set_pdf
      
      
	
      #respond_to do |format|
      #  format.html # index.html.erb
        format.pdf do
         
        report = WorkingDirectionsPDF.create @working_dirctions
        # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data(
          report.generate,
          filename:  "working_directions.pdf",
          type:        "application/pdf",
          disposition: "inline")
        end
      
	  #end
  end
  
  #def update_and_pdf
  #  update
  #end

  # DELETE /construction_data/1
  # DELETE /construction_data/1.json
  def destroy
    @construction_datum.destroy
    respond_to do |format|
      format.html { redirect_to construction_data_url, notice: 'Construction datum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  #工事コードの最終番号(+1)を取得する
  def get_last_construction_code_select
     #crescent = "%" + params[:header] + "%"
     #@construction_new_code = ConstructionDatum.where('construction_code LIKE ?', crescent).all.maximum(:construction_code)
     @construction_new_code = ConstructionDatum.all.maximum(:construction_code) 
	 
	 #最終番号に１を足す。
	 #newStr = @construction_new_code[1, 4]
	 #header = @construction_new_code[0, 1]
	 newNum = @construction_new_code.to_i + 1
	 
     @@construction_new_code = newNum.to_s
	 
  end

  # ajax
  def working_safety_matter_name_select
     @working_safety_matter_name = WorkingSafetyMatter.where(:id => params[:id]).where("id is NOT NULL").pluck(:working_safety_matter_name).flatten.join(" ")
  end
  
  #add171121
  def customer_extract
    
	if params[:customer_id] != ""
      #初期値として、”手入力”も選択できるようにする
	  @customer_extract = ConstructionDatum.where(:id => 1).where("id is NOT NULL").
           pluck("CONCAT(construction_data.construction_code, ':' , construction_data.construction_name), construction_data.id")

	  
	  #カテゴリー別のアイテムをセット
	  @customer_extract  += ConstructionDatum.where(:customer_id => params[:customer_id]).where("id is NOT NULL").
           pluck("CONCAT(construction_data.construction_code, ':' , construction_data.construction_name), construction_data.id")
    else
	#未選択状態の場合は、全リストを出す
	  #カテゴリー別のアイテムをセット
	  
	  #upd171205 リストに全て載せようとすると処理落ちするので
	  #現在日から１年前からの、登録された工事データのみ表示させるようにする。
	  #
	  require 'date'
      now_date = Date.today
      past_date = now_date << 12
	  #
	  
	  @customer_extract  = ConstructionDatum.where( "created_at >= ?" , past_date).
	      pluck("CONCAT(construction_data.construction_code, ':' , construction_data.construction_name), construction_data.id")
	  
	  #@customer_extract  = ConstructionDatum.all.
      #     pluck("CONCAT(construction_data.construction_code, ':' , construction_data.construction_name), construction_data.id")
	
	end
  end
    
  
  
  
  # ajax
  #add170218 見積書などで使用
  #upd171013
  def construction_and_customer_select
     @construction_name = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_name).flatten.join(" ")
	 @customer_id = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:customer_id).flatten.join(" ")
	 
	 #add170830
	 #郵便番号・住所
	 @post = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:post).flatten.join(" ")
	 add1 = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:address).flatten.join(" ")
	 #番地  add171006(仮)
	 num = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:house_number).flatten.join(" ")
	 add2 = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:address2).flatten.join(" ")
	 
	 @address = ""
	 if add1.present?
	   @address = add1 
	 end
	 
	 #番地
	 if num.present?
	   @house_number = num 
	 end
	 
	 #add171006(仮)
	 #if num.present?
	 #  @address += num 
	 #end
	 
	 if add2.present?
	   @address2 = add2 
	   #@address += add2 
	 end
	 #add end
	 
  end
  
  #見積書をもとに、初期情報をセットする
  def quotation_header_select
    
	 @construction_name = QuotationHeader.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_name).flatten.join(" ")
	 
	 customer = QuotationHeader.where(:id => params[:id]).where("id is NOT NULL").pluck(:customer_id).flatten.join(" ")
     @customer_id = CustomerMaster.where(:id => customer).where("id is NOT NULL").pluck(:customer_name, :id)
	 
	 #郵便番号（*工事場所）
     @post = QuotationHeader.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_post).flatten.join(" ")
	 
	 #住所（*工事場所）
	 @address = QuotationHeader.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_place).flatten.join(" ")
 
  end
  
  #納品書をもとに、初期情報をセットする
  def delivery_slip_header_select
    
	 @construction_name = DeliverySlipHeader.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_name).flatten.join(" ")
	 
	 customer = DeliverySlipHeader.where(:id => params[:id]).where("id is NOT NULL").pluck(:customer_id).flatten.join(" ")
     @customer_id = CustomerMaster.where(:id => customer).where("id is NOT NULL").pluck(:customer_name, :id)
	 
	 #郵便番号（*工事場所）
     @post = DeliverySlipHeader.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_post).flatten.join(" ")
	 
	 #住所（*工事場所）
	 @address = DeliverySlipHeader.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_place).flatten.join(" ")
 
  end
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_construction_datum
	  #binding.pry
	  
      @construction_datum = ConstructionDatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def construction_datum_params
      params.require(:construction_datum).permit(:construction_code, :construction_name, :alias_name, :reception_date, :customer_id, :construction_start_date, 
      :construction_end_date, :construction_period_start, :construction_period_end, :post, :address, :house_number, :address2, :latitude, :longitude, :construction_detail, :attention_matter, 
      :working_safety_matter_id, :working_safety_matter_name, :quotation_header_id, :delivery_slip_header_id, :billed_flag, :calculated_flag)
    end
end
