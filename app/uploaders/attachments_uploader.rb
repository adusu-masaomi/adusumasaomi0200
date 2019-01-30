class AttachmentsUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  #include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog
  
  #for CentOs's OneDrive Setting
  #def root
    #"/rootOneDrive/共有/工事資料/"
  #  "/rootOneDrive/共有/工事資料"

  #end 

  #一括Jpegコンバート(しない)
  #process convert: 'jpg'

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    #default
    #"uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.construction_datum.construction_code.to_s + "-" + model.construction_datum.construction_name}"
    
    #"#{model.construction_datum.construction_code.to_s + "-" + model.construction_datum.construction_name}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  
  #リサイズしない
  #基本サイズ
  #process :resize_to_fit => [200, 200]
  
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end
  # thumb バージョン(width 400px x height 200px)
  
  def cover
    manipulate! do |frame, index|
      frame if index.zero?
    end
  end
  
  
  #サムネイル用のファイル処理
  #version :thumb, :if => :image? do
  #  process :resize_to_fit => [200, 200]
  #end
  
  #version :pdf_thumb, :if => :pdf? do
  #version :thumb, :if => :pdf? do
  version :thumb, :if => :image? do
     process :cover
     process :convert => 'jpeg'
     
     process :resize_to_limit => [200, 200]
     
     def full_filename (for_file = model.artifact.file)
        super.chomp(File.extname(super)) + '.jpeg'
     end
  end
  
  def image?(new_file)
    #binding.pry
  
    (new_file.content_type.include? 'image') || (new_file.content_type.include? 'pdf')
    #new_file.content_type.include? 'image'
  end
  def pdf?(new_file)
    new_file.content_type.include? 'pdf'
  end
  
  def convert_cover(format)
    manipulate! do |img| # this is ::MiniMagick::Image instance
      img.format(format.to_s.downcase, 0)
      img
    end
  end

  def set_content_type_png(*args)
    self.file.instance_variable_set(:@content_type, "image/png")
  end
  #def set_content_type(*args)
  #  self.file.instance_variable_set(:@content_type, "image/jpeg")
  #end
  
  
  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_whitelist
  #   %w(jpg jpeg gif png)
  # end
  
  #社長用なので、全部許可する!
  # 許可する画像の拡張子
  #def extension_white_list
  #  %W[jpg jpeg gif png pdf jww dxf]
  #end
  
  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
  # 変換したファイルのファイル名の規則
  #def filename
  
  #end
  def filename
    
    #default
    #"#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.jpg" if original_filename.present?  
    #"#{model.id}-#{original_filename}" if original_filename.present?
    #"#{secure_token}-#{original_filename}" if original_filename.present?
    "#{original_filename}" if original_filename.present?
  end
  
  protected
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
 
end
