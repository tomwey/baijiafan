# coding: utf-8

module API
  class AuthCodesAPI < Grape::API
    
    resource :auth_codes do
      
      # 获取验证码
      params do
        requires :mobile, type: String, desc: "手机号，必须"
      end
      post :fetch do
        # 手机号验证
        unless check_mobile(params[:mobile])
          return { code: 1001, message: "不正确的手机号" }
        end
        
        # 1分钟内多次提交检查
        sym = "#{params[:mobile]}".to_sym
        if session[sym] and ( Time.now.to_i - session[sym].to_i ) < 60
          return { code: 1002, message: "同一手机号1分钟内只能获取一次验证码，请稍后重试" }
        end
        
        #同一手机号一天最多获取5次验证码
        log = SendSmsLog.where('mobile = ?', params[:mobile]).first
        if log.blank?
          log = SendSmsLog.create!(mobile: params[:mobile], first_sms_sent_at: Time.now)
        else
          dt = Time.now.to_i - log.first_sms_sent_at.to_i
          
          if dt > 24 * 3600 # 超过24小时都要重置发送记录
            log.send_total = 0
            log.first_sms_sent_at = Time.now
            log.save!
          else 
            # 24小时以内
            if log.send_total.to_i == 5 # 达到5次
              return { code: 1003, message: "同一手机号24小时内只能获取5次验证码，请稍后再试" }
            end
          end
        end # end Send sms log check
        
        # 获取验证码并发送到手机
        code = AuthCode.where('mobile = ? and verified = ?', params[:mobile], true).first
        if code.blank?
          code = AuthCode.create!(mobile: params[:mobile])
        end
        
        # 发送验证码短信
        result = send_sms(params[:mobile], "您的验证码是#{code.code}【百家饭】", "获取验证码失败")
        if result['code'].to_i == -1
          # 发送失败，更新每分钟发送限制
          session.delete(sym)
        end
        if result['code'].to_i == 0
          # 发送成功，更新发送日志
          log.update_attribute(:send_total, log.send_total + 1)
        end
        result
        
      end # end 获取验证码
      
    end # end auth_codes resource
    
  end
end