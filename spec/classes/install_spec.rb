require 'spec_helper'

describe 'marathon::install' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile }

      describe 'with default options' do
        it do
          is_expected.to contain_package('marathon').with_ensure('installed')
        end
      end

      describe 'when ensure is purged' do
        let(:params) { {:ensure => 'purged'} }
        it do
          is_expected.to contain_package('marathon').with_ensure('purged')
        end
      end
    end
  end
end
