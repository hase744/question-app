module CommonScopes
  extend ActiveSupport::Concern
  included do
    scope :abled, -> { where(is_disabled: false) }
    scope :disabled, -> { where(is_disabled: true) }
    scope :reward_mode, -> { where(mode: 'reward')}
    scope :not_reward_mode, -> { where.not(mode: 'reward')}
    scope :proposal_mode, -> { where(mode: 'proposal')}
    scope :published, -> {
      where('published_at <= ?', DateTime.now)
    }
  
  end
end