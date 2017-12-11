class QuotationHeaderHistoriesController < ApplicationController
  before_action :set_quotation_header_history, only: [:show, :edit, :update, :destroy]

  # GET /quotation_header_histories
  # GET /quotation_header_histories.json
  def index
    
	if params[:quotation_header_id].present?
      @quotation_header_histories = QuotationHeaderHistory.where(quotation_header_id: params[:quotation_header_id])
	else
	  @quotation_header_histories = QuotationHeaderHistory.all
	end
    
    
    
  end

  # GET /quotation_header_histories/1
  # GET /quotation_header_histories/1.json
  def show
  #  binding.pry
  end

  # GET /quotation_header_histories/new
  def new
    @quotation_header_history = QuotationHeaderHistory.new
  end

  # GET /quotation_header_histories/1/edit
  def edit
  end

  # POST /quotation_header_histories
  # POST /quotation_header_histories.json
  def create
    @quotation_header_history = QuotationHeaderHistory.new(quotation_header_history_params)

    respond_to do |format|
      if @quotation_header_history.save
        format.html { redirect_to @quotation_header_history, notice: 'Quotation header history was successfully created.' }
        format.json { render :show, status: :created, location: @quotation_header_history }
      else
        format.html { render :new }
        format.json { render json: @quotation_header_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quotation_header_histories/1
  # PATCH/PUT /quotation_header_histories/1.json
  def update
    respond_to do |format|
      if @quotation_header_history.update(quotation_header_history_params)
        
		#binding.pry
		
		#format.html { redirect_to @quotation_header_history, notice: 'Quotation header history was successfully updated.' }
        #format.json { render :show, status: :ok, location: @quotation_header_history }
		
		format.html {redirect_to quotation_header_history_path(@quotation_header_history, :quotation_header_id => params[:quotation_header_id] )}
      else
        format.html { render :edit }
        format.json { render json: @quotation_header_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quotation_header_histories/1
  # DELETE /quotation_header_histories/1.json
  def destroy
    
    #ヘッダIDをここで保持(内訳・明細も消すため)
    quotation_header_history_id = @quotation_header_history.id
  
  
    @quotation_header_history.destroy
    
	respond_to do |format|
      #format.html { redirect_to quotation_header_histories_url, notice: 'Quotation header history was successfully destroyed.' }
      #format.json { head :no_content }
	  #upd170626
      format.html {redirect_to quotation_header_histories_path( :quotation_header_history_id => params[:quotation_header_history_id], 
                                                                   :quotation_header_name => params[:quotation_header_name],
                                                                   :quotation_header_id => params[:quotation_header_id] )}
    end
	
	
	#内訳も消す
	QuotationBreakdownHistory.where(quotation_header_history_id: quotation_header_history_id).destroy_all
	#明細も消す
	QuotationDetailsHistory.where(quotation_header_history_id: quotation_header_history_id).destroy_all
	
	
  end
  
  #ajax
  #履歴データへ、元のデータを保管する。
  def set_history
    
	@quotation_header_id = params[:quotation_header_id]
    
	if @quotation_header_id.present?
      @quotation_header = QuotationHeader.find(@quotation_header_id)
      
	  
	  if @quotation_header.present?
	    
	    #見出しデータを履歴に保存する。
		
		#現在日時取得
		require 'date'
		now_datetime = Time.now
		
        quotation_header_history_params = { issue_date: now_datetime, quotation_header_id: @quotation_header_id, quotation_code: @quotation_header.quotation_code, 
          invoice_code: @quotation_header.invoice_code, delivery_slip_code: @quotation_header.delivery_slip_code,
          quotation_date: @quotation_header.quotation_date, construction_datum_id: @quotation_header.construction_datum_id, construction_name: @quotation_header.construction_name, 
          customer_id: @quotation_header.customer_id, customer_name: @quotation_header.customer_name, honorific_id: @quotation_header.honorific_id, responsible1: @quotation_header.responsible1, responsible2: @quotation_header.responsible2,
          post: @quotation_header.post, address: @quotation_header.address, tel: @quotation_header.tel, fax: @quotation_header.fax, construction_period: @quotation_header.construction_period, 
		  construction_place: @quotation_header.construction_place, trading_method: @quotation_header.trading_method, effective_period: @quotation_header.effective_period, 
		  quote_price: @quotation_header.quote_price, execution_amount: @quotation_header.execution_amount, 
          net_amount: @quotation_header.net_amount, last_line_number: @quotation_header.last_line_number }
		
		
		if @quotation_header_history = QuotationHeaderHistory.create(quotation_header_history_params)
		  
		  #内訳・明細履歴データへ保管
		  set_large_middle_history
		  
		end
	  end
	end
   						 
  end
  
  #内訳・明細履歴データへ元のデータを保管する
  def set_large_middle_history
    
    @quotation_detail_large_classification_records = QuotationDetailLargeClassification.where(:quotation_header_id => @quotation_header_id)
    
	if @quotation_detail_large_classification_records.present?
      @quotation_detail_large_classification_records.each do |qdlc|

        quotation_breakdown_history_params = {quotation_header_history_id: @quotation_header_history.id, quotation_items_division_id: qdlc.quotation_items_division_id, 
                working_large_item_id: qdlc.working_large_item_id, working_large_item_name: qdlc.working_large_item_name, 
                working_large_item_short_name: qdlc.working_large_item_short_name, working_large_specification: qdlc.working_large_specification, 
				line_number: qdlc.line_number, quantity: qdlc.quantity, execution_quantity: qdlc.execution_quantity, working_unit_id: qdlc.working_unit_id, 
				working_unit_name: qdlc.working_unit_name, working_unit_price: qdlc.working_unit_price, quote_price: qdlc.quote_price, 
				execution_unit_price: qdlc.execution_unit_price, execution_price: qdlc.execution_price, labor_productivity_unit: qdlc.labor_productivity_unit, 
                labor_productivity_unit_total: qdlc.labor_productivity_unit_total, last_line_number: qdlc.last_line_number, remarks: qdlc.remarks,
                construction_type: qdlc.construction_type , piping_wiring_flag: qdlc.piping_wiring_flag , equipment_mounting_flag: qdlc.equipment_mounting_flag , 
                labor_cost_flag: qdlc.labor_cost_flag }
       
	   if @quotation_breakdown_history = QuotationBreakdownHistory.create(quotation_breakdown_history_params)
	     #明細履歴データへ元のデータを保存させる
		    @quotation_detail_large_classification_id = qdlc.id
		    set_middle_history
       end

      end
    end
  end
  
  #明細履歴データへ元のデータを保管する
  def set_middle_history
    @quotation_detail_middle_classification_records = QuotationDetailMiddleClassification.where(:quotation_header_id => @quotation_header_id, 
             :quotation_detail_large_classification_id => @quotation_detail_large_classification_id)
    if @quotation_detail_middle_classification_records.present?
	
	  #PDF側のrbに対応させる(複雑にさせない）ため、history_id以外のフィールドも全てセットする
	
      @quotation_detail_middle_classification_records.each do |qdlmc|
        quotation_details_history_params = {quotation_header_history_id: @quotation_header_history.id, quotation_breakdown_history_id: @quotation_breakdown_history.id,
                  working_middle_item_id: qdlmc.working_middle_item_id, working_middle_item_name: qdlmc.working_middle_item_name, working_middle_item_short_name: qdlmc.working_middle_item_short_name,
                  line_number: qdlmc.line_number, working_middle_specification: qdlmc.working_middle_specification, quantity: qdlmc.quantity,
                  execution_quantity: qdlmc.execution_quantity, working_unit_id: qdlmc.working_unit_id, working_unit_price: qdlmc.working_unit_price, 
                  quote_price: qdlmc.quote_price, execution_unit_price: qdlmc.execution_unit_price, execution_price: qdlmc.execution_price,
				  labor_productivity_unit: qdlmc.labor_productivity_unit, labor_productivity_unit_total: qdlmc.labor_productivity_unit_total, 
                  remarks: qdlmc.remarks, construction_type: qdlmc.construction_type, piping_wiring_flag: qdlmc.piping_wiring_flag, 
				  equipment_mounting_flag: qdlmc.equipment_mounting_flag, labor_cost_flag: qdlmc.labor_cost_flag }
				  
        @quotation_details_history = QuotationDetailsHistory.create(quotation_details_history_params)
	  end
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quotation_header_history
      @quotation_header_history = QuotationHeaderHistory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quotation_header_history_params
      params.require(:quotation_header_history).permit(:issue_date, :quotation_header_id, :quotation_code, :invoice_code, :delivery_slip_code, 
                                                :quotation_date, :construction_datum_id, :construction_name, :customer_id, 
                                                :customer_name, :honorific_id, :responsible1, :responsible2, 
                                                :post, :address, :tel, :fax, :construction_period, :construction_place, :trading_method, 
                                               :effective_period, :quote_price, :execution_amount, :net_amount, :last_line_number)
    end
end
