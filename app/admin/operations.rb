ActiveAdmin.register Operation do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  #permit_params :state, :start_at, :comment, :admin_user_id
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
    permitted = [:state_id, :start_at, :comment, :admin_user_id]
    permitted << :other if params[:action] == 'create' && admin_user_signed_in?
    permitted
  end
  form do |f|
    f.inputs do
      f.input :state_id, as: :select, collection: {
        '稼働': State.find_by(name:"running").id, 
        '停止': State.find_by(name:"suspended").id, 
        'ユーザー登録のみ': State.find_by(name:"register").id, 
        "閲覧のみ": State.find_by(name:"browse").id
      }
      f.input :start_at, as: :datetime_picker
      f.input :comment
      f.input :admin_user_id, input_html: {value: current_admin_user.id}, as: :hidden
    end
    f.actions
  end
end
