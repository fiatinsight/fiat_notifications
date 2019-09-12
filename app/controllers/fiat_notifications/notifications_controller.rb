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
    #   @user = User.find(params[:user_id])
    #   @user.notifications.shown.each do |m|
    #     m.update_attributes(hidden: 1)
    #   end
    #
    #   respond_to do |format|
    #     format.html { redirect_back(fallback_location: notifications_system_user_path(@user), notice: "Notifications marked as read." ) }
    #   end
    # end

    private

      def notification_params
        params.require(:notification).permit(
          # :recipient_type, :recipient_id, :creator_type, :creator_id, :action, :notifiable_type, :notifiable_id,
          :hidden
        )
      end

  end
end
