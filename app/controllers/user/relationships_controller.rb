class User::RelationshipsController < User::Base
  before_action :check_login
  def update
    relationship = current_user.followee_relationships.find_by(target_user: User.find(params[:id]))
    if relationship
      relationship.destroy
    else
      current_user.followee_relationships.create(target_user: User.find(params[:id]))
    end
    render json: {"is_followed": true}
  end
  
  def update_total_followers
    total_target_users = Relationship.where(user_id: @follow_accout).count
    @follow_accout.update(total_target_users: total_target_users)
  end
end
