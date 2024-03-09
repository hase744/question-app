ActiveAdmin.register Relationship do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :user_id, :follower_id, :is_blocked
  #
  # or
  #
  # permit_params do
  #   permitted = [:user_id, :follower_id, :is_blocked]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  form do |f|
    f.inputs do
      f.input :user_id
      f.input :follower_id
      f.input :is_blocked, as: :boolean
    end
    f.actions
  end
end
