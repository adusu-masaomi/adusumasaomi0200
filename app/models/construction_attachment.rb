class ConstructionAttachment < ActiveRecord::Base
  belongs_to :construction_datum
  #belongs_to :construction_datum, optional: true →not work
  mount_uploader :attachment, AttachmentsUploader
 
 
  
end
