lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "capybara/sessionkeeper/version"

Gem::Specification.new do |spec|
  spec.name          = "capybara-sessionkeeper"
  spec.version       = Capybara::Sessionkeeper::VERSION
  spec.authors       = ["Kazuho Yamaguchi"]
  spec.email         = ["kzh.yap@gmail.com"]

  spec.summary       = "Save and restore cookies of capybara session."
  spec.description   = "Save and restore cookies of capybara session."
  spec.homepage      = "https://github.com/kyamaguchi/capybara-sessionkeeper"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "capybara"
  spec.add_dependency "selenium-webdriver"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop", "0.93.1"
  spec.add_development_dependency "rubocop-rspec", "1.44.1"
  spec.add_development_dependency "byebug"
end
