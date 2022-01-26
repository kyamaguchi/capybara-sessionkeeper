require "byebug"
require "bundler/setup"
require "capybara/sessionkeeper"

Dir[File.join(File.dirname(__FILE__), "..", "spec", "support", "**/*.rb")].sort.each {|f| require f}

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    FileUtils.rm_rf('spec/tmp')
  end

  config.after do
    session.reset_session! if $session
  end
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end
Capybara.save_path = 'spec/tmp/capybara'
