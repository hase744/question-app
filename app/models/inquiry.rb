class Inquiry < ApplicationRecord
  belongs_to :user, optional:true
end
