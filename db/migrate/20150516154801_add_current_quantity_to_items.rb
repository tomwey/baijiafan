class AddCurrentQuantityToItems < ActiveRecord::Migration
  def change
    add_column :items, :current_quantity, :integer
  end
end
