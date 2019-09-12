module FiatNotifications
  class NotificationsController < ActionController::Base

    def update
      @notification = Notification.find(params[:id])

      if params[:hide]
        @notification.update(hidden: 1)
      end

      respond_to do |format|
        # format.html
        format.js
      end
    end

    # def mark_all_read
    # end

    private

      def notification_params
        params.require(:notification).permit(:hidden)
      end

  end
end
