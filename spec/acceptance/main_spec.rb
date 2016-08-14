require 'spec_helper_acceptance'

describe 'puppet::main::settings' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        puppet::main::setting { 'environment':
          value => 'spec'
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file '/etc/puppet/puppet.conf' do
      it { is_expected.to be_file }
      its(:content) { should contain /spec/ }
    end

  end
end

