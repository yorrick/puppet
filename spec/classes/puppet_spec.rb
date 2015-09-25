#!/usr/bin/env rspec

require 'spec_helper'

describe 'puppet' do
  it { should contain_class 'puppet' }
end
