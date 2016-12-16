class PurchaseDataController < ApplicationController
  before_action :set_purchase_datum, only: [:show, :edit, :update, :destroy]
  
  #ransack保持用 
  #before_action only: [:index] do
  #  get_query('query_purchase_data')
  #end
  #ransack保持用
  #def get_query(cookie_key)
  #    cookies.delete(cookie_key) if params[:clear]
  #    cookies[cookie_key] = params[:q].to_json if params[:q]
  #    @query = params[:q].presence || JSON.load(cookies[cookie_key])
  #end

  #新規登録の画面引継用
  @@purchase_datum_purchase_date = ""
  @@purchase_datum_order_id = []
  @@purchase_datum_slip_code = []
  @@purchase_datum_construction_id = []
  @@purchase_datum_notes = ""
  
  @@new_flag = []
  #binding.pry
  
  # GET /purchase_data
  # GET /purchase_data.json
  
  def index
        
        #ransack保持用コード
        query = params[:q]
        query ||= eval(cookies[:recent_search_history].to_s)  	

	#@q = PurchaseDatum.ransack(params[:q]) 
        #ransack保持用--上記はこれに置き換える
        @q = PurchaseDatum.ransack(query)   
        
        #ransack保持用コード
        search_history = {
        value: params[:q],
        expires: 30.minutes.from_now
        }
        cookies[:recent_search_history] = search_history if params[:q].present?
        #

	@purchase_data = @q.result(distinct: true)
	
	#kaminari用設定。
	@purchase_data = @purchase_data.page(params[:page])
	
	@maker_masters = MakerMaster.all
	@purchase_divisions = PurchaseDivision.all
	@supplier_masters = SupplierMaster.all
	@purchase_order_data = PurchaseOrderDatum.all
	@construction_data = ConstructionDatum.all
	@customer_masters = CustomerMaster.all
	
	@material_masters = MaterialMaster.all
	
	@unit_masters = UnitMaster.all
	@purchase_unit_prices = PurchaseUnitPrice.none  
    
	respond_to do |format|
	  
	  format.html
	  
	      #csv
          require 'kconv'		
          format.csv { send_data @purchase_data.to_csv.kconv(Kconv::SJIS), type: 'text/csv; charset=shift_jis' }
      
	  #pdf
	  
	  #global set
	  $purchase_data = @purchase_data
	
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
	
	#仕入表PDF発行
    #respond_to do |format|
    #  format.html # index.html.erb
      
  end
  

  # GET /purchase_data/1
  # GET /purchase_data/1.json
  def show
  	@purchase_order_data = PurchaseOrderDatum.all
    @material_masters = MaterialMaster.all
    @unit_masters = UnitMaster.all
    @supplier_masters = SupplierMaster.all
    @purchase_divisions = PurchaseDivision.all
    
    
    #新規登録の画面引継用
    @@purchase_datum_purchase_date = @purchase_datum.purchase_date
    @@purchase_datum_order_id = @purchase_datum.purchase_order_datum_id
    @@purchase_datum_slip_code = @purchase_datum.slip_code
    @@purchase_datum_construction_id = @purchase_datum.construction_datum_id
	@@purchase_datum_notes = @purchase_datum.notes
    #binding.pry
    
  end

  # GET /purchase_data/new
  def new
    @purchase_datum = PurchaseDatum.new
	
    Time.zone = "Tokyo"
	
      @purchase_unit_prices = PurchaseUnitPrice.none
      @purchase_datum.build_PurchaseUnitPrice
      @purchase_datum.build_MaterialMaster

       @@new_flag = params[:new_flag]

       #binding.pry

       #初期値をセット(show画面からの遷移時のみ)
	   if @@new_flag == "1"
         @purchase_datum.purchase_date ||= @@purchase_datum_purchase_date
	     @purchase_datum.purchase_order_datum_id ||= @@purchase_datum_order_id
	     @purchase_datum.slip_code ||= @@purchase_datum_slip_code 
	     @purchase_datum.construction_datum_id ||= @@purchase_datum_construction_id
		 @purchase_datum.notes ||= @@purchase_datum_notes
	   end
	   
  end

  # GET /purchase_data/1/edit
  def edit
  	@purchase_unit_prices = PurchaseUnitPrice.where(["supplier_id = ? and material_id = ?", @purchase_datum.supplier_id, @purchase_datum.material_id])
    @material_masters = MaterialMaster.where(["id = ?", @purchase_datum.material_id]).pluck(:list_price)
	@maker_masters = MakerMaster.where(["id = ?", @purchase_datum.material_id])
  end

  # POST /purchase_data
  # POST /purchase_data.json
  def create
    @purchase_datum = PurchaseDatum.new(purchase_datum_params)

    respond_to do |format|
      if @purchase_datum.save
        format.html { redirect_to @purchase_datum, notice: 'Purchase datum was successfully created.' }
        format.json { render :show, status: :created, location: @purchase_datum }
       
       #仕入単価を更新
       if (params[:purchase_datum][:check_unit] == 'false')
           @purchase_datum.assign_attributes(purchase_unit_prices_params)
           @purchase_datum.update(purchase_unit_prices_params)
          
           #資材Mも更新
           #save_material_masters
           @purchase_datum.update_attributes(material_masters_params)
       end    
   
      else
        format.html { render :new }
        format.json { render json: @purchase_datum.errors, status: :unprocessable_entity }
      end

       
    end
  end

  # PATCH/PUT /purchase_data/1
  # PATCH/PUT /purchase_data/1.json
  def update
    respond_to do |format|
      if @purchase_datum.update(purchase_datum_params)
        format.html { redirect_to @purchase_datum, notice: 'Purchase datum was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase_datum }
       
        #仕入単価Mも更新する 
        if (params[:purchase_datum][:check_unit] == 'false')
          @purchase_datum.update(purchase_unit_prices_params)
          @purchase_datum.update(material_masters_params)         
        end 

      else
        format.html { render :edit }
        format.json { render json: @purchase_datum.errors, status: :unprocessable_entity }
      end
  
    end
  end

  # DELETE /purchase_data/1
  # DELETE /purchase_data/1.json
  def destroy
    @purchase_datum.destroy
    respond_to do |format|
      format.html { redirect_to purchase_data_url, notice: 'Purchase datum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  # ajax
  def unit_price_select
     @purchase_unit_prices = PurchaseUnitPrice.where(:supplier_id => params[:supplier_id], :material_id => params[:material_id]).where("supplier_id is NOT NULL").where("material_id is NOT NULL").pluck(:unit_price).flatten.join(",")
  end
  def list_price_select
     @material_masters = MaterialMaster.where(:id => params[:material_id]).where("id is NOT NULL").pluck(:list_price)
  end
  def maker_select
     @maker_masters = MaterialMaster.with_maker.where(:id => params[:material_id]).pluck("maker_masters.maker_name, maker_masters.id")
     #未登録(-)の場合はセットしない。
     if @maker_masters == [["-",1]]
        @maker_masters = MaterialMaster.all.pluck("maker_masters.maker_name, maker_masters.id")
     end 
  end
  def unit_select
     @unit_masters  = PurchaseUnitPrice.with_unit.where(:supplier_id => params[:supplier_id], :material_id => params[:material_id]).where("supplier_id is NOT NULL").where("material_id is NOT NULL").pluck("unit_masters.unit_name, unit_masters.id")
     
     #単位未登録の場合はデフォルト値をセット
     if @unit_masters.blank?
        @unit_masters  = [["-",1]]
     end
     
     #未登録(-)の場合はセットしない。
     if @unit_masters  == [["-",1]]
        PurchaseUnitPrice.all.pluck("unit_masters.unit_name, unit_masters.id")
     end 
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_datum
      @purchase_datum = PurchaseDatum.find(params[:id])

    end
	
	# Never trust parameters from the scary internet, only allow the white list through.
    def purchase_datum_params
      params.require(:purchase_datum).permit(:purchase_date, :slip_code, :purchase_order_datum_id, :construction_datum_id, 
                     :material_id, :material_code, :material_name, :maker_id, :maker_name, :quantity, :unit_id, :purchase_unit_price, 
                     :purchase_amount, :list_price, :supplier_id, :division_id, :notes )
    end
    
    def purchase_unit_prices_params
         params.require(:purchase_datum).permit(PurchaseUnitPrice_attributes: [:material_id, :supplier_id, :unit_price])
    end

    def material_masters_params
         params.require(:purchase_datum).permit(MaterialMaster_attributes: [:id,  :last_unit_price, :last_unit_price_update_at ])
    end
    
	#資材Mへ最終単価・日付を更新用
    #def save_material_masters
    #    @material_master = MaterialMaster.where(["id = ?", @purchase_datum.material_id]).first
    # if @material_master.present?
    #    @material_master.last_unit_price = params[:last_unit_price]
    #    @material_master.last_unit_price_update_at = params[:last_unit_price_update_at]
    #    @material_master.save
    # end
    #end
end
