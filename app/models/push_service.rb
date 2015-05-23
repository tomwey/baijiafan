# coding: utf-8
require 'jpush'
class PushService
    
  def self.push(msg, receipts = [], extras = {})
    client = JPush::JPushClient.new('a12ca4979667fc93e8f8f243', '309ddbeb6271f7eceab9def9');
      
    logger = Logger.new(STDOUT);
      
    tags = receipts.map { |to| "tel#{to}" }
    payload = JPush::PushPayload.build(
      platform: JPush::Platform.all,
      audience: JPush::Audience.build(
      tag: tags
      ),
      notification: JPush::Notification.build(
        ios: JPush::IOSNotification.build(
          alert: msg,
          sound: "default",
          extras: { "type" => extras[:type] }
        ),
        android: JPush::AndroidNotification.build(
          alert: msg,
          extras: { "type" => extras[:type] }
        )
      )
    )
    
    begin
      result = client.sendPush(payload);
      logger.debug("Got result " + result.toJSON)
    rescue JPush::ApiConnectionException
      logger.debug("没有找到用户")
    end
    
  end
  
end