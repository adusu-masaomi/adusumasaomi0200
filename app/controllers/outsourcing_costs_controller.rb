class OutsourcingCostsController < ApplicationController
  before_action :set_outsourcing_cost, only: [:show, :edit, :update, :destroy]

  #参照
  include ApplicationHelper

  # GET /outsourcing_costs
  # GET /outsourcing_costs.json
  def index
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history_outsourcing].to_s) 
  
    #外注一覧から遷移した場合はデフォルトでクエリーをセット
    if params[:move_flag] == "1"
      purchase_order_datum_id = params[:purchase_order_datum_id]
      query = {"purchase_order_datum_id_eq"=> purchase_order_datum_id}
      #検索用クッキーへも保存
      params[:q] = query
    end
    ##
  
    #@outsourcing_costs = OutsourcingCost.all
    @q = OutsourcingCost.ransack(query)   
    
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history_outsourcing] = search_history if params[:q].present?
    #
    @outsourcing_costs = @q.result(distinct: true)
    
  end

  # GET /outsourcing_costs/1
  # GET /outsourcing_costs/1.json
  def show
  end

  # GET /outsourcing_costs/new
  def new
    @outsourcing_cost = OutsourcingCost.new
  end

  # GET /outsourcing_costs/1/edit
  def edit
  end

  # POST /outsourcing_costs
  # POST /outsourcing_costs.json
  def create
    @outsourcing_cost = OutsourcingCost.new(outsourcing_cost_params)

    respond_to do |format|
      if @outsourcing_cost.save
        format.html { redirect_to @outsourcing_cost, notice: 'Outsourcing cost was successfully created.' }
        format.json { render :show, status: :created, location: @outsourcing_cost }
      else
        format.html { render :new }
        format.json { render json: @outsourcing_cost.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /outsourcing_costs/1
  # PATCH/PUT /outsourcing_costs/1.json
  def update
    
    #仕入データの支払フラグを更新
    update_purchase_data_payment_flag
    
    respond_to do |format|
      if @outsourcing_cost.update(outsourcing_cost_params)
        format.html { redirect_to @outsourcing_cost, notice: 'Outsourcing cost was successfully updated.' }
        format.json { render :show, status: :ok, location: @outsourcing_cost }
      else
        format.html { render :edit }
        format.json { render json: @outsourcing_cost.errors, status: :unprocessable_entity }
      end
    end
  end

  #仕入データの支払フラグを更新
  def update_purchase_data_payment_flag
 
    update_flag = false
    
    #
    supplier_id = nil
    if params[:outsourcing_cost][:staff_id].present?
      supplier_id = getStaffToSupplier(params[:outsourcing_cost][:staff_id].to_i)
    end
    
    
    purchase_data = nil
    
    if supplier_id.present?
      #upd190930
      #将来的にはこの分岐は不要
      
      if params[:outsourcing_cost][:purchase_order_datum_id].present?
        purchase_data = PurchaseDatum.where(:purchase_order_datum_id => params[:outsourcing_cost][:purchase_order_datum_id]).
                           where(:supplier_id => supplier_id).first
      else
        purchase_data = PurchaseDatum.where(:construction_datum_id => params[:outsourcing_cost][:construction_datum_id]).
                           where(:supplier_id => supplier_id).first
      end
    end
    #
    
    
    #支払日入力有、支払金額有、未払金額無しor未払金支払日入力有の場合のみ、支払いフラグを更新。
    #解除は、ないものとする。(したい場合は外注のビュー画面から解除可能)
    if params[:outsourcing_cost]["payment_date(1i)"].present? && params[:outsourcing_cost]["payment_date(2i)"].present? && 
       params[:outsourcing_cost]["payment_date(3i)"].present? && 
       if params[:outsourcing_cost][:payment_amount].present? 
         
         
         
         if params[:outsourcing_cost][:unpaid_amount].blank? || 
            params[:outsourcing_cost][:unpaid_amount] == 0 ||
            (params[:outsourcing_cost]["unpaid_payment_date(1i)"].present? && params[:outsourcing_cost]["unpaid_payment_date(2i)"].present? && 
             params[:outsourcing_cost]["unpaid_payment_date(3i)"].present?)
            
            if purchase_data.present?
                
                update_flag = true
                
                payment_due_date_str = params[:outsourcing_cost]["payment_due_date(1i)"] + "-" + params[:outsourcing_cost]["payment_due_date(2i)"] + 
                                          "-" + params[:outsourcing_cost]["payment_due_date(3i)"]
                payment_due_date = Date.strptime(payment_due_date_str, '%Y-%m-%d')  
                
                payment_date_str = params[:outsourcing_cost]["payment_date(1i)"] + "-" + params[:outsourcing_cost]["payment_date(2i)"] + "-" + params[:outsourcing_cost]["payment_date(3i)"]
                payment_date = Date.strptime(payment_date_str, '%Y-%m-%d')
                
                #add200201
                #資金繰データ(会計)を更新
                outsourcing_amount = params[:outsourcing_cost][:payment_amount].to_i
                @set_cash_flow = SetCashFlow.new
                @set_cash_flow.set_cash_flow_detail_actual_for_outsourcing(params, payment_date, outsourcing_amount)
                #
                                
                if params[:outsourcing_cost]["unpaid_payment_date(1i)"].present? && params[:outsourcing_cost]["unpaid_payment_date(2i)"].present? && 
                   params[:outsourcing_cost]["unpaid_payment_date(3i)"].present?
                #未払金支払日を仕入データにセット
                   #binding.pry
                
                   unpaid_payment_date_str = params[:outsourcing_cost]["unpaid_payment_date(1i)"] + "-" + 
                                          params[:outsourcing_cost]["unpaid_payment_date(2i)"] + "-" + 
                                          params[:outsourcing_cost]["unpaid_payment_date(3i)"]
                   unpaid_payment_date = Date.strptime(unpaid_payment_date_str, '%Y-%m-%d')
                   
                  purchase_params = {outsourcing_payment_flag: 1, payment_due_date: payment_due_date, payment_date: payment_date, unpaid_payment_date: unpaid_payment_date}
                
                  #add200201
                  #資金繰データ(会計)を更新
                  outsourcing_amount = params[:outsourcing_cost][:unpaid_amount].to_i
                  @set_cash_flow = SetCashFlow.new
                  @set_cash_flow.set_cash_flow_detail_actual_for_outsourcing(params, unpaid_payment_date, outsourcing_amount)
                  #
                
                else
                #未払支払日がない場合
                  purchase_params = {outsourcing_payment_flag: 1, payment_due_date: payment_due_date, payment_date: payment_date}
                end             
                
                #purchase_params = {outsourcing_payment_flag: 1, payment_due_date: payment_due_date, payment_date: payment_date}
                
                #ヴァリデーションしない
                purchase_data.assign_attributes(purchase_params)
                purchase_data.save!(:validate => false)
                
            end
            
            #purchase_data = PurchaseDatum.find
            
         end
       end
    
    
    
    elsif params[:outsourcing_cost]["payment_due_date(1i)"].present? && params[:outsourcing_cost]["payment_due_date(2i)"].present? && 
       params[:outsourcing_cost]["payment_due_date(3i)"].present? 
       
       #支払予定日のみ更新
       if purchase_data.present?
                
          update_flag = true
                
          payment_due_date_str = params[:outsourcing_cost]["payment_due_date(1i)"] + "-" + params[:outsourcing_cost]["payment_due_date(2i)"] + 
                                          "-" + params[:outsourcing_cost]["payment_due_date(3i)"]
          payment_due_date = Date.strptime(payment_due_date_str, '%Y-%m-%d')  
                
          purchase_params = {payment_due_date: payment_due_date}
                
          #ヴァリデーションしない
          purchase_data.assign_attributes(purchase_params)
          purchase_data.save!(:validate => false)
      end    
    
    
    end
    
    #支払完了でなければ、チェック解除して更新する
    if !update_flag
      if purchase_data.present?
        purchase_params = {outsourcing_payment_flag: 0}
        #ヴァリデーションしない
        purchase_data.assign_attributes(purchase_params)
        purchase_data.save!(:validate => false)
      end
    end
    
  end

  # DELETE /outsourcing_costs/1
  # DELETE /outsourcing_costs/1.json
  def destroy
    @outsourcing_cost.destroy
    respond_to do |format|
      format.html { redirect_to outsourcing_costs_url, notice: 'Outsourcing cost was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_outsourcing_cost
      @outsourcing_cost = OutsourcingCost.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def outsourcing_cost_params
      #udp190930 
      #purchase_order_datum_id追加
    
      params.require(:outsourcing_cost).permit(:purchase_order_datum_id, :construction_datum_id, :staff_id, :purchase_amount, :supplies_expense, 
                     :labor_cost, :misellaneous_expense, :execution_amount, :billing_amount, :purchase_order_amount, 
                     :closing_date, :source_bank_id, :payment_amount, :unpaid_amount, :payment_due_date, :payment_date, 
                     :unpaid_payment_date)
    end
end
