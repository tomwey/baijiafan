class LikeItem < ActiveRecord::Base
  
  belongs_to :item
  
  after_create :increment_counter
  def increment_counter
    user = item.user
    user.update_attribute(:likes_count, user.likes_count + 1)
  end
  
  after_destroy :decrement_counter
  def decrement_counter
    user = item.user
    user.update_attribute(:likes_count, user.likes_count - 1) if user.likes_count > 0
  end
  
end
