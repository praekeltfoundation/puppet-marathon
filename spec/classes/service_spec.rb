require 'spec_helper'

describe 'marathon::service' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile }

      describe 'with default options' do
        it do
          is_expected.to contain_service('marathon')
            .with_ensure('running')
            .with_enable(true)
            .with_hasrestart(true)
            .with_hasstatus(true)
        end
      end

      describe 'when manage is false' do
        let(:params) { {:manage => false} }
        it { is_expected.not_to contain_service('marathon') }
      end

      describe 'when ensure is stopped' do
        let(:params) { {:ensure => 'stopped'} }
        it { is_expected.to contain_service('marathon').with_ensure('stopped') }
      end
    end
  end
end
