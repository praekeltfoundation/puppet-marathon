require 'spec_helper'

describe 'marathon::repo' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should compile }
    end
  end
end
