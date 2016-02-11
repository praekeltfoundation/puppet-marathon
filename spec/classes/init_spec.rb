require 'spec_helper'

describe 'marathon' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should compile }

      describe 'with default options' do
        it { is_expected.to contain_anchor('marathon::begin') }

        it do
          is_expected.to contain_class('marathon::repo')
            .with_manage(true)
            .with_source('mesosphere')
            .that_requires('Anchor[marathon::begin]')
        end

        it do
          is_expected.to contain_class('marathon::install')
            .with_ensure('present')
            .that_requires('Class[marathon::repo]')
        end

        it do
          is_expected.to contain_class('marathon::config')
            .with(
              :owner => 'root',
              :group => 'root',
              :master => nil,
              :zk => nil,
              :options => {},
              :env_var => {},
              :syslog => true,
              :manage_logger => true,
              :logger => 'logback',
              :log_dir => '/var/log/marathon',
              :log_filename => 'marathon.log',
              :java_home => nil,
              :java_opts => '-Xmx512m',
              :ulimit => nil,
              :mesos_auth_principal => nil,
              :mesos_auth_secret => nil,
              :mesos_auth_secret_file => '/etc/marathon/.secret'
            ).that_requires('Class[marathon::install]')
        end

        it do
          is_expected.to contain_class('marathon::service')
            .with_ensure('running')
            .with_manage(true)
            .that_subscribes_to('Class[marathon::config]')
        end

        it do
          is_expected.to contain_anchor('marathon::end')
            .that_requires('Class[marathon::service]')
        end
      end

      it 'should restart the service when upgrading the package' do
        is_expected.to contain_package('marathon')
          .that_notifies('Class[Marathon::Service]')
      end
    end
  end
end
