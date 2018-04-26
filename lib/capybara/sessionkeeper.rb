require 'capybara'
require "capybara/sessionkeeper/version"

module Capybara
  module Sessionkeeper
    class CookieError < StandardError; end

    def save_cookies(path = nil)
      path = prepare_path(path, cookie_file_extension)
      data = Marshal.dump cookies_from_driver(driver)
      File.open(path, 'wb') {|f| f.puts(data) }
      path
    end

    def restore_cookies(path = nil)
      raise CookieError, "visit must be performed to restore cookies" if ['data:,', 'about:blank'].include?(current_url)
      path ||= find_latest_cookie_file
      return nil if path.nil?
      data = File.open(path, 'rb') {|f| f.read }
      Marshal.load(data).each do |cookie|
        begin
          set_cookie_for_driver(driver, cookie)
        rescue => e
          skip_invalid_cookie_domain_error(e)
        end
      end
      cookies_from_driver(driver)
    end

    def cookie_file_extension
      'cookies.txt'
    end

    def find_latest_cookie_file
      Dir.glob(File.join([Capybara.save_path, "*.#{cookie_file_extension}"].compact)).max_by{|f| File.mtime(f) }
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

    def cookies_from_driver(driver)
      if driver.class == Capybara::Poltergeist::Driver
        driver.cookies.map do |cookie|
          Hash[%w[name value path domain expires secure?].map{|k| [k.chomp('?').to_sym, cookie.last.send(k)] }]
        end
      else
        driver.browser.manage.all_cookies
      end
    end

    def set_cookie_for_driver(driver, cookie)
      if driver.class == Capybara::Poltergeist::Driver
        driver.browser.set_cookie(cookie)
      else
        driver.browser.manage.add_cookie(cookie)
      end
    end
  end
end

Capybara::Session.send(:include, Capybara::Sessionkeeper)
