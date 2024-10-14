module CommonMethods
  attr_accessor :current_nav_item
  extend ActiveSupport::Concern

  def en_to_em(str)
    NKF.nkf('-w -Z4', str)
  end

  def current_nav_item
    @current_nav_item
  end

  def set_current_nav_item
    @current_nav_item = params[:nav_item]
    @current_nav_item ||= action_name
    @current_nav_item = 'posts' if @current_nav_item == 'show'
  end

  def set_current_nav_item_for_service
    @current_nav_item = params[:nav_item]
    @current_nav_item ||= 'transactions'
  end
end