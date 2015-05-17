class Item < ActiveRecord::Base
  
  GEO_FACTORY = RGeo::Geographic.spherical_factory(srid: 4326)
  
  set_rgeo_factory_for_column :coordinates, GEO_FACTORY
  
  # geocoded_by :address, :lookup => lambda{ |obj| obj.geocoder_lookup } do |record, results|
  #   result = results.first
  #   
  #   # record.address = result.address
  #   record.coordinates = "POINT(#{result.longitude} #{result.latitude})"
  # end
  # 
  # before_save :geocode
  # 
  # def geocoder_lookup
  #   :baidu
  # end
  # geocoded_by :address do |record, results|
  #   result = results.first
  #   
  #   record.address = result.address
  #   record.coordinates = GEO_FACTORY.point(result.latitude, result.longitude)
  # end
  validates :title, :note, :price, :coordinates, :address, :expired_at, :presence => true
  validates :price, format: { with: /\d+/, message: "必须是整数" }, numericality: { greater_than_or_equal_to: 0 }
  
  belongs_to :user
  
  has_many :orders
  
  mount_uploader :image, ImageUploader
  
  def self.search(keyword)
    # Item.select("items.*, st_distance(coordinates, 'point(#{params[:longitude]} #{params[:latitude]})') as distance").where("st_dwithin(coordinates, 'point(#{params[:longitude]} #{params[:latitude]})', #{range})").order("distance")
  end
  
  after_destroy :decrease_publish_count
  def decrease_publish_count
    self.user.decrease_publish_count if self.user
  end
  
  def increase_stock(stock)
    self.update_attribute(:current_quantity, self.current_quantity + stock) if ( self.current_quantity + stock <= self.quantity )
  end
  
  def decrease_stock(stock)
    self.update_attribute(:current_quantity, self.current_quantity - stock) if self and self.current_quantity.to_i >=  stock
  end

  def as_json(opts = {})
    {
      id: self.id,
      title: self.title || "",
      intro: self.note || "",
      thumb_image: self.thumb_image_url,
      large_image: self.large_image_url,
      price: self.price || "",
      quantity: self.current_quantity || "",
      service_modes: self.service_modes || "",
      address: self.address || "",
      left_time: self.left_time, 
      expired_at: self.expired_time,
      latitude: latitude,
      longitude: longitude,
      blike: self.liked_by_user?(user),
      note: self.note || "",
      user: user || {}, 
    }
  end
  
  def latitude
    if coordinates
      coordinates.y || ""
    else
      ""
    end
  end
  
  def longitude
    if coordinates
      coordinates.x || ""
    else
      ""
    end
  end
  
  def expired_time
    if self.expired_at
      self.expired_at.strftime('%Y-%m-%d %H:%M:%S')
    else
      ""
    end
  end
  
  def liked_by_user?(user)
    return false if user.blank?
    LikeItem.where(user_id: user.id, item_id: self.id, item_user_id: self.user.id).count > 0
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