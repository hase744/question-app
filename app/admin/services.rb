ActiveAdmin.register Service do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :user_id, :title, :description, :price, :image, :request_id, :category, :unit_name, :price_per_unit, :stock_quantity, :is_published, :delivery_days, :request_form, :delivery_form, :total_views, :request_length
  #
  # or
  #
  # permit_params do
  #   permitted = [:user_id, :title, :description, :price, :image, :request_id, :category, :unit_name, :price_per_unit, :stock_quantity, :is_published, :delivery_days, :request_form, :delivery_form, :total_views, :request_length]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
