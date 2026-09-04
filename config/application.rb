require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AdagioBackend
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])
    config.api_only = true
    config.active_storage.variant_processor = :mini_magick

    # api_only mode strips the cookie jar out of the middleware stack by
    # default; we need it back to set/read the HttpOnly JWT cookie.
    config.middleware.use ActionDispatch::Cookies
  end
end
