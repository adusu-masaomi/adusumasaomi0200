class QuotationDetailMiddleClassificationsController < ApplicationController
  before_action :set_quotation_detail_middle_classification, only: [:show, :edit, :update, :destroy]
  
  @@new_flag = []
  
    # GET /quotation_detail_middle_classifications
  # GET /quotation_detail_middle_classifications.json
  def index
    
	  #@quotation_detail_middle_classifications = QuotationDetailMiddleClassification.all
    @null_flag = ""
    
    @number = 1
	
    #ransack保持用コード
    if params[:quotation_header_id].present?
      $quotation_header_id = params[:quotation_header_id]
      if params[:quotation_large_item_name].present?
          $quotation_large_item_name = params[:quotation_large_item_name]
      end
	  if params[:quotation_detail_large_classification_id].present?
          $quotation_detail_large_classification_id = params[:quotation_detail_large_classification_id]
	  end
	end
    
  
    #明細データ見出用
    if params[:quotation_header_name].present?
      $quotation_header_name = params[:quotation_header_name]
    end
    #
	
    if $quotation_header_id.present?
       #if $quotation_large_item_name.nil?
       #  $quotation_large_item_name = params[:quotation_large_item_name]
       #end
      query = {"quotation_header_id_eq"=>"", "with_header_id"=> $quotation_header_id, "with_large_item"=> $quotation_large_item_name , "quotation_middle_item_name_eq"=>""}
      @null_flag = "1"
    end 

    #if query.nil?
    if @null_flag == "" 
      #ransack保持用コード
      query = params[:q]
      query ||= eval(cookies[:recent_search_history].to_s)  	
    end
	
	#binding.pry
	
    #@q = QuotationDetailMiddleClassification.ransack(params[:q]) 
    #ransack保持用--上記はこれに置き換える
    @q = QuotationDetailMiddleClassification.ransack(query)   
    
    #ransack保持用コード
    if @null_flag == "" 
	  search_history = {
       value: params[:q],
       expires: 24.hours.from_now
      }
      cookies[:recent_search_history] = search_history if params[:q].present?
    end
	#

    @quotation_detail_middle_classifications = @q.result(distinct: true)
	#global set
	$quotation_detail_middle_classifications = @quotation_detail_middle_classifications
	
    @print_type = params[:print_type]
    
    #デフォルトの頁番号→グローバルに格納
    $default_page_number = params[:default_page_number].to_i
    #binding.pry
	
    #内訳書PDF発行
    respond_to do |format|
      format.html # index.html.erb
      format.pdf do
         #binding.pry
         
         if @print_type == "1"
          report = DetailedStatementPDF.create @detailed_statement
         else
          report = DetailedStatementLandscapePDF.create @detailed_statement_landscape
         end 
        # ブラウザでPDFを表示する
        # disposition: "inline" によりダウンロードではなく表示させている
        send_data(
          report.generate,
          filename:  "detailed_statatement.pdf",
          type:        "application/pdf",
          disposition: "inline")
        end
    end
    #
	
	
  end

  # GET /quotation_detail_middle_classifications/1
  # GET /quotation_detail_middle_classifications/1.json
  def show
  end

  # GET /quotation_detail_middle_classifications/new
  def new
    @quotation_detail_middle_classification = QuotationDetailMiddleClassification.new
  
    @quotation_detail_large_classification = QuotationDetailLargeClassification.all
    
    
    ###
    #初期値をセット(見出画面からの遷移時のみ)
    @@new_flag = params[:new_flag]
	
	#binding.pry
	
    if @@new_flag == "1"
       #@quotation_detail_middle_classification.quotation_header_id ||= params[:quotation_header_id]
       @quotation_detail_middle_classification.quotation_header_id ||= $quotation_header_id
	   if params[:quotation_detail_large_classification_id].present?
         @quotation_detail_middle_classification.quotation_detail_large_classification_id ||= params[:quotation_detail_large_classification_id]
	   else
         @quotation_detail_middle_classification.quotation_detail_large_classification_id ||= $quotation_detail_large_classification_id
       end
    end 
    
    #行番号を取得する
    get_line_number
    ###
  end

  # GET /quotation_detail_middle_classifications/1/edit
  def edit
   
    #@quotation_detail_large_classification = QuotationDetailLargeClassification.where(["quotation_header_id = ?", @quotation_detail_middle_classification.quotation_header_id])
    #@quotation_detail_large_classification = QuotationDetailLargeClassification.where(["id = ?", @quotation_detail_middle_classification.quotation_detail_large_classification_id])
  end

  # POST /quotation_detail_middle_classifications
  # POST /quotation_detail_middle_classifications.json
  def create
    #@quotation_detail_middle_classification = QuotationDetailMiddleClassification.new(quotation_detail_middle_classification_params)
    #respond_to do |format|
    #  if @quotation_detail_middle_classification.save
    #    format.html { redirect_to @quotation_detail_middle_classification, notice: 'Quotation detail middle classification was successfully created.' }
    #    format.json { render :show, status: :created, location: @quotation_detail_middle_classification }
    #  else
    #    format.html { render :new }
    #    format.json { render json: @quotation_detail_middle_classification.errors, status: :unprocessable_entity }
    #  end
    #  #品目データの金額を更新
    #  save_price_to_large_classifications
    #   #行挿入する 
    #  if (params[:quotation_detail_middle_classification][:check_line_insert] == 'true')
    #     line_insert
    #  end
	#end
    ###モーダル化対応
    @quotation_detail_middle_classification = QuotationDetailMiddleClassification.create(quotation_detail_middle_classification_params)

     #手入力用IDの場合は、単位マスタへも登録する。
    @quotation_unit = nil
    if @quotation_detail_middle_classification.quotation_unit_id == 1
       
	   #既に登録してないかチェック
       @check_unit = QuotationUnit.find_by(quotation_unit_name: @quotation_detail_middle_classification.quotation_unit_name)
       
	   
	   if @check_unit.nil?
          unit_params = { quotation_unit_name:  @quotation_detail_middle_classification.quotation_unit_name }
          @quotation_unit = QuotationUnit.create(unit_params)
       end
    end
    #同様に手入力用IDの場合、明細(中分類)マスターへ登録する。
    if @quotation_detail_middle_classification.quotation_middle_item_id == 1
         
		 @check_item = QuotationMiddleItem.find_by(quotation_middle_item_name: @quotation_detail_middle_classification.quotation_middle_item_name , quotation_middle_specification: @quotation_detail_middle_classification.quotation_middle_specification)
         @quotation_unit_id_params = @quotation_detail_middle_classification
		 
         if @quotation_unit.present?
           #quotation_unit_id_params = QuotationUnit.where(quotation_unit_name: @quotation_detail_middle_classification.quotation_unit_name).id
		   #quotation_unit_id_params = QuotationUnit.where(quotation_unit_name: @quotation_detail_middle_classification.quotation_unit_name).pluck(:id)
           @quotation_unit_id_params = QuotationUnit.find_by(quotation_unit_name: @quotation_detail_middle_classification.quotation_unit_name)
		   #quotation_unit_id_params = QuotationUnit.where(quotation_unit_name: @quotation_detail_middle_classification.quotation_unit_name)
           #binding.pry
         end 
 
         if @check_item.nil?
           large_item_params = { quotation_middle_item_name:  @quotation_detail_middle_classification.quotation_middle_item_name, 
quotation_middle_item_short_name: @quotation_detail_middle_classification.quotation_middle_item_short_name, 
quotation_middle_specification:  @quotation_detail_middle_classification.quotation_middle_specification, 
quotation_unit_id: @quotation_unit_id_params.id, 
quotation_unit_price: @quotation_detail_middle_classification.quotation_unit_price,
execution_unit_price: @quotation_detail_middle_classification.execution_unit_price,
material_id: @quotation_detail_middle_classification.material_id,
quotation_material_name: @quotation_detail_middle_classification.quotation_material_name,
material_unit_price: @quotation_detail_middle_classification.material_unit_price,
labor_unit_price: @quotation_detail_middle_classification.labor_unit_price,
labor_productivity_unit: @quotation_detail_middle_classification.labor_productivity_unit,
material_quantity: @quotation_detail_middle_classification.material_quantity,
accessory_cost: @quotation_detail_middle_classification.accessory_cost,
material_cost_total: @quotation_detail_middle_classification.material_cost_total,
labor_cost_total: @quotation_detail_middle_classification.labor_cost_total,
other_cost: @quotation_detail_middle_classification.other_cost
 }

          @quotation_middle_item = QuotationMiddleItem.create(large_item_params)
         end
    end



     #品目データの金額を更新
    save_price_to_large_classifications
    #行挿入する 
	@max_line_number = @quotation_detail_middle_classification.line_number
    if (params[:quotation_detail_middle_classification][:check_line_insert] == 'true')
      line_insert
    end
    
    #行番号の最終を書き込む
    quotation_dlc_set_last_line_number
	  
    @quotation_detail_middle_classifications = QuotationDetailMiddleClassification.where(:quotation_header_id => $quotation_header_id).where(:quotation_detail_large_classification_id => $quotation_detail_large_classification_id)
    ###
  end
  
  
  
  # PATCH/PUT /quotation_detail_middle_classifications/1
  # PATCH/PUT /quotation_detail_middle_classifications/1.json
  def update
    #respond_to do |format|
    #  if @quotation_detail_middle_classification.update(quotation_detail_middle_classification_params)
    #    format.html { redirect_to @quotation_detail_middle_classification, notice: 'Quotation detail middle classification was successfully updated.' }
    #    format.json { render :show, status: :ok, location: @quotation_detail_middle_classification }
    #  else
    #    format.html { render :edit }
    #    format.json { render json: @quotation_detail_middle_classification.errors, status: :unprocessable_entity }
    #  end
	#  #品目データの金額を更新
	#  save_price_to_large_classifications
	#  #行挿入する 
    #  if (params[:quotation_detail_middle_classification][:check_line_insert] == 'true')
    #     line_insert
    #  end
	#end
    
    @quotation_detail_middle_classification.update(quotation_detail_middle_classification_params)
    
    #品目データの金額を更新
	save_price_to_large_classifications
	
	#行挿入する 
	@max_line_number = @quotation_detail_middle_classification.line_number
    if (params[:quotation_detail_middle_classification][:check_line_insert] == 'true')
       line_insert
    end
    
	#行番号の最終を書き込む
    quotation_dlc_set_last_line_number

    ######################
    #手入力用IDの場合は、単位マスタへも登録する。
    @quotation_unit = nil
    if @quotation_detail_middle_classification.quotation_unit_id == 1
       
       #既に登録してないかチェック
       @check_unit = QuotationUnit.find_by(quotation_unit_name: @quotation_detail_middle_classification.quotation_unit_name)
       
	   
	   if @check_unit.nil?
          unit_params = { quotation_unit_name:  @quotation_detail_middle_classification.quotation_unit_name }
          @quotation_unit = QuotationUnit.create(unit_params)
       end
    end
    #同様に手入力用IDの場合、明細(中分類)マスターへ登録する。
    if @quotation_detail_middle_classification.quotation_middle_item_id == 1
         
		 @check_item = QuotationMiddleItem.find_by(quotation_middle_item_name: @quotation_detail_middle_classification.quotation_middle_item_name , quotation_middle_specification: @quotation_detail_middle_classification.quotation_middle_specification)
         @quotation_unit_id_params = @quotation_detail_middle_classification
		 
         if @quotation_unit.present?
           #quotation_unit_id_params = QuotationUnit.where(quotation_unit_name: @quotation_detail_middle_classification.quotation_unit_name).id
		   #quotation_unit_id_params = QuotationUnit.where(quotation_unit_name: @quotation_detail_middle_classification.quotation_unit_name).pluck(:id)
           @quotation_unit_id_params = QuotationUnit.find_by(quotation_unit_name: @quotation_detail_middle_classification.quotation_unit_name)
		   #quotation_unit_id_params = QuotationUnit.where(quotation_unit_name: @quotation_detail_middle_classification.quotation_unit_name)
           #binding.pry
         end 
 
         if @check_item.nil?
           large_item_params = { quotation_middle_item_name:  @quotation_detail_middle_classification.quotation_middle_item_name, 
quotation_middle_item_short_name: @quotation_detail_middle_classification.quotation_middle_item_short_name, 
quotation_middle_specification:  @quotation_detail_middle_classification.quotation_middle_specification, 
quotation_unit_id: @quotation_unit_id_params.id, 
quotation_unit_price: @quotation_detail_middle_classification.quotation_unit_price,
execution_unit_price: @quotation_detail_middle_classification.execution_unit_price,
material_id: @quotation_detail_middle_classification.material_id,
quotation_material_name: @quotation_detail_middle_classification.quotation_material_name,
material_unit_price: @quotation_detail_middle_classification.material_unit_price,
labor_unit_price: @quotation_detail_middle_classification.labor_unit_price,
labor_productivity_unit: @quotation_detail_middle_classification.labor_productivity_unit,
material_quantity: @quotation_detail_middle_classification.material_quantity,
accessory_cost: @quotation_detail_middle_classification.accessory_cost,
material_cost_total: @quotation_detail_middle_classification.material_cost_total,
labor_cost_total: @quotation_detail_middle_classification.labor_cost_total,
other_cost: @quotation_detail_middle_classification.other_cost
 }
          @quotation_middle_item = QuotationMiddleItem.create(large_item_params)
         end
    end
    ######################
    
    
    @quotation_detail_middle_classifications = QuotationDetailMiddleClassification.where(:quotation_header_id => $quotation_header_id).where(:quotation_detail_large_classification_id => $quotation_detail_large_classification_id)
  end

  # DELETE /quotation_detail_middle_classifications/1
  # DELETE /quotation_detail_middle_classifications/1.json
  def destroy
    #binding.pry
	if params[:quotation_header_id].present?
	
      $quotation_header_id = params[:quotation_header_id]
      if params[:quotation_detail_large_classification_id].present?
          $quotation_detail_large_classification_id = params[:quotation_detail_large_classification_id]
		  #$quotation_large_item_name = params[:quotation_large_item_name]
      end
	end
  
    @quotation_detail_middle_classification.destroy
    respond_to do |format|
      format.html { redirect_to quotation_detail_middle_classifications_url, notice: 'Quotation detail middle classification was successfully destroyed.' }
      format.json { head :no_content }
	  
	  #品目データの金額を更新
      save_price_to_large_classifications
	  
    end
  end
 
  #見積金額トータル
  def quote_total_price
     @execution_total_price = QuotationDetailMiddleClassification.where(["quotation_detail_large_classification_id = ?", @quotation_detail_middle_classification.quotation_detail_large_classification_id]).sumpriceQuote
  end 
  #実行金額トータル
  def execution_total_price
     @execution_total_price = QuotationDetailMiddleClassification.where(["quotation_detail_large_classification_id = ?", @quotation_detail_middle_classification.quotation_detail_large_classification_id]).sumpriceExecution
  end

   #歩掛りトータル
  def labor_total
     @labor_total = QuotationDetailMiddleClassification.where(["quotation_detail_large_classification_id = ?", @quotation_detail_middle_classification.quotation_detail_large_classification_id]).sumLaborProductivityUnit 
  end
 
  #トータル(品目→見出保存用)
  
  #見積金額トータル
  def quote_total_price_Large
     @execution_total_price_Large = QuotationDetailLargeClassification.where(["quotation_header_id = ?", @quotation_detail_middle_classification.quotation_header_id]).sumpriceQuote
  end 
  #実行金額トータル
  def execution_total_price_Large
     @execution_total_price_Large = QuotationDetailLargeClassification.where(["quotation_header_id = ?", @quotation_detail_middle_classification.quotation_header_id]).sumpriceExecution
  end

   #歩掛りトータル
  #def labor_total_Large
  #   @labor_total_Large = QuotationDetailLargeClassification.where(["id = ?", @quotation_detail_middle_classification.quotation_detail_large_classification_id]).sumLaborProductivityUnit 
  #end
  #

  # ajax
  def quotation_middle_item_select
     @quotation_middle_item_name = QuotationMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:quotation_middle_item_name).flatten.join(" ")
  end
  def quotation_middle_specification_select
     @quotation_middle_specification = QuotationMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:quotation_middle_specification).flatten.join(" ")
  end
  def quotation_unit_price_select
     @quotation_unit_price = QuotationMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:quotation_unit_price).flatten.join(" ")
  end
  def execution_unit_price_select
     @execution_unit_price = QuotationMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:execution_unit_price).flatten.join(" ")
  end
  #使用材料id(うまくいかないので保留・・・)
  def material_id_select
     
     #@material_id = QuotationMiddleItem.with_material.where(:id => params[:id]).pluck("material_masters.material_name, material_masters.id")
     #@material_id = QuotationMiddleItem.with_material.where(:id => params[:id]).pluck("material_masters.material_code, material_masters.id")
     @material_id = QuotationMiddleItem.with_material.where(:id => params[:id]).pluck("material_masters.material_code") 
     @material_id.push(MaterialMaster.all.pluck("material_masters.material_code") + MaterialMaster.all.pluck("material_masters.id"))
     @material_id.flatten!        

     #未登録の場合はデフォルト値をセット
     if @material_id.blank?
        @material_id  = [["-",1]]
     end
     
     #未登録(-)の場合はセットしない。
     if @material_id  == [["-",1]]
        MaterialMaster.all.pluck("material_masters.material_name, id")
     end 
  end
  #使用材料名
  def quotation_material_name_select
     @quotation_material_name = QuotationMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:quotation_material_name).flatten.join(" ")
  end
  #材料単価
  def material_unit_price_select
     @material_unit_price = QuotationMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_unit_price).flatten.join(" ")
  end
  #労務単価
  def labor_unit_price_select
     @labor_unit_price = QuotationMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:labor_unit_price).flatten.join(" ")
  end
  #歩掛り
  def labor_productivity_unit_select
     @labor_productivity_unit = QuotationMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:labor_productivity_unit).flatten.join(" ")
  end
  #使用材料
  def material_quantity_select
     @material_quantity = QuotationMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_quantity).flatten.join(" ")
  end
  #付属品等
  def accessory_cost_select
     @accessory_cost = QuotationMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:accessory_cost).flatten.join(" ")
  end
  #材料費等
  def material_cost_total_select
     @material_cost_total = QuotationMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_cost_total).flatten.join(" ")
  end
  #労務費等
  def labor_cost_total_select
     @labor_cost_total = QuotationMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:labor_cost_total).flatten.join(" ")
  end
  #その他
  def other_cost_select
     @other_cost = QuotationMiddleItem.where(:id => params[:id]).where("id is NOT NULL").pluck(:other_cost).flatten.join(" ")
  end
  #使用材料名(材料M)
  def m_quotation_material_name_select
     @m_quotation_material_name = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:material_name).flatten.join(" ")
  end
  #材料単価(材料M)
  def m_material_unit_price_select
     @m_material_unit_price = MaterialMaster.where(:id => params[:id]).where("id is NOT NULL").pluck(:last_unit_price).flatten.join(" ")
  end
  
  #見出し→品目絞り込み用
  def quotation_detail_large_classification_id_select
     @quotation_detail_large_classification = QuotationDetailLargeClassification.where(:quotation_header_id => params[:quotation_header_id]).where("id is NOT NULL").pluck(:quotation_large_item_name, :id)
  end
  
  #単位名
  def quotation_unit_name_select
     @quotation_unit_name = QuotationUnit.where(:id => params[:id]).where("id is NOT NULL").pluck(:quotation_unit_name).flatten.join(" ")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quotation_detail_middle_classification
      @quotation_detail_middle_classification = QuotationDetailMiddleClassification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quotation_detail_middle_classification_params
      params.require(:quotation_detail_middle_classification).permit(:quotation_header_id, :quotation_detail_large_classification_id, :line_number, :quotation_items_division_id, :quotation_middle_item_id, :quotation_middle_item_name, :quotation_middle_item_short_name, :quotation_middle_specification, :execution_quantity, :quantity, :quotation_unit_id, :quotation_unit_name, :quotation_unit_price, :quote_price, :execution_unit_price, :execution_price, :material_id, :quotation_material_name, :material_unit_price, :labor_unit_price, :labor_productivity_unit, :material_quantity, :accessory_cost, :material_cost_total, :labor_cost_total, :other_cost )
    end
    
    #単位マスタのストロングパラメータ
    #def quotation_unit_params
      #params.require(:quotation_unit).permit(:quotation_unit_name @quotation_detail_middle_classification.quotation_unit_name)
	#  params = {:quotation_unit_name @quotation_detail_middle_classification.quotation_unit_name}
    #end

    #以降のレコードの行番号を全てインクリメントする
    def line_insert
      QuotationDetailMiddleClassification.where(["quotation_header_id = ? and quotation_detail_large_classification_id = ? and line_number >= ? and id != ?", @quotation_detail_middle_classification.quotation_header_id, @quotation_detail_middle_classification.quotation_detail_large_classification_id, @quotation_detail_middle_classification.line_number, @quotation_detail_middle_classification.id]).update_all("line_number = line_number + 1")
       
      #最終行番号も取得しておく
      @max_line_number = QuotationDetailMiddleClassification.
        where(["quotation_header_id = ? and quotation_detail_large_classification_id = ? and line_number >= ? and id != ?", @quotation_detail_middle_classification.quotation_header_id, 
        @quotation_detail_middle_classification.quotation_detail_large_classification_id, @quotation_detail_middle_classification.line_number, 
        @quotation_detail_middle_classification.id]).maximum(:line_number)
    end 

    #見積品目データへ合計保存用　
    def save_price_to_large_classifications
        #@quotation_detail_large_classification = QuotationDetailLargeClassification.where(:quotation_header_id => params[:quotation_header_id]).where(:quotation_detail_large_classification_id => params[:quotation_detail_large_classification_id])
        @quotation_detail_large_classification = QuotationDetailLargeClassification.where(["quotation_header_id = ? and id = ?", @quotation_detail_middle_classification.quotation_header_id,@quotation_detail_middle_classification.quotation_detail_large_classification_id]).first

     if @quotation_detail_large_classification.present?

        #見積金額
        @quotation_detail_large_classification.quote_price = quote_total_price
        #実行金額
        @quotation_detail_large_classification.execution_price = execution_total_price
        #歩掛り
        @quotation_detail_large_classification.labor_productivity_unit = labor_total

        @quotation_detail_large_classification.save
    
        #見出データへも合計保存
        save_price_to_headers
     end

    end

    #見出データへ合計保存用
    def save_price_to_headers
       @quotation_header = QuotationHeader.find(@quotation_detail_large_classification.quotation_header_id)
       
       if @quotation_header.present? 
       #見積金額
          @quotation_header.quote_price = quote_total_price_Large
		  
		  #binding.pry
		  
          #実行金額
          @quotation_header.execution_amount = execution_total_price_Large
          @quotation_header.save
       end 
   end

   
   
   #見出しデータへ最終行番号保存用
    def quotation_dlc_set_last_line_number
        @quotation_detail_large_classifiations = QuotationDetailLargeClassification.where(["quotation_header_id = ? and id = ?", @quotation_detail_middle_classification.quotation_header_id,@quotation_detail_middle_classification.quotation_detail_large_classification_id]).first
		
        check_flag = false
	    if @quotation_detail_large_classifiations.last_line_number.nil? 
          check_flag = true
        else
	      if (@quotation_detail_large_classifiations.last_line_number < @max_line_number) then
           check_flag = true
		  end
	    end
	    if (check_flag == true)
	       quotation_dlc_params = { last_line_number:  @max_line_number}
		   if @quotation_detail_large_classifiations.present?
		     @quotation_detail_large_classifiations.update(quotation_dlc_params)
		   end 
        end 
    end
    #行番号を取得し、インクリメントする。（新規用）
    def get_line_number
      @line_number = 1
      if @quotation_detail_middle_classification.quotation_header_id.present? && @quotation_detail_middle_classification.quotation_detail_large_classification_id.present?
         @quotation_detail_large_classifiations = QuotationDetailLargeClassification.where(["quotation_header_id = ? and id = ?", @quotation_detail_middle_classification.quotation_header_id,@quotation_detail_middle_classification.quotation_detail_large_classification_id]).first
		 
		 if @quotation_detail_large_classifiations.present?
            if @quotation_detail_large_classifiations.last_line_number.present?
               @line_number = @quotation_detail_large_classifiations.last_line_number + 1
            end
         end
      end
	  
	  @quotation_detail_middle_classification.line_number = @line_number
    end
	
	
end
