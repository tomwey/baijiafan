class CreateOrderStateLogs < ActiveRecord::Migration
  def change
    create_table :order_state_logs do |t|
      t.integer :order_id # 操作的订单
      t.integer :user_id  # 操作人
      t.integer :user_type, default: 1 # 操作人类型, 1表示管理员 2表示用户 3表示商家
      t.string :operation_name # 具体订单操作步骤名称

      t.timestamps
    end
    
    add_index :order_state_logs, :order_id
    add_index :order_state_logs, :user_id
  end
end
