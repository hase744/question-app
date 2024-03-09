class User::VideosController < ApplicationController
  def show
    @url = params[:url]
  end
end
