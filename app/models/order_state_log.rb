class OrderStateLog < ActiveRecord::Base
  belongs_to :order
  belongs_to :user
  
  validates :order_id, :user_id, :operation_name, presence: true
end

# t.integer :order_id # 操作的订单
# t.integer :user_id  # 操作人
# t.integer :user_type, default: 1 # 操作人类型, 1表示管理员 2表示用户 3表示商家
# t.string :operation_name # 具体订单操作步骤名称
