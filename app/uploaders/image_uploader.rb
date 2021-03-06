# encoding: utf-8

class ImageUploader < BaseUploader

  version :small do
    process resize_to_fill: [80, 80]
  end
  
  version :thumb do
    process resize_to_fill: [320, 320]
  end

  version :large do
    process resize_to_fill: [640, 384]
  end

  def filename
    if super.present?
      "#{secure_token}.#{file.extension}"
    end
  end
  
  def extension_white_list
    %w(jpg jpeg png webp)
  end
  
  protected
    def secure_token
      var = :"@#{mounted_as}_secure_token"
      model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
    end

end
