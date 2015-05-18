# coding: utf-8
require 'JPush'
module PushService
  app_key = 'a12ca4979667fc93e8f8f243'
  master_secret = '309ddbeb6271f7eceab9def9'
  
  def push(msg, to)
    client = JPush::JPushClient.new(app_key, master_secret);
  
    logger = Logger.new(STDOUT);
  
    payload = JPush::PushPayload.new(platform: JPush::Platform.all,
      audience: "tel#{to}",#JPush::Audience.all,
      notification: JPush::Notification.new(alert: msg)
    ).check
  
    result = client.sendPush(payload);
    logger.debug("Got result " + result)
  end
  
end