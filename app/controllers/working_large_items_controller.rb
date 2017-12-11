class WorkingLargeItemsController < ApplicationController
  before_action :set_working_large_item, only: [:show, :edit, :update, :destroy]

  # GET /working_large_items
  # GET /working_large_items.json
  def index
    #@working_large_items = WorkingLargeItem.all
	@q = WorkingLargeItem.ransack(params[:q])   
    @working_large_items  = @q.result(distinct: true)
    @working_large_items  = @working_large_items.page(params[:page])
    
    @working_large_items  = @working_large_items.order('seq DESC')
    
  end
  
  #ドラッグ＆ドロップによる並び替え機能(seqをセットする)
  def reorder
    row = params[:row].split(",").reverse    #ビューの並びが逆のため、パラメータの配列を逆順でセットさせる。
    row.each_with_index {|row, i| WorkingLargeItem.update(row, {:seq => i})}
    render :text => "OK"
  end
  
  # GET /working_large_items/1
  # GET /working_large_items/1.json
  def show
  end

  # GET /working_large_items/new
  def new
    @working_large_item = WorkingLargeItem.new
  end

  # GET /working_large_items/1/edit
  def edit
  end

  # POST /working_large_items
  # POST /working_large_items.json
  def create
    @working_large_item = WorkingLargeItem.new(working_large_item_params)

    respond_to do |format|
      if @working_large_item.save
	  
	    #ソート用のseqにIDをセットする。
        @working_large_item.update(seq: @working_large_item.id)
		#
		
        format.html { redirect_to @working_large_item, notice: 'Working large item was successfully created.' }
        format.json { render :show, status: :created, location: @working_large_item }
      else
        format.html { render :new }
        format.json { render json: @working_large_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /working_large_items/1
  # PATCH/PUT /working_large_items/1.json
  def update
    respond_to do |format|
      if @working_large_item.update(working_large_item_params)
        format.html { redirect_to @working_large_item, notice: 'Working large item was successfully updated.' }
        format.json { render :show, status: :ok, location: @working_large_item }
      else
        format.html { render :edit }
        format.json { render json: @working_large_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /working_large_items/1
  # DELETE /working_large_items/1.json
  def destroy
    @working_large_item.destroy
    respond_to do |format|
      format.html { redirect_to working_large_items_url, notice: 'Working large item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_working_large_item
      @working_large_item = WorkingLargeItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def working_large_item_params
      params.require(:working_large_item).permit(:working_large_item_name, :working_large_item_short_name, 
             :working_large_specification, :working_unit_id, :working_unit_price, :execution_unit_price, 
             :execution_material_unit_price, :material_unit_price, :execution_labor_unit_price, :labor_unit_price,
             :labor_productivity_unit, :labor_productivity_unit_total, :seq)
    end
end
