class AddSlackToFiNotificationPreferences < ActiveRecord::Migration[5.2]
  def change
    add_column :fi_notification_preferences, :slack, :boolean
  end
end
