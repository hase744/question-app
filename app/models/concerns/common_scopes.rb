module CommonScopes
  extend ActiveSupport::Concern
  included do
    scope :abled, -> { where(is_disabled: false) }
    scope :disabled, -> { where(is_disabled: true) }
  end
end