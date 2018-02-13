class TaskContentsController < ApplicationController
  before_action :set_task_content, only: [:show, :edit, :update, :destroy]

  # GET /task_contents
  # GET /task_contents.json
  def index
    @task_contents = TaskContent.all
  end

  # GET /task_contents/1
  # GET /task_contents/1.json
  def show
  end

  # GET /task_contents/new
  def new
    @task_content = TaskContent.new
  end

  # GET /task_contents/1/edit
  def edit
  end

  # POST /task_contents
  # POST /task_contents.json
  def create
    @task_content = TaskContent.new(task_content_params)

    respond_to do |format|
      if @task_content.save
        format.html { redirect_to @task_content, notice: 'Task content was successfully created.' }
        format.json { render :show, status: :created, location: @task_content }
      else
        format.html { render :new }
        format.json { render json: @task_content.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /task_contents/1
  # PATCH/PUT /task_contents/1.json
  def update
    respond_to do |format|
      if @task_content.update(task_content_params)
        format.html { redirect_to @task_content, notice: 'Task content was successfully updated.' }
        format.json { render :show, status: :ok, location: @task_content }
      else
        format.html { render :edit }
        format.json { render json: @task_content.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /task_contents/1
  # DELETE /task_contents/1.json
  def destroy
    @task_content.destroy
    respond_to do |format|
      format.html { redirect_to task_contents_url, notice: 'Task content was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task_content
      @task_content = TaskContent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_content_params
      params.require(:task_content).permit(:name)
    end
end
