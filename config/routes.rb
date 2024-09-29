Rails.application.routes.draw do
  namespace :user do
    get 'videos/show'
  end
  namespace :user do
    get 'alerts/index'
  end
  namespace :user do
    get 'notices/index'
  end
  namespace :user do
    resource :inquiries, only: [:new, :create]
    get 'inquiries/new'
    get 'inquiries/create'
  end
  get 'new/create'
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root :to => 'abouts#index'
  resources :abouts, only:  [:index]
  get "abouts/question"
  get "abouts/inquiry"
  get "abouts/detail"
  get "abouts/how"
  get "abouts/announce"
  get "abouts/how_to_sell", as: "abouts_how_to_sell"
  get "abouts/how_to_purchase", as: "abouts_how_to_purchase"
  get "abouts/how_to_deliver", as: "abouts_how_to_deliver"
  get "abouts/how_to_reject", as: "abouts_how_to_reject"
  get "abouts/how_to_cancel", as: "abouts_how_to_cancel"
  get "abouts/how_to_request", as: "abouts_how_to_request"
  get "abouts/how_to_charge", as: "abouts_how_to_charge"
  get "abouts/service_guide", as: "abouts_service_guide"
  get "abouts/term_of_service", as: "abouts_term_of_service"
  get "abouts/privacy_policy", as: "abouts_privacy_policy"
  get "abouts/tokushou", as: "abouts_tokushou"
  #get "abouts/how_to_sell", as: "abouts_how_to_sell"
namespace :user do
  
    get "requests/:id/preview", to: "requests#preview", as: "request_preview"
    put "requests/:id/stop_accepting", to: "requests#stop_accepting", as: "request_stop_accepting"
    post "requests/publish/:id", to: "requests#publish", as: "request_publish"
    post "requests/purchase/:id", to: "requests#purchase", as: "request_purchase"
    get "requests/mine", to: "requests#mine", as:"request_mine"
    post "transactions/like/:id", to:"transactions#like", as: "transactions_like"
    put "transactions/deliver/:id",  to:"transactions#deliver", as:"deliver_transaction"
    post "transactions/pre_purchase_inquire/:id",  to:"transactions#pre_purchase_inquire", as:"inquire_transaction"
    get "transactions/pre_purchase_inquiry",  to:"transactions#pre_purchase_inquiry", as:"pre_purchase_inquiry"
    get "notifications/notification_bar", to: "notifications#notification_bar"
    get "notifications/notification_cells", to: "notifications#notification_cells"
    get "notifications/get_data"
    patch "notifications/all_notified", to: "notifications#all_notified", as:"all_notified"


    root to: 'transactions#index'
    get "configs/personal_config"
    get "configs/personal_config"
    get "configs/withdrawal", to:"configs#withdrawal", as:"configs_withdrawal"
    get 'connects/certify_phone', to: "connects#certify_phone", as:"get_certify_phone"
    get 'connects/alert', to: "connects#alert"
    get 'connects/send_token', to: "connects#send_token"
    post 'connects/certify_phone', to: "connects#certify_phone", as:"post_certify_phone"
    get 'connects/form', to: "connects#form"
    put 'connects/confirm', to: "connects#confirm"
    get 'connects/reward', to: 'connects#reward', as:"connect_reward"
    get 'connects/payments', to: 'connects#payments', as:"connect_payments"
    post 'connects/credit', to: 'connects#credit', as:"connect_credit"
    get 'images/answer'
    get 'accounts/likes/:id', to:"accounts#likes", as:"account_likes"
    get 'accounts/reviews/:id', to:"accounts#reviews", as:"account_reviews"
    get 'accounts/requests/:id', to:"accounts#requests", as:"account_requests"
    get 'accounts/users/:id', to:"accounts#users", as:"account_users"
    get 'accounts/registered_users/:id', to:"accounts#registered_users", as:"registered_users"
    get 'accounts/purchases/:id', to:"accounts#purchases", as:"account_purchases"
    get 'accounts/sales/:id', to:"accounts#sales", as:"account_sales"
    get 'accounts/services/:id', to:"accounts#services", as:"account_services"
    get 'accounts/posts/:id', to:"accounts#posts", as:"account_posts"
    get 'accounts/revive', to:"accounts#revive", as: "revive_account"
    get 'accounts/renew', to:"accounts#renew", as: "renew_account"
    post 'accounts/reregister', to:"accounts#reregister", as: "reregister_account"
    delete 'cards/delete', to:"cards#delete", as:"cards_delete"
    

    get "transaction_messages/cells", to: "transaction_messages#cells", as:"transaction_messages_cells"
    get "transaction_messages/reset_cells", to: "transaction_messages#reset_cells", as:"transaction_messages_reset_cells"
    patch 'transactions/create_description_image/:id', to:'transactions#create_description_image', as:'create_description_image'
    get "transctions/messages/:id", to:'transactions#messages', as:'transaction_message_room'

    get "services/requests/:id", to: "services#requests", as:"service_requests"
    get "services/reviews/:id", to: "services#reviews", as:"service_reviews"
    get "services/transactions/:id", to: "services#transactions", as:"service_transactions"
    put "services/:id/suggest", to: "services#suggest", as:"service_suggest"
    get "services/mine", to: "services#mine", as:"service_mine"
    put "orders/:id", to: "orders#cancel", as:"cancel_order"
    patch "orders/:id", to: "orders#reject", as:"reject_order"
    
    
    resource :connects, only: [:index, :new, :show, :create, :edit, :update, :destroy]
    resource :cards, only: [:index, :new, :show, :create, :edit, :update, :destroy]
    resource :configs, only: [ :index, :show, :edit, :update, :destroy]
    resource :alerts, only: [:show]
    resource :accounts, only: [:edit, :update]
    resources :reviews, only: [:update]
    resources :orders, only:[:index, :show, :edit]
    resources :transaction_messages, only: [:create, :show]
    resources :posts, only: [ :index, :show, :new, :edit, :create, :destroy, :update]
    resources :relationships, only: [ :update]
    resources :services, only: [ :index, :show, :new, :edit, :create, :destroy, :update]
    resources :requests, only: [ :index, :show, :new, :edit, :create, :update, :destroy]
    resources :accounts, only: [ :index, :show]
    resources :transactions, only: [ :index, :show, :edit, :update]
    resources :notifications, only: [ :index, :show]
    resources :histories, only: [ :index ,:new, :create]
    resources :request_supplements, only: [:create, :new]
    resource :payments, only: [:show, :create]
    resource :videos, only: [:show]
    resource :homes, only: [:show]
    resource :images, only: [:show]
    resource :service_likes, only: [:create, :destroy, :show]
    resource :request_likes, only: [:create, :destroy, :show]
    resource :transaction_likes, only: [:create, :destroy, :show]
    resources :requests do
      member do
        delete :remove_file, to: 'requests#remove_file'
      end
    end
    resources :transactions do
      member do
        delete :remove_file, to: 'transactions#remove_file'
      end
    end
  end

  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '*a', :to => 'application#rescue404'
end
