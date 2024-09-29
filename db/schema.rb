# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_09_21_234226) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_adress"
    t.string "method"
    t.string "controller"
    t.string "action"
    t.integer "id_number"
    t.text "parameter"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_access_logs_on_user_id"
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_user_roles", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "admin_user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["admin_user_id"], name: "index_admin_user_roles_on_admin_user_id"
    t.index ["role_id"], name: "index_admin_user_roles_on_role_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "announces", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "disclosed_at"
    t.string "file"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "delivery_items", force: :cascade do |t|
    t.bigint "transaction_id", null: false
    t.string "file"
    t.string "file_tmp"
    t.boolean "file_processing", default: false, null: false
    t.string "youtube_id"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["transaction_id"], name: "index_delivery_items_on_transaction_id"
  end

  create_table "error_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "error_class"
    t.text "error_message"
    t.text "error_backtrace"
    t.string "request_method"
    t.string "request_controller"
    t.string "request_action"
    t.integer "request_id_number"
    t.text "request_parameter"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_error_logs_on_user_id"
  end

  create_table "inquiries", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.string "email"
    t.text "body"
    t.text "answer"
    t.bigint "admin_user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["admin_user_id"], name: "index_inquiries_on_admin_user_id"
    t.index ["user_id"], name: "index_inquiries_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "notifier_id"
    t.text "title"
    t.text "description"
    t.string "image"
    t.boolean "is_notified", default: false
    t.string "controller"
    t.string "action"
    t.integer "id_number"
    t.string "parameter"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["action"], name: "index_notifications_on_action"
    t.index ["controller"], name: "index_notifications_on_controller"
    t.index ["id_number"], name: "index_notifications_on_id_number"
    t.index ["is_notified"], name: "index_notifications_on_is_notified"
    t.index ["notifier_id"], name: "index_notifications_on_notifier_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "operations", force: :cascade do |t|
    t.integer "state"
    t.datetime "start_at", null: false
    t.text "comment"
    t.bigint "admin_user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["admin_user_id"], name: "index_operations_on_admin_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "stripe_payment_id"
    t.string "stripe_card_id"
    t.string "stripe_customer_id"
    t.boolean "is_succeeded", default: false
    t.boolean "is_refunded", default: false
    t.string "status"
    t.integer "price"
    t.integer "point"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "body"
    t.string "file"
    t.string "file_tmp"
    t.boolean "file_processing", default: false, null: false
    t.integer "total_views", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["total_views"], name: "index_posts_on_total_views"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "question_answers", force: :cascade do |t|
    t.string "sort"
    t.text "question"
    t.text "answer"
    t.bigint "admin_user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["admin_user_id"], name: "index_question_answers_on_admin_user_id"
  end

  create_table "relationships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "target_user_id"
    t.integer "type_name", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["target_user_id"], name: "index_relationships_on_target_user_id"
    t.index ["user_id"], name: "index_relationships_on_user_id"
  end

  create_table "request_categories", force: :cascade do |t|
    t.integer "category_name", null: false
    t.bigint "request_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_name"], name: "index_request_categories_on_category_name"
    t.index ["request_id"], name: "index_request_categories_on_request_id"
  end

  create_table "request_items", force: :cascade do |t|
    t.bigint "request_id", null: false
    t.string "file"
    t.string "file_tmp"
    t.boolean "file_processing", default: false, null: false
    t.boolean "is_text_image", default: false, null: false
    t.string "youtube_id"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["request_id"], name: "index_request_items_on_request_id"
  end

  create_table "request_likes", force: :cascade do |t|
    t.bigint "request_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["request_id"], name: "index_request_likes_on_request_id"
    t.index ["user_id"], name: "index_request_likes_on_user_id"
  end

  create_table "request_supplements", force: :cascade do |t|
    t.bigint "request_id", null: false
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["request_id"], name: "index_request_supplements_on_request_id"
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "request_form_name", null: false
    t.integer "delivery_form_name", null: false
    t.string "title"
    t.text "description"
    t.string "image"
    t.integer "max_price"
    t.integer "mini_price"
    t.boolean "is_inclusive", default: true, null: false
    t.boolean "is_accepting", default: true, null: false
    t.integer "suggestion_acceptable_duration"
    t.datetime "suggestion_deadline"
    t.integer "description_total_characters", default: 0
    t.integer "file_duration"
    t.integer "total_files", default: 0
    t.integer "total_views", default: 0
    t.integer "total_services", default: 0
    t.integer "transaction_message_days"
    t.bigint "transaction_id"
    t.boolean "is_published", default: false
    t.datetime "published_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["delivery_form_name"], name: "index_requests_on_delivery_form_name"
    t.index ["description_total_characters"], name: "index_requests_on_description_total_characters"
    t.index ["file_duration"], name: "index_requests_on_file_duration"
    t.index ["is_accepting"], name: "index_requests_on_is_accepting"
    t.index ["is_inclusive"], name: "index_requests_on_is_inclusive"
    t.index ["is_published"], name: "index_requests_on_is_published"
    t.index ["max_price"], name: "index_requests_on_max_price"
    t.index ["mini_price"], name: "index_requests_on_mini_price"
    t.index ["published_at"], name: "index_requests_on_published_at"
    t.index ["request_form_name"], name: "index_requests_on_request_form_name"
    t.index ["suggestion_acceptable_duration"], name: "index_requests_on_suggestion_acceptable_duration"
    t.index ["suggestion_deadline"], name: "index_requests_on_suggestion_deadline"
    t.index ["title"], name: "index_requests_on_title"
    t.index ["total_files"], name: "index_requests_on_total_files"
    t.index ["total_services"], name: "index_requests_on_total_services"
    t.index ["total_views"], name: "index_requests_on_total_views"
    t.index ["transaction_id"], name: "index_requests_on_transaction_id"
    t.index ["transaction_message_days"], name: "index_requests_on_transaction_message_days"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "japanese_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "service_categories", force: :cascade do |t|
    t.integer "category_name", null: false
    t.bigint "service_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_name"], name: "index_service_categories_on_category_name"
    t.index ["service_id"], name: "index_service_categories_on_service_id"
  end

  create_table "service_files", force: :cascade do |t|
    t.bigint "service_id", null: false
    t.string "file"
    t.string "thumbnail"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id"], name: "index_service_files_on_service_id"
  end

  create_table "service_items", force: :cascade do |t|
    t.bigint "service_id", null: false
    t.string "file"
    t.string "file_tmp"
    t.boolean "file_processing", default: false, null: false
    t.string "youtube_id"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id"], name: "index_service_items_on_service_id"
  end

  create_table "service_likes", force: :cascade do |t|
    t.bigint "service_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id"], name: "index_service_likes_on_service_id"
    t.index ["user_id"], name: "index_service_likes_on_user_id"
  end

  create_table "services", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "request_form_name"
    t.integer "delivery_form_name"
    t.bigint "request_id"
    t.string "title"
    t.text "description"
    t.integer "price"
    t.boolean "is_published", default: true
    t.boolean "is_for_sale", default: true
    t.integer "delivery_days"
    t.integer "request_max_characters"
    t.integer "request_max_duration"
    t.integer "request_max_files"
    t.datetime "renewed_at"
    t.boolean "transaction_message_enabled", default: true
    t.boolean "allow_pre_purchase_inquiry", default: true
    t.integer "total_views", default: 0
    t.integer "total_sales_numbers", default: 0
    t.integer "total_sales_amount", default: 0
    t.integer "total_reviews", default: 0
    t.float "average_star_rating"
    t.float "rejection_rate"
    t.float "cancellation_rate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["average_star_rating"], name: "index_services_on_average_star_rating"
    t.index ["cancellation_rate"], name: "index_services_on_cancellation_rate"
    t.index ["delivery_days"], name: "index_services_on_delivery_days"
    t.index ["delivery_form_name"], name: "index_services_on_delivery_form_name"
    t.index ["is_for_sale"], name: "index_services_on_is_for_sale"
    t.index ["is_published"], name: "index_services_on_is_published"
    t.index ["rejection_rate"], name: "index_services_on_rejection_rate"
    t.index ["request_form_name"], name: "index_services_on_request_form_name"
    t.index ["request_id"], name: "index_services_on_request_id"
    t.index ["request_max_characters"], name: "index_services_on_request_max_characters"
    t.index ["request_max_duration"], name: "index_services_on_request_max_duration"
    t.index ["request_max_files"], name: "index_services_on_request_max_files"
    t.index ["title"], name: "index_services_on_title"
    t.index ["total_reviews"], name: "index_services_on_total_reviews"
    t.index ["total_sales_amount"], name: "index_services_on_total_sales_amount"
    t.index ["total_sales_numbers"], name: "index_services_on_total_sales_numbers"
    t.index ["total_views"], name: "index_services_on_total_views"
    t.index ["user_id"], name: "index_services_on_user_id"
  end

  create_table "transaction_categories", force: :cascade do |t|
    t.integer "category_name", null: false
    t.bigint "transaction_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_name"], name: "index_transaction_categories_on_category_name"
    t.index ["transaction_id"], name: "index_transaction_categories_on_transaction_id"
  end

  create_table "transaction_likes", force: :cascade do |t|
    t.bigint "transaction_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["transaction_id"], name: "index_transaction_likes_on_transaction_id"
    t.index ["user_id"], name: "index_transaction_likes_on_user_id"
  end

  create_table "transaction_messages", force: :cascade do |t|
    t.bigint "transaction_id", null: false
    t.bigint "sender_id", null: false
    t.bigint "receiver_id", null: false
    t.string "file"
    t.string "file_tmp"
    t.boolean "file_processing", default: false, null: false
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["receiver_id"], name: "index_transaction_messages_on_receiver_id"
    t.index ["sender_id"], name: "index_transaction_messages_on_sender_id"
    t.index ["transaction_id"], name: "index_transaction_messages_on_transaction_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "seller_id"
    t.bigint "buyer_id"
    t.bigint "service_id", null: false
    t.bigint "request_id", null: false
    t.integer "request_form_name", null: false
    t.integer "delivery_form_name", null: false
    t.datetime "delivery_time"
    t.datetime "service_checked_at"
    t.integer "price"
    t.text "service_title"
    t.text "service_descriprion"
    t.boolean "service_allow_pre_purchase_inquiry"
    t.integer "profit"
    t.integer "margin"
    t.string "stripe_payment_id"
    t.string "stripe_transfer_id"
    t.string "title"
    t.text "description"
    t.datetime "pre_purchase_inquired_at"
    t.integer "total_views", default: 0
    t.boolean "is_transacted", default: false
    t.datetime "transacted_at"
    t.boolean "is_published", default: false
    t.datetime "published_at"
    t.boolean "is_violating", default: false
    t.boolean "is_contracted", default: false
    t.datetime "contracted_at"
    t.boolean "is_suggestion", default: false
    t.datetime "suggested_at"
    t.boolean "is_rejected", default: false
    t.datetime "rejected_at"
    t.text "reject_reason"
    t.boolean "is_canceled", default: false
    t.datetime "canceled_at"
    t.boolean "transaction_message_enabled", default: false
    t.integer "star_rating"
    t.text "review_description"
    t.datetime "reviewed_at"
    t.text "review_reply"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["buyer_id"], name: "index_transactions_on_buyer_id"
    t.index ["canceled_at"], name: "index_transactions_on_canceled_at"
    t.index ["contracted_at"], name: "index_transactions_on_contracted_at"
    t.index ["delivery_form_name"], name: "index_transactions_on_delivery_form_name"
    t.index ["is_contracted"], name: "index_transactions_on_is_contracted"
    t.index ["is_published"], name: "index_transactions_on_is_published"
    t.index ["is_rejected"], name: "index_transactions_on_is_rejected"
    t.index ["is_suggestion"], name: "index_transactions_on_is_suggestion"
    t.index ["is_transacted"], name: "index_transactions_on_is_transacted"
    t.index ["is_violating"], name: "index_transactions_on_is_violating"
    t.index ["price"], name: "index_transactions_on_price"
    t.index ["profit"], name: "index_transactions_on_profit"
    t.index ["published_at"], name: "index_transactions_on_published_at"
    t.index ["rejected_at"], name: "index_transactions_on_rejected_at"
    t.index ["request_form_name"], name: "index_transactions_on_request_form_name"
    t.index ["request_id"], name: "index_transactions_on_request_id"
    t.index ["seller_id"], name: "index_transactions_on_seller_id"
    t.index ["service_id"], name: "index_transactions_on_service_id"
    t.index ["star_rating"], name: "index_transactions_on_star_rating"
    t.index ["suggested_at"], name: "index_transactions_on_suggested_at"
    t.index ["title"], name: "index_transactions_on_title"
    t.index ["total_views"], name: "index_transactions_on_total_views"
    t.index ["transacted_at"], name: "index_transactions_on_transacted_at"
  end

  create_table "user_categories", force: :cascade do |t|
    t.integer "category_name", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_name"], name: "index_user_categories_on_category_name"
    t.index ["user_id"], name: "index_user_categories_on_user_id"
  end

  create_table "user_state_histories", force: :cascade do |t|
    t.integer "state"
    t.bigint "user_id", null: false
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_state_histories_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "state", null: false
    t.string "name"
    t.string "image"
    t.string "image_tmp"
    t.string "header_image"
    t.string "header_image_tmp"
    t.boolean "image_processing", default: false, null: false
    t.boolean "header_image_processing", default: false, null: false
    t.boolean "is_seller", default: false
    t.boolean "is_published", default: true
    t.text "admin_description"
    t.text "track_record"
    t.text "description"
    t.string "youtube_id"
    t.string "video"
    t.boolean "can_email_advert", default: false
    t.boolean "can_email_transaction", default: false
    t.boolean "can_email_notification", default: false
    t.string "stripe_account_id"
    t.string "stripe_card_id"
    t.string "stripe_customer_id"
    t.string "stripe_connected_id"
    t.integer "country_id"
    t.string "phone_number"
    t.string "phone_confirmation_token"
    t.datetime "phone_confirmation_sent_at"
    t.datetime "phone_confirmed_at"
    t.integer "total_phone_confirmation_attempts", default: 0
    t.datetime "phone_confirmation_enabled_at"
    t.datetime "last_login_at"
    t.integer "total_reviews", default: 0
    t.integer "total_target_users", default: 0
    t.integer "total_sales_numbers", default: 0
    t.integer "total_sales_amount", default: 0
    t.integer "total_sales_number", default: 0
    t.integer "total_notifications", default: 0
    t.integer "total_points", default: 0
    t.float "average_star_rating"
    t.float "rejection_rate"
    t.float "cancellation_rate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["average_star_rating"], name: "index_users_on_average_star_rating"
    t.index ["cancellation_rate"], name: "index_users_on_cancellation_rate"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["is_published"], name: "index_users_on_is_published"
    t.index ["is_seller"], name: "index_users_on_is_seller"
    t.index ["last_login_at"], name: "index_users_on_last_login_at"
    t.index ["rejection_rate"], name: "index_users_on_rejection_rate"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["state"], name: "index_users_on_state"
    t.index ["total_notifications"], name: "index_users_on_total_notifications"
    t.index ["total_points"], name: "index_users_on_total_points"
    t.index ["total_reviews"], name: "index_users_on_total_reviews"
    t.index ["total_sales_amount"], name: "index_users_on_total_sales_amount"
    t.index ["total_sales_number"], name: "index_users_on_total_sales_number"
    t.index ["total_sales_numbers"], name: "index_users_on_total_sales_numbers"
    t.index ["total_target_users"], name: "index_users_on_total_target_users"
  end

  add_foreign_key "access_logs", "users"
  add_foreign_key "admin_user_roles", "admin_users"
  add_foreign_key "admin_user_roles", "roles"
  add_foreign_key "delivery_items", "transactions"
  add_foreign_key "error_logs", "users"
  add_foreign_key "inquiries", "admin_users"
  add_foreign_key "inquiries", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "notifications", "users", column: "notifier_id"
  add_foreign_key "operations", "admin_users"
  add_foreign_key "payments", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "relationships", "users"
  add_foreign_key "relationships", "users", column: "target_user_id"
  add_foreign_key "request_categories", "requests"
  add_foreign_key "request_items", "requests"
  add_foreign_key "request_likes", "requests"
  add_foreign_key "request_likes", "users"
  add_foreign_key "request_supplements", "requests"
  add_foreign_key "requests", "users"
  add_foreign_key "service_categories", "services"
  add_foreign_key "service_files", "services"
  add_foreign_key "service_items", "services"
  add_foreign_key "service_likes", "services"
  add_foreign_key "service_likes", "users"
  add_foreign_key "services", "requests"
  add_foreign_key "services", "users"
  add_foreign_key "transaction_categories", "transactions"
  add_foreign_key "transaction_likes", "transactions"
  add_foreign_key "transaction_likes", "users"
  add_foreign_key "transaction_messages", "transactions"
  add_foreign_key "transaction_messages", "users", column: "receiver_id"
  add_foreign_key "transaction_messages", "users", column: "sender_id"
  add_foreign_key "transactions", "requests"
  add_foreign_key "transactions", "services"
  add_foreign_key "transactions", "users", column: "buyer_id"
  add_foreign_key "transactions", "users", column: "seller_id"
  add_foreign_key "user_categories", "users"
  add_foreign_key "user_state_histories", "users"
end
