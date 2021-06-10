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
    
    #add210521
    #注文画面でのパラメータを消す
    $delivery_place_flag = nil
    
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
  
    #臨時FAX用
    #binding.pry
    #set_order_data_fax(format)
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
    
	#工事データの初期値をセット
    set_construction_default
	
	#@purchase_order_datum.mail_sent_flag = 0
	
  end

  # GET /purchase_order_data/1/edit
  def edit
    @@update_flag = 2
	
	#工事データの初期値をセット
    set_construction_default
 end
 
  # POST /purchase_order_data
  # POST /purchase_order_data.json
  def create
    @purchase_order_datum = PurchaseOrderDatum.new(purchase_order_datum_params)
    
    #add180919
    #コンスタントへ注文番号を書き込む(先頭記号が変わった時)
    update_constant
    
    #工事データの住所を更新
    update_address_to_construction
    
	#メール送信する(メール送信ボタン押した場合)
	if params[:send].present?
      
      #画面のメアドをグローバルへセット
      $email_responsible = params[:purchase_order_datum][:supplier_master_attributes][:email1]
      
      #add180405
      #CC用に担当者２のアドレスもグローバルへセット
      $email_responsible2 = nil
      if params[:purchase_order_datum][:supplier_master_id].present?
        supplier = SupplierMaster.where(id: params[:purchase_order_datum][:supplier_master_id]).first
         
        if supplier.present? && supplier.email2.present?
          $email_responsible2 = supplier.email2
        end
      end
      #add end
      
      #メール送信フラグをセット
      params[:purchase_order_datum][:mail_sent_flag] = 1
	  @purchase_order_datum = PurchaseOrderDatum.new(purchase_order_datum_params)  #add170922
   
	  PostMailer.send_when_update(@purchase_order_datum).deliver
	end
	
    respond_to do |format|
      if @purchase_order_datum.save
        
        #臨時FAX用
        save_only_flag = true
        set_order_data_fax(format)
        
        if save_only_flag
		      format.html {redirect_to purchase_order_datum_path(@purchase_order_datum, :construction_id => params[:construction_id], :move_flag => params[:move_flag])}
        else
          format.json { render :show, status: :ok, location: @purchase_order_datum }
        end
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
   
    #add201229
    #コンスタントへ注文番号を書き込む(先頭記号が変わった時)
    update_constant
   
    #工事データの住所を更新
    update_address_to_construction
   
    ###
    #メール送信する(メール送信ボタン押した場合)
	  if params[:send].present?
      
      #画面のメアドをグローバルへセット
      $email_responsible = params[:purchase_order_datum][:supplier_master_attributes][:email1]
      
      #CC用に担当者２のアドレスもグローバルへセット
      $email_responsible2 = nil
      if params[:purchase_order_datum][:supplier_master_id].present?
        supplier = SupplierMaster.where(id: params[:purchase_order_datum][:supplier_master_id]).first
         
        if supplier.present? && supplier.email2.present?
          $email_responsible2 = supplier.email2
        end
      end
      #add end
              
      #インスタンスへパラメータを再セット
      reset_parameters
	  
	    #メール送信フラグをセット
      params[:purchase_order_datum][:mail_sent_flag] = 1
	    
      #moved200519
	    #PostMailer.send_when_update(@purchase_order_datum).deliver
	  end
    ###
   
   
   respond_to do |format|
   
     
      if @purchase_order_datum.update(purchase_order_datum_params)
        
        #moved 200519
        ###
        #メール送信する(メール送信ボタン押した場合)
	      if params[:send].present?
          PostMailer.send_when_update(@purchase_order_datum).deliver
	      end
        ###
        
        save_only_flag = true
     
        #臨時FAX用
        set_order_data_fax(format)
     
       
        #format.html { redirect_to @purchase_order_datum, notice: 'Purchase order datum was successfully updated.' }
	      #format.json { render :show, status: :ok, location: @purchase_order_datum , construction_id: params[:construction_id], move_flag: params[:move_flag]}
		    if save_only_flag
    
          format.html {redirect_to purchase_order_datum_path(@purchase_order_datum, :construction_id => params[:construction_id], :move_flag => params[:move_flag])}
		    else
          format.json { render :show, status: :ok, location: @purchase_order_datum }
        
        end
      else
        format.html { render :edit }
        format.json { render json: @purchase_order_datum.errors, status: :unprocessable_entity }
      end
    end
	
	
  end
  
  def set_order_data_fax(format)
    
    if params[:format] == "pdf"
     #ｆａｘ用紙の発行
		  save_only_flag = false
       
		  #global set
      $purchase_order_datum = @purchase_order_datum 
        
      #pdf
	    #@print_type = params[:print_type]
      format.pdf do
        report = OrderNumberFaxPDF.create @order_number_fax 
        # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data(
          report.generate,
          filename:  "order_number_fax.pdf",
          type:        "application/pdf",
          disposition: "inline")
      end
    end
    ##
  end
  
  
  def set_construction_default
  #工事一覧画面等から遷移した場合に、フォームに初期値をセットさせる    
	  case params[:move_flag] 
      when "1"
	   #工事一覧画面から遷移した場合
       construction_id = params[:construction_id]
	   @construction_data = ConstructionDatum.where("id >= ?", construction_id)
	   
      else
       @construction_data = ConstructionDatum.order('construction_code DESC').all
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
    #add180926
    reset_last_number
  
    @purchase_order_datum.destroy
    respond_to do |format|
      #format.html { redirect_to purchase_order_data_url, notice: 'Purchase order datum was successfully destroyed.' }
	  format.html {redirect_to purchase_order_data_path( :construction_id => params[:construction_id], :move_flag => params[:move_flag])}
	  
      format.json { head :no_content }
    end
  end
  
  
  #add180919
  #constantに注文Noを書き込む
  def update_constant
    constant = Constant.find(1)   #id=１に定数ファイルが保管されている
    
    
    #del201229
    #if constant.purchase_order_last_header_code[0,1] != @purchase_order_datum.purchase_order_code[0,1]
      #外注用のアルファベットを除く
      #if @purchase_order_datum.purchase_order_code[0,1] != "M" && 
      #     @purchase_order_datum.purchase_order_code[0,1] != "O"
        
        #(header.ord + 1).chr
        current_header = @purchase_order_datum.purchase_order_code[0,1]
        constant_header = constant.purchase_order_last_header_code[0,1]
        
        current_year = @purchase_order_datum.purchase_order_code[1,2].to_i
        constant_year = constant.purchase_order_last_header_code[1,2].to_i
        
        update_flag = false
    
        if current_header.ord == constant_header.ord
        #コンスタントとアルファベットが同じ場合
          #年が切り替わった場合
          if current_year > constant_year
            update_flag = true
          else  
            #下２桁で比較
            if @purchase_order_datum.purchase_order_code[3,2].to_i >=
              constant.purchase_order_last_header_code[3,2].to_i 
              update_flag = true
            end
          end
        else
        #アルファベットが大きい場合、更新
          if current_header.ord > constant_header.ord
            update_flag = true
          else 
            #年が切り替わった場合
            if current_year > constant_year
              update_flag = true
            end
          end
        end
        
        #アルファベット以下の数値２桁が(AorB..+"xx")constant以上？
        #if @purchase_order_datum.purchase_order_code[1,2].to_i >=
        #   constant.purchase_order_last_header_code[1,2].to_i 
        
        if update_flag == true
          #更新する
          constant_params = { purchase_order_last_header_code: @purchase_order_datum.purchase_order_code}
          constant.update(constant_params)
        
        end
      #end
    #end
  end
  
  #工事データの住所をアプデする
  def update_address_to_construction
    
    
    if params[:purchase_order_datum][:post].present? ||
       params[:purchase_order_datum][:addressX].present?
      
      construction_datum_id = params[:purchase_order_datum][:construction_datum_id].to_i
      construction = ConstructionDatum.find(construction_datum_id)
      if construction.present?
        construction_params = { post: params[:purchase_order_datum][:post],
                                address: params[:addressX],
                                house_number: params[:purchase_order_datum][:house_number],
                                address2: params[:purchase_order_datum][:address2]}
        construction.update(construction_params)
      end
     
    end
    
  end
    
  #add180926
  def reset_last_number
    #Constantの最終番号に該当するものを削除した場合は、直近での最大値を再セットする
    last_number = @purchase_order_datum.purchase_order_code
    remove_id = @purchase_order_datum.id
    constant = Constant.find(1)   #id=１に定数ファイルが保管されている
    
    if constant.present? && constant.purchase_order_last_header_code == last_number
      #注文コードの直近最大値を取得
      #last_new_number = PurchaseOrderDatum.where('purchase_order_code < ?', last_number).maximum(:purchase_order_code)
      last_id = PurchaseOrderDatum.where('id < ?', remove_id).maximum(:id)
      last_new_number = PurchaseOrderDatum.find(last_id).purchase_order_code
      
      #binding.pry
      
      #更新する
      constant_params = { purchase_order_last_header_code: last_new_number}
      constant.update(constant_params)
    end
    
  end
  
  
  #ajax
  def get_last_number_select
    
     
      #crescent = "%" + params[:header] + "%"
     #@purchase_order_datum_new_code = PurchaseOrderDatum.where('purchase_order_code LIKE ?', crescent).all.maximum(:purchase_order_code) 
	  #upd201229
    #自動で番号を繰り上げる
    constant = Constant.find(1)   #id=１に定数ファイルが保管されている
    @purchase_order_datum_new_code = constant.purchase_order_last_header_code
   
    #年の判定
    year = @purchase_order_datum_new_code[1, 2]
    d = Date.today
    
    #binding.pry
    #d.strftime("%y")
    current_year = d.strftime("%y")
    
    #年が違った場合
    if current_year != year
    #新年とみなす
      header = "A"
      
      newNum = current_year + "00"
    else
      #最終番号に１を足す。
	    newStr = @purchase_order_datum_new_code[1, 4]
	    header = @purchase_order_datum_new_code[0, 1]
      
      digit2 = @purchase_order_datum_new_code[3, 2]
      
      if digit2 == "99"
      #99番の場合、アルファベット繰り上げる
        newStr = ((year.to_i) -1) * 100 + 99 #年はそのまま、０がらスタート
        header = (header.ord + 1).chr
      end
      
      newNum = newStr.to_i + 1
      
    end
   
	  #最終番号に１を足す。
	  #newStr = @purchase_order_datum_new_code[1, 4]
	  #header = @purchase_order_datum_new_code[0, 1]
   
	  @purchase_order_datum_new_code = header + newNum.to_s
	 
  end
  
  #頭文字で検索するajax
  def get_supplier_by_character
    
    @suppliers = ""
    
    #params[:header_code]
    if params[:header_code].present?
      sc = params[:header_code].tr('０-９ａ-ｚＡ-Ｚ','0-9a-zA-Z')  #半角にする
      sc = sc.downcase  #小文字にする
      
      @suppliers = SupplierMaster.where(:search_character => sc).pluck("supplier_masters.supplier_name, supplier_masters.id")
      
      if  @suppliers.blank?
        @suppliers = SupplierMaster.all.pluck("supplier_masters.supplier_name, supplier_masters.id")
      end
      
    else 
      @suppliers = SupplierMaster.all.pluck("supplier_masters.supplier_name, supplier_masters.id")
    end
    
    
  end
  
  def get_alias_name
     @alias_name = ConstructionDatum.where(:id => params[:id]).where("id is NOT NULL").pluck(:alias_name).flatten.join(" ")
  end
  def get_email1
     @email1 = SupplierMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:email1).flatten.join(" ")
  end
  
  #add210610
  #住所取得
  def get_address
    @post = ConstructionDatum.where(:id => params[:construction_datum_id]).
                              where("id is NOT NULL").pluck(:post).flatten.join(" ")
    @address = ConstructionDatum.where(:id => params[:construction_datum_id]).
                              where("id is NOT NULL").pluck(:address).flatten.join(" ")
    @house_number = ConstructionDatum.where(:id => params[:construction_datum_id]).
                              where("id is NOT NULL").pluck(:house_number).flatten.join(" ")
    @address2 = ConstructionDatum.where(:id => params[:construction_datum_id]).
                              where("id is NOT NULL").pluck(:address2).flatten.join(" ")
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
