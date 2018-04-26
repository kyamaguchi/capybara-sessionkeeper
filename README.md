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

Poltergeist may work with `:poltegeist` option.

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

### Read cookies of current session

Normally

```
session.driver.browser.manage.all_cookies
```

For poltegeist

```
session.driver.cookies
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

#### Test with poltergeist

```
POLTERGEIST=true envchain github rspec --example 'keeping signin'
# OR
POLTERGEIST=true envchain github rspec spec/capybara/sessionkeeper_spec.rb
```

You may get the error using poltergeist(phantomjs).

To workaround the error 'Capybara::Poltergeist::StatusFailError'

```
IGNORE_SSL=true POLTERGEIST=true envchain github rspec --example 'keeping signin'
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kyamaguchi/capybara-sessionkeeper.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
