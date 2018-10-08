class CreateFiatNotificationsNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :fiat_notifications_notifications do |t|
      t.string :recipient_type
      t.integer :recipient_id
      t.string :creator_type
      t.integer :creator_id
      t.string :notifiable_type
      t.integer :notifiable_id
      t.string :action
      t.boolean :hidden
      t.string :token

      t.timestamps
    end
  end
end
