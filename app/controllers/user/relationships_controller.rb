class User::RelationshipsController < User::Base
  before_action :check_login
  def update
    user = User.find(params[:id])
    relationship = current_user.followee_relationships.find_by(target_user: user)
    if relationship
      relationship.destroy
    elsif current_user != user
      current_user.followee_relationships.create(target_user: user)
    else
      render json: {"follow_succeeded": false}
      return
    end
    render json: {"follow_succeeded": true}
  end
  
  def update_total_followers
    total_target_users = Relationship.where(user_id: @follow_accout).count
    @follow_accout.update(total_target_users: total_target_users)
  end
end
