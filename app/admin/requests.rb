ActiveAdmin.register Request do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :user_id, :title, :description, :max_price, :mini_price, :category, :file, :suggestion_deadline, :delivery_form, :request_form, :youtube_id, :use_youtube, :total_views, :total_services, :service_id, :is_rejected, :reject_reason
  #
  # or
  #
  # permit_params do
  #   permitted = [:user_id, :title, :description, :max_price, :mini_price, :category, :file, :suggestion_deadline, :delivery_form, :request_form, :youtube_id, :use_youtube, :total_views, :total_services, :service_id, :is_rejected, :reject_reason]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
