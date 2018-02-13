class SchedulesController < ApplicationController
  before_action :set_schedule, only: [:show, :edit, :update, :destroy]

  # GET /schedules
  # GET /schedules.json
  def index
    #@schedules = Schedule.all
	
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
	@q = Schedule.ransack(query)
     
	#ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
	 
	@schedules = @q.result(distinct: true)
	
  end

  # GET /schedules/1
  # GET /schedules/1.json
  def show
  end

  # GET /schedules/new
  def new
    @schedule = Schedule.new
	
	#工事一覧画面から遷移した場合
    if params[:move_flag] == "1"
      if params[:construction_id].present?
        construction_id = params[:construction_id]
        @construction_data = ConstructionDatum.where("id >= ?", construction_id)
	  end
    end
	
  end

  # GET /schedules/1/edit
  def edit
  end

  # POST /schedules
  # POST /schedules.json
  def create
    @schedule = Schedule.new(schedule_params)

    respond_to do |format|
      if @schedule.save
        #format.html { redirect_to @schedule, notice: 'Schedule was successfully created.' }
        #format.json { render :show, status: :created, location: @schedule }
      
	    format.html {redirect_to schedule_path(@schedule, :construction_id => params[:construction_id], 
         :move_flag => params[:move_flag])}
		 
	  else
        format.html { render :new }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /schedules/1
  # PATCH/PUT /schedules/1.json
  def update
    respond_to do |format|
      if @schedule.update(schedule_params)
        #format.html { redirect_to @schedule, notice: 'Schedule was successfully updated.' }
        #format.json { render :show, status: :ok, location: @schedule }
		
		format.html {redirect_to schedule_path(@schedule, :construction_id => params[:construction_id], 
         :move_flag => params[:move_flag])}
		 
      else
        format.html { render :edit }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /schedules/1
  # DELETE /schedules/1.json
  def destroy
    @schedule.destroy
    respond_to do |format|
      #format.html { redirect_to schedules_url, notice: 'Schedule was successfully destroyed.' }
      #format.json { head :no_content }
	  format.html {redirect_to schedules_path( :construction_id => params[:construction_id], 
         :move_flag => params[:move_flag])}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_schedule
      @schedule = Schedule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def schedule_params
      params.require(:schedule).permit(:construction_datum_id, :content_name, :estimated_start_date, :estimated_end_date, :work_start_date, :work_end_date)
    end
end
