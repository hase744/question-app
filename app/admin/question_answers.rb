ActiveAdmin.register QuestionAnswer do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :sort, :question, :answer, :admin_user_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:sort, :question, :answer, :admin_user_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  form do |f|
    f.inputs do
      f.input :sort, as: :select, collection: {'売り手': "seller", '買い手': "buyer", "一般": "general"}
      f.input :question
      f.input :answer
      f.input :admin_user_id, input_html: {value: current_admin_user.id}, as: :hidden
    end
    f.actions
  end
end
