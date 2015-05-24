module ItemsHelper
  def render_image_tag(item)
    return "" if item.blank?
    return "" if item.image.blank?
    
    image_tag item.image.url(:thumb), size: '100x100'
  end
end