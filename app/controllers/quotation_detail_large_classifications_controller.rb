class QuotationDetailLargeClassificationsController < ApplicationController
  before_action :set_quotation_detail_large_classification, only: [:show, :edit, :update, :destroy]

  @@new_flag = []
  max_line_number = 0
  
  # GET /quotation_detail_large_classifications
  # GET /quotation_detail_large_classifications.json
  def index
    #ransack保持用コード
    @null_flag = ""
    
	if params[:quotation_header_id].present?
      $quotation_header_id = params[:quotation_header_id]
    end
  
  
    if $quotation_header_id.present?
	  query = {"quotation_header_id_eq"=>"", "with_header_id"=> $quotation_header_id, "quotation_large_item_name_eq"=>""}
	  
	  @null_flag = "1"
	end
	
	
	#if query.nil?
    if @null_flag == "" 
      query = params[:q]
      query ||= eval(cookies[:recent_search_history].to_s)  	
      
	end
    
    #binding.pry

    #@q = QuotationDetailLargeClassification.ransack(params[:q]) 
    #ransack保持用--上記はこれに置き換える
    @q = QuotationDetailLargeClassification.ransack(query)   
    
	if @null_flag == ""
      #ransack保持用コード
      search_history = {
       value: params[:q],
       expires: 24.hours.from_now
      }
      cookies[:recent_search_history] = search_history if params[:q].present?
    end 
	#

    @quotation_detail_large_classifications = @q.result(distinct: true)
    
    #
    #global set
	$quotation_detail_large_classifications = @quotation_detail_large_classifications
    
    #binding.pry
    @print_type = params[:print_type]
    #見積書PDF発行
    respond_to do |format|
      format.html # index.html.erb
      format.pdf do

        if @print_type == "1"
          report = EstimationSheetPDF.create @estimation_sheet 
        else
          report = EstimationSheetLandscapePDF.create @estimation_sheet_landscape
        end 	
	
        # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data report.generate,
		  filename:    "hoge.pdf",
          type:        "application/pdf",
          disposition: "inline"
        end
    end
    #
  end

  # GET /quotation_detail_large_classifications/1
  # GET /quotation_detail_large_classifications/1.json
  def show
  end

  # GET /quotation_detail_large_classifications/new
  def new
    @quotation_detail_large_classification = QuotationDetailLargeClassification.new
    
    ###
    #初期値をセット(見出画面からの遷移時のみ)
    @@new_flag = params[:new_flag]
    #binding.pry
    if @@new_flag == "1"
       #@quotation_detail_large_classification.quotation_header_id ||= params[:quotation_header_id]
	   @quotation_detail_large_classification.quotation_header_id ||= $quotation_header_id
	   
	end 
    
	#行番号を取得する
	get_line_number
    
  end

  # GET /quotation_detail_large_classifications/1/edit
  def edit
  end

  # POST /quotation_detail_large_classifications
  # POST /quotation_detail_large_classifications.json
  def create
    #@quotation_detail_large_classification = QuotationDetailLargeClassification.new(quotation_detail_large_classification_params)

    #respond_to do |format|
      #if @quotation_detail_large_classification.save
        #format.html { redirect_to @quotation_detail_large_classification, notice: 'Quotation detail large classification was successfully created.' }
        #format.json { render :show, status: :created, location: @quotation_detail_large_classification }
      #else
        #format.html { render :new }
        #format.json { render json: @quotation_detail_large_classification.errors, status: :unprocessable_entity }
      #end
      
	  @quotation_detail_large_classification = QuotationDetailLargeClassification.create(quotation_detail_large_classification_params)
	  
      # 見出データを保存 
      save_price_to_headers
      
	  
	  @max_line_number = @quotation_detail_large_classification.line_number
      #行挿入する 
      if (params[:quotation_detail_large_classification][:check_line_insert] == 'true')
         line_insert
      end

      #行番号の最終を書き込む
      quotation_headers_set_last_line_number
	  
      
      #手入力用IDの場合は、単位マスタへも登録する。
      if @quotation_detail_large_classification.quotation_unit_id == 1
         #既に登録してないかチェック
         @check_unit = QuotationUnit.find_by(quotation_unit_name: @quotation_detail_large_classification.quotation_unit_name)
         if @check_unit.nil?
            unit_params = { quotation_unit_name:  @quotation_detail_large_classification.quotation_unit_name }
            @quotation_unit = QuotationUnit.create(unit_params)
         end
	  end
      
      #同様に手入力用IDの場合、内訳(大分類)マスターへ登録する。
      if @quotation_detail_large_classification.quotation_large_item_id == 1
         @check_item = QuotationLargeItem.find_by(quotation_large_item_name: @quotation_detail_large_classification.quotation_large_item_name , quotation_large_specification: @quotation_detail_large_classification.quotation_large_specification)
         if @check_item.nil?
           large_item_params = { quotation_large_item_name:  @quotation_detail_large_classification.quotation_large_item_name, quotation_large_specification:  @quotation_detail_large_classification.quotation_large_specification }
           @quotation_large_item = QuotationLargeItem.create(large_item_params)
         end
      end
      
   #end
   
   #add
   #@quotation_detail_large_classifications = QuotationDetailLargeClassification.all
   @quotation_detail_large_classifications = QuotationDetailLargeClassification.where(:quotation_header_id => $quotation_header_id)
   
  end

  # PATCH/PUT /quotation_detail_large_classifications/1
  # PATCH/PUT /quotation_detail_large_classifications/1.json
  def update
  
      #binding.pry
  
    #respond_to do |format|
      #if @quotation_detail_large_classification.update(quotation_detail_large_classification_params)
        #format.html { redirect_to @quotation_detail_large_classification, notice: 'Quotation detail large classification was successfully updated.' }
        #format.json { render :show, status: :ok, location: @quotation_detail_large_classification }
      #else
        #format.html { render :edit }
        #format.json { render json: @quotation_detail_large_classification.errors, status: :unprocessable_entity }
      #end
      
	  #@max_line_number = @quotation_detail_large_classification.line_number
	  
	  @quotation_detail_large_classification.update(quotation_detail_large_classification_params)
	  
      # 見出データを保存 
      save_price_to_headers
      
	  @max_line_number = @quotation_detail_large_classification.line_number
	  #binding.pry
      if (params[:quotation_detail_large_classification][:check_line_insert] == 'true')
         line_insert
      end
	  
	  
	  
      #行番号の最終を書き込む
      quotation_headers_set_last_line_number
      
      #####
      #手入力用IDの場合は、単位マスタへも登録する。
      if @quotation_detail_large_classification.quotation_unit_id == 1
         #既に登録してないかチェック
         @check_unit = QuotationUnit.find_by(quotation_unit_name: @quotation_detail_large_classification.quotation_unit_name)
         if @check_unit.nil?
            unit_params = { quotation_unit_name:  @quotation_detail_large_classification.quotation_unit_name }
            @quotation_unit = QuotationUnit.create(unit_params)
         end
	  end
      
	   
	  
      #同様に手入力用IDの場合、内訳(大分類)マスターへ登録する。
      if @quotation_detail_large_classification.quotation_large_item_id == 1
         @check_item = QuotationLargeItem.find_by(quotation_large_item_name: @quotation_detail_large_classification.quotation_large_item_name , quotation_large_specification: @quotation_detail_large_classification.quotation_large_specification)
         if @check_item.nil?
           large_item_params = { quotation_large_item_name:  @quotation_detail_large_classification.quotation_large_item_name, quotation_large_specification:  @quotation_detail_large_classification.quotation_large_specification }
           @quotation_large_item = QuotationLargeItem.create(large_item_params)
         end
      end
	  #####
	  
	 	     
	  
      #@quotation_detail_large_classifications = QuotationDetailLargeClassification.all
      @quotation_detail_large_classifications = QuotationDetailLargeClassification.where(:quotation_header_id => $quotation_header_id)
  end

  # DELETE /quotation_detail_large_classifications/1
  # DELETE /quotation_detail_large_classifications/1.json
  def destroy
    
    #binding.pry
	
    if params[:quotation_header_id].present?
      $quotation_header_id = params[:quotation_header_id]
	  #binding.pry
    end
    
  
    @quotation_detail_large_classification.destroy
    respond_to do |format|
      format.html { redirect_to quotation_detail_large_classifications_url, notice: 'Quotation detail large classification was successfully destroyed.' }
      format.json { head :no_content }
    
      # 見出データを保存 
      save_price_to_headers
    end
	
	
  end
  
  #見積金額トータル
  def quote_total_price
     @execution_total_price = QuotationDetailLargeClassification.where(["quotation_header_id = ?", @quotation_detail_large_classification.quotation_header_id]).sumpriceQuote
  end 
  #実行金額トータル
  def execution_total_price
     @execution_total_price = QuotationDetailLargeClassification.where(["quotation_header_id = ?", @quotation_detail_large_classification.quotation_header_id]).sumpriceExecution
  end


 # ajax
  def quotation_large_item_select
     @quotation_large_item_name = QuotationLargeItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:quotation_large_item_name).flatten.join(" ")
  end
  def quotation_large_specification_select
     @quotation_large_specification = QuotationLargeItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:quotation_large_specification).flatten.join(" ")
  end
  def quotation_unit_name_select
     @quotation_unit_name = QuotationUnit.where(:id => params[:id]).where("id is NOT NULL").pluck(:quotation_unit_name).flatten.join(" ")
	 #binding.pry
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quotation_detail_large_classification
	   
	   @quotation_detail_large_classification = QuotationDetailLargeClassification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quotation_detail_large_classification_params
      params.require(:quotation_detail_large_classification).permit(:quotation_header_id, :quotation_items_division_id, :quotation_large_item_id, :quotation_large_item_name, :quotation_large_specification, :line_number, :quantity, :execution_quantity, :quotation_unit_id, :quotation_unit_name, :quote_price, :execution_price, :labor_productivity_unit)
    end
   
    #以降のレコードの行番号を全てインクリメントする
    def line_insert
      QuotationDetailLargeClassification.where(["quotation_header_id = ? and line_number >= ? and id != ?", @quotation_detail_large_classification.quotation_header_id, @quotation_detail_large_classification.line_number, @quotation_detail_large_classification.id]).update_all("line_number = line_number + 1")
      #最終行番号も取得しておく
      @max_line_number = QuotationDetailLargeClassification.
        where(["quotation_header_id = ? and line_number >= ? and id != ?", @quotation_detail_large_classification.quotation_header_id, 
        @quotation_detail_large_classification.line_number, @quotation_detail_large_classification.id]).maximum(:line_number)
    end
   
     #見出データへ合計保存用　
    def save_price_to_headers
        @quotation_header = QuotationHeader.find(@quotation_detail_large_classification.quotation_header_id)
        #見積金額
        @quotation_header.quote_price = quote_total_price
        #実行金額
        @quotation_header.execution_amount = execution_total_price
        @quotation_header.save
    end
	#見出しデータへ最終行番号保存用
    def quotation_headers_set_last_line_number
        @quotation_headers = QuotationHeader.find_by(id: @quotation_detail_large_classification.quotation_header_id)
        check_flag = false
	    if @quotation_headers.last_line_number.nil? 
          check_flag = true
        else
	      if (@quotation_headers.last_line_number < @max_line_number) then
           check_flag = true
		  end
	    end
	    if (check_flag == true)
	       quotation_header_params = { last_line_number:  @max_line_number}
		   if @quotation_headers.present?
		      
			 @quotation_headers.update(quotation_header_params)
		   end 
        end 
    end
    #行番号を取得し、インクリメントする。（新規用）
    def get_line_number
      @line_number = 1
      if @quotation_detail_large_classification.quotation_header_id.present?
         @quotation_headers = QuotationHeader.find_by(id: @quotation_detail_large_classification.quotation_header_id)
         if @quotation_headers.present?
            if @quotation_headers.last_line_number.present?
               @line_number = @quotation_headers.last_line_number + 1
            end
         end
      end
	  
	  @quotation_detail_large_classification.line_number = @line_number
    end
    
end
