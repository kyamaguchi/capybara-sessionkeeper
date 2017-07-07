def session
  @session ||= Capybara::Session.new(:chrome)
end
