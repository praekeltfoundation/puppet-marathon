require 'puppetlabs_spec_helper/rake_tasks'
require 'metadata-json-lint/rake_task'

task :librarian_spec_prep do
  sh 'librarian-puppet install --path=spec/fixtures/modules/'
end
task :spec_prep => :librarian_spec_prep

# Override puppetlabs_spec_helper's default lint settings
# * Don't want to ignore so many tests
# * Don't want to run lint on upstream modules
Rake::Task[:lint].clear
PuppetLint::RakeTask.new(:lint) do |config|
  config.fail_on_warnings = true
  config.disable_checks = [
      '80chars',
      'class_inherits_from_params_class',
      'autoloader_layout',
  ]
  config.ignore_paths = ["vendor/**/*.pp", "spec/**/*.pp", "modules/**/*.pp"]
end


task :test => [
  :syntax,
  :lint,
  :metadata_lint,
  :spec,
]
