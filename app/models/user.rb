class User < ActiveRecord::Base
  validates :mobile, presence: true
  validates :mobile, format: { with: /\A1[3|4|5|8][0-9]\d{4,8}\z/, message: "请输入11位正确手机号" }, 
  length: { is: 11 }, :uniqueness => true
  
  validates_uniqueness_of :nickname
            
  mount_uploader :avatar, AvatarUploader
  
  after_create :generate_private_token
  def generate_private_token
    random_key = "#{SecureRandom.hex(10)}"
    self.update_attribute(:private_token, random_key)
  end
  
  def as_json(opts = {})
    {
      id: self.id,
      nickname: self.nickname || "",
      token: self.private_token || "",
      avatar: self.avatar.url(:big) || "",
    }
  end
end
