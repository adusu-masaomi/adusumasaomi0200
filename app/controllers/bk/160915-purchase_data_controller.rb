class PurchaseDataController < ApplicationController
  before_action :set_purchase_datum, only: [:show, :edit, :update, :destroy]
  #testing!!
  after_action :set_default_purchase_datum, only: [:show]

  # GET /purchase_data
  # GET /purchase_data.json
  
  def index
  	#@purchase_data = PurchaseDatum.all
    #@v        = PurchaseOrderDatum.search(params[:q])
    #@q        = PurchaseDatum.search(params[:q])
	#@q = PurchaseDatum.search(params[:q])
	#@q = PurchaseDatum.with_purchase_order.ransack(params[:q]) 
	
	@q = PurchaseDatum.ransack(params[:q])   
	@purchase_data = @q.result(distinct: true)
	@purchase_data = @purchase_data.page(params[:page])
	
	@maker_masters = MakerMaster.all
	@purchase_divisions = PurchaseDivision.all
	@supplier_masters = SupplierMaster.all
	@purchase_order_data = PurchaseOrderDatum.all
	@construction_data = ConstructionDatum.all
	@customer_masters = CustomerMaster.all
	
	@material_masters = MaterialMaster.all
	#@material_masters_code = MaterialMaster.select("material_code")
	
	#@material_masters_code = MakerMaster.where(["id = ?", @purchase_datum.material_id])
	#@purchase_unit_prices = PurchaseUnitPrice.where(["supplier_id = ? and material_id = ?", @purchase_datum.supplier_id, @purchase_datum.material_id])
	
	@unit_masters = UnitMaster.all
	@purchase_unit_prices = PurchaseUnitPrice.none  
	
	#if params[:q].present? && params[:q][:with_purchase_order].present?
    #    @purchase_data = @purchase_data.with_purchase_order(params[:q][:with_purchase_order])
    #end
    
	respond_to do |format|
      #@material_masters_code = MaterialMaster.where(["id = ?", @purchase_datum.material_id]).select("material_code")
	  
	  format.html
	  
          require 'kconv'		
          format.csv { send_data @purchase_data.to_csv.kconv(Kconv::SJIS), type: 'text/csv; charset=shift_jis' }

          #format.csv { send_data @purchase_data.to_csv.encode("SJIS"), type: 'text/csv; charset=shift_jis' }
	  
          #format.csv { send_data @purchase_data.to_csv.encode("UTF-16LE"), type: 'text/csv; charset=utf-16le' }
	  
      #format.xls { send_data @purchase_data.to_csv(col_sep: "\t") }
      #format.xlsx do
      #  generate_xlsx # xlsxファイル生成用メソッド
      #end
	end
  end
  

  # GET /purchase_data/1
  # GET /purchase_data/1.json
  def show
  	#️ @purchase_order_datum = PurchaseOrderDatum.find(params[:purchase_order_datum_id])
  	#@purchase_order_datum= PurchaseOrderDatum.where(["id = ?", @purchase_datum.purchase_order_datum_id])
    @purchase_order_data = PurchaseOrderDatum.all
	@material_masters = MaterialMaster.all
	@unit_masters = UnitMaster.all
	@supplier_masters = SupplierMaster.all
	@purchase_divisions = PurchaseDivision.all
  end

  # GET /purchase_data/new
  def new
    @purchase_datum = PurchaseDatum.new
      @purchase_unit_prices = PurchaseUnitPrice.none
      # @purchase_unit_prices.unshift(["選択してください。", ""])
	
      @purchase_datum.build_PurchaseUnitPrice

       #testing!!
       @purchase_datum.purchase_order_datum_id ||= @purchase_datum_order_id
	
  end

  # GET /purchase_data/1/edit
  def edit
  	@purchase_unit_prices = PurchaseUnitPrice.where(["supplier_id = ? and material_id = ?", @purchase_datum.supplier_id, @purchase_datum.material_id])
       
        #@purchase_datum.build_purchase_unit_prices(supplier_id: supplier_id, material_id: material_id) 
        #@purchase_datum.build_purchase_unit_prices

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
       
        #purchase_price = PurchaseUnitPrice.where("supplier_id = ?", @purchase_datum.supplier_id).where("material_id = ?", @purchase_datum.material_id).pluck(:unit_price, :id)
       
        #仕入単価Mも更新する 
        if (params[:purchase_datum][:check_unit] == 'false')
          @purchase_datum.update(purchase_unit_prices_params)         
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
     # pluckで敢えて配列にしています。
	 # @models = Model.where(maker_id: params[:maker_id]).pluck(:name, :id)
	 # @purchase_unit_prices = PurchaseUnitPrice.where(supplier_id: params[:@purchase_data.supplier_id]), material_id: params[:@purchase_data.material_id]).pluck(:id, :unit_price) 　　 
	 #@purchase_unit_prices = PurchaseUnitPrice.where(:supplier_id => params[:supplier_id], :material_id => params[:material_id]).where("supplier_id is NOT NULL").where("material_id is NOT NULL").pluck(:id, :unit_price)
	 # 初期値
     #@purchase_unit_prices.unshift(["選択してください。", ""])
	 
	 @purchase_unit_prices = PurchaseUnitPrice.where(:supplier_id => params[:supplier_id], :material_id => params[:material_id]).where("supplier_id is NOT NULL").where("material_id is NOT NULL").pluck(:unit_price).flatten.join(",")
	 # 初期値
     #@purchase_unit_prices.unshift(["選択してください。", ""])
  end
  def list_price_select
     @material_masters = MaterialMaster.where(:id => params[:material_id]).where("id is NOT NULL").pluck(:list_price)
     #@material_masters = MaterialMaster.where(["id = ?", material_id]).where("material_id is NOT NULL").pluck(:list_price)
  end
  def maker_select
     #@maker_masters = MakerMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:maker_name, :id)
     #@maker_masters = MaterialMaster.joins(:MakerMaster).where(:id => params[:material_id]).where("maker_masters.id = ?", @material_masters_maker_id).pluck("maker_masters.maker_name, maker_masters.id").flatten.join(",")     
     	 
	 
	 #@maker_masters = MaterialMaster.with_maker.where(:id => params[:material_id]).pluck("maker_masters.maker_name, maker_masters.id").flatten.join(",")     
	 @maker_masters = MaterialMaster.with_maker.where(:id => params[:material_id]).pluck("maker_masters.maker_name, maker_masters.id")
	 
  end
  def unit_select
     #@unit_masters = UnitMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:unit_name, :id)
     @unit_masters  = PurchaseUnitPrice.with_unit.where(:supplier_id => params[:supplier_id], :material_id => params[:material_id]).where("supplier_id is NOT NULL").where("material_id is NOT NULL").pluck("unit_masters.unit_name, unit_masters.id")
     
     #単位未登録の場合はデフォルト値をセット
     if @unit_masters.blank?
        @unit_masters  = [["-",1]]
     end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_datum
      @purchase_datum = PurchaseDatum.find(params[:id])

    end
    
    def set_default_purchase_datum
      @purchase_datum_order_id =  params[:purchase_order_datum_id]
      #binding.pry
    end


	# @purchase_datum.update_attributes(params[:purchase_datum])
	
	# Never trust parameters from the scary internet, only allow the white list through.
    def purchase_datum_params
      params.require(:purchase_datum).permit(:purchase_date, :slip_code, :purchase_order_datum_id, :construction_datum_id, :material_id, :material_code, :material_name, :maker_id, :maker_name, :quantity, :unit_id, :purchase_unit_price, :purchase_amount, :list_price, :supplier_id, :division_id  )
    end
    
   def purchase_unit_prices_params
         params.require(:purchase_datum).permit(PurchaseUnitPrice_attributes: [:material_id, :supplier_id, :unit_price])
    end

      #def generate_xlsx
      #Axlsx::Package.new do |p|
      #p.workbook.add_worksheet(name: "シート名") do |sheet|      
      #  sheet.add_row ["First Column", "Second", "Third"]
      #  sheet.add_row [1, 2, 3]
      #end
      #send_data(p.to_stream.read,
      #        type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      #        filename: "sample.xlsx")
      #end
      #end
end
