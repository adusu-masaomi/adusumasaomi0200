class SupplierMastersController < ApplicationController
  before_action :set_supplier_master, only: [:show, :edit, :update, :destroy]

  # GET /supplier_masters
  # GET /supplier_masters.json
  def index
    #@supplier_masters = SupplierMaster.all
    #@supplier_csv = SupplierMaster.all
   
    @q = SupplierMaster.ransack(params[:q])   
    @supplier_masters  = @q.result(distinct: true)
    
    #kaminari用設定
    @supplier_masters  = @supplier_masters.page(params[:page])
    
    respond_to do |format|
	    format.html
      #csv
      format.csv { send_data @supplier_masters.to_csv.encode("SJIS"), type: 'text/csv; charset=shift_jis', disposition: 'attachment' }
      #format.csv { send_data SupplierMaster.all.to_csv }
      
      #format.csv do |csv|
      #  send_posts_csv(@supplier_masters)
      #end
    end
    
  end
  
  def send_posts_csv(supplier_masters)
    csv_data = CSV.generate do |csv|
      column_names = %w(投稿者名 タイトル 本文)
      csv << column_names
      supplier_masters.each do |supplier_master|
        column_values = [
          supplier_master.supplier_name,
          supplier_master.tel_main,
          supplier_master.fax_main,
          supplier_master.responsible1,
        ]
        csv << column_values
      end
    end
    send_data(csv_data, filename: "投稿一覧.csv")
  end
  
  # GET /supplier_masters/1
  # GET /supplier_masters/1.json
  def show
  end

  # GET /supplier_masters/new
  def new
    @supplier_master = SupplierMaster.new
    #add210629
    @supplier_master.supplier_responsibles.build
  end

  # GET /supplier_masters/1/edit
  def edit
  end

  # POST /supplier_masters
  # POST /supplier_masters.json
  def create
    
    #頭文字を必ず半角小文字にする
    set_character
  
    @supplier_master = SupplierMaster.new(supplier_master_params)

    respond_to do |format|
      if @supplier_master.save
        format.html { redirect_to @supplier_master, notice: 'Supplier master was successfully created.' }
        format.json { render :show, status: :created, location: @supplier_master }
      else
        format.html { render :new }
        format.json { render json: @supplier_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /supplier_masters/1
  # PATCH/PUT /supplier_masters/1.json
  def update
  
    #頭文字を必ず半角小文字にする
    set_character
  
    respond_to do |format|
	
	   if @supplier_master.update(supplier_master_params)
        format.html { redirect_to @supplier_master, notice: 'Supplier master was successfully updated.' }
        format.json { render :show, status: :ok, location: @supplier_master }
      else
        format.html { render :edit }
        format.json { render json: @supplier_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /supplier_masters/1
  # DELETE /supplier_masters/1.json
  def destroy
    @supplier_master.destroy
    respond_to do |format|
      format.html { redirect_to supplier_masters_url, notice: 'Supplier master was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
   
  #頭文字を必ず半角小文字にする
  def set_character
    if params[:supplier_master][:search_character].present?
      sc = params[:supplier_master][:search_character].tr('０-９ａ-ｚＡ-Ｚ','0-9a-zA-Z')  #半角にする
      sc = sc.downcase  #小文字にする
      
      params[:supplier_master][:search_character] = sc
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supplier_master
      @supplier_master = SupplierMaster.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supplier_master_params
      params.require(:supplier_master).permit(:supplier_name, :tel_main, :fax_main, :email_main, :responsible1, :email1, 
           :responsible2, :email2, :responsible3, :email3, :responsible_cc, :email_cc, 
           :search_character, :outsourcing_flag, 
           supplier_responsibles_attributes: [:id, :responsible_name, :responsible_email, :_destroy])
    end
end
