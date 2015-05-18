# coding: utf-8
require 'jpush'
class PushService
    
  def self.push(msg, receipts = [])
    client = JPush::JPushClient.new('a12ca4979667fc93e8f8f243', '309ddbeb6271f7eceab9def9');
      
    logger = Logger.new(STDOUT);
      
    tags = receipts.map { |to| "tel#{to}" }
    payload = JPush::PushPayload.build(
      platform: JPush::Platform.all,
      audience: JPush::Audience.build(
      tag: tags
      ),
      notification: JPush::Notification.build(alert: msg)
    )
      
    result = client.sendPush(payload);
    logger.debug("Got result " + result.toJSON)
  end
  
end