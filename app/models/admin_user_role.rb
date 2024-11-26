class AdminUserRole < ApplicationRecord
  belongs_to :admin_user
  enum role_name: Role.all.map{|c| c.name.to_sym}, _prefix: true
end
