class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :title, :null => false
      t.integer :price
      t.integer :quantity
      t.datetime :expired_at, :null => false
      t.string :address
      t.point :coordinates, geographic: true
      t.string :note
      t.string :image
      t.string :service_modes, :null => false
      t.integer :user_id

      t.timestamps
    end
    add_index :items, :user_id
    add_index :items, :coordinates, using: :gist
  end
end
