ActiveAdmin.register Media do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
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
  permit_params :name, :japanese_name
  #
  # or
  #
  # permit_params do
  #   permitted = [:name]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
