# ptomulik-packagex

[![Build Status](https://travis-ci.org/ptomulik/puppet-packagex.png?branch=master)](https://travis-ci.org/ptomulik/puppet-packagex)
[![Coverage Status](https://coveralls.io/repos/ptomulik/puppet-packagex/badge.png?branch=master)](https://coveralls.io/r/ptomulik/puppet-packagex?branch=master)
[![Code Climate](https://codeclimate.com/github/ptomulik/puppet-packagex.png)](https://codeclimate.com/github/ptomulik/puppet-packagex)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What packagex affects](#what-packagex-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with packagex](#beginning-with-packagex)
4. [Usage](#usage)
5. [Resolved issues](#resolved-issues)
6. [Known incompatibilities](#known-incompatibilities)
7. [Limitations](#limitations)
8. [Development](#development)

## Overview

This is an enhanced version of puppet *package* resource and some of its
providers.

This is a place, where I develop and test my extended version of puppet
*package* resource with enhanced providers. The releases found at
https://forge.puppetlabs.com/ptomulik/packagex are known to be functional and
may be used with recent versions of puppet (3.2 and later). Currently I've
developed *portsx* provider, which is an enhanced and bug-fixed version of
puppet's *ports* provider.

## Module Description

The module re-implements puppet package resource adding some crucial features
to it and its providers. Currently new features include:

  * *build_options* - a property (ensurable) that allows defining additional
    options for package.
  * *portsx* provider - enhanced package provider for FreeBSD ports collection.
    It provides following new features and bug-fixes:
    * *install_options* - extra CLI flags passed to *portupgrade* when
      installing, reinstalling and upgrading packages,
    * *uninstall_options* - extra CLI flags passed to *pkg_deinstall* when
      uninstalling packages,
    * *build_options* - configuration options for package,
    * *portorigin*s (instead of *portname*s) are used to identify package instances,
    * it's upgradeable (tested, the original puppet provider declared that it's
      upgradeable, but it never worked for me),
    * *portversion* is used to find installed packages (instead of *pkg_info*),
    * *make search* is used to find uninstalled ports listed in puppet manifests,
    * unable to uninstall package due to dependency problems - this problem may
      be easily mitigated now by using appropriate *uninstall_options*
    * added unit tests (original provider was totally untested),

The *build_options* are independent of the well known *install_options* and
*uninstall_options*. The definition of *build_options* is generally
provider-specific. Whereas *install_options* and *uninstall_options* are just
parameters (not ensurable), the *build_options* is a fully featured property,
that is the options may be ensured on a package. For *portsx* provider this is
simply an `{OPTION => value}` hash, with boolean values. The *build_options*
were added especially to allow *portsx* provider (FreeBSD ports) to
define/ensure port options when installing and managing FreeBSD packages. Of
course, the same concept may be reused by other providers, if necessary.

The *portsx* provider ensures that package is compiled with these
*build_options*. Normally you would set build options with `make config` using
ncurses-based frontend. Here, you can define *build_options* in your puppet
manifest. If a package is already installed and you change its *build_options*
in manifest file, the package gets rebuilt with new options and reinstalled.

Instead of *portname*s, *portorigin*s are used to identify *portsx* instances
(see [FreeBSD ports collection and it's
terminology](#freebsd-ports-collection-and-its-terminology)). This copes with
several problems caused by portnames' ambiguity (see [FreeBSD ports collection
and ambiguity of
portnames](#freebsd-ports-collection-and-ambiguity-of-portnames)). You can now
install and mainain ports that have common *portname* (but different
portorigins). Examples of such packages include *mysql-client* or *ruby* (see
below).

The [*portversion*](http://www.freebsd.org/cgi/man.cgi?query=portversion&manpath=ports&sektion=1)
utility is used to find installed ports. It's better than using
[*pkg_info*](http://www.freebsd.org/cgi/man.cgi?query=pkg_info&sektion=1) for
several reasons. First, it is said to be faster, because it uses compiled
version of ports INDEX file. Second, it works with both kinds of package
databases - with the old *pkg* database and the new
[*pkgng*](http://www.freebsd.org/doc/handbook/pkgng-intro.html) database,
providing seamless interface to any of them. Third, it provides package names
and their "out-of-date" statuses in a single call, so we don't need to
separatelly check out-of-date status for installed packages. While this version
of *portsx* is not yet ready to work with *pkgng*, using *portversion* is a big
step towards *pkgng* world.

#### FreeBSD ports collection and its terminology

We use the following terminology when referring ports/packages:

  * a string in form `'apache22'` or `'ruby'` is referred to as *portname*
  * a string in form `'apache22-2.2.25'` or `'ruby-1.8.7.371,1'` is referred to
    as a *pkgname*
  * a string in form `'www/apache22'` or `'lang/ruby18'` is referred to as a
    port *origin* or *portorigin*

See [http://www.freebsd.org/doc/en/books/porters-handbook/makefile-naming.html](http://www.freebsd.org/doc/en/books/porters-handbook/makefile-naming.html)

Port *origins* are used as primary identifiers for *portsx* instances. It's recommended to use *portorigins* instead of *portnames* as package names in manifest files.

#### FreeBSD ports collection and ambiguity of portnames

Using *portnames* (e.g. `apache22`) as package names in manifests is allowed.
The *portname*s, however, are ambiguous, meaning that port search may find
multiple ports matching the given *portname*. For example `'mysql-client'`
package has three ports at the time of this writing  (2013-11-30):
`mysql-client-5.1.71`, `mysql-client-5.5.33`, and `mysql-client-5.6.13` with
origins `databases/mysql51-client`, `databases/mysql55-client` and
`databases/mysql56-client` respectively. If none of these ports are installed
and you use this ambiguous *portname* in your manifest, you'll se the following
warning:

```console
Warning: Puppet::Type::Packagex::ProviderPortsx: Found 3 ports named 'mysql-client': 'databases/mysql51-client', 'databases/mysql55-client', 'databases/mysql56-client'. Only 'databases/mysql56-client' will be ensured.
```

## Setup

### What packagex affects

* installs, upgrades, reinstalls and uninstalls packages,
* modifies FreeBSD ports options' files `/var/db/ports/*/options.local`,

### Setup Requirements

You may need to enable **pluginsync** in your `puppet.conf`.

### Beginning with packagex

Its usage is essentially same as for the original *package* resource. Here I
just put some examples specific to new features/providers.

#### Example 1 - using build options on FreeBSD

Using `build_options` on FreeBSD (with *portsx* provider):

```puppet
packagex { 'www/apache22': 
  build_options => {'SUEXEC' => true}
}
```

#### Example 2 - using *uninstall_options* to cope with dependency problems

Sometimes freebsd refuses to uninstall a package due to dependency problems
that would appear after deinstallation. In such situations we may use the
`uninstall_options` to instruct the provider to (for example) uninstall also
all packages that depend on the package being uninstalled. When using ports
with old *pkg* package manager (the other is *pkgng* not covered here), one
would write in its manifest:

```puppet
packagex { 'www/apache22':
  ensure => absent,
  uninstall_options => ['-r'] 
}
```

#### Example 3 - using *install_options*

The new *portsx* provider implements *install_options* feature. The flags
provided via *install_options* are passed to `portupgrade` command when
installing, reinstalling or upgrading packages. With no *install_options*
provided, sensible defaults are selected by *portsx* provider.

Let's say we want to install precompiled package, if available (`-P` flag).
Write the following manifest:

```puppet
packagex { 'www/apache22':
  ensure => present,
  install_options => ['-P', '-M', {'BATCH' => 'yes'}]
}
```

Now, if we run puppet, we'll see the command:

```console
~ # puppet agent -t --debug --trace
...
Debug: Executing '/usr/local/sbin/portupgrade -N -P -M BATCH=yes www/apache22'
...
```

Note, that the *portsx* provider adds some flags by its own (`-N` in the above
example).

## Usage

I think, there is nothing worth to be written in addition to
[Beginning with packagex](#beginning-with-packagex).

## Resolved issues

### FreeBSD ports provider

#### Outdated ports get installed when portorigin is used in *site.pp*

The test case is following (2013.11.30):

* package `mysql-client` is absent initially,
* there are three ports available in ports tree that share `mysql-client`
  *portname* :
  * `databases/mysql51-client` (oldest),
  * `databases/mysql55-client`, and
  * `databases/mysql55-client` (most recent),
* the *site.pp* contains: `package {'mysql-client': ensure => present}` or
  `package {'mysql-client': ensure => latest}`,

Note, that the situation with `mysql-client` has changed recently such that
`databases/mysql55-client` uses `mysql55-client` as *portname* for example, but
it was the case a little bit earlier that `mysql-client` was used by all three
ports. Shared *portname*s are still used by some other packages, however.

```console
~ # `puppet agent -t --debug --trace`
...
Debug: Executing '/usr/local/sbin/portupgrade -N -M BATCH=yes mysql-client'
...
```

after installation we have:

```console
~ # portversion -v -o mysql-client
databases/mysql51-client    =  up-to-date with port
```

which is certainly not the most recent available version.

The same case, but with new *packagex* provider yields:

```console
~ # `puppet agent -t --debug --trace`
...
Warning: Puppet::Type::Packagex::ProviderPortsx: Found 3 ports named 'mysql-client': 'databases/mysql51-client', 'databases/mysql55-client', 'databases/mysql56-client'. Only 'databases/mysql56-client' will be ensured.
Debug: Executing '/usr/local/sbin/portupgrade -N -M BATCH=yes databases/mysql56-client'
...
```

on output and afer installation we have:

```console
~ # portversion -v -o mysql-client
databases/mysql56-client    =  up-to-date with port
```

The reason for the old *ports* provider to pickup outdated port is the following. If we manually run the `portupgrade` command, we'll see:

```console
~ # /usr/local/sbin/portupgrade -N -M BATCH=yes mysql-client
--->  Found 3 ports matching 'mysql-client':
        databases/mysql51-client
        databases/mysql55-client
        databases/mysql56-client
Install 'databases/mysql51-client'? [yes]
```

The old *ports* provider simply says `y` here and installs first proposed port.

#### Package resources are not properly listed with `puppet resource package` command

The test case is following (2013.11.30):

* two ports `lang/ruby18` and `lang/ruby19` sharing common *portname* `ruby`
  are initially installed,
* `vim-lite` package is initially installed,
* some other ports are installed, especially those containing ruby gems,

Comparing length of package lists from several commands suggests that something
goes wrong with `puppet resource package` for *ports* provider:

```console
~ # portversion | wc -l
      56
~ # pkg_info | wc -l
      56
~ # puppet resource package | grep '^package {' | wc -l
      61
```

Running diff on package lists:

```console
~ # portversion -Q > /tmp/list1
~ # puppet resource package | grep package | awk -F "[ :']+" '{print $3}' > /tmp/list2
~ # diff -u /tmp/list1 /tmp/list2
--- /tmp/list1  2013-12-01 01:20:10.000000000 +0100
+++ /tmp/list2  2013-12-01 01:20:14.000000000 +0100
@@ -8,6 +8,7 @@
 automake-wrapper
 console
 bison
+bzip2-ruby
 cloc
 cmake
 cmake-modules
@@ -15,14 +16,18 @@
 db42
 dialog4ports
 dmidecode
+editors/vim-lite
 expat
 f2c
+facter
 fpp
 gdbm
 gettext
 gmake
 hello
 help2man
+hiera
+json_pure
 libexecinfo
 libffi
 libiconv
@@ -42,7 +47,7 @@
 portupgrade
 puppet
 ruby
-ruby
+ruby-augeas
 ruby19-bdb
 ruby19-date2
 ruby19-gems
```

Now investigating particular packages from the list above reveals
inconsistencies in detail:

```console
~ # puppet resource package | grep '^package {' | grep 'bzip2-ruby'
package { 'bzip2-ruby':
~ # portversion -v 'bzip2-ruby'
** No matching package found: bzip2-ruby
```

```console
~ # puppet resource package | grep '^package {' | grep 'vim-lite'
package { 'editors/vim-lite':
package { 'vim-lite':
~ # portversion -v -o vim-lite
editors/vim-lite            =  up-to-date with port
```

```console
~ # puppet resource package | grep '^package {' | grep 'facter'
package { 'facter':
package { 'rubygem-facter':
~ # portversion -v -o facter
** No matching package found: facter
~ # portversion -v -o rubygem-facter
sysutils/rubygem-facter     =  up-to-date with port
```

```console
~ # puppet resource package | grep '^package {' | grep 'hiera'
package { 'hiera':
package { 'rubygem-hiera':
~ # portversion -v hiera
** No matching package found: hiera
~ # portversion -v rubygem-hiera
rubygem-hiera-1.1.2         =  up-to-date with port
```

```console
~ # puppet resource package | grep '^package {' | grep 'json_pure'
package { 'json_pure':
package { 'rubygem-json_pure':
~ # portversion -v -o json_pure
** No matching package found: json_pure
~ # portversion -v -o rubygem-json_pure
devel/rubygem-json_pure     =  up-to-date with port
```

```console
~ # puppet resource package | grep '^package {' | grep "'ruby'"
package { 'ruby':
~ # portversion -v -o ruby
lang/ruby18                 =  up-to-date with port
lang/ruby19                 =  up-to-date with port
```

```console
~ # puppet resource package | grep '^package {' | grep 'ruby-augeas'
package { 'ruby-augeas':
package { 'rubygem-ruby-augeas':
~ # portversion -v -o ruby-augeas
** No matching package found: ruby-augeas
~ # portversion -v -o rubygem-ruby-augeas
textproc/rubygem-augeas     =  up-to-date with port
```

The same case, but with the new *portsx* provider yields:

```console
~ # portversion | wc -l
      56
~ # pkg_info | wc -l
      56
~ # puppet resource packagex | grep 'packagex {' | wc -l
      56
```

```console
~ # portversion -Q -o | sort > /tmp/list1
~ # puppet resource packagex | grep packagex | awk -F "[ :']+" '{print $3}' | sort > /tmp/list2
~ # diff -u /tmp/list1 /tmp/list2
```

that is the information from the new *portsx* provider agrees with that
obtained from operating system.

#### With `ensure => latest` packages are not upgraded

The test case is following (2013.12.1):

* `help2man-1.43.3` is initially installed,
* new version `help2man-1.43.3` is available in ports tree:

```console
~ # portversion -v help2man
help2man-1.43.3             <  needs updating (port has 1.43.3_1)
```

* we have `site.pp` with `package { 'help2man': ensure => latest}`

If we now run puppet, we'll see:

```console
~ # puppet agent -t --debug --trace
...
Debug: /Stage[main]//Node[puppet-test.mgmt.meil.pw.edu.pl]/Package[help2man]/ensure: help2man "1.43.3" is installed, latest is "1.43.3_1"
Debug: Executing '/usr/local/sbin/portupgrade -N -M BATCH=yes help2man'
Notice: /Stage[main]//Node[puppet-test.mgmt.meil.pw.edu.pl]/Package[help2man]/ensure: ensure changed '1.43.3' to '1.43.3_1'
...
...
```

However, after that the outated version of package is still installed:

```console
~ # portversion -v help2man
help2man-1.43.3             <  needs updating (port has 1.43.3_1)
```

The reason becames obvious, when we run the *portupgrade* command manually:

```console
~ # /usr/local/sbin/portupgrade -N -M BATCH=yes help2man
** Found already installed package(s) of 'misc/help2man': help2man-1.43.3
```

The `-N` flag shouldn't be here. Correct command line is:

```console
~ # /usr/local/sbin/portupgrade -R -M BATCH=yes help2man
```

and is used by the new *portsx* provider. If we use the new *portsx* provider,
the package upgrades smoothly:

```console
~ # puppet agent -t --debug --trace
...
Debug: Packagex[help2man](provider=portsx): Newer version in port
Debug: /Stage[main]//Node[puppet-test.mgmt.meil.pw.edu.pl]/Packagex[help2man]/ensure: help2man "1.43.3" is installed, latest is "1.43.3_1"
Debug: Executing '/usr/local/sbin/portupgrade -R -M BATCH=yes misc/help2man'
...
```
and after that:
```console
~ # portversion -v help2man
help2man-1.43.3_1           =  up-to-date with port
```

Note, for testing purposes, you may downgrade package with `portdowngrade`
tool.

#### The package upgrade fails if portname changes between versions

The test case is (2013.12.1):

* installed is `mysql-client-5.5.31` (`databases/mysl55-client`)
* the new version is available:

```console
~ # portversion -v mysql-client
mysql-client-5.5.31         <  needs updating (port has 5.5.34)
```

* the portname changes from `mysql-client` to `mysql55-client` between
  versions.
* the *site.pp* contains:   `package{'mysql-client': ensure => latest}`

If we run puppet, it fails to upgrade the port:

```console
~ # puppet agent -t --debug --trace
...
Debug: Executing '/usr/local/sbin/portupgrade -N -M BATCH=yes mysql-client'
Error: Could not update: Could not find package mysql-client
/usr/local/lib/ruby/site_ruby/1.9/puppet/util/errors.rb:96:in `fail'
/usr/local/lib/ruby/site_ruby/1.9/puppet/type/package.rb:93:in `rescue in block (3 levels) in <module:Puppet>'
/usr/local/lib/ruby/site_ruby/1.9/puppet/type/package.rb:90:in `block (3 levels) in <module:Puppet>'</module:Puppet></module:Puppet>
...
```

Running the *portupgrade* command manually reveals the main problem:

```console
~ # /usr/local/sbin/portupgrade -N -M BATCH=yes mysql-client
** No such package or port: mysql-client
```

The new *portsx* provider operates on *portorigins* and the upgrade runs
without problem:

```console
~ # puppet agent -t --debug --trace
...
Debug: Packagex[mysql-client](provider=portsx): Newer version in port
Debug: /Stage[main]//Node[puppet-test.mgmt.meil.pw.edu.pl]/Packagex[mysql-client]/ensure: mysql-client "5.5.31" is installed, latest is "5.5.34"
Debug: Executing '/usr/local/sbin/portupgrade -R -M BATCH=yes databases/mysql55-client'
...
```

Note, that the new *portsx* provider will fail at next transaction (the one
after successful upgrade). This is because now it's virtually impossible to
match the outdated portname `mysql-client` to existing ports once the packages
*portname* changed. The remedy is to use *portorigin*
`databases/mysql55-client` in *site.pp*. Note, that this helps only for the new
*portsx* provider (the old still doesn't work due to the `-N` flag issue).

#### Uninstall fails when there are other packages that depend on this one

The tests case is (2013.12.1):

* package `apache22-event-mpm-2.2.25` is initially installed,
* other packages that depend on it are initially installed, for example:
  * `ap22-mod_rpaf2-0.6_3`
  * `portdowngrade-1.4`
  * `subversion-1.8.3`
* the *site.pp* contains `package{'www/apache22-event-mpm': ensure => absent}`

If we invoke puppet, it runs into trouble:

```console
~ # puppet agent -t --debug --trace
...
Debug: Executing '/usr/local/sbin/pkg_deinstall www/apache22-event-mpm'
Error: Execution of '/usr/local/sbin/pkg_deinstall www/apache22-event-mpm' returned 1: --->  Deinstalling 'apache22-event-mpm-2.2.25'
pkg_delete: package 'apache22-event-mpm-2.2.25' is required by these other packages
and may not be deinstalled:
ap22-mod_rpaf2-0.6_3
portdowngrade-1.4
subversion-1.8.3
** Listing the failed packages (-:ignored / *:skipped / !:failed)
        ! apache22-event-mpm-2.2.25     (pkg_delete failed)
...
```

Now, if we use the new *portsx* provider with appropriate *uninstall_options*,
it is again able to uninstalls the package (and all the other packages that
depend on it if needed). For example, one may use `-r` flag if the old *pkg*
toolstack is used to manage packages:

```puppet
packagex { 'www/apache22-event-mpm':
           ensure => absent,
           uninstall_options => ['-r'] }
```

Then running puppet, we can easilly uninstall the package(s) recursivelly.:

```console
~ # puppet agent -t --debug --trace
...
Debug: Executing '/usr/local/sbin/pkg_deinstall -r apache22-event-mpm-2.2.25'
Notice: /Stage[main]//Node[puppet-test.mgmt.meil.pw.edu.pl]/Packagex[www/apache22-event-mpm]/ensure: removed
...
Notice: Finished catalog run in 15.09 seconds
```

Note that you may disable recursive uninstall by overwritting the
*uninstall_options* in *site.pp* i.e.  not listing `-r` in options:


## Known incompatibilities

Some design decisions caused, that there are incompatibilities w.r.t original
version of *package* resource and some of its providers.

### Known incompatibilities in *portsx*

#### Portorigins used internally to identify packages.

This may cause some troubles to scrips/manifests that depend on package names
held by the *portsx* provider. If there are some scripts, for example, which
parse the output of `puppet resource package ...`, then they may fail with new
*portsx* provider. To exemplify this, let's see the output of `puppet resource
...` for the old *ports* provider and new *portsx* provider.

For the old one we have, for example:

```console
~ # puppet resource package | grep 'package {' | grep "autoconf':"
package { 'autoconf':
```

whereas the same for the new implementation is:

```console
~ # puppet resource packagex | grep 'packagex {' | grep "autoconf':"
packagex { 'devel/autoconf':
```

See the difference in the package name?


#### The `puppet resource packagex` displays *build_options*

This too may break some scripts that parse output of `puppet resource packagex
...`. The example output for package having *build_options* is:

```console
~ # puppet resource packagex 'textproc/libxml2'
packagex { 'textproc/libxml2':
  ensure        => '2.8.0_3',
    build_options => '{:MEM_DEBUG=>false, :SCHEMA=>true, :THREADS=>true, :THREAD_ALLOC=>false, :XMLLINT_HIST=>false}',
    }
```

Note, that the *build_options* would never appear in output of the original
(old) *ports* provider.

## Limitations

* There is no support for *pkgng* yet, but it shall be relatively easy to add this
  support. The only things to be adapted are the `uninstall` method in provider
  class and the parts of code that determine `@property_hash[:build_options]`
  (*pkgng* stores options in package database, so we don't have to parse
  options files that may be out-of-sync with reality).
* Currently there is no system tests for the new *portsx* provider. This is,
  because there are no FreeBSD prefab images provided by `rspec-system` yet. I
  hope this changes in not so far future, see status of the [request for freebsd
  prefab images](https://github.com/puppetlabs/rspec-system/issues/52).


## Development
The project is held at github:
* [https://github.com/ptomulik/puppet-packagex](https://github.com/ptomulik/puppet-packagex)
Issue reports, patches, pull requests are welcome!
