# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      t.integer :state, null: false, index:true
      t.string :name
      t.string :image
      t.string :image_tmp
      t.string :header_image
      t.string :header_image_tmp
      t.boolean :image_processing, null: false, default: false
      t.boolean :header_image_processing, null: false, default: false
      t.boolean :is_seller, default: false, index:true
      t.boolean :is_published, default: true, index:true
      
      t.text :admin_description
      #t.string :categories
      t.text :track_record
      t.text :description
      t.string :youtube_id
      t.string :video

      t.boolean :can_email_advert, default: false
      t.boolean :can_email_transaction, default: false
      t.boolean :can_email_message, default: false
      t.boolean :can_email_notification, default: false
      t.boolean :can_receive_message, default: true

      t.string :stripe_account_id
      t.string :stripe_card_id
      t.string :stripe_customer_id
      t.string :stripe_connected_id

      t.integer :country_id
      t.string :phone_number
      t.string :phone_confirmation_token
      t.datetime :phone_confirmation_sent_at
      t.datetime :phone_confirmed_at
      t.integer :total_phone_confirmation_attempts, default: 0
      t.datetime :phone_confirmation_enabled_at

      t.datetime :last_login_at, index:true

      t.integer :total_reviews, default: 0, index:true
      t.integer :total_followers, default: 0, index:true
      t.integer :total_sales_numbers, default: 0, index:true
      t.integer :total_sales_amount, default: 0, index:true
      t.integer :total_sales_number, default: 0, index:true
      t.integer :total_notifications, default: 0, index:true
      t.integer :total_points, default: 0, index:true

      t.float :average_star_rating, default: nil, index:true
      t.float :rejection_rate, default: nil, index:true
      t.float :cancellation_rate, default: nil, index:true

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end
end