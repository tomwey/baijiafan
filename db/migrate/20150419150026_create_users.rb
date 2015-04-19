class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :mobile, :null => false
      t.string :private_token
      t.string :nickname
      t.string :avatar

      t.timestamps
    end
    add_index :users, :mobile, unique: true
    add_index :users, :private_token, unique: true
    add_index :users, :nickname, unique: true
  end
end
