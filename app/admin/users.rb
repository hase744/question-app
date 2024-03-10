ActiveAdmin.register User do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
   permit_params :email, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at, :confirmation_token, :confirmed_at, :confirmation_sent_at, :unconfirmed_email, :name, :image, :header_image, :suspended, :is_seller, :can_email_notification, :email_transaction_notification, :is_published, :is_suspended, :category, :track_record, :description, :youtube_id, :video, :stripe_account_id, :stripe_card_id, :stripe_customer_id, :stripe_connected_id, :phone_number, :phone_confirmation_token, :phone_confirmation_sent_at, :phone_confirmed_at, :last_login, :star_rating, :total_reviews, :total_sales, :mini_price, :state
  #
  # or
  #
  # permit_params do
  #   permitted = [:email, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at, :confirmation_token, :confirmed_at, :confirmation_sent_at, :unconfirmed_email, :name, :image, :header_image, :suspended, :is_seller, :can_email_notification, :email_transaction_notification, :is_published, :category, :track_record, :description, :youtube_id, :video, :stripe_account_id, :stripe_card_id, :stripe_customer_id, :stripe_connected_id, :phone_number, :phone_confirmation_token, :phone_confirmation_sent_at, :phone_confirmed_at, :last_login, :star_rating, :total_reviews, :total_sales, :mini_price]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  index do
    selectable_column
    column :id
    column :name do |model|
      link_to(model.name, "/user/accounts/#{model.id}")
    end
    column :state
    column :is_deleted
    column :is_suspended
    column :is_seller

    actions
    #column :is_deleted
    #default_actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :state
    end
    f.actions
  end
end
