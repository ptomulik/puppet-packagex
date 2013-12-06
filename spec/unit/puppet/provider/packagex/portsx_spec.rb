#! /usr/bin/env ruby
require 'spec_helper'

require 'puppet/util/ptomulik/packagex/portsx/port_record'
require 'puppet/util/ptomulik/packagex/portsx/pkg_record'
require 'puppet/util/ptomulik/packagex/portsx/options'

provider_class = Puppet::Type.type(:packagex).provider(:portsx)

describe provider_class do

  pkgrecord_class = Puppet::Util::PTomulik::Packagex::Portsx::PkgRecord
  portrecord_class = Puppet::Util::PTomulik::Packagex::Portsx::PortRecord
  options_class = Puppet::Util::PTomulik::Packagex::Portsx::Options


  before :each do
    # Create a mock resource
    @resource = stub 'resource'

    # A catch all; no parameters set
    @resource.stubs(:[]).returns(nil)

    # But set name and source
    @resource.stubs(:[]).with(:name).returns   "mypackage"
    @resource.stubs(:[]).with(:ensure).returns :installed

    @provider = provider_class.new
    @provider.resource = @resource
    @provider.class.stubs(:portorigin).with('mypackage').returns('origin/mypackage')
  end

  it "should have an install method" do
    @provider = provider_class.new
    @provider.should respond_to(:install)
  end

  it "should have a reinstall method" do
    @provider = provider_class.new
    @provider.should respond_to(:reinstall)
  end

  it "should have an update method" do
    @provider = provider_class.new
    @provider.should respond_to(:update)
  end

  it "should have an uninstall method" do
    @provider = provider_class.new
    @provider.should respond_to(:uninstall)
  end

  it "should have a build_options_validate method" do
    @provider = provider_class.new
    @provider.should respond_to(:build_options_validate)
  end

  it "should have a build_options_munge method" do
    @provider = provider_class.new
    @provider.should respond_to(:build_options_munge)
  end

  it "should have a build_options_insync? method" do
    @provider = provider_class.new
    @provider.should respond_to(:build_options_insync?)
  end

  it "should have a build_options_should_to_s method" do
    @provider = provider_class.new
    @provider.should respond_to(:build_options_should_to_s)
  end

  it "should have a build_options_is_to_s method" do
    @provider = provider_class.new
    @provider.should respond_to(:build_options_is_to_s)
  end

  it "should have a build_options method" do
    @provider = provider_class.new
    @provider.should respond_to(:build_options)
  end

  it "should have a build_options= method" do
    @provider = provider_class.new
    @provider.should respond_to(:build_options=)
  end

  it "should have an install_options method" do
    @provider = provider_class.new
    @provider.should respond_to(:install_options)
  end

  it "should have a reinstall_options method" do
    @provider = provider_class.new
    @provider.should respond_to(:reinstall_options)
  end

  it "should have an upgrade_options method" do
    @provider = provider_class.new
    @provider.should respond_to(:upgrade_options)
  end

  it "should have an uninstall_options method" do
    @provider = provider_class.new
    @provider.should respond_to(:uninstall_options)
  end

  it "should have a latest method" do
    @provider = provider_class.new
    @provider.should respond_to(:latest)
  end

  describe "::instances" do
    [
      # 1.
      [
        [
          [ portrecord_class[{
            :pkgname => 'apache22-2.2.26',
            :portname => 'apache22',
            :portorigin => 'www/apache22',
            :pkgversion => '2.2.26',
            :portstatus => '=',
            :portinfo => 'up-to-date with port',
            :options => options_class[ { :SUEXEC => true } ],
            :options_file => '/var/db/ports/www_apache22/options.local',
            :options_files => [
              '/var/db/ports/apache22/options',
              '/var/db/ports/apache22/options.local',
              '/var/db/ports/www_apache22/options',
              '/var/db/ports/www_apache22/options.local'
            ]
          }]],
          [portrecord_class[{
            :pkgname => 'ruby-1.9.3.484,1',
            :portname => 'ruby',
            :portorigin => 'lang/ruby19',
            :pkgversion => '1.9.3.484,1',
            :portstatus => '=',
            :portinfo => 'up-to-date with port',
            :options => options_class[ ],
            :options_file => '/var/db/ports/lang_ruby19/options.local',
            :options_files => [
              '/var/db/ports/ruby/options',
              '/var/db/ports/ruby/options.local',
              '/var/db/ports/lang_ruby19/options',
              '/var/db/ports/lang_ruby19/options.local'
            ]
          }]]
        ],
        [
          [
            {
              :name => 'www/apache22',
              :ensure => '2.2.26',
              :build_options => options_class[ { :SUEXEC => true } ],
              :provider => :portsx
            },
            {
              :pkgname => 'apache22-2.2.26',
              :portorigin => 'www/apache22',
              :portname => 'apache22',
              :portstatus => '=',
              :portinfo => 'up-to-date with port',
              :options_file =>  '/var/db/ports/www_apache22/options.local',
              :options_files => [
                '/var/db/ports/apache22/options',
                '/var/db/ports/apache22/options.local',
                '/var/db/ports/www_apache22/options',
                '/var/db/ports/www_apache22/options.local'
              ]
            }
          ],
          [
            {
              :name => 'lang/ruby19',
              :ensure => '1.9.3.484,1',
              :build_options => options_class[ {} ],
              :provider => :portsx
            },
            {
              :pkgname => 'ruby-1.9.3.484,1',
              :portorigin => 'lang/ruby19',
              :portname => 'ruby',
              :portstatus => '=',
              :portinfo => 'up-to-date with port',
              :options_file =>  '/var/db/ports/lang_ruby19/options.local',
              :options_files => [
                '/var/db/ports/ruby/options',
                '/var/db/ports/ruby/options.local',
                '/var/db/ports/lang_ruby19/options',
                '/var/db/ports/lang_ruby19/options.local'
              ]
            }
          ]
        ]
      ]
    ].each do |records,output|
      context "with installed packages=#{records.collect{|r| r.first[:pkgname]}.inspect}" do
        let(:records) { records }
        let(:output) { output }
        before(:each) do
          described_class.stubs(:search_packages).once.with().multiple_yields(*records)
        end
        (1..records.length-1).each do |i|
          record = records[i][0]
          props, attribs = output[i]
          context "for #{record[:portorigin]}" do
            let(:props) { props }
            let(:attribs) { attribs }
            it "should find provider by pkgorigin" do
              described_class.instances.find{|inst| inst.name == record[:portorigin]}.should_not be_nil
            end
            it "provider should have correct properties" do
              prov = described_class.instances.find{|inst| inst.name == record[:portorigin]}
              prov.properties.should == props
            end
            it "provider should have correct attributes" do
              prov = described_class.instances.find{|inst| inst.name == record[:portorigin]}
              attribs.each do |key,attr|
                prov.method(key).call.should == attr
              end
            end
          end
        end
      end
    end

    # Multiple portorigins for single pkgname, in shouldn't happen but I have
    # seen such situation once.
    context "when an installed package has multiple origins" do
      let(:records) {[
        [pkgrecord_class[{
          :pkgname => 'ruby-1.9.3.484,1',
          :portname => 'ruby',
          :portorigin => 'lang/ruby19',
          :pkgversion => '1.9.3.484,1',
          :portstatus => '=',
          :portinfo => 'up-to-date with port',
          :options => options_class[ ],
          :options_file => '/var/db/ports/lang_ruby19/options.local',
          :options_files => [
            '/var/db/ports/ruby/options',
            '/var/db/ports/ruby/options.local',
            '/var/db/ports/lang_ruby19/options',
            '/var/db/ports/lang_ruby19/options.local'
          ]
        }]],
        [ pkgrecord_class[{
          :pkgname => 'ruby-1.9.3.484,1',
          :portname => 'ruby',
          :portorigin => 'lang/ruby20',
          :pkgversion => '1.9.3.484,1',
          :portstatus => '=',
          :portinfo => 'up-to-date with port',
          :options => options_class[ ],
          :options_file => '/var/db/ports/lang_ruby20/options.local',
          :options_files => [
            '/var/db/ports/ruby/options',
            '/var/db/ports/ruby/options.local',
            '/var/db/ports/lang_ruby20/options',
            '/var/db/ports/lang_ruby20/options.local'
          ]
        }]]
      ] }
      it "prints warning but does not raises an error" do
        described_class.stubs(:search_packages).once.with().multiple_yields(*records)
        described_class.stubs(:warning).once.with(
          "Found 2 installed ports named 'ruby-1.9.3.484,1': 'lang/ruby19', " +
          "'lang/ruby20'. Only 'lang/ruby20' will be processed."
        )
        expect { described_class.instances }.to_not raise_error
      end
    end

    # No ports for an installed package.
    context "when an installed package has multiple origins" do
      let(:records) {[
        [pkgrecord_class[{
          :pkgname => 'ruby-1.8.7.123,1',
          :portname => 'ruby',
          :pkgversion => '1.8.7.123,1',
          :portstatus => '?',
          :portinfo => 'anything',
          :options => options_class[ ]
        }]],
      ] }
      it "prints warning but does not raise an error" do
        described_class.stubs(:search_packages).once.with().multiple_yields(*records)
        described_class.stubs(:warning).once.with(
          "Could not find port for installed package 'ruby-1.8.7.123,1'." +
          "Build options will not work for this package."
        )
        expect { described_class.instances }.to_not raise_error
      end
    end
  end

  describe "::prefetch(packages)" do
    [
      # 1.
      [
        [ # instances
          [
            {:name => 'www/apache22', :ensure => :present},
            {
              :pkgname => 'apache22-2.2.26', :portorigin => 'www/apache22',
              :portname => 'apache22', :portstatus => '=',
              :portinfo => 'up-to-date with port',
              :options_file => '/var/db/ports/www_apache22/options.local',
              :options_files => [
                '/var/db/ports/apache22/options',
                '/var/db/ports/apache22/options.local',
                '/var/db/ports/www_apache22/options',
                '/var/db/ports/www_apache22/options.local'
              ]
            }
          ],
          [
            {:name => 'lang/ruby19', :ensure => :present},
            {
              :pkgname => 'ruby-1.9.3', :portorigin => 'lang/ruby19',
              :portname => 'ruby', :portstatus => '=',
              :portinfo => 'up-to-date with port',
              :options_file => '/var/db/ports/lang_ruby19/options.local',
              :options_files => [
                '/var/db/ports/ruby/options',
                '/var/db/ports/ruby/options.local',
                '/var/db/ports/lang_ruby19/options',
                '/var/db/ports/lang_ruby19/options.local'
              ]
            }
          ]
        ],
        { # packages
          'ruby' => Puppet::Type.type(:packagex).new({
            :name => 'ruby',:ensure=>'present'
          }),
          'mysql55-client' => Puppet::Type.type(:packagex).new({
            :name => 'mysql55-client',:ensure=>'present'
          })
        },
        [ # ports
          [
            'mysql55-client',
            portrecord_class[{
              :pkgname => 'mysql55-client-5.5.3',
              :portname => 'mysql55-client',
              :portorigin => 'databases/mysql55-client',
              :options_file => '/var/db/ports/lang_ruby20/options.local',
              :options_files => [
                '/var/db/ports/ruby/options',
                '/var/db/ports/ruby/options.local',
                '/var/db/ports/lang_ruby20/options',
                '/var/db/ports/lang_ruby20/options.local'
              ]
            }]
          ]
        ]
      ],
    ].each do |instances,packages,ports|
      inst_names = instances.map{|data| data.first[:name]}.join(", ")
      pkg_names = packages.map{|key,pkg| key}.join(", ")
      newpkgs = packages.keys
      providers = []
      instances.each do |props, attribs|
        prov = described_class.new(props)
        prov.assign_port_attributes(attribs)
        if pkg = (packages[prov.name] || packages[prov.portorigin] ||
                   packages[prov.pkgname] || packages[prov.portname])
          newpkgs -= [prov.name,prov.portorigin, prov.pkgname, prov.portname]
          pkg.provider = prov
        end
        providers << prov
      end
      newpkgs.each do |key|
        pkg = packages[key]
        pkg.provider = described_class.new(:name => name, :ensure => :absent)
      end
      context "with installed: #{inst_names}, manifested: #{pkg_names}" do
        let(:packages) { packages }
        let(:providers) { providers }
        let(:newpkgs) { newpkgs }
        before(:each) do
          described_class.stubs(:instances).once.returns(providers)
          described_class.stubs(:search_ports).once.with(newpkgs).multiple_yields(*ports)
        end
        it do
          expect { described_class.prefetch(packages) }.to_not raise_error
        end
      end
    end
  end

  describe "uninitialized attributes" do
    [
      :pkgname,
      :portorigin,
      :portname,
      :portstatus,
      :portinfo,
      :options_file,
      :options_files
    ].each do |attr|
      context "#{attr}" do
        let(:attr) { attr }
        before(:each) { subject.stubs(:name).returns 'bar/foo' }
        it do
          expect { subject.method(attr).call }.to raise_error Puppet::Error,
            "Attribute '#{attr}' not assigned for package 'bar/foo'."
        end
      end
    end
  end

  describe "#build_options_validate(opts)" do
    [
      [ 123, ArgumentError, "123 of type Fixnum is not an options Hash (for $build_options)"],
      [ { :FOO => true }, nil, nil ],
      [ { 76 => false }, ArgumentError, "76 is not a valid option name (for $build_options)" ],
      [ { :FOO => 123}, ArgumentError, "123 is not a valid option value (for $build_options)" ],
    ].each do |opts,err,msg|
      context "#build_options_validate(#{opts.inspect})" do
        let(:opts) { opts }
        let(:err) { err }
        let(:msg) { msg }
        it do
          if err
            expect { subject.build_options_validate(opts) }.to raise_error err, msg
          else
            expect { subject.build_options_validate(opts) }.to_not raise_error
          end
        end
      end
    end
  end

  describe "#build_options_munge(opts)" do
    [
      { :FOO => true },
      options_class[{ :FOO => true }],
    ].each do |opts|
      context "#build_options_munge(#{opts.inspect})" do
        let(:opts) { opts }
        it do
          subject.build_options_munge(opts).should == options_class[opts]
        end
      end
    end
  end

  describe "#build_options_insync?(should,is)" do
    [
      [
        options_class[{:FOO => true}],
        options_class[{:FOO => true}],
        true
      ],
      [
        options_class[{:FOO => true}],
        options_class[{:FOO => false}],
        false
      ],
      [
        options_class[{}],
        options_class[{:FOO => false}],
        true
      ],
      [
        options_class[{:FOO => true}],
        options_class[{:BAR => false}],
        false
      ],
      [
        options_class[{:FOO => true}],
        options_class[{:BAR => false, :FOO => true}],
        true
      ],
      [
        Hash[{:FOO => true}],
        options_class[{:FOO => true}],
        false
      ],
      [
        options_class[{:FOO => true}],
        Hash[{:FOO => true}],
        false
      ]
    ].each do |should,is,result|
      let(:should) { should }
      let(:is) { is }
      let(:result) { result }
      context "#build_options_insync?(#{should.inspect}, #{is.inspect})" do
        it { subject.build_options_insync?(should,is).should == result}
      end
    end
  end

  describe "#build_options_should_to_s(should, newvalue)" do
    [
      [{},options_class[{:FOO => true}]],
      [{},{:FOO => true}]
    ].each do |should,newvalue|
      let(:should) { should }
      let(:newvalue) { newvalue }
      let(:result) { newvalue.is_a?(options_class) ? options_class[newvalue.sort].inspect : newvalue.inspect }
      context "#build_options_should_to_s(#{should.inspect}, #{newvalue.inspect})" do
        it { subject.build_options_should_to_s(should,newvalue).should == result}
      end
    end
  end

  describe "#build_options_is_to_s(should, currvalue)" do
    [
      [{},{},"{}"],
      [options_class[{}],options_class[{:FOO => true}], "{}"],
      [options_class[{:FOO => true}],options_class[{}], "{}"],
      [options_class[{:FOO => true,:BAR => false}],options_class[{:BAR => true}],
       options_class[{:BAR=>true}].inspect],
    ].each do |should,currvalue,result|
      let(:should) { should }
      let(:currvalue) { currvalue }
      let(:result) { result }
      context "#build_options_is_to_s(#{should.inspect}, #{currvalue.inspect})" do
        it { subject.build_options_is_to_s(should,currvalue).should == result}
      end
    end
  end

  describe "#build_options" do
    it do
      subject.stubs(:properties).once.returns({:build_options => options_class[{}]})
      subject.build_options.should == options_class[{}]
    end
  end

  describe "#build_options=(opts)" do
    it do
      subject.stubs(:reinstall).once.with(options_class[{:FOO => true}])
      expect { subject.build_options=options_class[{:FOO => true}] }.to_not raise_error
    end
  end

  describe "#install_options" do
    it do
      subject.stubs(:resource).once.returns({:install_options => %w{-x}})
      subject.install_options.should == %w{-N -x}
    end
  end

  describe "#reinstall_options" do
    it do
      subject.stubs(:resource).once.returns({:install_options => %w{-x}})
      subject.reinstall_options.should == %w{-f -x}
    end
  end

  describe "#upgrade_options" do
    it do
      subject.stubs(:resource).once.returns({:install_options => ['-x','-M',{:BATCH=>'yes'}]})
      subject.upgrade_options.should == %w{-x -M BATCH=yes}
    end
  end

  describe "#uninstall_options" do
    it do
      subject.stubs(:resource).once.returns({:uninstall_options => %w{-x}})
      subject.uninstall_options.should == %w{-x}
    end
  end

  describe "when installing" do
    context "and portupgrade is supposed to succeed" do
      before :each do
        ops =  options_class[{:FOO => true}]
        ops.stubs(:save).once.with('/var/db/ports/bar_foo/options.local', {:pkgname => 'foo-1.2.3'})
        subject.stubs(:properties).returns({:build_options => options_class[{:FOO => false}]})
        subject.stubs(:resource).returns({:name => 'bar/foo', :build_options => ops})
        subject.stubs(:options_file).returns('/var/db/ports/bar_foo/options.local')
        subject.stubs(:pkgname).returns('foo-1.2.3')
        subject.stubs(:portupgrade).once.with(*%w{-N -M BATCH=yes bar/foo})
      end

      it "should use 'portupgrade -N -M BATCH=yes bar/foo'" do
        expect { subject.install }.to_not raise_error
      end
    end

    context "and portupgrade fails" do
      it "should revert options and reraise" do
        opts1 = options_class[{:FOO=>true}]
        opts2 = options_class[{:FOO=>false}]
        opts1.stubs(:save).once.with('/var/db/ports/bar_foo/options.local', {:pkgname => 'foo-2.4.5'})
        opts2.stubs(:save).once.with('/var/db/ports/bar_foo/options.local', {:pkgname => 'foo-2.4.5'})
        subject.stubs(:pkgname).returns('foo-2.4.5')
        subject.stubs(:properties).returns({:build_options => opts1})
        subject.stubs(:resource).returns({:build_options => opts2})
        subject.stubs(:options_file).returns('/var/db/ports/bar_foo/options.local')
        subject.stubs(:portupgrade).raises RuntimeError, "go and revert options!"
        expect { subject.install }.to raise_error RuntimeError, "go and revert options!"
      end
    end
    context "and there is no such package" do
      it "should revert options and raise exception" do
        opts1 = options_class[{:FOO=>true}]
        opts2 = options_class[{:FOO=>false}]
        opts1.stubs(:save).once.with('/var/db/ports/bar_foo/options.local', {:pkgname => 'foo-2.4.5'})
        opts2.stubs(:save).once.with('/var/db/ports/bar_foo/options.local', {:pkgname => 'foo-2.4.5'})
        subject.stubs(:pkgname).returns('foo-2.4.5')
        subject.stubs(:properties).returns({:build_options => opts1})
        subject.stubs(:resource).returns({:name=>'bar/foo', :build_options => opts2})
        subject.stubs(:options_file).returns('/var/db/ports/bar_foo/options.local')
        subject.stubs(:portupgrade).returns("** No such package: bar/foo")
        expect { subject.install }.to raise_error Puppet::ExecutionFailure, "Could not find package bar/foo"
      end
    end
  end

  describe "when reinstalling" do
    it "should call do_potupgrade portorigin, reinstall_options, options" do
      subject.stubs(:portorigin).returns 'port/origin'
      subject.stubs(:reinstall_options).returns %w{-r -o}
      subject.stubs(:do_portupgrade).once.with('port/origin', %w{-r -o}, {})
      expect { subject.reinstall({}) }.to_not raise_error
    end
  end

  describe "when upgrading" do
    context "not an installed package" do
      it "should call install" do
        subject.stubs(:properties).returns({:ensure => :absent})
        subject.stubs(:do_portupgrade).never
        subject.stubs(:install).once
        expect { subject.update }.to_not raise_error
      end
    end
    context "an installed package" do
      it "should call do_potupgrade portorigin, reinstall_options, options" do
        subject.stubs(:properties).returns({:ensure => :present})
        subject.stubs(:resource).returns({:build_options=>{}})
        subject.stubs(:portorigin).returns('bar/foo')
        subject.stubs(:upgrade_options).returns(%w{-R -M BATCH=yes})
        subject.stubs(:do_portupgrade).once.with('bar/foo', %w{-R -M BATCH=yes},{})
        subject.stubs(:install).never
        expect { subject.update }.to_not raise_error
      end
    end
  end

  describe "when uninstalling" do
    it do
      subject.stubs(:pkgname).returns('foo-1.2.3')
      subject.stubs(:uninstall_options).returns(%w{-x})
      subject.stubs(:portuninstall).with(*%w{-x foo-1.2.3})
      expect { subject.uninstall }.to_not raise_error
    end
  end


  describe "#latest" do
    [
      ['1.2.3', '=', 'up-to-date-with-port', '1.2.3', nil],
      ['1.2.3', '>', 'up-to-date-with-port', '1.2.3', nil],
      ['1.2.3', '<', 'needs updating (port has 2.4.5)', '2.4.5', nil],
      ['1.2.3', '?', '', :latest, "The installed package foo-1.2.3 does not appear in the ports database nor does its port directory exist."],
      ['1.2.3', '!', '', :latest, "The installed package foo-1.2.3 does not appear in the ports database, the port directory actually exists, but the latest version number cannot be obtained."],
      ['1.2.3', '#', '', :latest, "The installed package foo-1.2.3 does not have an origin recorded."],
      ['1.2.3', '&', '', :latest, "Invalid status flag '&' for package foo-1.2.3 (returned by portversion command)."],
    ].each do |oldver,status,info,result,warn|
      context "{:ensure => #{oldver.inspect}, :portstatus => #{status.inspect}, :portinfo => #{info.inspect}" do
        let(:oldver) { oldver }
        let(:status) { status }
        let(:info) { info }
        let(:warn) { warn }
        it do
          subject.stubs(:pkgname).returns 'foo-1.2.3'
          subject.stubs(:portstatus).returns status
          subject.stubs(:properties).returns({:ensure => oldver})
          subject.stubs(:portinfo).returns info
          if warn
            subject.stubs(:warning).once.with(warn)
          end
          subject.latest.should == result
        end
      end
      context "{:ensure=>'1.2.3', :portstatus=>'<', :portinfo=>'xyz'}" do
        it do
          subject.stubs(:portstatus).returns('<')
          subject.stubs(:portinfo).returns('xyz')
          subject.stubs(:properties).returns({:ensure => '1.2.3'})
          expect { subject.latest }.to raise_error Puppet::Error, "Could not match version info 'xyz'"
        end
      end
    end
  end

  describe "#query" do
    [
      [
        { :name => 'bar/foo', :ensure=>:absent },
        [
          {
            :name => 'geez/noop',
            :ensure=>'1.2.3',
            :portorigin => 'geez/foo',
            :pkgname => 'foo-1.2.3',
            :portname => 'foo'
          },
          {
            :name => 'ding/dong',
            :ensure=>'4.5.6',
            :portorigin => 'ding/dong',
            :pkgname => 'dong-4.5.6',
            :portname => 'dong'
          },
        ],
        nil
      ],
      [
        { :name => 'bar/foo', :ensure=>:absent },
        [
          {
            :name => 'geez/noop',
            :ensure=>'1.2.3',
            :portorigin => 'geez/foo',
            :pkgname => 'foo-1.2.3',
            :portname => 'foo'
          },
          {
            :name => 'gadong',
            :ensure=>'4.5.6',
            :portorigin => 'bar/foo',
            :pkgname => 'foo-4.5.6',
            :portname => 'foo'
          },
        ],
        1
      ],
    ].each do |me,others,result|
      subject { described_class.new(me) }
      let(:me) { me }
      let(:others) { others }
      let(:result) { result }
      it do
        instances = []
        others.each do |o|
          inst = described_class.new({:name => o[:name], :ensure => o[:ensure]})
          o.delete(:name)
          o.delete(:ensure)
          inst.assign_port_attributes(o)
          instances << inst
        end
        result = instances[result].properties if result
        described_class.stubs(:instances).returns instances
        subject.query.should == result
      end
    end
  end

end