ActiveAdmin.register PotentialSeller do

  ## See permitted parameters documentation:
  ## https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  ##
  ## Uncomment all parameters which should be permitted for assignment
  ##
  #permit_params :name, :email, :url, :media_id, :user_id, :proposer_id, :inviter_id, :category_id, :total_followers, :description, :profile_description, :is_allowed, :is_checked, :is_regitered, :allowance_reason, :reward, :is_rewarded, :total_followers
  ##
  ## or
  ##
  ## permit_params do
  ##   permitted = [:name, :email, :url, :media_id, :user_id, :admin_user_id, :category_id, :total_followers, :description, :profile_description, :is_allowed, :is_regitered, :allowance_reason]
  ##   permitted << :other if params[:action] == 'create' && current_user.admin?
  ##   permitted
  ## end
  #controller do
  #  def create
  #    super do |format|
  #      #call_api(:create)
  #    end
  #  end
#
  #  #def action_methods
  #  #    if current_admin_user.roles.exists?(name: 'super_admin')
  #  #      super
  #  #    else
  #  #      super - ['destroy']
  #  #    end
  #  #end
  #end
#
  #@medias = Media.all
  #media_hash = {}
  #@medias.each do |media|
  #  media_hash[media.japanese_name] = media.id
  #end
  ##mediaの追加を反映させるため
  #puts "メディア"
  #puts @medias
#
  #@categories = Category.all
  #category_hash = {}
  #@categories.each do |category|
  #  category_hash[category.japanese_name] = category.id
  #end
#
  #form do |f|
  #  f.inputs do
  #    f.input :media_id, as: :select, collection: media_hash
  #    f.input :name
  #    f.input :url
  #    f.input :email
  #    f.input :category, as: :select, collection: category_hash
  #    f.input :profile_description
  #    f.input :total_followers
  #    f.input :inviter, as: :select, collection: {current_admin_user.name => current_admin_user.id}
  #    if current_admin_user.roles.exists?(name: 'super_admin')
  #        f.input :is_allowed, input_html: {checked: false}
  #        f.input :is_checked, input_html: {checked: false}
  #        f.input :allowance_reason
  #        f.input :reward, as: :select, collection: {"アマゾンギフトカード5000円" => "アマゾンギフトカード5000円"}
  #        f.input :is_rewarded, input_html: {checked: false}
  #    end
  #    f.input :user
  #    f.input :description
  #    #f.input :admin_user, as: :hidden, input_html: { value: current_admin_user.id }
  #  end
  #  f.actions
  #end
#
  #index do
  #  selectable_column
  #  column :id
  #  column :name
  #  column :url do |model|
  #    link_to(model.url, model.url)
  #  end
  #  column :total_followers
  #  column :inviter
  #  column :is_allowed
  #  column :is_rewarded
  #  column :is_checked
  #  actions
  #  #column :is_deleted
  #  #default_actions
  #end
#
  #controller do
  #  before_action :check_user, only: [:edit, :update, :destroy]
  #  after_action :change_proposer, only: [:create]
#
  #  def check_user
  #    unless current_admin_user == resource.proposer || current_admin_user.roles.exists?(name: 'super_admin')
  #      redirect_to admin_dashboard_path, alert: '他の人が作成した売り手候補編集する権限がありません。'
  #    end
  #  end
#
  #  def change_proposer
  #    resource.update(proposer: current_admin_user)
  #  end
  #end
end
