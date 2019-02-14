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
    if supplier_id.present?
      purchase_data = PurchaseDatum.where(:construction_datum_id => params[:outsourcing_cost][:construction_datum_id]).
                           where(:supplier_id => supplier_id).first
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
            #params[:outsourcing_cost][:unpaid_amount] == 0
            
            #社員IDから仕入先IDを取得
            
            #supplier_id = nil
            #if params[:outsourcing_cost][:staff_id].present?
            #  supplier_id = getStaffToSupplier(params[:outsourcing_cost][:staff_id].to_i)
            #end
            
            #if supplier_id.present?
              
              
            #  purchase_data = PurchaseDatum.where(:construction_datum_id => params[:outsourcing_cost][:construction_datum_id]).
            #               where(:supplier_id => supplier_id).first
            
              if purchase_data.present?
                
                update_flag = true
                
                purchase_params = {outsourcing_payment_flag: 1}
                
                #ヴァリデーションしない
                purchase_data.assign_attributes(purchase_params)
                purchase_data.save!(:validate => false)
                
              end
            #end
            
            #purchase_data = PurchaseDatum.find
            
         end
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
      params.require(:outsourcing_cost).permit(:construction_datum_id, :staff_id, :purchase_amount, :supplies_expense, :labor_cost, :misellaneous_expense, :execution_amount, :billing_amount, :purchase_order_amount, :closing_date, :payment_amount, :unpaid_amount, :payment_due_date, :payment_date, :unpaid_payment_date)
    end
end
