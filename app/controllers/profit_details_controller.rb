class ProfitDetailsController < ApplicationController
  before_action :set_profit_detail, only: [:show, :edit, :update, :destroy]

  # GET /profit_details
  # GET /profit_details.json
  def index
    #@profit_details = ProfitDetail.all
    
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)      
    
    #ransack保持用--上記はこれに置き換える
    @q = ProfitDetail.ransack(query)   
        
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 480.minutes.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    ##
    
    @profit_details = @q.result(distinct: true)
    
    @profit_details  = @profit_details.page(params[:page])  #kaminari用
    
    if params[:format] == "pdf" 
      
      @from_date = nil
      @to_date = nil
      
      if query["occurred_on_gteq"].present?
        @from_date = query["occurred_on_gteq"].to_date
      end
      if query["occurred_on_lteq"].present?
        @to_date = query["occurred_on_lteq"].to_date
      end
      
      #荒利集計PDF発行
      respond_to do |format|
        format.html # index.html.erb
        format.pdf do
          
          case params[:print_type]
            when "1"
              report = ProfitDetailConstructionPDF.create(@profit_details, @from_date, @to_date)
            when "2"
              report = ProfitDetailCostPDF.create(@profit_details, @from_date, @to_date)
            when "3"
              report = ProfitDetailRepaymentPDF.create(@profit_details, @from_date, @to_date)
            else
          end
          
          # ブラウザでPDFを表示する
          # disposition: "inline" によりダウンロードではなく表示させている
          send_data(
          report.generate,
          filename:  "profit_detail.pdf",
          type:        "application/pdf",
          disposition: "inline")
        end
      end
    end
    
  end

  # GET /profit_details/1
  # GET /profit_details/1.json
  def show
  end

  # GET /profit_details/new
  def new
    @profit_detail = ProfitDetail.new
  end

  # GET /profit_details/1/edit
  def edit
  end

  # POST /profit_details
  # POST /profit_details.json
  def create
    @profit_detail = ProfitDetail.new(profit_detail_params)

    respond_to do |format|
      if @profit_detail.save
        format.html { redirect_to @profit_detail, notice: 'Profit detail was successfully created.' }
        format.json { render :show, status: :created, location: @profit_detail }
      else
        format.html { render :new }
        format.json { render json: @profit_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /profit_details/1
  # PATCH/PUT /profit_details/1.json
  def update
    respond_to do |format|
      if @profit_detail.update(profit_detail_params)
        format.html { redirect_to @profit_detail, notice: 'Profit detail was successfully updated.' }
        format.json { render :show, status: :ok, location: @profit_detail }
      else
        format.html { render :edit }
        format.json { render json: @profit_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profit_details/1
  # DELETE /profit_details/1.json
  def destroy
    @profit_detail.destroy
    respond_to do |format|
      format.html { redirect_to profit_details_url, notice: 'Profit detail was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profit_detail
      @profit_detail = ProfitDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profit_detail_params
      params.require(:profit_detail).permit(:occurred_on, :cost_id, :table_type_id, :table_id)
    end
end
