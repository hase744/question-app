class RequestSupplement < ApplicationRecord
  belongs_to :request
  validate :validate_request

  def validate_request
    return unless new_record?
    unless self.request.is_suggestable?
      errors.add(:base, "作成できません")
    end
  end
end
