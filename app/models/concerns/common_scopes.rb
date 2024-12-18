module CommonScopes
  extend ActiveSupport::Concern
  included do
    scope :abled, -> { where(is_disabled: false) }
    scope :disabled, -> { where(is_disabled: true) }
    scope :tip_mode, -> { where(mode: 'tip')}
    scope :not_tip_mode, -> { where.not(mode: 'tip')}
  end
end