ActiveAdmin.register Contact do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :room_id, :user_id, :destination_id, :new_message, :is_blocked, :is_valid
  #
  # or
  #
  # permit_params do
  #   permitted = [:room_id, :user_id, :destination_id, :new_message, :is_blocked, :is_valid]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
