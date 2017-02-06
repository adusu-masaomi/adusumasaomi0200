class ConstructionCostsController < ApplicationController
  before_action :set_construction_cost, only: [:show, :edit, :update, :destroy]

  # GET /construction_costs
  # GET /construction_costs.json
  def index
    # @construction_costs = ConstructionCost.all
    #@q = ConstructionCost.ransack(params[:q]) 
	
    ###
	#ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)  	

    #ransack保持用--上記はこれに置き換える
    @q = ConstructionCost.ransack(query)   
        
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 30.minutes.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    ###
	
    @construction_costs = @q.result(distinct: true)

   respond_to do |format|
      format.html
      format.csv { send_data @construction_costs.to_csv.encode("SJIS"), type: 'text/csv; charset=shift_jis' }
	  
	  #pdf!!!!!!!
	  #global set
	  $construction_costs = @construction_costs
	  format.pdf do

        report = PurchaseListPDF.create @purchase_list 
        
        # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data(
          report.generate,
          filename:  "purchase_list.pdf",
          type:        "application/pdf",
          disposition: "inline")
      end
      #
    end
  end

  # GET /construction_costs/1
  # GET /construction_costs/1.json
  def show
  end

  # GET /construction_costs/new
  def new
    @construction_cost = ConstructionCost.new
    @construction_cost.build_construction_datum
  end

  # GET /construction_costs/1/edit
  def edit
  end

  # POST /construction_costs
  # POST /construction_costs.json
  def create
    
	#仕入金額・実行金額をセットする
	set_amount
	  
	@construction_cost = ConstructionCost.new(construction_cost_params)

    respond_to do |format|
	  
      if @construction_cost.save
        format.html { redirect_to @construction_cost, notice: 'Construction cost was successfully created.' }
        format.json { render :show, status: :created, location: @construction_cost }
      else
        format.html { render :new }
        format.json { render json: @construction_cost.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /construction_costs/1
  # PATCH/PUT /construction_costs/1.json
  def update
    
	#仕入金額・実行金額をセットする
	set_amount
	
	#binding.pry
	
	respond_to do |format|
      if @construction_cost.update(construction_cost_params)
        format.html { redirect_to @construction_cost, notice: 'Construction cost was successfully updated.' }
        format.json { render :show, status: :ok, location: @construction_cost }
      else
        format.html { render :edit }
        format.json { render json: @construction_cost.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /construction_costs/1
  # DELETE /construction_costs/1.json
  def destroy
    @construction_cost.destroy
    respond_to do |format|
      format.html { redirect_to construction_costs_url, notice: 'Construction cost was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # ajax
  def construction_name_select
     @construction_name = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_name).flatten.join(" ")
  end
  def construction_labor_cost_select
     @construction_labor_cost = ConstructionDailyReport.where(:construction_datum_id => params[:construction_datum_id]).sum(:labor_cost)
  end
  def purchase_order_amount_select
     #ok
	 #@purchase_order_amount = PurchaseDatum.where(:construction_datum_id => params[:construction_datum_id]).group(:purchase_order_datum_id).sum(:purchase_amount).flatten.join(",")
	 #good
	 #@purchase_order_amount = PurchaseDatum.joins(:purchase_order_datum).where(:construction_datum_id => params[:construction_datum_id]).group('purchase_order_data.purchase_order_code').sum(:purchase_amount).flatten.join(",")
	 
	 #@purchase_order_amount = PurchaseDatum.joins(:purchase_order_datum).joins(:SupplierMaster).where(:construction_datum_id => params[:construction_datum_id]).group('purchase_order_data.purchase_order_code').pluck("purchase_order_data.purchase_order_code, supplier_masters.supplier_name, SUM(purchase_data.purchase_amount) ").flatten.join(",")
	 
	 @purchase_order_amount = PurchaseDatum.joins(:purchase_order_datum).joins(:SupplierMaster).joins(:PurchaseDivision).where(:construction_datum_id => params[:construction_datum_id]).group('purchase_order_data.purchase_order_code').pluck("purchase_divisions.purchase_division_long_name, supplier_masters.supplier_name, purchase_order_data.purchase_order_code, SUM(purchase_data.purchase_amount) ").flatten.join(",")
	 
	 
  end
  
  def set_amount
  #仕入金額・実行金額をセットする
    
	#仕入金額
    purchase_amount = PurchaseDatum.where(:construction_datum_id => params[:construction_cost][:construction_datum_id]).sum(:purchase_amount)
    if purchase_amount.present?
	#binding.pry
	  params[:construction_cost][:purchase_amount] = purchase_amount
	end
	
	execution_amount = 0
	#実行金額へ加算
	if params[:construction_cost][:supplies_expense].present?
	  #binding.pry
	  execution_amount += params[:construction_cost][:supplies_expense].to_i
	end
	
	if params[:construction_cost][:labor_cost].present?
	  execution_amount += params[:construction_cost][:labor_cost].to_i
	end
	
	if params[:construction_cost][:misellaneous_expense].present?
	  execution_amount += params[:construction_cost][:misellaneous_expense].to_i
	end
	
	if purchase_amount.present?
	  execution_amount += purchase_amount
	  params[:construction_cost][:execution_amount] = execution_amount.to_s
	end
	
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_construction_cost
      @construction_cost = ConstructionCost.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def construction_cost_params
      params.require(:construction_cost).permit(:construction_datum_id, :supplies_expense, :labor_cost, :misellaneous_expense, :constructing_amount, :purchase_order_amount, 
                                                :purchase_amount, :execution_amount)
    end
end
