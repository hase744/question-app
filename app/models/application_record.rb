class ApplicationRecord < ActiveRecord::Base
  Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  self.abstract_class = true
  include CommonMethods
  include CategoryConfig
  include FormConfig
  include OperationConfig
  include Variables

  def form_array
    ["video","image","text"]
  end
end
