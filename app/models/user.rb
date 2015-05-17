class User < ActiveRecord::Base
  validates :mobile, presence: true
  validates :mobile, format: { with: /\A1[3|4|5|8][0-9]\d{4,8}\z/, message: "请输入11位正确手机号" }, 
  length: { is: 11 }, :uniqueness => true
  
  has_many :likes, dependent: :destroy
  has_many :orders, dependent: :destroy
  
  validates :nickname, uniqueness: true, allow_nil: true
            
  mount_uploader :avatar, AvatarUploader
  
  after_create :generate_private_token
  def generate_private_token
    random_key = "#{SecureRandom.hex(10)}"
    self.update_attribute(:private_token, random_key)
  end
  
  def increase_orders_count
    self.update_attribute(:orders_count, self.orders_count + 1)
  end
  
  def decrease_orders_count
    self.update_attribute(:orders_count, self.orders_count - 1) if self.orders_count > 0
  end
  
  # def liked_by_user?(user)
  #   return false if user.blank?
  #   Like.where(likeable: self, user_id: user.id).count > 0
  # end
  
  # 点赞
  # def like(likeable)
  #   return false if likeable.blank?
  #   return false if likeable.liked_by_user?(self) # 已经被赞过
  #   Like.where(likeable_id: likeable.id,
  #               likeable_type: likeable.class,
  #               user_id: self.id).first_or_create
  # end
  
  # 取消赞
  # def unlike(likeable)
  #   return false if likeable.blank?
  #   return false if not likeable.liked_by_user?(self) # 如果没被赞
  #   Like.destroy_all(likeable_id: likeable.id,
  #                    likeable_type: likeable.class,
  #                    user_id: self.id)
  # end
  
  def like(item)
    return false if item.blank?
    user = item.user
    user.update_attribute(:likes_count, user.likes_count + 1)
    # return false if item.liked_by_user?(self)
    # LikeItem.where(user_id: self.id, 
    #                item_id: item.id, 
    #                item_user_id: item.user.id).first_or_create
  end
  
  def unlike(item)
    return false if item.blank?
    user = item.user
    user.update_attribute(:likes_count, user.likes_count - 1) if user.likes_count > 0
    # return false if not item.liked_by_user?(self)
    # LikeItem.destroy_all(user_id: self.id,
    #                  item_id: item.id,
    #                  item_user_id: item.user.id)
  end
  
  def increase_publish_count
    self.update_attribute(:publish_count, self.publish_count + 1)
  end
  
  def decrease_publish_count
    self.update_attribute(:publish_count, self.publish_count - 1) if self.publish_count > 0
  end
  
  def as_json(opts = {})
    {
      id: self.id,
      mobile: self.mobile || "",
      nickname: self.nickname || "",
      token: self.private_token || "",
      avatar: self.avatar_url,
      signature: self.signature || "",
      likes_count: self.likes_count,
      publish_count: self.publish_count,
      orders_count: self.orders_count,
    }
  end
  
  def avatar_url
    if self.avatar.present?
      self.avatar.url(:big)
    else
      ""
    end
  end
end
