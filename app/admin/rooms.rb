ActiveAdmin.register Room do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :last_message, :last_message_at, :is_blocked
  #
  # or
  #
  # permit_params do
  #   permitted = [:last_message, :last_message_at, :is_blocked]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
  form do |f|
    f.inputs do
      f.input :last_message
      f.input :last_message_at, as: :datetime_picker
      f.input :is_blocked
    end
    f.actions
  end
end
