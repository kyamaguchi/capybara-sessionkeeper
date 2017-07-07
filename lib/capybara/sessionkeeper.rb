require 'capybara'
require "capybara/sessionkeeper/version"

module Capybara
  module Sessionkeeper
    def save_cookies(path = nil)
      path = prepare_path(path, 'cookies.txt')
      data = driver.browser.manage.all_cookies
      File.write(path, data, mode: 'wb')
      path
    end
  end
end

Capybara::Session.send(:include, Capybara::Sessionkeeper)
