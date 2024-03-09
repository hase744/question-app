ActiveAdmin.register Category do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :japanese_name, :description, :parent_category_id, :start_at, :end_at
  #controller do
  #  def action_methods
  #      if current_admin_user.roles.exists?(name: 'super_admin')
  #        super
  #      else
  #        super - ['destroy',"create","update"]
  #      end
  #  end
  #end
#
  #permit_params do
  #  permitted = [:name, :japanese_name, :start_at, :end_at, :parent_category_id, :description]
  #  permitted << :other if params[:action] == 'create' && admin_user_signed_in?
  #  permitted
  #end
#
  #hash = {} #親カテゴリーになり得るカテゴリーを{日本語名:id}の型のハッシュ
  #Category.where(parent_category:nil).each do |c|
  #  puts c.japanese_name
  #  hash[c.japanese_name] = c.id
  #end
#
  #form do |f|
  #  f.inputs do
  #    f.input :name
  #    f.input :japanese_name
  #    f.input :parent_category_id, as: :select, collection: hash
  #    f.input :start_at, as: :datetime_picker
  #    f.input :end_at, as: :datetime_picker
  #    f.input :description
  #  end
  #  f.actions
  #end
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :japanese_name, :description, :parent_category_id, :start_at, :end_at]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
