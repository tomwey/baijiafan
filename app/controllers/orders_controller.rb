class OrdersController < ApplicationController
  def index
    @orders = Order.order('id DESC').paginate page: params[:page], per_page: 30
  end
end