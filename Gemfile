source 'https://rubygems.org'

group :test do
  gem 'rake'

  puppetversion = ENV['PUPPET_VERSION'] || ['>= 3.4.0']
  gem 'puppet', puppetversion

  gem 'librarian-puppet'

  # metadata-json-lint 1.0.0 gem dropped support for Ruby < 2.0
  metadata_json_lint_version = '>= 0'
  if RUBY_VERSION < '2.0'
    metadata_json_lint_version = '< 1.0.0'
  end
  gem 'metadata-json-lint', metadata_json_lint_version

  gem 'puppetlabs_spec_helper', '~> 1.1.1'
  gem 'rspec-puppet-facts'

  gem 'rubocop', '~> 0.41.1'

  # json 2.0.0 gem dropped support for Ruby < 2.0
  gem 'json', '< 2.0.0' if RUBY_VERSION < '2.0'
end
