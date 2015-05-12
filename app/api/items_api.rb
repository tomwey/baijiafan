# coding: utf-8

module API
  class ItemsAPI < Grape::API
    resource :items do
      
      # 发布菜
      params do
        requires :token, type: String, desc: "Token，必须"
        requires :title, type: String, desc: "标题，必须"
        requires :price, type: Integer, desc: "价格，整数，必须"
        # requires :quantity, type: Integer, desc: "数量，整数，必须"
        requires :expired_at, type: String, desc: "截止日期，字符串，必须，格式为：2000-01-01 12:00:00"
        requires :address, type: String, desc: "地址，字符串，必须"
        requires :latitude, type: String, desc: "纬度，字符串，必须"
        requires :longitude, type: String, desc: "经度，字符串，必须"
        requires :service_modes, type: String, desc: "服务方式，字符串，必须"
        optional :image, desc: "图片数据，二进制数据，可选"
        optional :note, type: String, desc: "温馨提示，可选，字符串"
      end
      
      post :create do
        user = authenticate!
        
        item = Item.new(
                        title: params[:title], 
                        price: params[:price], 
                        # quantity: params[:quantity],
                        expired_at: params[:expired_at], 
                        address: params[:address], 
                        service_modes: params[:service_modes]
                        )
        
        item.user_id = user.id
        
        item.coordinates = 'POINT(' + "#{params[:longitude]}" + ' ' + "#{params[:latitude]}" + ')'
        
        if params[:image]
          item.image = params[:image]
        end
        
        if params[:note]
          item.note = params[:note]
        end    
        
        if item.save
          item.user.increase_publish_count if item.user
          { code: 0, message: "ok" }
        else
          { code: 2001, message: item.errors.full_messages.join(',') }
        end           
        
      end # end 发布
      
      # 查看菜的详情
      get '/show/:id' do
        item = Item.find_by(id: params[:id])
        { code: 0, message: "ok", data: item || {} }
      end # end view
      
      # 根据当前位置获取菜单列表
      params do
        requires :latitude, type: String, desc: "纬度，数字符串，必须"
        requires :longitude, type: String, desc: "经度，数字符串，必须"
        optional :range, type: Integer, desc: "覆盖范围，以米为单位，默认为500米范围内，整数，可选"
        optional :page, type: Integer, desc: "当前页码"
        optional :size, type: Integer, desc: "分页大小"
      end
      get :list do
        range = params[:range] || "500"
        @items = Item.select("items.*, st_distance(coordinates, 'point(#{params[:longitude]} #{params[:latitude]})') as distance").where("st_dwithin(coordinates, 'point(#{params[:longitude]} #{params[:latitude]})', #{range})").where('expired_at > ?', Time.now).order("distance")
        
        page = params[:page] || "1"
        size = params[:size] || "30"
        
        page = page.to_i
        size = size.to_i
        
        @items = @items.paginate page: page, per_page: size
        
        { code: 0, message: "ok", data: @items }
      end # end list
      
      # 搜索位置或菜名
      params do
        requires :q, type: String, desc: "搜索位置或菜名"
      end
      get :search do
        items = Item.search(params[:q])
        { code: 0, message: "ok", data: items }
      end
      
    end # end resource
    
    resource :item do
      
      # 修改菜品信息
      params do
        requires :token, type: String, desc: "Token，必须"
        requires :item_id, type: Integer, desc: "菜品id"
        optional :title, type: String, desc: "标题，必须"
        optional :price, type: Integer, desc: "价格，整数，必须"
        # optional :quantity, type: Integer, desc: "数量，整数，必须"
        optional :expired_at, type: String, desc: "截止日期，字符串，必须，格式为：2000-01-01 12:00:00"
        optional :address, type: String, desc: "地址，字符串，必须"
        optional :latitude, type: String, desc: "纬度，字符串，必须"
        optional :longitude, type: String, desc: "经度，字符串，必须"
        optional :service_modes, type: String, desc: "服务方式，字符串，必须"
        optional :image, desc: "图片数据，二进制数据，可选"
        optional :note, type: String, desc: "温馨提示，可选，字符串"
      end
      
      post :update do
        user = authenticate!
        
        item = Item.where(id: params[:item_id], user_id: user.id).first
        
        if params[:title]
          item.title = params[:title]
        end
        
        if params[:price]
          item.price = params[:price]
        end
        
        # if params[:quantity]
        #   item.quantity = params[:quantity]
        # end
        
        if params[:expired_at]
          item.expired_at = params[:expired_at]
        end
        
        if params[:address]
          item.address = params[:address]
        end
        
        if params[:service_modes]
          item.service_modes = params[:service_modes]
        end
        
        if params[:longitude] and params[:latitude]
          item.coordinates = 'POINT(' + "#{params[:longitude]}" + ' ' + "#{params[:latitude]}" + ')'
        end
        
        if params[:image]
          item.image = params[:image]
        end
        
        if params[:note]
          item.note = params[:note]
        end    
        
        if item.save
          { code: 0, message: "ok" }
        else
          { code: 2002, message: item.errors.full_messages.join(',') }
        end
      end
      # 删除菜品信息
      params do
        requires :token, type: String, desc: "Token"
        requires :item_id, type: Integer, desc: "条目id" 
      end
      post :delete do
        user = authenticate!
        
        Item.destroy_all(user_id: user.id, id: params[:item_id])
        { code: 0, message: "ok" }
      end
      
      # 用户点赞操作2
      params do
        requires :item_id, type: Integer, desc: "条目id"
      end
      post '/:method' do
        # user = authenticate!
        return { code: -1, message: "不正确的点赞操作" } unless %W(like unlike).include?(params[:method])
        
        item = Item.find_by(id: params[:item_id])
        return { code: 1007, message: "该产品未找到" } if item.blank?
        
        user = item.user
        method = params[:method].to_sym
        if method == :like
          likes_count = user.likes_count + 1
        else
          likes_count = user.likes_count - 1
        end
        
        if user.update_attribute(:likes_count, likes_count)
          { code: 0, message: "ok" }
        else
          { code: 1008, message: "点赞操作失败" }
        end
        
        # if user.send(params[:method].to_sym, item)
        #   { code: 0, message: "ok" }
        # else
        #   { code: 1007, message: "点赞操作失败" }
        # end
      end # end 点赞2
      
    end # end item resource
  end
end