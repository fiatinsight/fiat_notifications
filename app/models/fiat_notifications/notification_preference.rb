module FiatNotifications
  class NotificationPreference < ApplicationRecord
    include Tokenable

    self.table_name = "fi_notification_preferences"

    belongs_to :notifiable, polymorphic: true
    belongs_to :noticeable, polymorphic: true

    validates :notifiable, presence: true
    # validates :noticeable, presence: true, if: self.noticeable?

    enum preference_type: {
      general: 0,
      noticeable: 1
    }
  end
end
