class State < ApplicationRecord
    has_many :users, dependent: :destroy
end
