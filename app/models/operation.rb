class Operation < ApplicationRecord
  belongs_to :admin_user
  belongs_to :state
  after_commit :update_operation_config
end
