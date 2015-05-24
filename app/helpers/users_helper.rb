module UsersHelper
  def render_avatar_tag(user)
    return "" if user.blank?
    return "" if user.avatar.blank?
    
    image_tag user.avatar.url(:large)
  end
end