class AddViewedToFiNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :fi_notifications, :viewed, :boolean
  end
end
