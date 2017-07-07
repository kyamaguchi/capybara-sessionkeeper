require 'capybara'
require "capybara/sessionkeeper/version"

module Capybara
  module Sessionkeeper
    class CookieError < StandardError; end

    def save_cookies(path = nil)
      path = prepare_path(path, 'cookies.txt')
      data = Marshal.dump driver.browser.manage.all_cookies
      File.write(path, data)
      path
    end

    def restore_cookies(path)
      raise CookieError, "visit must be performed to restore cookies" if driver.browser.manage.all_cookies.empty?
      data = File.read(path)
      Marshal.load(data).each do |d|
        driver.browser.manage.add_cookie d
      end
      driver.browser.manage.all_cookies
    rescue => e
      raise $!, "You need to visit the site you are trying to restore cookie first\n#{$!}", $!.backtrace
    end
  end
end

Capybara::Session.send(:include, Capybara::Sessionkeeper)
