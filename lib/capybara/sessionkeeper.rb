require 'capybara'
require "capybara/sessionkeeper/version"

module Capybara
  module Sessionkeeper
    def save_cookies
      data = driver.browser.manage.all_cookies
      File.open('all_cookies.txt', 'wb') {|f| f.write(data)}
    end
  end
end

Capybara::Session.send(:include, Capybara::Sessionkeeper)
