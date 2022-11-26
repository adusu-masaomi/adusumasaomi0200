class CustomerMastersController < ApplicationController
  before_action :set_customer_master, only: [:show, :edit, :update, :destroy]

  # GET /customer_masters
  # GET /customer_masters.json
  def index
    #@customer_masters = CustomerMaster.all
   #@customer_masters = CustomerMaster.page(params[:page])
   
   #ransack保持用コード
   query = params[:q]
   query ||= eval(cookies[:recent_search_history].to_s)  	
   
   
    #@q = CustomerMaster.ransack(params[:q])   
	#ransack保持用--上記はこれに置き換える
    @q = CustomerMaster.ransack(query)
	
	#ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
	
    @customer_masters  = @q.result(distinct: true)
    @customer_masters  = @customer_masters.page(params[:page])
    
    
    $customers = @customer_masters
    
    $print_flag_customer = params[:print_flag]
    
    #csv_data = CSV.generate(encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true) do |csv|
    #    csv << []
    #end
    
    
	respond_to do |format|
	  format.html
      
      #format.csv { send_data @customer_masters.to_csv.encode("SJIS"), type: 'text/csv; charset=shift_jis' }
      
      #csv
      format.csv { send_data @customer_masters.to_csv.encode("SJIS"), type: 'text/csv; charset=shift_jis', disposition: 'attachment' }
      
      
	  format.pdf do
        report = CustomerListCardPDF.create @customer_list_card 
        # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data(
          report.generate,
          filename:  "customer_list_card.pdf",
          type:        "application/pdf",
          disposition: "inline")
      end
	end
    
  end

  # GET /customer_masters/1
  # GET /customer_masters/1.json
  def show
  end

  # GET /customer_masters/new
  def new
    @customer_master = CustomerMaster.new
  end

  # GET /customer_masters/1/edit
  def edit
  end

  # POST /customer_masters
  # POST /customer_masters.json
  def create
    
    #住所のパラメータ変換
    params[:customer_master][:address] = params[:addressX]
    
    @customer_master = CustomerMaster.new(customer_master_params)

    ###連絡先マスターへも追加する
	create_or_update_contact
	
    if @contact_new.present?
      @customer_master.contact_id = @contact_new.id
    end
    ###

    respond_to do |format|
      if @customer_master.save
        format.html { redirect_to @customer_master, notice: 'Customer master was successfully created.' }
        format.json { render :show, status: :created, location: @customer_master }
      else
        format.html { render :new }
        format.json { render json: @customer_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customer_masters/1
  # PATCH/PUT /customer_masters/1.json
  def update
    
    #住所のパラメータ変換
    params[:customer_master][:address] = params[:addressX]
	
    respond_to do |format|
      if @customer_master.update(customer_master_params)
	  
	    #連絡先マスターも更新する
		create_or_update_contact
	  
        format.html { redirect_to @customer_master, notice: 'Customer master was successfully updated.' }
        format.json { render :show, status: :ok, location: @customer_master }
      else
        format.html { render :edit }
        format.json { render json: @customer_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customer_masters/1
  # DELETE /customer_masters/1.json
  def destroy
    @customer_master.destroy
    respond_to do |format|
      format.html { redirect_to customer_masters_url, notice: 'Customer master was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  #連絡先マスターへの追加・更新
  def create_or_update_contact
    contact_id =  params[:customer_master][:contact_id]

    contact_params = { name: params[:customer_master][:responsible1], search_character: params[:customer_master][:search_character],
                         company_name: params[:customer_master][:customer_name], post: params[:customer_master][:post], 
                         address: params[:customer_master][:address], tel: params[:customer_master][:tel_main], fax: params[:customer_master][:fax_main],
                         email: params[:customer_master][:email_main], partner_division_id: 1 }
    
	if contact_id.present?

      @contact = Contact.find(contact_id)
      
	  if @contact.present?
	  #更新
	    @contact.update(contact_params)
      end
	else
	  #登録
	  @contact_new = Contact.create(contact_params)
	end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer_master
      @customer_master = CustomerMaster.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_master_params
      params.require(:customer_master).permit(:customer_name, :search_character, :post, :address, :house_number, :address2, :tel_main, :fax_main, :email_main, :closing_date, 
	                 :closing_date_division, :due_date, :due_date_division, :responsible1, :responsible2, :contact_id, :payment_bank_id, :card_not_flag, :contractor_flag, :public_flag)
    end
end
