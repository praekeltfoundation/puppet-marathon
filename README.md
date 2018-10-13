> **DEPRECATION NOTICE**: This Puppet module is no longer maintained and should not be used. We now use [Mesosphere DC/OS](https://dcos.io) instead of using Marathon directly.

# puppet-marathon

[![Puppet
Forge](http://img.shields.io/puppetforge/v/praekeltfoundation/marathon.svg)](https://forge.puppetlabs.com/praekeltfoundation/marathon)
[![Build Status](https://travis-ci.org/praekeltfoundation/puppet-marathon.svg?branch=develop)](https://travis-ci.org/praekeltfoundation/puppet-marathon)

A Puppet module for configuring Marathon

This module was designed for Marathon version 0.13.0+. Older versions should still work but may require some extra configuration.

This module has been tested on:
 - Ubuntu 14.04 running Puppet 3.4 and 3.8
 - RHEL 7 running Puppet 3.7

Again, this should work on other setups but we make no promises.

## Getting started
The module should be immediately familiar to anybody who has used the [`deric/mesos`](https://github.com/deric/puppet-mesos) module.

```puppet
class { 'marathon':
  zookeeper   => 'zk://127.0.0.1:2181/marathon',
  master      => 'zk://127.0.0.1:2181/mesos',
  options     => {
    hostname         => $::hostname,
    event_subscriber => 'http_callback',
  },
}
```

For information about all the available parameters see the documentation for the [class](manifests/init.pp).

## Marathon + Mesos
This module reuses large parts of the `deric/mesos` module and as such that module is a dependency. That module is also our recommended way to manage Mesos with Puppet.

**NOTE:** There is a conflict when installing both Mesos and Marathon using these modules as both packages are generally installed from the same repository. To work around these conflicts, it is possible to disable the management of the repo by the Marathon module.

For example:
```puppet
class { 'mesos':
  repo   => 'mesosphere',
  master => $mesos_zk
}

class { 'marathon':
  repo_manage => false,
  zookeeper   => $marathon_zk,
  master      => $mesos_zk,
}

Class['mesos::repo'] -> Package['marathon']
```

Two things to note:
 1. The `repo_manage => false` line ensures that the Marathon module doesn't try to configure a repo that conflicts with the Mesos one.
 2. We must specify the repo dependency for the Marathon package as there is no way for the Marathon module to know this dependency if it is not managing the repo itself.


## Marathon logging
Like any good Java program (technically, Scala), Marathon uses loggers that are configured using a file specified in the JVM's classpath at runtime. This module takes care of configuring this logging for certain versions of Marathon.

To disable the configuration of logging (enabled by default), pass `manage_logger => false`. Even with management of loggers enabled Marathon will still output to syslog (although this depends on exactly how Marathon is launched).

**NOTE:** At this time, the logging configuration only works for versions 0.13.0+ of Marathon. Marathon recently switched from `log4j` to `slf4j` + `logback`. This module only includes a configuration file [template for `logback`](templates/logback.xml.erb).

## Marathon Monitoring
Marathon have been integration with Graphite, report metrics to Graphite as defined by the given URL. Example: tcp://localhost:2003?prefix=marathon-test&interval=10 

For example:
```puppet
class { 'marathon'
  reporter_graphite => 'tcp://localhost:2003?prefix=marathon-test&interval=10'
  }
```

