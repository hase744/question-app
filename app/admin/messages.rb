ActiveAdmin.register Message do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :room_id, :sender_id, :receiver_id, :body, :file, :is_read
  #
  # or
  #
  # permit_params do
  #   permitted = [:room_id, :sender_id, :receiver_id, :body, :file, :is_read]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
  form do |f|
    f.inputs do
      f.input :room_id
      f.input :sender_id
      f.input :receiver_id
      f.input :body
      f.input :file, as: :file
      f.input :is_read
    f.actions
    end
  end
end
