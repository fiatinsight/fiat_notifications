module FiatNotifications
  class SubscriptionsController < ActionController::Base

    def index
      @notifications = Notification.order("created_at DESC").all
    end

    def update
      @notification = Notification.find(params[:id])

      sibling_notifications = Notification.shown.where(notifiable_type: @notification.notifiable_type, notifiable_id: @notification.notifiable_id, recipient_id: params[:user_id])

      sibling_notifications.each do |notification|
        notification.update_attributes(hidden: 1)
      end

      respond_to do |format|
        if @notification.notifiable_type == "Message"
          if current_user_sim.internal
            format.html { redirect_to system_message_path(@notification.notifiable_id) }
          else
            format.html { redirect_to client_message_path(@notification.notifiable_id) }
          end
        end
      end
    end

    def mark_all_read
      @user = User.find(params[:user_id])
      @user.notifications.shown.each do |m|
        m.update_attributes(hidden: 1)
      end

      respond_to do |format|
        format.html { redirect_back(fallback_location: notifications_system_user_path(@user), notice: "Notifications marked as read." ) }
      end
    end

    def destroy
    end

    private

      # Never trust parameters from the scary internet, only allow the white list through.
      def notification_params
        params.require(:notification).permit(:user_id, :recipient_id, :action, :notifiable_type, :notifiable_id, :hidden)
      end

  end
end
