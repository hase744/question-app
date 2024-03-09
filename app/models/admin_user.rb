class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable
  has_many :admin_user_roles
  #has_many :admin_users, through: :admin_user_roles
  has_many :roles, through: :admin_user_roles, source: :role

  def display_name
    self.email
  end
end
