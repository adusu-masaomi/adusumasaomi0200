class DailyLoanDetailsController < ApplicationController
  before_action :set_daily_loan_detail, only: [:show, :edit, :update, :destroy]

  # GET /daily_loan_details
  # GET /daily_loan_details.json
  def index
    #@daily_loan_details = DailyLoanDetail.all
    
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s) 
    @q = DailyLoanDetail.ransack(query)
    
    #ransack保持用コード
     search_history = {
     value: params[:q],
     expires: 240.minutes.from_now
     }
     cookies[:recent_search_history] = search_history if params[:q].present?
    #
  
    @daily_loan_details = @q.result(distinct: true)
    @daily_loan_details  = @daily_loan_details.page(params[:page])  #kaminari用
    
  end

  # GET /daily_loan_details/1
  # GET /daily_loan_details/1.json
  def show
  end

  # GET /daily_loan_details/new
  def new
    @daily_loan_detail = DailyLoanDetail.new
  end

  # GET /daily_loan_details/1/edit
  def edit
  end

  # POST /daily_loan_details
  # POST /daily_loan_details.json
  def create
    @daily_loan_detail = DailyLoanDetail.new(daily_loan_detail_params)

    respond_to do |format|
      if @daily_loan_detail.save
        format.html { redirect_to @daily_loan_detail, notice: 'Daily loan detail was successfully created.' }
        format.json { render :show, status: :created, location: @daily_loan_detail }
      else
        format.html { render :new }
        format.json { render json: @daily_loan_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /daily_loan_details/1
  # PATCH/PUT /daily_loan_details/1.json
  def update
    respond_to do |format|
      if @daily_loan_detail.update(daily_loan_detail_params)
        format.html { redirect_to @daily_loan_detail, notice: 'Daily loan detail was successfully updated.' }
        format.json { render :show, status: :ok, location: @daily_loan_detail }
      else
        format.html { render :edit }
        format.json { render json: @daily_loan_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /daily_loan_details/1
  # DELETE /daily_loan_details/1.json
  def destroy
    @daily_loan_detail.destroy
    respond_to do |format|
      format.html { redirect_to daily_loan_details_url, notice: 'Daily loan detail was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_daily_loan_detail
      @daily_loan_detail = DailyLoanDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def daily_loan_detail_params
      params.require(:daily_loan_detail).permit(:table_type_id, :table_id, :lend_borrow_id, :occurred_on, :summary, :amount, :source_id)
    end
end
