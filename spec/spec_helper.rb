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
