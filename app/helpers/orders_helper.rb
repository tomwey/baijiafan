module OrdersHelper
  
  def render_order_state(order)
    return "" if order.blank?
    
    case order.state.to_sym
    when :normal then '待确认'
    when :accepted then '卖家已确认'
    when :canceled then '已取消'
    when :completed then '已完成'
    else ""
    end
  end
  
  def render_log_user_type(log)
    return "" if log.blank?
    
    case log.user_type.to_i
    when 1 then '管理员'
    when 2 then '用户'
    when 3 then '卖家'
    else ''
    end
    
  end
  
end