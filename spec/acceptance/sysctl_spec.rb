require 'spec_helper_acceptance'

describe 'sysctl' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include ::sysctl
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file '/etc/sysctl.conf' do
      it { is_expected.to be_file }
    end

  end
end

