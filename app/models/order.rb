class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :item
  
  has_many :order_state_logs # 订单操作历史
  
  validates :user_id, :item_id, :state, presence: true
  validates :fee, format: { with: /\d+/, message: "必须是整数" }, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, format: { with: /\d+/, message: "必须是整数" }, numericality: { greater_than_or_equal_to: 1 }
  
  scope :unaccepted, -> { with_state(:normal) }
  
  before_create :generate_order_no
  def generate_order_no
    self.order_no = Time.now.to_s(:number)[2,12] + Time.now.nsec.to_s
  end
  
  after_create :update_stock_and_send_notification
  def update_stock_and_send_notification
    # 减少库存
    item.decrease_stock(self.quantity)
    
    # 更新订单数
    item.user.increase_orders_count if item.user
    user.increase_orders_count
    
    # 发送下单通知给卖家
    receipts = []
    receipts << item.user.mobile
    PushService.push('您获得了一个订单', receipts)
    
  end
  
  # 恢复库存
  def increase_item_stock
    item.increase_stock(self.quantity)
  end
  
  # 记录操作日志
  def write_log(user_id, user_type, operation_name, action)
    OrderStateLog.create(order_id: self.id, user_id: user_id, user_type: user_type, operation_name: operation_name, action: action)
  end
  
  state_machine initial: :normal do
    state :accepted # 接受订单
    state :canceled # 取消订单
    state :completed # 完成订单
    
    # 确认订单（商家接受订单）
    after_transition :normal => :accepted, :do => :add_orders_count_and_write_log
    event :accept do
      transition :normal => :accepted
    end
    
    # 用户取消订单
    event :user_cancel do
      transition :normal => :canceled
    end
    
    # 商家取消订单
    event :seller_cancel do
      transition [:normal, :accepted] => :canceled
    end
    
    # 完成订单（商家可以标记订单完成）
    after_transition :accepted => :completed, :do => :seller_write_completion_log
    event :complete do
      transition :accepted => :completed
    end
    
  end
  
  # 卖家确认订单后的操作
  def add_orders_count_and_write_log
    seller = item.user
    
    # 更新卖家的订单数
    # seller.increase_orders_count if seller
    
    # 通知用户订单已经确认
    receipts = []
    receipts << user.mobile
    PushService.push('卖家已经确认了您的订单', receipts)
    
    # 记录订单操作日志
    OrderStateLog.create(order_id: self.id, user_id: seller.id, user_type: 3, operation_name: '卖家确认订单', action: "accept")
  end
  
  # 卖家完成订单后的操作
  def seller_write_completion_log
    seller = item.user
    
    OrderStateLog.create(order_id: self.id, user_id: seller.id, user_type: 3, operation_name: '卖家完成订单', action: "complete")
  end
  
  def as_json(opts = {})
    {
      id: self.id,
      order_no: self.order_no || "",
      item: item || {},
      quantity: self.quantity || "",
      fee: self.fee || "",
      ordered_at: self.format_ordered_at,
      service_modes: self.service_modes || "",
      address: self.address || "",
      state: self.state || "",
      note: self.note || "",
      user: self.user || {},
      # operate: self.format_operate,
      # operate_logs: self.order_state_logs || [],
    }
  end
  
  def format_ordered_at
    self.created_at.strftime('%m.%d %H:%M')
  end
  
  def format_state
    case self.state.to_sym
    when :normal then '待确认'
    when :accepted then '已确认'
    when :completed then '已完成'
    when :canceled then '已取消'
    else 'Error'
    end
  end
  
end

# t.integer :user_id
# t.integer :item_id
# t.string  :state
# t.string :service_modes
# t.string :address
# t.integer :quantity, default: 1
# t.string :note
# t.integer :fee
# order_no