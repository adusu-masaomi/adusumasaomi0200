class ConstructionAttachmentsController < ApplicationController
  before_action :set_construction_attachment, only: [:show, :edit, :update, :destroy]

  # GET /construction_attachments
  # GET /construction_attachments.json
  def index
    @construction_attachments = ConstructionAttachment.all
  end

  # GET /construction_attachments/1
  # GET /construction_attachments/1.json
  def show
  end

  # GET /construction_attachments/new
  def new
    @construction_attachment = ConstructionAttachment.new
  end

  # GET /construction_attachments/1/edit
  def edit
  end

  # POST /construction_attachments
  # POST /construction_attachments.json
  def create
    @construction_attachment = ConstructionAttachment.new(construction_attachment_params)

    respond_to do |format|
      if @construction_attachment.save
        format.html { redirect_to @construction_attachment, notice: 'Construction attachment was successfully created.' }
        format.json { render :show, status: :created, location: @construction_attachment }
      else
        format.html { render :new }
        format.json { render json: @construction_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /construction_attachments/1
  # PATCH/PUT /construction_attachments/1.json
  def update
    respond_to do |format|
      if @construction_attachment.update(construction_attachment_params)
        format.html { redirect_to @construction_attachment, notice: 'Construction attachment was successfully updated.' }
        format.json { render :show, status: :ok, location: @construction_attachment }
      else
        format.html { render :edit }
        format.json { render json: @construction_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /construction_attachments/1
  # DELETE /construction_attachments/1.json
  def destroy
    @construction_attachment.destroy
    respond_to do |format|
      format.html { redirect_to construction_attachments_url, notice: 'Construction attachment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_construction_attachment
      @construction_attachment = ConstructionAttachment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def construction_attachment_params
      params.require(:construction_attachment).permit(:construction_datum_id, :title, :attachment)
    end
end
