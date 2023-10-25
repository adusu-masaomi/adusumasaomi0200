class WorkingSubcategoriesController < ApplicationController
  before_action :set_working_subcategory, only: [:show, :edit, :update, :destroy]

  # GET /working_subcategories
  # GET /working_subcategories.json
  def index
    #@working_subcategories = WorkingSubcategory.all
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)  	
    
    
    #####
    #主カテゴリー画面からの遷移の場合、初期値をセット。
    if params[:working_category_id].present?
      working_cartegory_id = params[:working_category_id]
      #upd 230501
      if query.nil?
        query = {"working_category_id_eq"=> working_cartegory_id}
      else
        query.store("working_category_id_eq", working_cartegory_id)
      end
    end
    #####
    
    
    #ransack保持用-
    @q = WorkingSubcategory.ransack(query)   
    
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
	
    @working_subcategories  = @q.result(distinct: true)
    
  end

  # GET /working_subcategories/1
  # GET /working_subcategories/1.json
  def show
  end

  # GET /working_subcategories/new
  def new
    @working_subcategory = WorkingSubcategory.new
    
    #主カテゴリー画面からの遷移の場合、初期値をセット。
    if params[:working_category_id].present?
      @working_subcategory.working_category_id ||= params[:working_category_id]
    end
	
  end

  # GET /working_subcategories/1/edit
  def edit
  end

  # POST /working_subcategories
  # POST /working_subcategories.json
  def create
    @working_subcategory = WorkingSubcategory.new(working_subcategory_params)

    respond_to do |format|
      if @working_subcategory.save
        #format.html { redirect_to @working_subcategory, notice: 'Working subcategory was successfully created.' }
        #format.json { render :show, status: :created, location: @working_subcategory }
        
        
        format.html {redirect_to working_subcategory_path(@working_subcategory, 
         :working_category_id => params[:working_category_id])}
      else
        format.html { render :new }
        format.json { render json: @working_subcategory.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /working_subcategories/1
  # PATCH/PUT /working_subcategories/1.json
  def update
    respond_to do |format|
      if @working_subcategory.update(working_subcategory_params)
        #format.html { redirect_to @working_subcategory, notice: 'Working subcategory was successfully updated.' }
        #format.json { render :show, status: :ok, location: @working_subcategory }
         format.html {redirect_to working_subcategory_path(@working_subcategory,
           :working_category_id => params[:working_category_id])}
      else
        format.html { render :edit }
        format.json { render json: @working_subcategory.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /working_subcategories/1
  # DELETE /working_subcategories/1.json
  def destroy
    
    @working_subcategory.destroy
    respond_to do |format|
      #format.html { redirect_to working_subcategories_url, notice: 'Working subcategory was successfully destroyed.' }
      #format.json { head :no_content }
      format.html {redirect_to working_subcategories_path( :working_category_id => params[:working_category_id])}
    end
  end

  #ajax
  #親カテゴリーを選択したら該当する商品を取得
  def subcategory_extract
    if params[:working_category_id] != ""
      
      #初期値の空白をセット
      array  = WorkingSubcategory.where(:id => "1").where("id is NOT NULL").pluck("name, id")  #restore 180208
      
      #カテゴリー別のアイテムをセット
      array += WorkingSubcategory.where(:working_category_id => params[:working_category_id]).where("id is NOT NULL").order(:seq).
        pluck("name, id")
      
      if array.present?
        @working_subcategory_select_hide = array
      
      else
        @working_subcategory_select_hide = ""

        #array  = WorkingSubcategory.where(:id => "1").where("id is NOT NULL").pluck("name, id")
        #@working_subcategory_select_hide = array
        
        #@working_subcategory_select_hide = WorkingSubcategory.all.order(:seq).
        #   pluck("name, id")
        
      end
	end
	
  end
  
  #ajax
  #add180206
  #ドラッグ＆ドロップによる並び替え機能(seqをセットする)
  def reorder
    
	row = params[:row].split(",")   
	
    
    
	#行番号へセットするため、配列は１から開始させる。
	row.each_with_index {|row, i| WorkingSubcategory.update(row, {:seq => i + 1})}
    render :text => "OK"

  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_working_subcategory
      @working_subcategory = WorkingSubcategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def working_subcategory_params
      params.require(:working_subcategory).permit(:working_category_id, :name, :seq)
    end
end
