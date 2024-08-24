class RequestCategory < CategoryBase::Base
  belongs_to :request
  delegate :user, to: :request
end
