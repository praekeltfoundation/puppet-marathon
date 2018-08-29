source 'https://rubygems.org'

group :test do
  gem 'rake'

  puppetversion = ENV['PUPPET_VERSION'] || ['>= 3.4.0']
  gem 'puppet', puppetversion

  gem 'librarian-puppet'

  # metadata-json-lint 1.0.0 gem dropped support for Ruby < 2.0
  gem 'metadata-json-lint', RUBY_VERSION < '2.0' ? '< 1.0.0' : '>= 0'

  gem 'puppetlabs_spec_helper', '~> 1.1.1'
  gem 'rspec-puppet-facts'

  gem 'rubocop', '~> 0.49.0'

  # json 2.0.0 gem dropped support for Ruby < 2.0
  gem 'json', '< 2.0.0' if RUBY_VERSION < '2.0'
end
