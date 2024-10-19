class RequestCategory < CategoryBase::Base
  belongs_to :request
  delegate :user, to: :request
  validates :category_name, presence: true
end
