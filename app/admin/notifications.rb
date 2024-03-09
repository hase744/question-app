ActiveAdmin.register Notification do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :user_id, :notifier_id, :description, :image, :is_notified, :controller, :action, :id_number, :parameter
  #
  # or
  #
  #permit_params do
  #  permitted = [:user_id, :notifier_id, :description, :image, :is_notified, :controller, :action, :id_number, :parameter]
  #  permitted << :other if params[:action] == 'create' && admin_user_signed_in?
  #  permitted
  #end
  
  form do |f|
    f.inputs "Notification" do
      f.input :user_id
      f.input :notifier_id
      f.input :description
      f.input :controller
      f.input :action
      f.input :id_number
      f.input :image, as: :file
      f.input :is_notified, as: :boolean
    end
    f.actions
  end
end
