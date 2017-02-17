class ConstructionDailyReportsController < ApplicationController
  before_action :set_construction_daily_report, only: [:show, :edit, :update, :destroy]
  
  #V‹K“o˜^‚Ì‰æ–ÊˆøŒp—p
  @@construction_working_date = ""
  @@construction_datum_id = []
  @@new_flag = []
  
  # GET /construction_daily_reports
  # GET /construction_daily_reports.json
  def index
    # @construction_daily_reports = ConstructionDailyReport.all
    
     @q = ConstructionDailyReport.ransack(params[:q])  
     @construction_daily_reports = @q.result(distinct: true)
     @construction_daily_reports = @construction_daily_reports.page(params[:page])
   
    # @users = User.all.order(sort_column + ' ' + sort_direction)@
    
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
        report = LaborCostSummaryPDF.create @construction_daily_reports 
        # ƒuƒ‰ƒEƒU‚ÅPDF‚ð•\Ž¦‚·‚é
        send_data(
          report.generate,
          filename:  "labor_cost_summary.pdf",
          type:        "application/pdf",
          disposition: "inline")
      end
      #
	
	
	end
  	
  end

  # GET /construction_daily_reports/1
  # GET /construction_daily_reports/1.json
  def show
    @staff_pay = Staff.none
    #V‹K“o˜^‚Ì‰æ–ÊˆøŒp—p
	#binding.pry
    @@construction_working_date = @construction_daily_report.working_date
    @@construction_datum_id = @construction_daily_report.construction_datum_id
  
  end

  # GET /construction_daily_reports/new
  def new
    @construction_daily_report = ConstructionDailyReport.new
    @staff = Staff.all
	
	#@construction_daily_report.construction_datum.build
	# !!OK
	@construction_daily_report.build_construction_datum
	
	#@construction_daily_report.create_construction_datum
	
	@construction_datum = ConstructionDatum.new
	
	#‰Šú’l‚ðƒZƒbƒg(show‰æ–Ê‚©‚ç‚Ì‘JˆÚŽž‚Ì‚Ý)
	@@new_flag = params[:new_flag]
	if @@new_flag == "1"
      @construction_daily_report.working_date = @@construction_working_date
      @construction_daily_report.construction_datum_id = @@construction_datum_id
	end
  end

  # GET /construction_daily_reports/1/edit
  def edit
    @staff_pay = Staff.where(["id = ?", @construction_daily_report.staff_id]).pluck(:daily_pay)
    @staff = Staff.new
	
	@construction_data = ConstructionDatum.where(["id = ?", @construction_daily_report.construction_datum_id])
	
	@construction_date = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_start_date, :id)
	
  end

  # POST /construction_daily_reports
  # POST /construction_daily_reports.json
  def create
    # ??was erased??
	@construction_daily_report = ConstructionDailyReport.new(construction_daily_report_params)
	
	
    respond_to do |format|
      if @construction_daily_report.save 
        format.html { redirect_to @construction_daily_report, notice: 'Construction daily report was successfully created.' }
        format.json { render :show, status: :created, location: @construction_daily_report }
      else
        format.html { render :new }
        format.json { render json: @construction_daily_report.errors, status: :unprocessable_entity }
      end
	  
	  #HŽ–ŠJŽnEI—¹“ú‚ðXV
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
	  
        format.html { redirect_to @construction_daily_report, notice: 'Construction daily report was successfully updated.' }
        format.json { render :show, status: :ok, location: @construction_daily_report }
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
      format.html { redirect_to construction_daily_reports_url, notice: 'Construction daily report was successfully destroyed.' }
      format.json { head :no_content }
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
  def staff_pay_select
     @staff_pay = Staff.where(:id => params[:id]).where("id is NOT NULL").pluck(:daily_pay, :id)
  end
 

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_construction_daily_report
      @construction_daily_report = ConstructionDailyReport.find(params[:id])
    end
	
	# Never trust parameters from the scary internet, only allow the white list through.
    def construction_daily_report_params
        params.require(:construction_daily_report).permit(:working_date, :construction_datum_id, :staff_id, :start_time_1, :end_time_1, 
	                 :start_time_2, :end_time_2, :working_times, :man_month, :labor_cost)
    end
    def construction_data_params
    	# params.require(:construction_daily_report).permit(construction_datum_attributes: [:id, :construction_start_date])
        params.require(:construction_daily_report).permit(construction_datum_attributes: [:id, :construction_start_date, :construction_end_date])
    end
	
  end
