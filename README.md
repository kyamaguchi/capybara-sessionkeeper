# Capybara::Sessionkeeper

[![Gem Version](https://badge.fury.io/rb/capybara-sessionkeeper.svg)](https://badge.fury.io/rb/capybara-sessionkeeper)
[![CircleCI](https://circleci.com/gh/kyamaguchi/capybara-sessionkeeper.svg?style=svg)](https://circleci.com/gh/kyamaguchi/capybara-sessionkeeper)

Save and restore cookies of capybara session

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capybara-sessionkeeper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capybara-sessionkeeper

## Usage

Require with capybara

```
require "capybara"
require "capybara/sessionkeeper"
```

### Supported drivers

[Recommended] Chrome driver is supported.  
[Install chromedriver](http://chromedriver.chromium.org/downloads)

```
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end
```

Firefox(:selenium option) may not work.  
[Install geckodriver](https://github.com/mozilla/geckodriver/releases)

```
session = Capybara::Session.new(:selenium)
```

`session` will be equivalent to `page` in the system test.

### Location of cookie file

It follows `Capybara.save_path`.

### Save cookies

```
session = Capybara::Session.new(:chrome)
session.visit 'https://github.com/'
path = session.save_cookies
```

Save cookie file with specified file name.

```
session.save_cookies('user1.cookies.txt')
```

### Restore cookies

You have to visit the site which you are trying to restore cookie beforehand.  
Otherwise, you will get error.

```
session = Capybara::Session.new(:chrome)
session.visit 'https://github.com/'
cookies = session.restore_cookies
```

Restore cookie file with specified file name.

```
session.restore_cookies(File.join(Capybara.save_path, 'user1.cookies.txt'))
```

### Save and restore cookies from YAML

Save cookie to yaml string (serialization to yaml).

```
yaml_str = session.cookies_to_yaml
```

Restore cookie from yaml string (deserialization from yaml).

```
session.restore_cookies_from_data(yaml_str, format: 'yaml')
```

### Read cookies of current session

```
session.driver.browser.manage.all_cookies
```

### Notice of cookie restoration

On restoring cookies, this gem ignores `Selenium::WebDriver::Error::InvalidCookieDomainError`.  
If you repeat `save_cookies` and `restore_cookies` in a single file, you could lose some cookies of domains you haven't visited.  

This behavior can be changed in the future.  

Some use cases are,  
Save/Restore cookies by users/use cases/sites.  
You can switch signed-in users easily.  
You don't need to sign in every time.  
You just need to sign in once(or occasionally) and save/restore cookies.  

## Development

### Testing with :selenium(Firefox) driver

```
SELENIUM=true rspec
```

### Test app

Some spec uses test app https://github.com/kyamaguchi/testapp-capybara-sessionkeeper

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kyamaguchi/capybara-sessionkeeper.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
