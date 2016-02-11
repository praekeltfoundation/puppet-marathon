require 'spec_helper'

describe 'marathon::repo' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile }

      describe 'with default options' do
        it do
          is_expected.to contain_class('mesos::repo').with_source('mesosphere')
        end
      end

      describe 'when manage is false' do
        let(:params) { {:manage => false} }
        it { is_expected.not_to contain_class('mesos::repo') }
      end
    end
  end
end
