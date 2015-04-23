class AuthCode < ActiveRecord::Base
  
  validates :mobile, presence: true
  validates :mobile, format: { with: /\A1[3|4|5|8][0-9]\d{4,8}\z/, message: "请输入11位正确手机号" }, length: { is: 11 }
  
  before_create :generate_code
  def generate_code
    self.code = rand.to_s[2..7]
  end
  
end
