# ptomulik-packagex

#### Table of Contents

1. [Overview](#overview)
2. [Setup](#setup)
    * [What packagex affects](#what-packagex-affects)
    * [Setup requirements](#setup-requirements)
3. [Development](#development)

## Overview

__NOTE__: I decided to split this package into smaller pieces in order to
achieve better reusability. Now this module is only a "virtual" module with no
contents and it only defines dependencies to other modules.

This is an enhanced version of puppet *package* resource and some of its
providers.

This is a place, where I develop and test my extended version of puppet
*package* resource with enhanced providers. The releases found at
https://forge.puppetlabs.com/ptomulik/packagex are known to be functional and
may be used with recent versions of puppet (3.2 and later). 

Providers are developed in separate projects, but all the supported providers
get installed as a dependencies of this module. Currently the
__ptomulik-packagex__ installs the following providers: 

  - [portsx](https://github.com/ptomulik/puppet-packagex_portsx) provider,

The resource type is developed in separate project as well, see
[ptomulik-packagex_resource](https://github.com/ptomulik/puppet-packagex_resource).

## Setup

### What packagex affects

* installs, upgrades, reinstalls and uninstalls packages,

### Setup Requirements

You may need to enable **pluginsync** in your `puppet.conf`.

### Beginning with packagex

Its usage is essentially same as for the original *package* resource.

## Development
The project is held at github:
* [https://github.com/ptomulik/puppet-packagex](https://github.com/ptomulik/puppet-packagex)
Issue reports, patches, pull requests are welcome!
