# Capybara::Sessionkeeper

[![Gem Version](https://badge.fury.io/rb/capybara-sessionkeeper.svg)](https://badge.fury.io/rb/capybara-sessionkeeper)
[![Build Status](https://travis-ci.org/kyamaguchi/capybara-sessionkeeper.svg?branch=master)](https://travis-ci.org/kyamaguchi/capybara-sessionkeeper)

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

```
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end
```

Firefox(:selenium option) also works.

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

Save cookie to yaml string (serialization to yaml).

```
cookie_yaml_str = session.save_cookies_to_yaml
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

Restore cookie from yaml string (deserialization from yaml)

```
cookies_yaml_str = <<~YAML
---
- :name: _gh_sess
  :value: aWRQdUVLanFEUk56d3h1ZDB5M3c0MXk1V2J5QllU--9c09ace4dda7227197637d9e105d9746245cf513
  :path: "/"
  :domain: github.com
  :expires: 
  :secure: true
YAML
session.restore_cookies_from_yaml(cookies_yaml_str)
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

### Testing spec which requires signin using envchain

There are some spec requiring GitHub signin.  

You can store environment variables in macOS Keychain.  
Check out [envchain](https://github.com/sorah/envchain)

```
brew install envchain
envchain --set github GITHUB_USERNAME GITHUB_PASSWORD

envchain github rspec
```

### Testing with :selenium(Firefox) driver

```
SELENIUM=true rspec
SELENIUM=true envchain github rspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kyamaguchi/capybara-sessionkeeper.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
