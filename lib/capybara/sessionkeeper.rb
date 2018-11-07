require 'capybara'
require "capybara/sessionkeeper/version"
require 'yaml'

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
      path ||= find_latest_cookie_file
      return nil if path.nil?
      data = File.open(path, 'rb') {|f| f.read }
      restore_cookies_from_data(data)
    end

    def restore_cookies_from_data(data, options = {})
      raise CookieError, "visit must be performed to restore cookies" if ['data:,', 'about:blank'].include?(current_url)
      cookies = %w[yml yaml].include?(options[:format]) ? YAML.load(data) : Marshal.load(data)
      cookies.each do |d|
        begin
          driver.browser.manage.add_cookie d
        rescue => e
          skip_invalid_cookie_domain_error(e)
        end
      end
      driver.browser.manage.all_cookies
    end

    def cookies_to_yaml
      YAML.dump driver.browser.manage.all_cookies
    end

    def cookie_file_extension
      'cookies.txt'
    end

    def find_latest_cookie_file
      Dir.glob(File.join([Capybara.save_path, "*.#{cookie_file_extension}"].compact)).max_by{|f| File.mtime(f) }
    end

    def skip_invalid_cookie_domain_error(e)
      if e.message =~ /invalid cookie domain/ || # Chrome
         e.message =~ /InvalidCookieDomainError/ || # Old firefox
         e.class.to_s == 'Selenium::WebDriver::Error::InvalidCookieDomainError' # Firefox
        # puts e.class, e.message
        # puts "Skipped invalid cookie domain: #{d[:domain]} - #{d.inspect}"
      else
        raise(e)
      end
    end
  end
end

Capybara::Session.send(:include, Capybara::Sessionkeeper)
