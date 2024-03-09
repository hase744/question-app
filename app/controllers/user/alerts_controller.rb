class User::AlertsController < ApplicationController
  layout 'alert'
  def show
    #@message = UserStatus.where("user_id = ? && start_at <= ?",current_user.id, DateTime.now).order(start_at: "ASC").last.description
    @message = "アカウントが凍結されました。"
  end
end
