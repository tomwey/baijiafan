class ItemsController < ApplicationController
  def index
    @items = Item.where(visible: true).order('id DESC').paginate page: params[:page], per_page: 30
  end
  
  def show
    @item = Item.find(params[:id])
  end
  
  def destroy
    @item = Item.find(params[:id])
    @item.update_attribute(:visible, false)
    redirect_to items_url
  end
end