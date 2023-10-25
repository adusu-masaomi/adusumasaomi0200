class ConstructionDailyReportsController < ApplicationController
  before_action :set_construction_daily_report, only: [:show, :edit, :update, :destroy]
  
  #新規登録の画面引継用
  #@@construction_working_date = ""
  #@@construction_datum_id = []
  #@@new_flag = []
  
  #@@construction_id_for_report = nil
    
  # GET /construction_daily_reports
  # GET /construction_daily_reports.json
  def index
    # @construction_daily_reports = ConstructionDailyReport.all
     
    #グラグ画面で保持した工事IDを元に戻す
    #if @@construction_id_for_report.present?
    if session[:construction_id_for_report].present?
      #params[:construction_id] = @@construction_id_for_report
      params[:construction_id] = session[:construction_id_for_report]
      params[:move_flag] = "1"
      #@@construction_id_for_report = nil
      session[:construction_id_for_report] = nil
    end
	 
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)  	
  

    if params[:move_flag] == "1"
      #工事一覧画面から遷移した場合
      construction_id = params[:construction_id]
      query = {"construction_datum_id_eq"=> construction_id }
    end
	 
    if query.present? && query["update_at_gteq"].present?
      #更新日検索をかける場合、日付を-1にする(時差の関係?でうまくできないため)
      #dt = Date.parse(query["update_at_gteq"])
      dt = Time.parse(query["update_at_gteq"])
      dt = dt - (60 * 60 * 9)  #アメリカ時間で９時間進んでいるので、マイナスする
      query["update_at_gteq"] = dt.to_s
      #ransack保持用
      @q = ConstructionDailyReport.ransack(query)
        
      #上記で日付をマイナスしたため、再検索用にまた戻す
      #dt += 1
      dt += (60 * 60 * 9)
      query["update_at_gteq"] = dt.to_s
    else
      #ransack保持用
      @q = ConstructionDailyReport.ransack(query)
    end
     #
     
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
     
    #グラフ用データとして一旦保持
    #@chart_data = @construction_daily_reports
	 
    @construction_daily_reports = @construction_daily_reports.page(params[:page])
	 
    #グラフ用
    # 日ごとの合計値
    #@chart_data = @construction_daily_reports.joins(:construction_datum).order('construction_datum_id ASC').group(:construction_name).sum('working_times / 3600')
   
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
      
      #$outsoucing_staff = nil   
      @outsourcing_staff = nil
      
      format.pdf do
        case params[:pdf_flag] 
        when "1"
          #binding.pry
          
          #労務費集計表
          if confirm_outsourcing == false
            #縦型PDF（外注のいない場合）
            if exist_takano == false
              report = LaborCostSummaryPDF.create @construction_daily_reports 
            else
              report = LaborCostSummaryMasaomiPDF.create @construction_daily_reports
            end
          else
          #横型PDF（外注のいる場合）
            if exist_takano == false
              report = LaborCostSummaryLandscapePDF.create @construction_daily_reports
            else
            #外注＆高野いる場合(ただし、小柳・須戸・高野のペアはないものとする)
              #report = LaborCostSummaryOutsourcingTakanoPDF.create @construction_daily_reports
              report = LaborCostSummaryOutsourcingTakanoPDF.create(@construction_daily_reports, @outsourcing_staff)
            end
          end
        when "2"
          #作業日報
		      #report = DailyWorkReportPDF.create @daily_work_report
          report = DailyWorkReportPDF.create @construction_daily_reports
        end
  
        # ブラウザでPDFを表示する
          send_data(
            report.generate,
            filename:  "labor_cost_summary.pdf",
            type:        "application/pdf",
            disposition: "inline")
      end   #end pdf do
      #
	
    end     #end do
  	
  end
  
  #グラフ表示用
  def index2
    
    if params[:move_flag] == "1"
      #工事一覧画面から遷移した場合
      construction_id = params[:construction_id]
      params[:q] = {"construction_datum_id_eq"=> construction_id }
    end
    #メインの画面からの検索用工事IDを保持
    if params[:construction_id].present?
      #@@construction_id_for_report = params[:construction_id]
      session[:construction_id_for_report] = params[:construction_id]
    end

    @q = ConstructionDailyReport.ransack(params[:q])   
  
    #ransack保持用コード
     #search_history = {
     #value: params[:q],
     #expires: 24.hours.from_now
     #}
     #cookies[:recent_search_history] = search_history if params[:q].present?
     #

    @construction_daily_reports = @q.result(distinct: true)
     
    #グラフ用データとして一旦保持
    @chart_data = @construction_daily_reports

    @construction_daily_reports = @construction_daily_reports.page(params[:page])

    #グラフ用
    # 日ごとの合計値
    @chart_data_times = @construction_daily_reports.joins(:construction_datum).order('construction_datum_id ASC').group(:construction_name).sum('working_times / 3600')
    @chart_data_costs = @construction_daily_reports.joins(:construction_datum).order('construction_datum_id ASC').group(:construction_name).sum('labor_cost')
  
    @construction_data = ConstructionDatum.all
    @staff = Staff.all
  
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
    check_outsourcing_5 = @construction_daily_reports.where('staff_id= ?', '5')
    if check_outsourcing_5.present?
      #$outsoucing_staff = 5
      @outsourcing_staff = 5
    else
      check_outsourcing_6 = @construction_daily_reports.where('staff_id= ?', '6')
      if check_outsourcing_6.present?
        #$outsoucing_staff = 6
        @outsourcing_staff = 6
      end
    end
    
    #if $outsoucing_staff.present?
    if @outsourcing_staff.present?
      return true
    else   
	   return false
    end
    
  end
  
  # GET /construction_daily_reports/1
  # GET /construction_daily_reports/1.json
  def show
    @staff_pay = Staff.none
    
    #del230421
    #新規登録の画面引継用
    #@@construction_working_date = @construction_daily_report.working_date
    #@@construction_datum_id = @construction_daily_report.construction_datum_id
    #@@working_details = @construction_daily_report.working_details
  end

  # GET /construction_daily_reports/new
  def new
    @construction_daily_report = ConstructionDailyReport.new
    @staff = Staff.all
	
    @construction_daily_report.build_construction_datum
    @construction_datum = ConstructionDatum.new
	
    #初期値をセット(show画面からの遷移時のみ)
    #@@new_flag = params[:new_flag]
    #if @@new_flag == "1"
    if params[:new_flag] == "1"
      @construction_daily_report.working_date = params[:working_date]
      @construction_daily_report.construction_datum_id = params[:construction_datum_id]
      @construction_daily_report.working_details = params[:working_details]
      
      #@construction_daily_report.working_date = @@construction_working_date
      #@construction_daily_report.construction_datum_id = @@construction_datum_id
      #@construction_daily_report.working_details = @@working_details
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
