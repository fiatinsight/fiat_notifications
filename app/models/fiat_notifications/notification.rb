module FiatNotifications
  class Notification < ApplicationRecord
    include Tokenable

    belongs_to :recipient, polymorphic: true
    belongs_to :creator, polymorphic: true
    belongs_to :notifiable, polymorphic: true

    validates :recipient, presence: true
    validates :creator, presence: true
    validates :notifiable, presence: true

    scope :shown, lambda { where(hidden: [0,nil]) }

    after_commit -> { FiatNotifications::Notification::RelayJob.set(wait: 5.seconds).perform_later(self) }, on: :create
  end
end
