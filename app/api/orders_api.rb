# coding: utf-8

module API
  class OrdersAPI < Grape::API
    
    resource :orders do
      
      # 下订单
      params do
        requires :token, type: String, desc: "用户Token"
        requires :item_id, type: Integer, desc: "条目id"
        requires :service_modes, type: String, desc: "服务方式"
        requires :address, type: String, desc: "服务地址"
        requires :quantity, type: Integer, desc: "份数"
        optional :fee, type: Integer, desc: "总价"
        optional :note, type: String, desc: "备注"
      end
      post :create do
        user = authenticate!
        
        item = Item.find_by(id: params[:item_id])
        if item.blank?
          return { code: -2, message: "未找到该条目" }
        end
        
        if item.expired_at < Time.now
          return { code: -3, message: "该条目已过期，不能下单" }
        end
        
        if item.current_quantity.blank? or item.current_quantity <= 0
          return { code: -4, message: "该条目已经售完" }
        end
        
        if user == item.user
          return { code: -5, message: "您不能预订自己的产品" }
        end
        
        order = Order.new(user_id: user.id, 
                          item_id: params[:item_id], 
                          service_modes: params[:service_modes],
                          address: params[:address],
                          quantity: params[:quantity],
                          note: params[:note] )
        
        if params[:fee]
          order.fee = params[:fee]
        else
          order.fee = order.item.price * order.quantity
        end               
        
        if order.save
          { code: 0, message: "ok" }
        else
          { code: 3001, message: order.errors.full_messages.join(',') }
        end              
      end # end create
      
      # 我的订单列表
      params do
        requires :token, type: String, desc: "用户Token"
        requires :type, type: Integer, desc: "列表数据类型，1表示我吃过的订单，2表示我卖过的订单"
        optional :page, type: Integer, desc: "当前页码"
        optional :size, type: Integer, desc: "分页大小"
      end
      get :list do
        user = authenticate!
        
        # puts params[:type]
        if not %w(1 2).include?(params[:type].to_s)
          return { code: -1, message: "不正确的type参数，type的值只能是1或2" }
        end
        
        type = params[:type].to_i
        if type == 1
          @orders = user.orders.order('id DESC')
        else
          @orders = Order.joins(:item).where('items.user_id = ?', user.id).order('id DESC')
        end
        
        page = params[:page] || "1"
        size = params[:size] || "30"
        
        @orders = @orders.paginate page: page.to_i, per_page: size.to_i
        
        { code: 0, message: "ok", data: @orders }
      end # end list
      
      # 获取卖家未接受的订单
      params do
        requires :token, type: String, desc: "用户Token"
      end
      get :unaccepted do
        user = authenticate!
        
        @orders = Order.joins(:item).where('items.user_id = ?', user.id).order('id DESC')
        
        { code: 0, message: "ok", data: @orders }
      end # end unaccepted
      
    end # end orders resource
    
    resource :order do
      # 卖家接受订单
      params do
        requires :token, type: String, desc: "用户Token"
        requires :order_no, type: String, desc: "订单号"
      end
      post :accept do
        user = authenticate!
        @order = Order.joins(:item).where('items.user_id = ? and order_no = ?', user.id, params[:order_no]).limit(1)
        
        if @order.blank?
          return { code: -2, message: "未找到订单" }
        end
        
        unless @order.state.to_sym == :normal
          return { code: 3008, message: "不能接受订单" }
        end
        
        if @order.accept
          { code: 0, message: "ok" }
        else
          { code: 3002, message: "卖家接受订单失败" }
        end
      end # end accept
      
      # 取消订单
      params do
        requires :token, type: String, desc: "用户Token"
        requires :role, type: String, desc: "操作角色，值为buyer(买家，普通用户)或seller(卖家，发布者)之一"
        requires :order_no, type: String, desc: "订单号"
      end
      post :cancel do
        user = authenticate!
        
        unless %w(buyer seller).include?(params[:role].to_s)
          return { code: -1, message: "不正确的role参数值，值应该为buyer或seller" }
        end
        
        if params[:role] == 'buyer'
          # 买方
          @order = user.orders.where('order_no = ?',params[:order_no]).limit(1)
          
          if @order.blank?
            return { code: -2, message: "未找到订单" }
          end
          
          if @order.state.to_sym == :normal
            if @order.user_cancel
              
              # 恢复库存
              @order.increase_item_stock
              
              # 记录订单操作日志
              @order.write_log(user.id, 2, '用户取消订单', 'user_cancel')
              
              { code: 0, message: "ok" }
            else
              { code: 3004, message: "用户取消订单失败" }
            end
          else
            { code: 3003, message: "用户不能取消订单" }
          end
        else
          # 卖方
          @order = Order.joins(:item).where('items.user_id = ? and order_no = ?', user.id, params[:order_no]).limit(1)
          
          if @order.blank?
            return { code: -2, message: "未找到订单" }
          end
          
          if @order.state.to_sym == :normal or @order.state.to_sym == :accepted
            if @order.seller_cancel
              
              # 恢复库存
              @order.increase_item_stock
              
              # 更新订单数
              user.decrease_orders_count
              
              # 记录订单操作日志
              @order.write_log(user.id, 3, '卖家取消订单', 'seller_cancel')
              { code: 0, message: "ok" }
            else
              { code: 3006, message: "卖家取消订单失败" }
            end
          else
            { code: 3005, message: "卖家不能取消订单" }
          end
        end
        
      end # end cancel
      
      # 卖家完成订单
      params do
        requires :token, type: String, desc: "用户Token"
        requires :order_no, type: String, desc: "订单号"
      end
      post :complete do
        user = authenticate!
        
        @order = Order.joins(:item).where('items.user_id = ? and order_no = ?', user.id, params[:order_no]).limit(1)
        
        if @order.blank?
          return { code: -2, message: "未找到订单" }
        end
        
        if @order.complete
          { code: 0, message: "ok" }
        else
          { code: 3007, message: "卖家完成订单失败" }
        end
        
      end # end complete
      
      # 用户评价订单
      
      # 删除订单
      
      
    end # end order resource
    
  end
  
end