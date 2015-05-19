# coding: utf-8

require "rest_client"

module API
  class UsersAPI < Grape::API
    
    resource :account do
      
      # 用户登录
      params do
        requires :mobile, type: String, desc: "用户手机号，必须"
        requires :code, type: String, desc: "验证码，必须"
      end
      
      post :login do
        # 手机号验证
        unless check_mobile(params[:mobile])
          return { code: 1001, message: "不正确的手机号" }
        end
        
        # 检查验证码是否有效
        ac = AuthCode.where('mobile = ? and code = ? and verified = ?', params[:mobile], params[:code], true).first
        if ac.blank?
          return { code: 1004, message: "验证码无效" }
        end
        
        # 快捷登录
        user = User.find_by(mobile: params[:mobile])
        if user.present?
          ac.update_attribute('verified', false)
          return { code: 0, message: "ok", data: user }
        end
        
        user = User.new(mobile: params[:mobile])
        if user.save
          ac.update_attribute('verified', false)
          { code: 0, message: "ok", data: user }
        else
          { code: 1005, message: "用户登录失败" }
        end
        
      end # end account login
      
    end # end account resource
    
    resource :user do
      
      # 获取用户个人资料
      params do
        requires :token, type: String, desc: "Token, 必须"
      end
      
      get :me do
        user = authenticate!
        { code: 0, message: "ok", data: user }
      end # end get me
      
      
      # 更新头像
      params do
        requires :token, type: String, desc: "Token, 必须"
        requires :avatar, desc: "用户头像图片数据，可选"
      end
      
      post :update_avatar do
        user = authenticate!
        
        if params[:avatar]
          user.avatar = params[:avatar]
        end
        
        if user.save
          { code: 0, message: "ok", data: user }
        else
          { code: 1006, message: user.errors.full_messages.join(",") }
        end
        
      end # end update avatar
      
      # 修改用户资料
      params do
        requires :token, type: String, desc: "Token, 必须"
        optional :avatar, desc: "用户头像图片数据，可选"
        optional :nickname, type: String, desc: "用户昵称，可选"
        optional :signature, type: String, desc: "个性签名，可选"
      end
      
      post :update_profile do
        user = authenticate!
        
        if params[:avatar]
          user.avatar = params[:avatar]
        end
        
        if params[:nickname]
          user.nickname = params[:nickname]
        end
        
        if params[:signature]
          user.signature = params[:signature]
        end
        
        if user.save
          { code: 0, message: "ok", data: user }
        else
          { code: 1006, message: user.errors.full_messages.join(",") }
        end
      end # end update profile
      
      # 获取该用户下所发布的所有菜单
      params do
        requires :token, type: String, desc: "Token, 必须"
      end
      get :items do
        user = authenticate!
        
        items = Item.where(user_id: user.id, visible: true).order('id DESC')
        { code: 0, message: "ok", data: items }
      end # end items
      
      # 用户点赞操作
      # params do
      #   requires :token, type: String, desc: "Token, 必须"
      #   requires :like_type, type: String, desc: "需要点赞的对象类名，值为：User, Item(菜谱)中的一个"
      #   requires :like_id, type: String, desc: "需要点赞的对象id"
      # end
      # post '/:method' do
      #   user = authenticate!
      #   return { code: -1, message: "不正确的点赞操作" } unless %W(like unlike).include?(params[:method])
      #   
      #   likeable = params[:like_type].constantize.find_by(id: params[:like_id])
      #   if user.send(params[:method].to_sym, likeable)
      #     { code: 0, message: "ok", data: likeable }
      #   else
      #     { code: 1007, message: "点赞操作失败" }
      #   end
      #   
      # end # end 点赞操作
    end # end user resource
    
  end
end