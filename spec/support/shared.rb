def driver_for_test
  ENV['SELENIUM'] == 'true' ? :selenium : :chrome
end

def session
  $session ||= Capybara::Session.new(driver_for_test)
end
