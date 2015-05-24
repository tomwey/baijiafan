class OrderStateLogsController < ApplicationController
  def index
    @logs = OrderStateLog.order('id DESC').paginate page: params[:page], per_page: 30
  end
end