class CreateSendSmsLogs < ActiveRecord::Migration
  def change
    create_table :send_sms_logs do |t|
      t.string :mobile
      t.integer :send_total, default: 0
      t.datetime :first_sms_sent_at

      t.timestamps
    end
  end
end
