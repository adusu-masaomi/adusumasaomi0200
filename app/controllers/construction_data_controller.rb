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
    expires: 30.minutes.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
	
    @construction_data  = @q.result(distinct: true)
    
    #kaminari用設定
    @construction_data  = @construction_data .page(params[:page])

    @customer_masters = CustomerMaster.all
    
	
	#binding.pry
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
  
    
    @construction_datum = ConstructionDatum.new(construction_datum_params)

    #binding.pry
    
    #工事開始日・終了日（実績）の初期値をセットする
    @construction_datum.construction_start_date = '3000-01-01'
    @construction_datum.construction_end_date = '2000-01-01'
	
    respond_to do |format|

	
      if @construction_datum.save
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
        format.html { redirect_to @construction_datum, notice: 'Construction datum was successfully updated.' }
		
	  	  
		if params[:directions].present?
		  #指示書の発行
		  
		  #global set
          $construction_datum = @construction_datum 
		  
		  
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
  
    
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_construction_datum
	  #binding.pry
      @construction_datum = ConstructionDatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def construction_datum_params
      params.require(:construction_datum).permit(:construction_code, :construction_name, :alias_name, :reception_date, :customer_id, :construction_start_date, 
      :construction_end_date, :construction_period_start, :construction_period_end, :construction_place, :construction_detail, :attention_matter, 
      :working_safety_matter_id, :working_safety_matter_name, :billed_flag)
    end
end
