ActiveAdmin.register AdminUser do
  permit_params :email, :name, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  controller do
    before_action :check_user, only: [:edit, :update, :destroy]

    def check_user
      unless current_admin_user == resource || current_admin_user.roles.exists?(name: 'super_admin')
        redirect_to admin_dashboard_path, alert: '他の管理者アカウントを編集する権限がありません。'
      end
    end

    def update
      if params[:admin_user][:password].blank?
        params[:admin_user].delete("password")
        params[:admin_user].delete("password_confirmation")
      end
      super
    end
    
    #def action_methods
    #  if current_admin_user.roles.exists?(name: 'super_admin')
    #    super
    #  else
    #    super - ['destroy',"create","edit","update"]
    #  end
    #end
  end

  def display_name
    self.email
  end
end
