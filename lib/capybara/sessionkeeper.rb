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
      data = File.open(path, 'rb', &:read)
      restore_cookies_from_data(data)
    end

    def restore_cookies_from_data(data, options = {})
      raise CookieError, "visit must be performed to restore cookies" if ['data:,', 'about:blank'].include?(current_url)
      cookies = %w[yml yaml].include?(options[:format]) ? YAML.load(data) : Marshal.load(data)
      cookies.each do |d|
        begin
          driver.browser.manage.delete_cookie d[:name]
          driver.browser.manage.add_cookie d
        rescue StandardError => e
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

    def skip_invalid_cookie_domain_error(error)
      if error.message =~ /invalid cookie domain/ || # Chrome
         error.message =~ /InvalidCookieDomainError/ || # Old firefox
         error.class.to_s == 'Selenium::WebDriver::Error::InvalidCookieDomainError' # Firefox
        # puts error.class, error.message
        # puts "Skipped invalid cookie domain: #{d[:domain]} - #{d.inspect}"
      else
        raise(error)
      end
    end
  end
end

Capybara::Session.include Capybara::Sessionkeeper
