require 'spec_helper'

describe 'marathon::config' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile }

      context 'secrets' do
        describe 'when the auth principal and secret are set' do
          let(:params) do
            {
              :mesos_auth_principal => 'marathon',
              :mesos_auth_secret => 'very-secret',
            }
          end

          it 'stores the secret' do
            is_expected.to contain_file('/etc/marathon/.secret')
              .with_content('very-secret')
            is_expected.to contain_mesos__property(
              'marathon_mesos_authentication_principal')
              .with_value('marathon')
            is_expected.to contain_mesos__property(
              'marathon_mesos_authentication_secret_file')
              .with_value('/etc/marathon/.secret')
          end
        end

        describe 'when the auth principal is not set' do
          let(:params) do
            {
              :mesos_auth_principal => :undef,
              :mesos_auth_secret => 'very-secret'
            }
          end

          it 'does not store the secret' do
            is_expected.not_to contain_file('/etc/marathon/.secret')
            is_expected.not_to contain_mesos__property(
              'marathon_mesos_authentication_principal')
            is_expected.not_to contain_mesos__property(
              'marathon_mesos_authentication_secret_file')
          end
        end

        describe 'when the auth secret is not set' do
          let(:params) do
            {
              :mesos_auth_principal => 'principal',
              :mesos_auth_secret => :undef
            }
          end

          it 'does not store the secret' do
            is_expected.not_to contain_file('/etc/marathon/.secret')
            is_expected.not_to contain_mesos__property(
              'marathon_mesos_authentication_principal')
            is_expected.not_to contain_mesos__property(
              'marathon_mesos_authentication_secret_file')
          end
        end

        describe 'when a custom secret file path is set' do
          let(:params) do
            {
              :mesos_auth_principal => 'marathon',
              :mesos_auth_secret => 'very-secret',
              :mesos_auth_secret_file => '/root/.marathon_secret',
            }
          end

          it 'stores the secret in the specified location' do
            is_expected.to contain_file('/root/.marathon_secret')
              .with_content('very-secret')
            is_expected.to contain_mesos__property(
              'marathon_mesos_authentication_secret_file')
              .with_value('/root/.marathon_secret')
          end
        end
      end

      context 'with default params' do
        it 'creates config directories' do
          is_expected.to contain_file('/etc/marathon')
            .with_ensure('directory')
          is_expected.to contain_file('/etc/marathon/conf')
            .with_ensure('directory')
        end

        it 'configures logback' do
          is_expected.to contain_file('/var/log/marathon')
            .with_ensure('directory')
          is_expected.to contain_file('/etc/marathon/logback.xml')
            .with_content(/<file>\/var\/log\/marathon\/marathon.log<\/file>/)
        end

        case facts[:osfamily]
        when /Debian/

          it 'writes config to /etc/default/marathon' do
            logback_opt =
              '-Dlogback.configurationFile=file:/etc/marathon/logback.xml'
            is_expected.to contain_file('/etc/default/marathon')
              .with_content(/^JAVA_OPTS="-Xmx512m #{logback_opt}"$/)
              .without_content(/JAVA_HOME/)
              .without_content(/ulimit/)
          end

          it 'does not configure systemd' do
            is_expected.not_to contain_file('/etc/sysconfig/marathon')
          end

        when /RedHat/

          it 'does not configure sysvinit' do
            is_expected.to contain_file('/etc/default/marathon')
              .with_ensure('absent')
          end

          it 'configures systemd' do
            logback_path = '/etc/marathon/logback.xml'
            logback_opt = "-Dlogback.configurationFile=file:#{logback_path}"
            is_expected.to contain_file('/etc/sysconfig/marathon')
              .with_content(/^JAVA_OPTS=-Xmx512m #{logback_opt}$/)
              .without_content(/JAVA_HOME/)

            is_expected.to contain_file('/etc/systemd/system/marathon.service')
              .with_ensure('absent')
            is_expected.to contain_exec('systemctl-daemon-reload_marathon')
          end
        end
      end

      context 'with lots of custom params' do
        let(:params) do
          {
            :owner => 'marathon-user',
            :group => 'marathon-group',
            :master => 'zk://foo:2181/mesos',
            :zookeeper => 'zk://foo:2181/marathon',
            :options => {
              'some_options' => 'with-value',
              'some_other_options' => 'with-other-value',
            },
            :env_var => {
              'foo' => 'bar',
              'f00' => 'b4r',
            },
            :java_home => '/opt/some/java/home',
            :java_opts => '-Xmx1024m',
            :ulimit => 9001,
          }
        end

        it { is_expected.to compile }

        it 'stores some config in /etc/marathon/conf' do
          is_expected.to contain_mesos__property('marathon_master')
            .with_value('zk://foo:2181/mesos')
            .with_owner('marathon-user')
            .with_group('marathon-group')
          is_expected.to contain_mesos__property('marathon_zk')
            .with_value('zk://foo:2181/marathon')
            .with_owner('marathon-user')
            .with_group('marathon-group')
          is_expected.to contain_mesos__property('marathon_some_options')
            .with_value('with-value')
            .with_owner('marathon-user')
            .with_group('marathon-group')
          is_expected.to contain_mesos__property('marathon_some_other_options')
            .with_value('with-other-value')
            .with_owner('marathon-user')
            .with_group('marathon-group')
        end

        case facts[:osfamily]
        when /Debian/

          it 'writes config to /etc/default/marathon' do
            logback_opt =
              '-Dlogback.configurationFile=file:/etc/marathon/logback.xml'
            is_expected.to contain_file('/etc/default/marathon')
              .with_content(/^ulimit -n 9001$/)
              .with_content(/^JAVA_OPTS="-Xmx1024m #{logback_opt}"$/)
              .with_content(/^JAVA_HOME="\/opt\/some\/java\/home"$/)
              .with_content(/^export foo="bar"$/)
              .with_content(/^export f00="b4r"$/)
          end

          it 'does not configure systemd' do
            is_expected.not_to contain_file('/etc/sysconfig/marathon')
          end

        when /RedHat/

          it 'does not configure sysvinit' do
            is_expected.to contain_file('/etc/default/marathon')
              .with_ensure('absent')
          end

          it 'configures systemd' do
            logback_opt =
              '-Dlogback.configurationFile=file:/etc/marathon/logback.xml'
            is_expected.to contain_file('/etc/sysconfig/marathon')
              .with_content(/^JAVA_OPTS=-Xmx1024m #{logback_opt}$/)
              .with_content(/^JAVA_HOME=\/opt\/some\/java\/home$/)
              .with_content(/^foo=bar$/)
              .with_content(/^f00=b4r$/)

            is_expected.to contain_file('/etc/systemd/system/marathon.service')
              .with_content(/^LimitNOFILE=9001$/)
            is_expected.to contain_exec('systemctl-daemon-reload_marathon')
          end
        end
      end

      context 'syslog' do
        describe 'when syslog is true' do
          let(:params) { {:syslog => true} }
          it do
            is_expected.to contain_file('/etc/marathon/conf/?no-logger')
              .with_ensure('absent')
          end
        end

        describe 'when syslog is false' do
          let(:params) { {:syslog => false} }
          it do
            is_expected.to contain_file('/etc/marathon/conf/?no-logger')
              .with_ensure('present')
          end
        end
      end

      context 'master and zookeeper parameters' do
        describe 'when master is set' do
          let(:params) { {:master => '127.0.0.1'} }
          it do
            is_expected.to contain_mesos__property('marathon_master')
              .with_value('127.0.0.1')
          end
        end

        describe 'when master is not set' do
          let(:params) { {:master => :undef} }
          it { is_expected.not_to contain_mesos__property('marathon_master') }
        end

        describe 'when zookeeper is set' do
          let(:params) { {:zookeeper => 'zk://127.0.0.1:2181/marathon'} }
          it do
            is_expected.to contain_mesos__property('marathon_zk')
              .with_value('zk://127.0.0.1:2181/marathon')
          end
        end

        describe 'when zookeeper is not set' do
          let(:params) { {:zookeeper => :undef} }
          it { is_expected.not_to contain_mesos__property('marathon_zk') }
        end
      end
    end
  end
end
