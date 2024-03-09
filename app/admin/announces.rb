ActiveAdmin.register Announce do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :title, :body, :disclosed_at, :file
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :body, :disclosed_at, :file]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
  permit_params do
    permitted = [:title, :body, :disclosed_at, :file]
    permitted << :other if params[:action] == 'create' && admin_user_signed_in?
    permitted
  end
  form do |f|
    f.inputs do
      f.input :title
      f.input :body
      f.input :disclosed_at, as: :datetime_picker
      f.input :admin_user_id, input_html: {value: current_admin_user.id}, as: :hidden
    end
    f.actions
  end
end
