Rails.application.routes.draw do
  mount FiatNotifications::Engine => "/fiat_notifications"
end
