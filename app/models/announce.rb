class Announce < ApplicationRecord
    after_commit :create_notification

    def create_notification
    end
end
