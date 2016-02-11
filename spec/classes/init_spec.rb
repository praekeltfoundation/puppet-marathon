require 'spec_helper'

describe 'marathon' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should compile }

      it 'should restart the service when upgrading the package' do
        is_expected.to contain_package('marathon')
          .with_notify('Class[Marathon::Service]')
      end
    end
  end
end
