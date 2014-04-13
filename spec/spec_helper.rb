ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

require 'capybara/rspec'
require 'webmock/rspec'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"

  #Only expect syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Fixtures -----
def fixture_path
  File.expand_path(Rails.root.join("spec/fixtures"), __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

def set_sponsorpay_mandatory_settings
  #these test settings are taken from SponsorPay public docs
  SponsorPay.configure do |config|
    config.appid = '157'
    config.api_key = 'e95a21621a1865bcbae3bee89c4d4f84'
    config.locale = 'de'
    config.os_version = '7'
    config.ip = '212.45.111.17'
    config.device_id = '2b6f0cc904d137be2e1730235f5664094b831186'
  end
end
