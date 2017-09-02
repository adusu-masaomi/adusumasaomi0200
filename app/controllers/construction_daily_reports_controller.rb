class ConstructionDailyReportsController < ApplicationController
  before_action :set_construction_daily_report, only: [:show, :edit, :update, :destroy]
  
  #新規登録の画面引継用
  @@construction_working_date = ""
  @@construction_datum_id = []
  @@new_flag = []
  
  # GET /construction_daily_reports
  # GET /construction_daily_reports.json
  def index
    # @construction_daily_reports = ConstructionDailyReport.all
     
	 #ransack保持用コード
     query = params[:q]
     query ||= eval(cookies[:recent_search_history].to_s)  	
		
     
	 if params[:move_flag] == "1"
	   #工事一覧画面から遷移した場合
	   construction_id = params[:construction_id]
	   query = {"construction_datum_id_eq"=> construction_id }
	 end
	 
	 #@q = ConstructionDailyReport.ransack(params[:q])  
     #ransack保持用--上記はこれに置き換える
	 @q = ConstructionDailyReport.ransack(query)
     
	 #ransack保持用コード
     search_history = {
     value: params[:q],
     expires: 240.minutes.from_now
     }
     cookies[:recent_search_history] = search_history if params[:q].present?
     #
	 
	 @construction_daily_reports = @q.result(distinct: true)
     @construction_daily_reports = @construction_daily_reports.page(params[:page])
   
    # @users = User.all.order(sort_column + ' ' + sort_direction)　
    
    @construction_data = ConstructionDatum.all
    @staff = Staff.all
    # @staff_pay = Staff.all
   
    
    respond_to do |format|
      format.html
      format.csv { send_data @construction_daily_reports.to_csv.encode("SJIS"), type: 'text/csv; charset=shift_jis', disposition: 'attachment' }
    
	  #pdf
      #global set
      $construction_daily_reports = @construction_daily_reports
      
	  format.pdf do
        case params[:pdf_flag] 
		  when "1"
          #労務費集計表
		    if confirm_outsourcing == false
            #縦型PDF
			  if exist_takano == false
                report = LaborCostSummaryPDF.create @construction_daily_reports 
			  else
			    report = LaborCostSummaryMasaomiPDF.create @construction_daily_reports
			  end
            else
            #横型PDF
              report = LaborCostSummaryLandscapePDF.create @construction_daily_reports
		    end
		  when "2"
          #作業日報
		    report = DailyWorkReportPDF.create @daily_work_report
		end
		
        
		
		#case params[:pdf_flag] 
		#  when "1"
        #    report = LaborCostSummaryPDF.create @construction_daily_reports 
        #  when "2"
        #  #横型
        #    report = LaborCostSummaryLandscapePDF.create @construction_daily_reports 
        #end
		
		# ブラウザでPDFを表示する
        send_data(
          report.generate,
          filename:  "labor_cost_summary.pdf",
          type:        "application/pdf",
          disposition: "inline")
      end
      #
	
	
	end
  	
  end
  
  
  #高野（応援？）がいる場合のチェク
  def exist_takano
    takano = @construction_daily_reports.where('staff_id= ?', '4')
    
    if takano.present?
       return true
	else   
	   return false
    end
  
  end
  
  
  def confirm_outsourcing
  #外注さんが作業に関わっているかどうかのチェック(PDF用)
  #(社員IDが5または6の場合。)
    outsourcing = @construction_daily_reports.where('staff_id= ? OR staff_id= ?', '5', '6')
    
    if outsourcing.present?
       return true
	else   
	   return false
    end
    
  end
  
  # GET /construction_daily_reports/1
  # GET /construction_daily_reports/1.json
  def show
    @staff_pay = Staff.none
    #新規登録の画面引継用
	#binding.pry
    @@construction_working_date = @construction_daily_report.working_date
    @@construction_datum_id = @construction_daily_report.construction_datum_id
    @@working_details = @construction_daily_report.working_details
  end

  # GET /construction_daily_reports/new
  def new
    @construction_daily_report = ConstructionDailyReport.new
    @staff = Staff.all
	
	@construction_daily_report.build_construction_datum
	@construction_datum = ConstructionDatum.new
	
	#初期値をセット(show画面からの遷移時のみ)
	@@new_flag = params[:new_flag]
	if @@new_flag == "1"
      @construction_daily_report.working_date = @@construction_working_date
      @construction_daily_report.construction_datum_id = @@construction_datum_id
      @construction_daily_report.working_details = @@working_details
	end
	
    #工事一覧画面から遷移した場合
    if params[:move_flag] == "1"
      if params[:construction_id].present?
        construction_id = params[:construction_id]
        @construction_data = ConstructionDatum.where("id >= ?", construction_id)
		
	  end
    end
  end

  # GET /construction_daily_reports/1/edit
  def edit
    @staff_pay = Staff.where(["id = ?", @construction_daily_report.staff_id]).pluck(:daily_pay)
    @staff = Staff.new
	
	@construction_data = ConstructionDatum.where(["id = ?", @construction_daily_report.construction_datum_id])
	
    #工事Ｎｏの訂正可能にする
    #upd170707
    construction_all = ConstructionDatum.all
    @construction_data += construction_all
	#
	
	@construction_date = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_start_date, :id)
	
  end

  # POST /construction_daily_reports
  # POST /construction_daily_reports.json
  def create
    # ??was erased??
	@construction_daily_report = ConstructionDailyReport.new(construction_daily_report_params)
	
	
    respond_to do |format|
      if @construction_daily_report.save 
        #format.html { redirect_to @construction_daily_report, notice: 'Construction daily report was successfully created.' }
        #format.json { render :show, status: :created, location: @construction_daily_report }
		
        format.html {redirect_to construction_daily_report_path(@construction_daily_report, :construction_id => params[:construction_id], 
         :move_flag => params[:move_flag])}
		 
      else
        format.html { render :new }
        format.json { render json: @construction_daily_report.errors, status: :unprocessable_entity }
      end
	  
	  #工事開始・終了日を更新
	  @construction_daily_report.assign_attributes(construction_data_params)
	  @construction_daily_report.update(construction_data_params)
      
    end
  end

  # PATCH/PUT /construction_daily_reports/1
  # PATCH/PUT /construction_daily_reports/1.json
  def update
    respond_to do |format|
      
	  # params = { construction_daily_report: { construction_datum_attributes: { construction_start_date: construction_start_date } } }
	  
	  if @construction_daily_report.update(construction_daily_report_params) 
	  
        #format.html { redirect_to @construction_daily_report, notice: 'Construction daily report was successfully updated.' }
        #format.json { render :show, status: :ok, location: @construction_daily_report }

        format.html {redirect_to construction_daily_report_path(@construction_daily_report, :construction_id => params[:construction_id], 
         :move_flag => params[:move_flag])}
		 
      else
        format.html { render :edit }
        format.json { render json: @construction_daily_report.errors, status: :unprocessable_entity }
      end
      
      @construction_daily_report.update(construction_data_params)  
	 
    end
  end
  
  
  
  # DELETE /construction_daily_reports/1
  # DELETE /construction_daily_reports/1.json
  def destroy
    @construction_daily_report.destroy
    respond_to do |format|
      #format.html { redirect_to construction_daily_reports_url, notice: 'Construction daily report was successfully destroyed.' }
      #format.json { head :no_content }
	  format.html {redirect_to construction_daily_reports_path( :construction_id => params[:construction_id], 
         :move_flag => params[:move_flag])}
    end
  end
  
  # ajax
  def start_day_select
     @construction_date = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_start_date).flatten.join(" ")
  end
  def end_day_select
     @construction_date = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_end_date).flatten.join(" ")
  end
  
  # ajax
  
  #del170707
  #def staff_pay_select
  #   @staff_pay = Staff.where(:id => params[:id]).where("id is NOT NULL").pluck(:daily_pay, :id)
  #end
  
  #upd170707
  def staff_information_select
     @staff_pay = Staff.where(:id => params[:id]).where("id is NOT NULL").pluck(:daily_pay, :id)
     @staff_affiliation = Staff.where(:id => params[:id]).where("id is NOT NULL").pluck(:affiliation_id).flatten.join(" ")
  end
 

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_construction_daily_report
      @construction_daily_report = ConstructionDailyReport.find(params[:id])
    end
	
	# Never trust parameters from the scary internet, only allow the white list through.
    def construction_daily_report_params
        params.require(:construction_daily_report).permit(:working_date, :construction_datum_id, :staff_id, :start_time_1, :end_time_1, 
	                 :start_time_2, :end_time_2, :working_times, :man_month, :labor_cost, :working_details )
    end
    def construction_data_params
    	# params.require(:construction_daily_report).permit(construction_datum_attributes: [:id, :construction_start_date])
        params.require(:construction_daily_report).permit(construction_datum_attributes: [:id, :construction_start_date, :construction_end_date])
    end
	
  end
