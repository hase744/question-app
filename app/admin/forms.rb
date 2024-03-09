ActiveAdmin.register Form do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :japanese_name, :description, :start_at, :end_at
  #
  # or
  #

  controller do
    def action_methods
        if current_admin_user.roles.exists?(name: 'super_admin')
          super
        else
          super - ['destroy',"create","update"]
        end
    end
  end

  permit_params do
    permitted = [:name, :japanese_name, :start_at, :end_at, :description]
    permitted << :other if params[:action] == 'create' && admin_user_signed_in?
    permitted
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :japanese_name
      f.input :start_at, as: :datetime_picker
      f.input :end_at, as: :datetime_picker
      f.input :description
    end
    f.actions
  end
  # permit_params do
  #   permitted = [:name, :japanese_name, :description, :start_at, :end_at]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
