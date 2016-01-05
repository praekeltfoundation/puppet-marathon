require 'puppet-lint/tasks/puppet-lint'
require 'rspec-puppet/rake_task'

Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
  config.ignore_paths = ["spec/**/*.pp", "vendor/**/*.pp", "modules/**/*.pp"]
end

task :default => [:spec, :lint]
