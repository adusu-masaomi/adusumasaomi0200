class ConstructionDailyReportsController < ApplicationController
  before_action :set_construction_daily_report, only: [:show, :edit, :update, :destroy]

  # GET /construction_daily_reports
  # GET /construction_daily_reports.json
  def index
    # @construction_daily_reports = ConstructionDailyReport.all
	@q = ConstructionDailyReport.ransack(params[:q])   
	@construction_daily_reports = @q.result(distinct: true)
	@construction_data = ConstructionDatum.all
	@staff = Staff.all
    # @staff_pay = Staff.all
  end

  # GET /construction_daily_reports/1
  # GET /construction_daily_reports/1.json
  def show
    @staff_pay = Staff.none
  end

  # GET /construction_daily_reports/new
  def new
    @construction_daily_report = ConstructionDailyReport.new
	@staff = Staff.all
    # @staff_pay = Staff.none
  end

  # GET /construction_daily_reports/1/edit
  def edit
    #@staff_pay = Staff.where(["id = ?", @construction_daily_report.staff_id]).pluck(:dayly_pay)
	#@staff_pay = Staff.where(["id = ?", @construction_daily_report.staff_id]).pluck(:dayly_pay, :id)
    @staff_pay = Staff.where(["id = ?", @construction_daily_report.staff_id])
	
	#@staff = Staff.where(["id = ?", @construction_daily_report.staff_id])
	# @staff = Staff.all
  end

  # POST /construction_daily_reports
  # POST /construction_daily_reports.json
  def create
    @construction_daily_report = ConstructionDailyReport.new(construction_daily_report_params)

    respond_to do |format|
      if @construction_daily_report.save
        format.html { redirect_to @construction_daily_report, notice: 'Construction daily report was successfully created.' }
        format.json { render :show, status: :created, location: @construction_daily_report }
      else
        format.html { render :new }
        format.json { render json: @construction_daily_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /construction_daily_reports/1
  # PATCH/PUT /construction_daily_reports/1.json
  def update
    respond_to do |format|
      if @construction_daily_report.update(construction_daily_report_params)
        format.html { redirect_to @construction_daily_report, notice: 'Construction daily report was successfully updated.' }
        format.json { render :show, status: :ok, location: @construction_daily_report }
      else
        format.html { render :edit }
        format.json { render json: @construction_daily_report.errors, status: :unprocessable_entity }
      end
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
  def staff_pay_select
     # @staff_pay = Staff.where(:id => params[:id]).where("id is NOT NULL").pluck(:dayly_pay, :id)
	 @staff_pay = Staff.where(:id => params[:id]).where("id is NOT NULL").pluck(:id)
	 @staff = Staff.new
	 # <%= render partial: 'staffs', locals: {:staff_id =>  @construction_daily_report.staff_id} %>
	 # @staff_pay = Staff.where(:id => params[:id]).where("id is NOT NULL").pluck(:dayly_pay)
	 respond_to do |format|
        format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_construction_daily_report
      @construction_daily_report = ConstructionDailyReport.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def construction_daily_report_params
      params.require(:construction_daily_report).permit(:working_date, :construction_datum_id, :staff_id, :start_time_1, :end_time_1, :start_time_2, :end_time_2, :working_times, :man_month, :labor_cost)
    end
  end
