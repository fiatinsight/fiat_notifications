class CreateFiNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :fi_notifications do |t|
      t.string :notifier_type
      t.integer :notifier_id
      t.string :creator_type
      t.integer :creator_id
      t.string :observable_type
      t.integer :observable_id
      t.string :action
      t.boolean :hidden
      t.string :token

      t.timestamps
    end
  end
end
