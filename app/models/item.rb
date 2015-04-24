class Item < ActiveRecord::Base
  
  GEO_FACTORY = RGeo::Geographic.spherical_factory(srid: 4326)
  
  set_rgeo_factory_for_column :coordinates, GEO_FACTORY
  
  validates :price, :quantity, format: { with: /\d+/, message: "必须是整数" }, numericality: { greater_than_or_equal_to: 0 }
  
  belongs_to :user
  
  mount_uploader :image, ImageUploader


  def as_json(opts = {})
    {
      id: self.id,
      title: self.title || "",
      thumb_image: self.thumb_image_url,
      large_image: self.large_image_url,
      price: self.price || "",
      quantity: self.quantity || "",
      service_modes: self.service_modes || "",
      address: self.address || "",
      left_time: self.left_time, 
      latitude: coordinates.y || "",
      longitude: coordinates.x || "",
      note: self.note || "",
      user: {
        nickname: user.nickname,
        mobile: user.mobile,
        avatar: user.avatar_url,
        likes_count: 0,
      }
    }
  end
  
  def left_time
    if self.expired_at.blank?
      ""
    else
      now = Time.now
      if self.expired_at > now
        ( self.expired_at - now ).to_i.to_s
      else
        "0"
      end
    end
  end
  
  def large_image_url
    if self.image.present?
      self.image.url(:large)
    else
      ""
    end
  end
  
  def thumb_image_url
    if self.image.present?
      self.image.url(:thumb)
    else
      ""
    end
  end
  
end

#t.string :title, :null => false
#t.integer :price
#t.integer :quantity
#t.datetime :expired_at, :null => false
#t.string :address
#t.point :coordinates, geographic: true
#t.string :note
#t.string :image
#t.string :service_modes, :null => false
#t.integer :user_id