class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :user_id
      t.integer :item_id
      t.string  :state
      t.string :service_modes
      t.string :address
      t.integer :quantity, default: 1
      t.string :note
      t.integer :fee, default: 0

      t.timestamps
    end
    
    add_index :orders, :user_id
    add_index :orders, :item_id
  end
end
