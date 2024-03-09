class User::RelationshipsController < User::Base
    before_action :check_login
    def update
        relationship = Relationship.find_by(followee: User.find(params[:id]))
        @follow_accout = User.find(params[:id])
        if relationship == nil
            Relationship.create!(followee: User.find(params[:id]), follower_id: current_user.id)
            update_total_followers
            puts "#{current_user.name}が#{User.find(params[:id]).name}をフォロー"
        else
            relationship.delete
            update_total_followers
            puts "#{current_user.name}が#{User.find(params[:id]).name}をフォロー解除"
        end
        id = params[:id].to_i
        render json: {"is_followed": true}
    end

    def create
    end

    def delete
    end
    
    def update_total_followers
        total_followers = Relationship.where(followee_id: @follow_accout).count
        @follow_accout.update(total_followers: total_followers)
    end
end
