def driver_for_test
  if ENV['SELENIUM'] == 'true'
    :selenium
  elsif ENV['POLTERGEIST'] == 'true'
    :poltergeist
  else
    :chrome
  end
end

def session
  $session ||= Capybara::Session.new(driver_for_test)
end
