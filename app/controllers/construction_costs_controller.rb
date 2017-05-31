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
    
    if params[:move_flag] == "1"
       #工事一覧画面から遷移した場合
       construction_id = params[:construction_id]
       query = {"construction_datum_id_eq"=> construction_id }
    end
	
	#@search = ConstructionCost.search(params[:q])
    
    #ransack保持用--上記はこれに置き換える
    @q = ConstructionCost.ransack(query)   
        
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 480.minutes.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    ###
    
    @construction_costs = @q.result(distinct: true)
    
	
   respond_to do |format|
      format.html
      format.csv { send_data @construction_costs.to_csv.encode("SJIS"), type: 'text/csv; charset=shift_jis' }
      
      #pdf
      #global set
      
      if params[:construction_costs_id].present?
        @construction_costs = ConstructionCost.where(id: params[:construction_costs_id])
        $construction_costs = @construction_costs
      
      else
        $construction_costs = @construction_costs
      end
      
      
      format.pdf do
        
        #集計表発行時にデータの初期値をセットする
        set_default_data
       
		
        report = ConstructionCostSummaryPDF.create @construction_costs 
        
        # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data(
          report.generate,
          filename:  "construction_cost_summary.pdf",
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
    #upd170209 入力時に反映することにした。
    ##set_amount
      
    @construction_cost = ConstructionCost.new(construction_cost_params)

    respond_to do |format|
      
      if @construction_cost.save
        #format.html { redirect_to @construction_cost, notice: 'Construction cost was successfully created.' }
        #format.json { render :show, status: :created, location: @construction_cost }
		
		 format.html {redirect_to construction_cost_path(@construction_cost, :construction_id => params[:construction_id], 
         :move_flag => params[:move_flag])}
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
    #upd170209 入力時に反映することにした。
    #set_amount
    
    respond_to do |format|
      if @construction_cost.update(construction_cost_params)
        #format.html { redirect_to @construction_cost, notice: 'Construction cost was successfully updated.' }
        #format.json { render :show, status: :ok, location: @construction_cost }
		
		format.html {redirect_to construction_cost_path(@construction_cost, :construction_id => params[:construction_id], 
         :move_flag => params[:move_flag])}
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
  
  #集計表発行時にデータの初期値をセットする
  def set_default_data
    
	
	  #params[:construction_datum_id] = @construction_costs.pluck("construction_datum_id")[0].to_s
	  params[:construction_datum_id] = @construction_costs.first.construction_datum_id.to_s
    
	construction_labor_cost = 0
	if @construction_costs.first.labor_cost.nil?
      #労務費をセット
      #construction_labor_cost_select  #サブルーチンへ
	  construction_labor_cost = ConstructionDailyReport.where(:construction_datum_id => params[:construction_datum_id]).sum(:labor_cost)
      if construction_labor_cost.present?
        @construction_costs[0].labor_cost = construction_labor_cost
	  end
    end
	
	#仕入金額をセット
	if @construction_costs[0].purchase_amount == 0
      purchase_amount = PurchaseDatum.where(:construction_datum_id => params[:construction_datum_id]).sum(:purchase_amount)
      if purchase_amount.present?
        @construction_costs[0].purchase_amount = purchase_amount
      end
	  #仕入明細をセット
      purchase_order_amount_select
      if @purchase_order_amount.present?
        @construction_costs[0].purchase_order_amount = @purchase_order_amount
      end
    end
    
    
	#実行金額をセット
	if @construction_costs[0].execution_amount == 0
      execution_amount = construction_labor_cost + purchase_amount
      @construction_costs[0].execution_amount = execution_amount
    end
	
  end

  # ajax
  def construction_name_select
     @construction_name = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:construction_name).flatten.join(" ")
  end
  def construction_labor_cost_select
       
	   
       @construction_labor_cost_origin = ConstructionDailyReport.where(:construction_datum_id => params[:construction_datum_id]).sum(:labor_cost)
       @construction_labor_cost = ConstructionCost.where(:construction_datum_id => params[:construction_datum_id]).pluck(:labor_cost).flatten.join(" ")
       
       if params[:labor_cost].nil? || params[:labor_cost] == "0"
         if @construction_labor_cost.to_i > 0
           @construction_labor_cost = @construction_labor_cost.to_i
         else
		    #upd170330 労務費が故意にゼロの場合もありうる(外注費とするため）
		    @construction_labor_cost = 0
           #@construction_labor_cost = @construction_labor_cost_origin.to_i
         end
       else
         @construction_labor_cost = params[:labor_cost]
       end
    
     
  end
  def purchase_order_amount_select
    
    #仕入明細データをセット 
    #@purchase_order_amount = PurchaseDatum.joins(:purchase_order_datum).joins(:SupplierMaster).joins(:PurchaseDivision).
    #where(:construction_datum_id => params[:construction_datum_id]).
    #group('purchase_order_data.purchase_order_code').
    #pluck("purchase_divisions.purchase_division_long_name, supplier_masters.supplier_name, purchase_order_data.purchase_order_code, SUM(purchase_data.purchase_amount) ").flatten.join(",")
    
    @purchase_order_amount = PurchaseDatum.joins(:purchase_order_datum).joins(:SupplierMaster).joins(:PurchaseDivision).
    where(:construction_datum_id => params[:construction_datum_id]).
    group('purchase_order_data.purchase_order_code').order('purchase_data.division_id, purchase_order_data.purchase_order_code').
    pluck("purchase_divisions.purchase_division_long_name, supplier_masters.supplier_name, purchase_order_data.purchase_order_code, SUM(purchase_data.purchase_amount) ").flatten.join(",")
    
  end
  
  def purchase_amount_etc_select
    
    #仕入金額を取得
    @purchase_amount = PurchaseDatum.where(:construction_datum_id => params[:construction_datum_id]).sum(:purchase_amount)
    
    #消耗品を取得
    @supplies_expense = ConstructionCost.where(:construction_datum_id => params[:construction_datum_id]).pluck(:supplies_expense).flatten.join(" ")
    
    #諸経費を取得
    @misellaneous_expense = ConstructionCost.where(:construction_datum_id => params[:construction_datum_id]).pluck(:misellaneous_expense).flatten.join(" ")
    
    #請負金額を取得
    @constructing_amount = ConstructionCost.where(:construction_datum_id => params[:construction_datum_id]).pluck(:constructing_amount).flatten.join(" ")
    
    
  end
  def purchase_amount_select
    #仕入金額を取得
    @purchase_amount = PurchaseDatum.where(:construction_datum_id => params[:construction_datum_id]).sum(:purchase_amount)
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
