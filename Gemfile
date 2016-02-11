source 'https://rubygems.org'

group :test do
  gem 'rake'

  puppetversion = ENV['PUPPET_VERSION'] || ['>= 3.4.0']
  gem 'puppet', puppetversion

  gem 'librarian-puppet'
  gem 'metadata-json-lint'
  gem 'puppetlabs_spec_helper'
  gem 'rspec-puppet-facts'

  gem 'rubocop', '~> 0.37.0'
  # On certain setups, rubocop seems to crash without this gem :-/
  gem 'safe_yaml', '~> 1.0.0'
end
