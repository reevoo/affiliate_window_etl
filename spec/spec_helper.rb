require "simplecov"
require "simplecov-console"
SimpleCov.formatter = SimpleCov::Formatter::Console
SimpleCov.minimum_coverage 90
SimpleCov.start

require "affiliate_window_etl"

require "support/fake_database"
require "support/fake_client"

require "rspec"
require "timecop"
require "pry"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.color = true
  config.formatter = :doc
end
