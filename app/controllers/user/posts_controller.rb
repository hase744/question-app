class User::PostsController < User::Base
  before_action :check_login, only:[:new, :create, :destroy]
  before_action :identify_user, only:[:destroy]
  layout :choose_layout

  private def choose_layout
    case action_name
    when "show"
      "responsive_layout"
    else
      "small"
    end
  end

  def new
    @post = Post.new
    @submit_text = "投稿"
  end

  def show
    @post = Post.find(params[:id])
    if user_signed_in?
      @relationship = Relationship.find_by(user:@post.user, target_user_id: current_user.id)
    else
      @relationship = nil
    end
  end

  def create
    @post = Post.new
    @post.user = current_user
    @post.process_file_upload = true
    @post.assign_attributes(post_params)
    if @post.save
      flash.notice = "投稿しました。"
      redirect_to user_account_path(current_user.id)
    else
      flash.notice = "投稿に失敗しました。"
      render "user/posts/new"
    end
  end

  def destroy
    @post = Post.find(params[:id])
    if @post.user == current_user
      if @post.destroy
        flash.notice = "投稿を削除しました。"
        redirect_to user_account_path(current_user.id)
      else
        flash.notice = "投稿の削除に失敗しました。"
        redirect_to user_post_path(@post.id)
      end
    end
  end

  private def post_params
    params.require(:post).permit(
      :body,
      :file
    )
  end

  private def identify_user
    post =  Post.find(params[:id])
    if post.user != current_user
      redirect_to user_accounts_path
    end
  end
end
