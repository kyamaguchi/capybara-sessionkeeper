require 'capybara'
require "capybara/sessionkeeper/version"

module Capybara
  module Sessionkeeper
    class CookieError < StandardError; end

    def save_cookies(path = nil)
      path = prepare_path(path, cookie_file_extension)
      data = Marshal.dump driver.browser.manage.all_cookies
      File.open(path, 'wb') {|f| f.puts(data) }
      path
    end

    def restore_cookies(path = nil)
      raise CookieError, "visit must be performed to restore cookies" if driver.browser.manage.all_cookies.empty?
      path ||= find_latest_cookie_file
      return nil if path.nil?
      data = File.open(path, 'rb') {|f| f.read }
      Marshal.load(data).each do |d|
        begin
          driver.browser.manage.add_cookie d
        rescue => e
          skip_invalid_cookie_domain_error(e)
        end
      end
      driver.browser.manage.all_cookies
    end

    def cookie_file_extension
      'cookies.txt'
    end

    private

    def find_latest_cookie_file
      Dir.glob(File.join(Capybara.save_path, "*.#{cookie_file_extension}")).max_by{|f| File.mtime(f) }
    end

    def skip_invalid_cookie_domain_error(e)
      if e.message =~ /InvalidCookieDomainError/
        # Case of :selenium driver(Firefox). e.message -> "ReferenceError: InvalidCookieDomainError is not defined"
        # Selenium::WebDriver::Error::UnknownError: ReferenceError: InvalidCookieDomainError is not defined
      elsif e.message =~ /invalid cookie domain/
        # Case of :chrome driver. e.message -> 'invalid cookie domain: invalid domain:".github.com"'
        # Selenium::WebDriver::Error::InvalidCookieDomainError
        # puts "Skipped invalid cookie domain: #{d[:domain]} - #{d.inspect}"
      else
        raise(e)
      end
    end
  end
end

Capybara::Session.send(:include, Capybara::Sessionkeeper)
