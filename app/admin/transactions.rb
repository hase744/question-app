ActiveAdmin.register Transaction do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :seller_id, :buyer_id, :service_id, :request_id, :price, :margin, :stripe_payment_id, :title, :description, :category, :use_youtube, :youtube_id, :file, :total_views, :total_likes, :is_transacted, :is_transacted_at, :is_canceled, :is_canceled_at, :star_rating, :review_description, :reviewed_at, :review_reply
  #
  # or
  #
  # permit_params do
  #   permitted = [:seller_id, :buyer_id, :service_id, :request_id, :price, :margin, :stripe_payment_id, :title, :description, :category, :use_youtube, :youtube_id, :file, :total_views, :total_likes, :is_transacted, :is_transacted_at, :is_canceled, :is_canceled_at, :star_rating, :review_description, :reviewed_at, :review_reply]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
