# frozen_string_literal: true

class Ability
  include CanCan::Ability
  
  def initialize(admin_user)
    admin_user ||= admin_user
    # role が admin のユーザーはモデルの操作を行うことができて管理者画面を閲覧可能
    if admin_user.roles.exists?(name: 'super_admin')
      #can :read, :all
      can :manage, :all
    elsif admin_user.roles.exists?(name: 'promoter')
      can :read, :all
      can :manage, AdminUser
      can :create, PotentialSeller
      can :edit, PotentialSeller
      can :update, PotentialSeller
      cannot :read, Message
      cannot :read, AccessLog
    # role が read_only のユーザーはモデルの操作を行うことができず閲覧のみ可能、管理者画面は閲覧不可能
    #elsif admin_user.has_role?(:read_only)
    #  can :read, :all
    #  cannot :access_admin_page, :all
#
    ## role を持っていないユーザーは全ての画面が閲覧不可能
    else
      cannot :read, :all
    end
  end
  #def initialize(user)
  #  # Define abilities for the user here. For example:
  #  #
  #  #   return unless user.present?
  #  #   can :read, :all
  #  #   return unless user.admin?
  #  #   can :manage, :all
  #  #
  #  # The first argument to `can` is the action you are giving the user
  #  # permission to do.
  #  # If you pass :manage it will apply to every action. Other common actions
  #  # here are :read, :create, :update and :destroy.
  #  #
  #  # The second argument is the resource the user can perform the action on.
  #  # If you pass :all it will apply to every resource. Otherwise pass a Ruby
  #  # class of the resource.
  #  #
  #  # The third argument is an optional hash of conditions to further filter the
  #  # objects.
  #  # For example, here the user can only update published articles.
  #  #
  #  #   can :update, Article, published: true
  #  #
  #  # See the wiki for details:
  #  # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
  #end
end
