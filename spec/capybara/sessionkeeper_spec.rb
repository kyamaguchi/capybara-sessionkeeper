require "spec_helper"

RSpec.describe Capybara::Sessionkeeper do
  it "has a version number" do
    expect(Capybara::Sessionkeeper::VERSION).not_to be nil
  end

  describe '#save_cookies' do
    it "saves cookies into file" do
      session.visit 'https://github.com/'
      path = session.save_cookies
      expect(path).to match(/capybara-\d+.cookies.txt/)
    end

    it "saves cookies into specified file" do
      cookie_path = 'my/cookie.txt'
      session.visit 'https://github.com/'
      session.save_cookies(cookie_path)
      expect(File.exists?(File.join(Capybara.save_path, cookie_path))).to be_truthy
    end

    it "saves cookies without error when visit has never performed" do
      path = session.save_cookies
      expect(path).to match(/capybara-\d+.cookies.txt/)
    end
  end

  describe '#restore_cookies' do
    context "when path of cookie file isn't given" do
      let(:save_path_for_test) { 'spec/fixtures/restore_test' }

      it "restores cookies from the latest file" do
        allow(Capybara).to receive(:save_path).and_return(save_path_for_test)
        session.visit 'https://github.com/'
        cookies = session.restore_cookies
        expect(cookies).not_to be_nil
        expect(cookies.all?{|c| c[:domain] =~ /github\.com/ }).to be_truthy
      end

      it "returns nil when cookie file doesn't exist in save_path" do
        allow(Capybara).to receive(:save_path).and_return('spec/fixtures/not_exist')
        session.visit 'https://github.com/'
        expect(session.restore_cookies).to be_nil
      end
    end

    let(:cookie_path) { 'spec/fixtures/github.cookies.txt' }

    it "restores cookies from file" do
      expect(session.driver.browser.manage.all_cookies).to be_empty
      session.visit 'https://github.com/'
      cookies = session.restore_cookies(cookie_path)
      expect(cookies).not_to be_empty
      expect(cookies.all?{|c| c[:domain] =~ /github\.com/ }).to be_truthy
    end

    it "skips invalid domain error" do
      expect(session.driver.browser.manage.all_cookies).to be_empty
      session.visit 'https://www.google.com/'
      expect{
        session.restore_cookies(cookie_path)
      }.not_to raise_error
    end

    it "raises error when visit has never been performed" do
      expect{
        session.restore_cookies(cookie_path)
      }.to raise_error(Capybara::Sessionkeeper::CookieError, /visit/)
    end
  end

  describe '#find_latest_cookie_file' do
    it "works when Capybara.save_path is nil" do
      allow(Capybara).to receive(:save_path).and_return(nil)
      expect{
        session.find_latest_cookie_file
      }.not_to raise_error
    end
  end

  context 'keeping signin' do
    def github_username
      raise('set your github credentials using envchain. See README.') if ENV['GITHUB_USERNAME'].nil?
      ENV['GITHUB_USERNAME']
    end
    def github_password
      ENV['GITHUB_PASSWORD']
    end

    def login_github(session)
      session.visit 'https://github.com/login'
      sleep 2
      session.fill_in 'login_field', with: github_username
      session.fill_in 'password', with: github_password
      session.click_on 'Sign in'
      session
    end

    def visit_home(session)
      session.visit "https://github.com/#{github_username}"
      within('.vcard-username') do
        expect(session).to have_content(login)
      end
      session
    end

    it "sees profile page after restoring cookies" do
      begin
        github_username
      rescue => e
        skip("#{e.message} #{e.backtrace.first}")
      end
      login_github(session)
      expect(session).to have_selector('#user-links')
      session.visit 'https://github.com/settings/profile'
      expect(session).to have_content('Public profile')
      session.save_cookies

      session.reset_session!

      session.visit 'https://github.com/'
      expect(session).to have_link('Sign in')
      expect(session).not_to have_selector('#user-links')

      session.restore_cookies

      session.visit session.current_url
      expect(session).to have_selector('#user-links')
      session.visit 'https://github.com/settings/profile'
      expect(session).to have_content('Public profile')
    end
  end

  it "test1" do
    expect(false).to be_falsey
  end

  it "test2" do
    expect(true).to be_truthy
  end
end
