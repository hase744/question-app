require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module QuestionApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.i18n.default_locale = :ja
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.time_zone = 'Asia/Tokyo'
    config.generators do |g|
      g.test_framework :rspec,
        controller_specs: true,  # コントローラスペックを生成
        request_specs: false     # リクエストスペックを生成しない
    end
    config.stripe_publishable_key = Rails.env.production? ? ENV['STRIPE_PUBLISHABLE_KEY'] : ENV['STRIPE_PUBLISHABLE_KEY_DEV']
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
