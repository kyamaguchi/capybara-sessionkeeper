require "spec_helper"

RSpec.describe Capybara::Sessionkeeper do
  it "has a version number" do
    expect(Capybara::Sessionkeeper::VERSION).not_to be nil
  end

  describe '#save_cookies' do
    let(:cookie_filepath) { 'all_cookies.txt' }

    before do
      File.delete(cookie_filepath) if File.exists?(cookie_filepath)
    end

    it "saves cookies into file" do
      expect(File.exists?(cookie_filepath)).to be_falsey
      session = Capybara::Session.new(:chrome)
      session.visit 'https://github.com/'
      session.save_cookies
      expect(File.exists?(cookie_filepath)).to be_truthy
    end
  end
end
