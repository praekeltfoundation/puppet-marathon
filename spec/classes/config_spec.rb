require 'spec_helper'

describe 'marathon::config' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should compile }

      context 'secrets' do
        context 'w/o secret' do
          let(:params) { {
              :options => {}
          } }

          it 'stores secret in specified file' do
            should_not contain_file('/etc/marathon/.secret')
            should_not contain_mesos__property('marathon_mesos_authentication_principal')
            should_not contain_mesos__property('marathon_mesos_authentication_secret_file')
          end
        end

        context 'at default location' do
          let(:params) { {
              :mesos_auth_principal => 'marathon',
              :mesos_auth_secret => 'very-secret',
              :options => {
                  'mesos_authentication_principal' => 'not-marathon',
                  'mesos_authentication_secret_file' => '/root/.secret',
              }
          } }

          it 'stores secret in specified file' do
            should contain_file('/etc/marathon/.secret')
                       .with_content('very-secret')
            should contain_mesos__property('marathon_mesos_authentication_principal').with_value('marathon')
            should contain_mesos__property('marathon_mesos_authentication_secret_file').with_value('/etc/marathon/.secret')
          end
        end

        context 'at default location, w/o principal set' do
          let(:params) { {
              :mesos_auth_secret => 'very-secret',
          } }

          it 'stores secret in specified file' do
            should_not contain_file('/etc/marathon/.secret')
            should_not contain_mesos__property('marathon_mesos_authentication_principal')
            should_not contain_mesos__property('marathon_mesos_authentication_secret_file')
          end
        end

        context 'at default location, w/o secret set' do
          let(:params) { {
              :mesos_auth_principal => 'marathon',
          } }

          it 'stores secret in specified file' do
            should_not contain_file('/etc/marathon/.secret')
            should_not contain_mesos__property('marathon_mesos_authentication_principal')
            should_not contain_mesos__property('marathon_mesos_authentication_secret_file')
          end
        end

        context 'at specific location from params' do
          let(:params) { {
              :mesos_auth_principal => 'marathon',
              :mesos_auth_secret => 'very-secret',
              :mesos_auth_secret_file => '/root/.marathon_secret',
          } }

          it 'stores secret in specified file' do
            should contain_file('/root/.marathon_secret')
                       .with_content('very-secret')
            should contain_mesos__property('marathon_mesos_authentication_secret_file').with_value('/root/.marathon_secret')
          end
        end
      end

      context 'with default params' do

        it { should compile }

        it 'creates conf dir' do
          should contain_file('/etc/marathon')
                     .with_ensure('directory')
          should contain_file('/etc/marathon/conf')
                     .with_ensure('directory')
        end

        it 'configures logback' do
          should contain_file('/var/log/marathon')
                     .with_ensure('directory')
          should contain_file('/etc/marathon/logback.xml')
                     .with_content(/<file>\/var\/log\/marathon\/marathon.log<\/file>/)
        end

        case facts[:osfamily]
          when /Debian/

            it 'writes config to /etc/default/marathon' do
              should contain_file('/etc/default/marathon')
                         .with_content(/^JAVA_OPTS="-Xmx512m -Dlogback.configurationFile=file:\/etc\/marathon\/logback.xml"$/)
                         .without_content(/JAVA_HOME/)
                         .without_content(/ulimit/)
            end

            it 'does not configure systemd' do
              should_not contain_file('/etc/sysconfig/marathon')
            end

          when /RedHat/

            it 'does not configure sysvinit' do
              should contain_file('/etc/default/marathon')
                         .with_ensure('absent')
            end

            it 'configures systemd' do
              should contain_file('/etc/sysconfig/marathon')
                         .with_content(/^JAVA_OPTS=-Xmx512m -Dlogback.configurationFile=file:\/etc\/marathon\/logback.xml$/)
                         .without_content(/JAVA_HOME/)

              should contain_file('/etc/systemd/system/marathon.service')
                         .with_ensure('absent')
              should contain_exec('systemctl-daemon-reload_marathon')
            end

          else
            it 'is an unsupported OS' do
              fail("#{facts[:osfamily]} is unsupported")
            end
        end
      end

      context 'with lots of custom params' do

        let(:params) { {
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
        } }

        it { should compile }

        it 'stores some config in /etc/marathon/conf' do
          should contain_mesos__property('marathon_master')
                     .with_value('zk://foo:2181/mesos')
          should contain_mesos__property('marathon_zk')
                     .with_value('zk://foo:2181/marathon')
          should contain_mesos__property('marathon_some_options')
                     .with_value('with-value')
          should contain_mesos__property('marathon_some_other_options')
                     .with_value('with-other-value')
        end

        case facts[:osfamily]
          when /Debian/

            it 'writes config to /etc/default/marathon' do
              should contain_file('/etc/default/marathon')
                         .with_content(/^ulimit -n 9001$/)
                         .with_content(/^JAVA_OPTS="-Xmx1024m -Dlogback.configurationFile=file:\/etc\/marathon\/logback.xml"$/)
                         .with_content(/^JAVA_HOME="\/opt\/some\/java\/home"$/)
                         .with_content(/^export foo="bar"$/)
                         .with_content(/^export f00="b4r"$/)
            end

            it 'does not configure systemd' do
              should_not contain_file('/etc/sysconfig/marathon')
            end

          when /RedHat/

            it 'does not configure sysvinit' do
              should contain_file('/etc/default/marathon')
                         .with_ensure('absent')
            end

            it 'configures systemd' do
              should contain_file('/etc/sysconfig/marathon')
                         .with_content(/^JAVA_OPTS=-Xmx1024m -Dlogback.configurationFile=file:\/etc\/marathon\/logback.xml$/)
                         .with_content(/^JAVA_HOME=\/opt\/some\/java\/home$/)
                         .with_content(/^foo=bar$/)
                         .with_content(/^f00=b4r$/)

              should contain_file('/etc/systemd/system/marathon.service')
                         .with_content(/^LimitNOFILE=9001$/)
              should contain_exec('systemctl-daemon-reload_marathon')
            end

          else
            it 'is an unsupported OS' do
              fail("#{facts[:osfamily]} is unsupported")
            end
        end
      end

      context 'syslog' do
        describe 'when syslog is true' do
          let(:params) { { :syslog => true } }
          it do
            is_expected.to contain_file('/etc/marathon/conf/?no-logger').with({
              'ensure' => 'absent',
            })
          end
        end

        describe 'when syslog is false' do
          let(:params) { { :syslog => false } }
          it do
            is_expected.to contain_file('/etc/marathon/conf/?no-logger').with({
              'ensure' => 'present',
            })
          end
        end
      end
    end
  end
end
