class ServiceCategory < CategoryBase::Base
  belongs_to :service
  delegate :user, to: :service
end
