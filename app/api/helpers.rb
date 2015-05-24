# coding: utf-8
module API
  module APIHelpers
    
    # 获取服务器session
    def session
      env[Rack::Session::Abstract::ENV_SESSION_KEY]
    end
    
    # 最大分页大小
    def max_page_size
      100
    end
    
    # 默认分页大小
    def default_page_size
      15
    end
    
    # 分页大小
    def page_size
      size = params[:size].to_i
      size = size.zero? ? default_page_size : size
      [size, max_page_size].min
    end
    
    # 当前登录用户
    def current_user
      token = params[:token]
      @current_user ||= User.where(private_token: token).first
    end
    
    # 发送短信工具方法
    def send_sms(mobile, text, error_msg)
      RestClient.post('http://yunpian.com/v1/sms/send.json', "apikey=7612167dc8177b2f66095f7bf1bca49d&mobile=#{mobile}&text=#{text}") { |response, request, result, &block|
        resp = JSON.parse(response)
        if resp['code'] == 0
          { code: 0, message: "ok" }
        else
          { code: -1, message: resp['msg'] }
        end
      }
    end
    
    # 认证用户
    def authenticate!
      return { code: 401, message: "用户未登录" } unless current_user
      return { code: -10, message: "您的账号已经被禁用" } unless current_user.verified
      current_user
    end
    
    # 手机号验证
    def check_mobile(mobile)
      return false if mobile.length != 11
      mobile =~ /\A1[3|4|5|8][0-9]\d{4,8}\z/
    end
    
    # end helpers
  end
end