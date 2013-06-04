#!/usr/bin/env rspec

require 'spec_helper'

describe "puppet::master::setting" do
  let (:title) { 'reports' }

  context "with ensure => 'installed'" do
    let (:params) { { :ensure => 'installed' } }

    it { expect { subject }.to raise_error(
      Puppet::Error, /parameter ensure must be present or absent/
    )}
  end

  context "with ensure => 'absent'" do
    let (:params) { { :ensure => 'absent' } }

    it do
      should contain_augeas('puppet::master::reports').with({
        :incl    => '/etc/puppet/puppet.conf',
        :lens    => 'Puppet.lns',
        :context => '/files/etc/puppet/puppet.conf/master',
        :changes => 'rm reports',
        :onlyif  => 'match reports size > 0',
      })
    end

    context "and value => true" do
      let (:params) { { :ensure => 'absent', :value => 'true' } }

      it do
        should contain_augeas('puppet::master::reports').with({
          :incl    => '/etc/puppet/puppet.conf',
          :lens    => 'Puppet.lns',
          :context => '/files/etc/puppet/puppet.conf/master',
          :changes => 'rm reports',
          :onlyif  => 'match reports size > 0',
        })
      end
    end
  end

  context "without required parameters" do
    let (:params) { {} }

    it { expect { subject }.to raise_error(
      Puppet::Error, /required parameter value must be a non-empty string/
    )}
  end

  context "with value => ''" do
    let (:params) { { :value => '' } }

    it { expect { subject }.to raise_error(
      Puppet::Error, /required parameter value must be a non-empty string/
    )}
  end

  context "with value => false" do
    let (:params) { { :value => false } }

    it { expect { subject }.to raise_error(
      Puppet::Error, /required parameter value must be a non-empty string/
    )}
  end

  context "with value => 'tagmail'" do
    let (:params) { { :value => 'tagmail' } }

    it do
      should contain_augeas('puppet::master::reports').with({
        :incl    => '/etc/puppet/puppet.conf',
        :lens    => 'Puppet.lns',
        :context => '/files/etc/puppet/puppet.conf/master',
        :changes => 'set reports tagmail',
        :onlyif  => 'match reports[. = tagmail] size == 0',
      })
    end

    context "and ensure => 'present'" do
      let (:params) { { :ensure => 'present', :value => 'tagmail' } }

      it do
        should contain_augeas('puppet::master::reports').with({
          :incl    => '/etc/puppet/puppet.conf',
          :lens    => 'Puppet.lns',
          :context => '/files/etc/puppet/puppet.conf/master',
          :changes => 'set reports tagmail',
          :onlyif  => 'match reports[. = tagmail] size == 0',
        })
      end
    end
  end
end
