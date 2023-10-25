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
    
    #注文画面でのパラメータを消す
    $delivery_place_flag = nil
    
    case params[:move_flag] 
    when "1"
      #工事一覧画面から遷移した場合
      construction_id = params[:construction_id]
      query = {"construction_datum_id_eq"=> construction_id }
    else
      #画面遷移用に工事ID、注文番号をセット
      if query.present?  
        if query[:id_eq].present?
          params[:purchase_order_datum_id] = query[:id_eq]
        end
        if query[:construction_datum_id_eq].present?
          params[:construction_id] = query[:construction_datum_id_eq]
        end
        if query[:supplier_master_id_eq].present?
          params[:supplier_master_id] = query[:supplier_master_id_eq]
        end
      end
      #
        
      #when "2"
        #   #注文一覧画面から遷移した場合
        #   purchase_order_id = params[:purchase_order_id]
        #   query = {"id_eq"=> purchase_order_id }
    end  #case end
    
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
  
    #データ呼び出し用変数を初期化(history用)
    $purchase_order_history = nil
    $purchase_order_date =  nil
    $supplier_master_id =  nil
    #
    
  end

  # GET /purchase_order_data/1
  # GET /purchase_order_data/1.json
  def show
  end

  @@update_flag = 0  #未使用??

  # GET /purchase_order_data/new
  def new
    
    @purchase_order_datum = PurchaseOrderDatum.new
    
    #工事データをビルド
    @purchase_order_datum.build_construction_datum
    
    #仕入先マスターをビルド
    #デフォルトのIDは２（＝岡田電気）とする
    #デフォルトのIDは未選択とする
    @supplier_master = SupplierMaster.find(1)
    @purchase_order_datum.supplier_master = @supplier_master

    #仕入担当者をビルド
    @purchase_order_datum.build_supplier_responsible
    @@update_flag =  1
    
    #工事データの初期値をセット
    set_construction_default
  
    #@purchase_order_datum.mail_sent_flag = 0
    
  end

  # GET /purchase_order_data/1/edit
  def edit
    @@update_flag = 2
	
    #仕入担当者をビルド
	  if @purchase_order_datum.supplier_responsible.nil?
      @purchase_order_datum.build_supplier_responsible
    end
    #
    
    #工事データの初期値をセット
    set_construction_default
    
    #担当者の初期値セット
    set_email_default
  end
 
  # POST /purchase_order_data
  # POST /purchase_order_data.json
  def create
    @purchase_order_datum = PurchaseOrderDatum.new(purchase_order_datum_params)
    
    #コンスタントへ注文番号を書き込む(先頭記号が変わった時)
    update_constant
    
    #工事データの住所を更新
    update_address_to_construction
    
    #メール送信する(メール送信ボタン押した場合)
    if params[:send].present?
      
      #画面のメアドをグローバルへセット
      set_responsible
    
      #メール送信フラグをセット
      params[:purchase_order_datum][:mail_sent_flag] = 1
	    @purchase_order_datum = PurchaseOrderDatum.new(purchase_order_datum_params)  #add170922
   
      #PostMailer.send_when_update(@purchase_order_datum).deliver
      #upd230502
      PostMailer.send_when_update(@purchase_order_datum, @responsible_name, @email_responsible,
                                  @email_responsible2).deliver
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
        #バリデーション失敗の場合も、仕入担当者をリビルド
	      @purchase_order_datum.build_supplier_responsible
      
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
   
    #コンスタントへ注文番号を書き込む(先頭記号が変わった時)
    update_constant
   
    #工事データの住所を更新
    update_address_to_construction
   
    #
    #メール送信する(メール送信ボタン押した場合)
    if params[:send].present?
      
      #画面のメアドをグローバルへセット
      set_responsible
      
      #インスタンスへパラメータを再セット
      reset_parameters
	  
	    #メール送信フラグをセット
      params[:purchase_order_datum][:mail_sent_flag] = 1
	    
    end
    #
   
    respond_to do |format|
      if @purchase_order_datum.update(purchase_order_datum_params)
        
        #
        #メール送信する(メール送信ボタン押した場合)
	      if params[:send].present?
          #PostMailer.send_when_update(@purchase_order_datum).deliver
          #upd230502
          PostMailer.send_when_update(@purchase_order_datum, @responsible_name, @email_responsible,
                                      @email_responsible2).deliver
        end
        #
        
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
        #バリデーション失敗の場合も、仕入担当者をリビルド
	      @purchase_order_datum.build_supplier_responsible
        
        format.html { render :edit }
        format.json { render json: @purchase_order_datum.errors, status: :unprocessable_entity }
      end
    end  #end do
		
  end
  
  #メール用の担当をセット
  def set_responsible
    
    @supplier_update_flag = 0  # 1:new  2:upd
    
    #画面のメアドをグローバルへセット
    #仕入先担当Ｍから選択できるようにした  
    #$email_responsible = nil
    #$responsible_name = nil
    @email_responsible = nil
    @responsible_name = nil
    
    if params[:purchase_order_datum][:supplier_responsible_id].present?
      supplier_responsible = SupplierResponsible.where(id: params[:purchase_order_datum][:supplier_responsible_id]).first
      if supplier_responsible.present? && supplier_responsible.responsible_email.present?
        #$responsible_name = supplier_responsible.responsible_name
        #$email_responsible = supplier_responsible.responsible_email
        @responsible_name = supplier_responsible.responsible_name
        @email_responsible = supplier_responsible.responsible_email
        
        #メアドが異なっていた場合
        ##苗字変更は考慮しない--id変更と見分けがつかない為、不可とする
        
        if supplier_responsible.responsible_email != 
           params[:purchase_order_datum][:supplier_responsible_attributes][:responsible_email]
          
          @supplier_update_flag = 2
          
          #メアドのみ新規登録とみなす
          if params[:purchase_order_datum][:supplier_responsible_attributes][:responsible_email].to_i == 0
            #$email_responsible = params[:purchase_order_datum][:supplier_responsible_attributes][:responsible_email]
            @email_responsible = params[:purchase_order_datum][:supplier_responsible_attributes][:responsible_email]
          end
          
          #メアドがIDの場合(違う名前で同一Emailの場合)
          update_email_when_id
        end
        
      else
        #文字で入ってきてる場合
        if params[:purchase_order_datum][:supplier_responsible_id].to_i == 0
          @supplier_update_flag = 1
          
          #$responsible_name = params[:purchase_order_datum][:supplier_responsible_id]
          @responsible_name = params[:purchase_order_datum][:supplier_responsible_id]
          
          #↓IDで入る場合もある  -->対策必要????
          
          #$email_responsible = params[:purchase_order_datum][:supplier_responsible_attributes][:responsible_email]
          @email_responsible = params[:purchase_order_datum][:supplier_responsible_attributes][:responsible_email]
          
          #メアドがIDの場合(違う名前で同一Emailの場合)
          update_email_when_id
          
        end
      
      end
    end
    #
    #if $responsible_name == nil
    if @responsible_name == nil
      #$responsible_name = "御担当者"
      @responsible_name = "御担当者"
    end
    
    #CC用に担当者２のアドレスもグローバルへセット
    #$email_responsible2 = nil
    @email_responsible2 = nil
    if params[:purchase_order_datum][:supplier_master_id].present?
      supplier = SupplierMaster.where(id: params[:purchase_order_datum][:supplier_master_id]).first
      
      if supplier.present? && supplier.email_cc.present?
        #$email_responsible2 = supplier.email_cc
        @email_responsible2 = supplier.email_cc
      end
    end
    
    #仕入担当者の追加・更新
    update_responsible
    
  end
  
  def update_email_when_id
    
    #メアドがIDの場合(違う名前で同一Emailの場合)
    if params[:purchase_order_datum][:supplier_responsible_attributes][:responsible_email].to_i > 0
      supplier_responsible = SupplierResponsible.where(id: 
                                        params[:purchase_order_datum][:supplier_responsible_attributes][:responsible_email]).first
      if supplier_responsible.present?
        #$email_responsible = supplier_responsible.responsible_email
        @email_responsible = supplier_responsible.responsible_email
      end
    end
  end
  
  
  #仕入担当者の追加・更新
  def update_responsible
    
    supplier_responsible_params = { supplier_master_id: params[:purchase_order_datum][:supplier_master_id],
                                    #responsible_name: $responsible_name,
                                    #responsible_email: $email_responsible
                                    responsible_name: @responsible_name,
                                    responsible_email: @email_responsible
                                  }
    
    case @supplier_update_flag
    when 1  #新規
      supplier_responsible = SupplierResponsible.new(supplier_responsible_params)
      supplier_responsible.save!(:validate => false)
        
      #パラメーターへ再び戻す
      params[:purchase_order_datum][:supplier_responsible_id] = supplier_responsible.id
    when 2  #更新
      supplier_responsible = SupplierResponsible.where(:id => params[:purchase_order_datum][:supplier_responsible_id]).first
        
      if supplier_responsible.present?
        supplier_responsible.update(supplier_responsible_params)
      end
    end
    
  end
  
  def set_order_data_fax(format)
    
    if params[:format] == "pdf"
     #ｆａｘ用紙の発行
      save_only_flag = false
       
      #global set
      $purchase_order_datum = @purchase_order_datum 
      
      #担当者をセット
      set_responsible
      
      #pdf
	    format.pdf do
        #report = OrderNumberFaxPDF.create @order_number_fax
        report = OrderNumberFaxPDF.create(@purchase_order_datum, @responsible_name)
 
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
      if params[:construction_id].present?
        #工事Noで検索をかけた場合を考慮
        construction_id = params[:construction_id]
        @construction_data = ConstructionDatum.where("id >= ?", construction_id)
      else
        @construction_data = ConstructionDatum.order('construction_code DESC').all
      end
    end 
  end
  
  def set_email_default
  #担当emailの初期値をセット
    
    @supplier_responsibles = nil
    @supplier_responsible_emails = nil
    
    if @purchase_order_datum.supplier_master_id.present?
      supplier_master_id = @purchase_order_datum.supplier_master_id.to_i
      
      @supplier_responsibles = SupplierResponsible.where(:supplier_master_id => supplier_master_id)
      @supplier_responsible_emails = SupplierResponsible.where(:supplier_master_id => supplier_master_id)
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
    reset_last_number
  
    @purchase_order_datum.destroy
    respond_to do |format|
      #format.html { redirect_to purchase_order_data_url, notice: 'Purchase order datum was successfully destroyed.' }
	  format.html {redirect_to purchase_order_data_path( :construction_id => params[:construction_id], :move_flag => params[:move_flag])}
	  
      format.json { head :no_content }
    end
  end
  
  
  #constantに注文Noを書き込む
  def update_constant
    constant = Constant.find(1)   #id=１に定数ファイルが保管されている
    
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
      #(同年で)  
      if (current_year == constant_year) && 
         (current_header.ord > constant_header.ord)
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
      
      #更新する
      constant_params = { purchase_order_last_header_code: last_new_number}
      constant.update(constant_params)
    end
    
  end
  
  #ajax
  def get_last_number_select
    #crescent = "%" + params[:header] + "%"
    #@purchase_order_datum_new_code = PurchaseOrderDatum.where('purchase_order_code LIKE ?', crescent).all.maximum(:purchase_order_code) 
	  #自動で番号を繰り上げる
    constant = Constant.find(1)   #id=１に定数ファイルが保管されている
    @purchase_order_datum_new_code = constant.purchase_order_last_header_code
   
    #年の判定
    year = @purchase_order_datum_new_code[1, 2]
    d = Date.today
    
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
  
     #supplier_responsibleから取得する
     @supplier_responsibles = SupplierResponsible.where(:supplier_master_id => params[:id]).pluck("responsible_name, id")
     @supplier_responsible_emails = SupplierResponsible.where(:supplier_master_id => params[:id]).pluck("responsible_email, id")
     #未登録(-)の場合はセットしない。
     #if @maker_masters == [["-",1]] || @maker_masters.blank?
     #   @maker_masters = MakerMaster.all.pluck("maker_masters.maker_name, maker_masters.id")
     #end 
     #
  end
  
  #担当Email取得
  def get_responsible_email
    @supplier_responsible_emails = SupplierResponsible.where(:id => params[:supplier_responsible_id]).pluck("responsible_email, id")
  
    #仕入の担当者も全て加える
    @supplier_responsible_emails += SupplierResponsible.where(:supplier_master_id => params[:supplier_master_id]).
                                               where.not(:id => params[:supplier_responsible_id]).pluck("responsible_email, id")
  end
  
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
      params.require(:purchase_order_datum).permit(:purchase_order_code, :construction_datum_id, :supplier_master_id,
                     :supplier_responsible_id, :alias_name, :mail_sent_flag, 
                     :orders_attributes => [:purchase_order_datum_id, :material_id, :material_code, :material_name, :quantity])
    end
end
