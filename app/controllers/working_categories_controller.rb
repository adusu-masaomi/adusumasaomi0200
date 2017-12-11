class WorkingCategoriesController < ApplicationController
  before_action :set_working_category, only: [:show, :edit, :update, :destroy]

  # GET /working_categories
  # GET /working_categories.json
  def index
    @working_categories = WorkingCategory.all
  end

  # GET /working_categories/1
  # GET /working_categories/1.json
  def show
  end

  # GET /working_categories/new
  def new
    @working_category = WorkingCategory.new
  end

  # GET /working_categories/1/edit
  def edit
  end

  # POST /working_categories
  # POST /working_categories.json
  def create
    @working_category = WorkingCategory.new(working_category_params)

    respond_to do |format|
      if @working_category.save
        format.html { redirect_to @working_category, notice: 'Working category was successfully created.' }
        format.json { render :show, status: :created, location: @working_category }
      else
        format.html { render :new }
        format.json { render json: @working_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /working_categories/1
  # PATCH/PUT /working_categories/1.json
  def update
    respond_to do |format|
      if @working_category.update(working_category_params)
        format.html { redirect_to @working_category, notice: 'Working category was successfully updated.' }
        format.json { render :show, status: :ok, location: @working_category }
      else
        format.html { render :edit }
        format.json { render json: @working_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /working_categories/1
  # DELETE /working_categories/1.json
  def destroy
    @working_category.destroy
    respond_to do |format|
      format.html { redirect_to working_categories_url, notice: 'Working category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_working_category
      @working_category = WorkingCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def working_category_params
      params.require(:working_category).permit(:category_name)
    end
end
