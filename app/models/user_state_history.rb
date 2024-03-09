class UserStateHistory < ApplicationRecord
  belongs_to :state, class_name: "UserState"
  belongs_to :user

  #after_commit :edit_user_state
  #
  #def edit_user_state
  #  self.user.update(state: self.state)
  #end
end
