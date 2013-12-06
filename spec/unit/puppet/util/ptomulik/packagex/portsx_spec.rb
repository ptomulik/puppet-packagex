#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util/ptomulik/packagex/portsx'
require 'puppet/util/ptomulik/packagex/portsx/functions'
require 'puppet/util/ptomulik/packagex/portsx/port_search'
require 'puppet/util/ptomulik/packagex/portsx/pkg_search'

describe Puppet::Util::PTomulik::Packagex::Portsx do
  it do 
    described_class.should include Puppet::Util::PTomulik::Packagex::Portsx::PortSearch
  end
  it do 
    described_class.should include Puppet::Util::PTomulik::Packagex::Portsx::PkgSearch
  end
end
