class DailyLoanHeadersController < ApplicationController
  before_action :set_daily_loan_header, only: [:show, :edit, :update, :destroy]

  # GET /daily_loan_headers
  # GET /daily_loan_headers.json
  def index
    #@daily_loan_headers = DailyLoanHeader.all
  
    #ransack保持用コード
    query = params[:q]
    
    query ||= eval(cookies[:recent_search_history].to_s) 
    @q = DailyLoanHeader.ransack(query)
    
    #ransack保持用コード
     search_history = {
     value: params[:q],
     expires: 240.minutes.from_now
     }
     cookies[:recent_search_history] = search_history if params[:q].present?
    #
  
    @daily_loan_headers = @q.result(distinct: true)
    @daily_loan_headers  = @daily_loan_headers.page(params[:page])  #kaminari用
    
  end

  # GET /daily_loan_headers/1
  # GET /daily_loan_headers/1.json
  def show
  end

  # GET /daily_loan_headers/new
  def new
    @daily_loan_header = DailyLoanHeader.new
  end

  # GET /daily_loan_headers/1/edit
  def edit
  end

  # POST /daily_loan_headers
  # POST /daily_loan_headers.json
  def create
    @daily_loan_header = DailyLoanHeader.new(daily_loan_header_params)

    respond_to do |format|
      if @daily_loan_header.save
        format.html { redirect_to @daily_loan_header, notice: 'Daily loan header was successfully created.' }
        format.json { render :show, status: :created, location: @daily_loan_header }
      else
        format.html { render :new }
        format.json { render json: @daily_loan_header.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /daily_loan_headers/1
  # PATCH/PUT /daily_loan_headers/1.json
  def update
    respond_to do |format|
      if @daily_loan_header.update(daily_loan_header_params)
        format.html { redirect_to @daily_loan_header, notice: 'Daily loan header was successfully updated.' }
        format.json { render :show, status: :ok, location: @daily_loan_header }
      else
        format.html { render :edit }
        format.json { render json: @daily_loan_header.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /daily_loan_headers/1
  # DELETE /daily_loan_headers/1.json
  def destroy
    @daily_loan_header.destroy
    respond_to do |format|
      format.html { redirect_to daily_loan_headers_url, notice: 'Daily loan header was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_daily_loan_header
      @daily_loan_header = DailyLoanHeader.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def daily_loan_header_params
      params.require(:daily_loan_header).permit(:occurred_on, :lend, :borrow)
    end
end
