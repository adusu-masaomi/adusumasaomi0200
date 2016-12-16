class WorkingSafetyMattersController < ApplicationController
  before_action :set_working_safety_matter, only: [:show, :edit, :update, :destroy]

  # GET /working_safety_matters
  # GET /working_safety_matters.json
  def index
    @working_safety_matters = WorkingSafetyMatter.all
  end

  # GET /working_safety_matters/1
  # GET /working_safety_matters/1.json
  def show
  end

  # GET /working_safety_matters/new
  def new
    @working_safety_matter = WorkingSafetyMatter.new
  end

  # GET /working_safety_matters/1/edit
  def edit
  end

  # POST /working_safety_matters
  # POST /working_safety_matters.json
  def create
    @working_safety_matter = WorkingSafetyMatter.new(working_safety_matter_params)

    respond_to do |format|
      if @working_safety_matter.save
        format.html { redirect_to @working_safety_matter, notice: 'Working safety matter was successfully created.' }
        format.json { render :show, status: :created, location: @working_safety_matter }
      else
        format.html { render :new }
        format.json { render json: @working_safety_matter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /working_safety_matters/1
  # PATCH/PUT /working_safety_matters/1.json
  def update
    respond_to do |format|
      if @working_safety_matter.update(working_safety_matter_params)
        format.html { redirect_to @working_safety_matter, notice: 'Working safety matter was successfully updated.' }
        format.json { render :show, status: :ok, location: @working_safety_matter }
      else
        format.html { render :edit }
        format.json { render json: @working_safety_matter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /working_safety_matters/1
  # DELETE /working_safety_matters/1.json
  def destroy
    @working_safety_matter.destroy
    respond_to do |format|
      format.html { redirect_to working_safety_matters_url, notice: 'Working safety matter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_working_safety_matter
      @working_safety_matter = WorkingSafetyMatter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def working_safety_matter_params
      params.require(:working_safety_matter).permit(:working_safety_matter_name)
    end
end
