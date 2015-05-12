class AddPublishCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :publish_count, :integer, default: 0
  end
end
