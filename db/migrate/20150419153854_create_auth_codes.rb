class CreateAuthCodes < ActiveRecord::Migration
  def change
    create_table :auth_codes do |t|
      t.string :code, :null => false, limit: 6
      t.string :mobile
      t.boolean :verified, default: true

      t.timestamps
    end
  end
end
