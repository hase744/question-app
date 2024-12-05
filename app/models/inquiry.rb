class Inquiry < ApplicationRecord
  belongs_to :admin_user, optional:true
  belongs_to :user, optional:true
end
