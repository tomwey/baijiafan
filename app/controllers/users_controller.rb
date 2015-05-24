class UsersController < ApplicationController
  def index
    @users = User.order('id DESC').paginate page: params[:page], per_page: 30
  end
  
  def block
    @user = User.find(params[:id])
    @user.verified = false
    
    if @user.save
      render text: "1"
    else
      render text: "-1"
    end
  end
  
  def unblock
    @user = User.find(params[:id])
    @user.verified = true
    
    if @user.save
      render text: "1"
    else
      render text: "-1"
    end
  end
  
end