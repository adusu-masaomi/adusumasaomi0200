class PurchaseOrderDataController < ApplicationController
  #layout :layout_by_resource
  #layout '../purchase_order_data/index'
  #layout 'purchase_order_data2/index'
  
  before_action :set_purchase_order_datum, only: [:show, :edit, :update, :destroy]
  
  
  def layout_by_resource
   if params[:order_flag] == true
      'purchase_order_data2'
     else
      'purchase_order_data'
    end
   end

  # Userクラスを作成していないので、擬似的なUser構造体を作る
  #MailUser = Struct.new(:name, :email)

  # GET /purchase_order_data
  # GET /purchase_order_data.json
  def index
    
	#ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)  
    
    case params[:move_flag] 
    when "1"
	   #工事一覧画面から遷移した場合
       construction_id = params[:construction_id]
       query = {"construction_datum_id_eq"=> construction_id }
	   
	#when "2"
	#   #注文一覧画面から遷移した場合
	#   purchase_order_id = params[:purchase_order_id]
    #   query = {"id_eq"=> purchase_order_id }
    end
	
	 #@q = PurchaseOrderDatum.ransack(params[:q])   
	 #ransack保持用--上記はこれに置き換える
     @q = PurchaseOrderDatum.ransack(query)   
     #ransack保持用コード
     search_history = {
     value: params[:q],
     #expires: 240.minutes.from_now
	 expires: 24.hours.from_now
     }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
		
    @purchase_order_data  = @q.result(distinct: true)
    @purchase_order_data  = @purchase_order_data.page(params[:page])


    @construction_data = ConstructionDatum.all
  
end

  # GET /purchase_order_data/1
  # GET /purchase_order_data/1.json
  def show
  end

  @@update_flag = 0

  # GET /purchase_order_data/new
  def new
    @purchase_order_datum = PurchaseOrderDatum.new
    
    #工事データをビルド
	@purchase_order_datum.build_construction_datum
	
    #仕入先マスターをビルド
    #デフォルトのIDは２（＝岡田電気）とする
	#@supplier_master = SupplierMaster.find(2)
    #デフォルトのIDは未選択とする
	@supplier_master = SupplierMaster.find(1)
	@purchase_order_datum.supplier_master = @supplier_master
	
	
    @@update_flag =  1
    
	
  end

  # GET /purchase_order_data/1/edit
  def edit
    @@update_flag = 2
   end
 
  # POST /purchase_order_data
  # POST /purchase_order_data.json
  def create
    @purchase_order_datum = PurchaseOrderDatum.new(purchase_order_datum_params)
    
	#メール送信する(メール送信ボタン押した場合)
	if params[:send].present?
      
      #画面のメアドをグローバルへセット
      $email_responsible = params[:purchase_order_datum][:supplier_master_attributes][:email1]
   
      #メール送信フラグをセット
      params[:purchase_order_datum][:mail_sent_flag] = 1
   
	  PostMailer.send_when_update(@purchase_order_datum).deliver
	end
	
    respond_to do |format|
      if @purchase_order_datum.save
        format.html { redirect_to @purchase_order_datum, notice: 'Purchase order datum was successfully created.' }
        format.json { render :show, status: :created, location: @purchase_order_datum }
      else
        format.html { render :new }
        format.json { render json: @purchase_order_datum.errors, status: :unprocessable_entity }
      end
    end
	
	#メール送信する
	#PostMailer.send_when_update(@purchase_order_datum).deliver
	
  end

  # PATCH/PUT /purchase_order_data/1
  # PATCH/PUT /purchase_order_data/1.json
  def update
   
   #メール送信する(メール送信ボタン押した場合)
	if params[:send].present?
      
      #画面のメアドをグローバルへセット
      $email_responsible = params[:purchase_order_datum][:supplier_master_attributes][:email1]

      #インスタンスへパラメータを再セット
      reset_parameters
	  
	  #メール送信フラグをセット
      params[:purchase_order_datum][:mail_sent_flag] = 1
	  
	  PostMailer.send_when_update(@purchase_order_datum).deliver
	end
	
   
   respond_to do |format|
   
      if @purchase_order_datum.update(purchase_order_datum_params)
        format.html { redirect_to @purchase_order_datum, notice: 'Purchase order datum was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase_order_datum }
      else
        format.html { render :edit }
        format.json { render json: @purchase_order_datum.errors, status: :unprocessable_entity }
      end
    end
	
	
  end
  
  #インスタンスへパラメータを再セットする
  def reset_parameters
    #@purchase_order_datum.construction_datum.alias_name = params[:purchase_order_datum][:construction_datum_attributes][:alias_name]
	@purchase_order_datum.alias_name = params[:purchase_order_datum][:alias_name]
    @purchase_order_datum.purchase_order_code = params[:purchase_order_datum][:purchase_order_code]
    id = params[:purchase_order_datum][:construction_datum_attributes][:id]
    @purchase_order_datum.construction_datum.construction_name = ConstructionDatum.where(:id => id).where("id is NOT NULL").pluck(:construction_name).flatten.join(" ")
  end

  # DELETE /purchase_order_data/1
  # DELETE /purchase_order_data/1.json
  def destroy
    @purchase_order_datum.destroy
    respond_to do |format|
      format.html { redirect_to purchase_order_data_url, notice: 'Purchase order datum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  #ajax
  def get_last_number_select
     crescent = "%" + params[:header] + "%"
     @purchase_order_datum_new_code = PurchaseOrderDatum.where('purchase_order_code LIKE ?', crescent).all.maximum(:purchase_order_code) 
	 
	 #最終番号に１を足す。
	 newStr = @purchase_order_datum_new_code[1, 4]
	 header = @purchase_order_datum_new_code[0, 1]
	 newNum = newStr.to_i + 1
	 
	 @purchase_order_datum_new_code = header + newNum.to_s
	 
  end
  def get_alias_name
     @alias_name = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:alias_name).flatten.join(" ")
  end
  def get_email1
     @email1 = SupplierMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:email1).flatten.join(" ")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_order_datum
      @purchase_order_datum = PurchaseOrderDatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_order_datum_params
      #params.require(:purchase_order_datum).permit(:purchase_order_code, :construction_datum_id, :supplier_master_id , :mail_sent_flag, 
      #               :orders_attributes => [:purchase_order_datum_id, :material_id, :material_code, :material_name, :quantity],
      #               :construction_datum_attributes => [:alias_name])
      params.require(:purchase_order_datum).permit(:purchase_order_code, :construction_datum_id, :supplier_master_id , :alias_name, :mail_sent_flag, 
                     :orders_attributes => [:purchase_order_datum_id, :material_id, :material_code, :material_name, :quantity])
    end
end
