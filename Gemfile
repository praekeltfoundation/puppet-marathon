source 'https://rubygems.org'

group :test do
  gem 'rake'

  puppetversion = ENV['PUPPET_VERSION'] || ['>= 3.4.0']
  gem 'puppet', puppetversion

  gem 'librarian-puppet'
  # A certain version of metadata-json-lint added a check for unbounded version
  # requirements of dependencies. We do this now, but I can't figure out which
  # version added the check, so just pin to a known-good version.
  gem 'metadata-json-lint', '~> 1.2.2'
  gem 'puppetlabs_spec_helper', '~> 1.1.1'
  gem 'rspec-puppet-facts'

  gem 'rubocop', '~> 0.41.1'

  # json 2.0.0 gem dropped support for Ruby < 2.0
  gem 'json', '< 2.0.0' if RUBY_VERSION < '2.0'
end
