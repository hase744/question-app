class Form < ApplicationRecord
    has_many :services, foreign_key: :request_form_id
    has_many :services, foreign_key: :delivery_form_id
    has_many :requests, foreign_key: :request_form_id
    has_many :requests, foreign_key: :delivery_form_id
    has_many :transactions, foreign_key: :request_form_id
    has_many :transactions, foreign_key: :delivery_form_id
    after_commit :update_form_config
end
