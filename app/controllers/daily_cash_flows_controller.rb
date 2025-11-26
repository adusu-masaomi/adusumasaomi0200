class DailyCashFlowsController < ApplicationController
  before_action :set_daily_cash_flow, only: [:show, :edit, :update, :destroy]

  # GET /daily_cash_flows
  # GET /daily_cash_flows.json
  def index
    #@daily_cash_flows = DailyCashFlow.all
    
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s) 
    @q = DailyCashFlow.ransack(query)
    
    #ransack保持用コード
     search_history = {
     value: params[:q],
     expires: 240.minutes.from_now
     }
     cookies[:recent_search_history] = search_history if params[:q].present?
    #
    @daily_cash_flows = @q.result(distinct: true)
    
    @daily_cash_flows  = @daily_cash_flows.page(params[:page])  #kaminari用
  end

  # GET /daily_cash_flows/1
  # GET /daily_cash_flows/1.json
  def show
  end

  # GET /daily_cash_flows/new
  def new
    @daily_cash_flow = DailyCashFlow.new
  end

  # GET /daily_cash_flows/1/edit
  def edit
  end

  # POST /daily_cash_flows
  # POST /daily_cash_flows.json
  def create
    @daily_cash_flow = DailyCashFlow.new(daily_cash_flow_params)

    respond_to do |format|
      if @daily_cash_flow.save
        format.html { redirect_to @daily_cash_flow, notice: 'Daily cash flow was successfully created.' }
        format.json { render :show, status: :created, location: @daily_cash_flow }
      else
        format.html { render :new }
        format.json { render json: @daily_cash_flow.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /daily_cash_flows/1
  # PATCH/PUT /daily_cash_flows/1.json
  def update
    respond_to do |format|
      if @daily_cash_flow.update(daily_cash_flow_params)
        format.html { redirect_to @daily_cash_flow, notice: 'Daily cash flow was successfully updated.' }
        format.json { render :show, status: :ok, location: @daily_cash_flow }
      else
        format.html { render :edit }
        format.json { render json: @daily_cash_flow.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /daily_cash_flows/1
  # DELETE /daily_cash_flows/1.json
  def destroy
    @daily_cash_flow.destroy
    respond_to do |format|
      format.html { redirect_to daily_cash_flows_url, notice: 'Daily cash flow was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_daily_cash_flow
      @daily_cash_flow = DailyCashFlow.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def daily_cash_flow_params
      params.require(:daily_cash_flow).permit(:cash_flow_date, :income, :expence, :previous_balance, :balance, 
                     :plan_actual_flag, :completed_flag, :income_completed_flag, :expence_completed_flag)
    end
end
