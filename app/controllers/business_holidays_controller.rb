class BusinessHolidaysController < ApplicationController
  before_action :set_business_holiday, only: [:show, :edit, :update, :destroy]

  # GET /business_holidays
  # GET /business_holidays.json
  def index
    #@business_holidays = BusinessHoliday.all
	
	#ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)  	
     
	 
	#@q = ConstructionDailyReport.ransack(params[:q])  
    #ransack保持用--上記はこれに置き換える
	@q = BusinessHoliday.ransack(query)
     
	#ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
	 
    @business_holidays = @q.result(distinct: true)
    @business_holidays = @business_holidays.page(params[:page])
	
  end

  # GET /business_holidays/1
  # GET /business_holidays/1.json
  def show
  
  end

  # GET /business_holidays/new
  def new
    @business_holiday = BusinessHoliday.new
	
	
	#続けて入力する場合に、元の日付+1日をセットする。
	if params[:working_date_saved].present?
	  require 'rubygems'
      require 'active_support'

	  d = params[:working_date_saved]
	  date = Date.parse(d)
	  #１日加える
	  date += 1.days
	  
	  @business_holiday.working_date = date
	end
	
  end

  # GET /business_holidays/1/edit
  def edit
  end

  # POST /business_holidays
  # POST /business_holidays.json
  def create
    @business_holiday = BusinessHoliday.new(business_holiday_params)

    respond_to do |format|
      if @business_holiday.save
        format.html { redirect_to @business_holiday, notice: 'Business holiday was successfully created.' }
        format.json { render :show, status: :created, location: @business_holiday }
      else
        format.html { render :new }
        format.json { render json: @business_holiday.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /business_holidays/1
  # PATCH/PUT /business_holidays/1.json
  def update
    respond_to do |format|
      if @business_holiday.update(business_holiday_params)
        format.html { redirect_to @business_holiday, notice: 'Business holiday was successfully updated.' }
        format.json { render :show, status: :ok, location: @business_holiday }
      else
        format.html { render :edit }
        format.json { render json: @business_holiday.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /business_holidays/1
  # DELETE /business_holidays/1.json
  def destroy
    @business_holiday.destroy
    respond_to do |format|
      format.html { redirect_to business_holidays_url, notice: 'Business holiday was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  #ajax
  #
  #日付のパラメータから休日フラグを返す
  def get_business_holiday
    business_holiday_record  = BusinessHoliday.where(:working_date => params[:working_date]).first
	
    if business_holiday_record.present?
	  @holiday_flag = business_holiday_record.holiday_flag
	end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_business_holiday
      @business_holiday = BusinessHoliday.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def business_holiday_params
      params.require(:business_holiday).permit(:working_date, :holiday_flag)
    end
end
