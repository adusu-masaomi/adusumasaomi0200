class MonthlyLoansController < ApplicationController
  before_action :set_monthly_loan, only: [:show, :edit, :update, :destroy]

  # GET /monthly_loans
  # GET /monthly_loans.json
  def index
    #@monthly_loans = MonthlyLoan.all
     #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s) 
    @q = MonthlyLoan.ransack(query)
    
    search_history = {
      value: params[:q],
      expires: 240.minutes.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
    @monthly_loans = @q.result(distinct: true)
    @monthly_loans  = @monthly_loans.page(params[:page])  #kaminari用
    
  end

  # GET /monthly_loans/1
  # GET /monthly_loans/1.json
  def show
  end

  # GET /monthly_loans/new
  def new
    @monthly_loan = MonthlyLoan.new
  end

  # GET /monthly_loans/1/edit
  def edit
  end

  # POST /monthly_loans
  # POST /monthly_loans.json
  def create
    @monthly_loan = MonthlyLoan.new(monthly_loan_params)

    respond_to do |format|
      if @monthly_loan.save
        format.html { redirect_to @monthly_loan, notice: 'Monthly loan was successfully created.' }
        format.json { render :show, status: :created, location: @monthly_loan }
      else
        format.html { render :new }
        format.json { render json: @monthly_loan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /monthly_loans/1
  # PATCH/PUT /monthly_loans/1.json
  def update
    respond_to do |format|
      if @monthly_loan.update(monthly_loan_params)
        format.html { redirect_to @monthly_loan, notice: 'Monthly loan was successfully updated.' }
        format.json { render :show, status: :ok, location: @monthly_loan }
      else
        format.html { render :edit }
        format.json { render json: @monthly_loan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /monthly_loans/1
  # DELETE /monthly_loans/1.json
  def destroy
    @monthly_loan.destroy
    respond_to do |format|
      format.html { redirect_to monthly_loans_url, notice: 'Monthly loan was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_monthly_loan
      @monthly_loan = MonthlyLoan.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def monthly_loan_params
      params.require(:monthly_loan).permit(:occur_year_month, :lend, :borrow, :lend_total, :borrow_total, :is_actual)
    end
end
