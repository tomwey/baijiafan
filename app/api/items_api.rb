# coding: utf-8

module API
  class ItemsAPI < Grape::API
    resource :items do
      
      # 发布菜
      params do
        requires :token, type: String, desc: "Token，必须"
        requires :title, type: String, desc: "标题，必须"
        requires :price, type: Integer, desc: "价格，整数，必须"
        requires :quantity, type: Integer, desc: "数量，整数，必须"
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
                        quantity: params[:quantity],
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
        optional :range, type: Integer, desc: "覆盖范围，以公里为单位，默认为2公里范围内，整数，可选"
      end
      get :list do
        range = params[:range] || "2"
        items = Item.select("items.*, st_distance(coordinates, 'point(#{params[:longitude]} #{params[:latitude]})') as distance").where("st_dwithin(coordinates, 'point(#{params[:longitude]} #{params[:latitude]})', #{range.to_i * 1000})").order("distance")
        { code: 0, message: "ok", data: items }
      end # end list
      
    end # end resource
    
  end
end