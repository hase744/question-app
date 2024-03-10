class Operation < ApplicationRecord
  belongs_to :admin_user
  enum state: CommonConcern.operation_states
  after_commit :update_operation_config
end
