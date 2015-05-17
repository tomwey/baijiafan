class AddActionToOrderStateLogs < ActiveRecord::Migration
  def change
    add_column :order_state_logs, :action, :string
  end
end
