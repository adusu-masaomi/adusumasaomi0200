class MonthlyProfitsController < ApplicationController
  before_action :set_monthly_profit, only: [:show, :edit, :update, :destroy]

  # GET /monthly_profits
  # GET /monthly_profits.json
  def index
    #@monthly_profits = MonthlyProfit.all
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)      
    
    #ransack保持用--上記はこれに置き換える
    @q = MonthlyProfit.ransack(query)   
        
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 480.minutes.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    ###
    
    
    @monthly_profits = @q.result(distinct: true)
    #
    #
    @monthly_profits  = @monthly_profits.page(params[:page])  #kaminari用
    
    
    #月次利益データの集計処理
    if params[:setCalculate] == "true"
      occurred_on = params[:q][:occurred_on]
      
      require './app/controllers/calculate_monthly_profit'
      calc = CalculateMonthlyProfit.new
      calc.set_monthly_profit(occurred_on)
      
    end
    
    
    if params[:format] == "pdf" 
      
      @from_date = nil
      @to_date = nil
      
      if query["occurred_on_gteq"].present?
        @from_date = query["occurred_on_gteq"].to_date
      end
      if query["occurred_on_lteq"].present?
        @to_date = query["occurred_on_lteq"].to_date
      end
      
      #binding.pry
      
      #荒利集計PDF発行
      respond_to do |format|
        #binding.pry
        
        format.html # index.html.erb
        format.pdf do
          report = MonthlyGrossProfitPDF.create(@monthly_profits, @from_date, @to_date)
        
          # ブラウザでPDFを表示する
          # disposition: "inline" によりダウンロードではなく表示させている
          send_data(
          report.generate,
          filename:  "monthly_gross_profit.pdf",
          type:        "application/pdf",
          disposition: "inline")
        end
      end
    end
    
    
  end

  # GET /monthly_profits/1
  # GET /monthly_profits/1.json
  def show
  end

  # GET /monthly_profits/new
  def new
    @monthly_profit = MonthlyProfit.new
  end

  # GET /monthly_profits/1/edit
  def edit
  end

  # POST /monthly_profits
  # POST /monthly_profits.json
  def create
    @monthly_profit = MonthlyProfit.new(monthly_profit_params)

    respond_to do |format|
      if @monthly_profit.save
        format.html { redirect_to @monthly_profit, notice: 'Monthly profit was successfully created.' }
        format.json { render :show, status: :created, location: @monthly_profit }
      else
        format.html { render :new }
        format.json { render json: @monthly_profit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /monthly_profits/1
  # PATCH/PUT /monthly_profits/1.json
  def update
    respond_to do |format|
      if @monthly_profit.update(monthly_profit_params)
        format.html { redirect_to @monthly_profit, notice: 'Monthly profit was successfully updated.' }
        format.json { render :show, status: :ok, location: @monthly_profit }
      else
        format.html { render :edit }
        format.json { render json: @monthly_profit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /monthly_profits/1
  # DELETE /monthly_profits/1.json
  def destroy
    @monthly_profit.destroy
    respond_to do |format|
      format.html { redirect_to monthly_profits_url, notice: 'Monthly profit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_monthly_profit
      @monthly_profit = MonthlyProfit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def monthly_profit_params
      params.require(:monthly_profit).permit(:occurred_on, :sales, :variable_cost, :gross_profit, :expense, :repayment)
    end
end
