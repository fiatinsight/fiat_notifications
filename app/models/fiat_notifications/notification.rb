module FiatNotifications
  class Notification < ApplicationRecord
    include Tokenable

    self.table_name = "fi_notifications"

    belongs_to :notifier, polymorphic: true
    belongs_to :creator, polymorphic: true
    belongs_to :observable, polymorphic: true

    validates :notifier, presence: true
    validates :creator, presence: true
    validates :observable, presence: true

    scope :shown, lambda { where(hidden: [0,nil]) }

    # after_commit -> { FiatNotifications::Notification::RelayJob.set(wait: 5.seconds).perform_later(self) }, on: :create
  end
end
