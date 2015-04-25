class CreateLikeItems < ActiveRecord::Migration
  def change
    create_table :like_items do |t|
      t.integer :user_id
      t.integer :item_id
      t.integer :item_user_id

      t.timestamps
    end
    add_index :like_items, :user_id
    add_index :like_items, :item_id
    add_index :like_items, :item_user_id
  end
end
