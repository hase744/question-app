class UserStateHistory < ApplicationRecord
  enum state: CommonConcern.user_states
  belongs_to :user

  #after_commit :edit_user_state
  #
  #def edit_user_state
  #  self.user.update(state: self.state)
  #end
end