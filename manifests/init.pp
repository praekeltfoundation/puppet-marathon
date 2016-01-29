# == Class: marathon
#
# === Parameters
#
# [*repo_manage*]
#   Whether or not to manage the repo for installing Marathon. This module
#   simply reuses mesos::repo so if that class is defined elsewhere then this
#   parameter should be set to false.
#
# [*repo_source*]
#   The repository to use. Currently supported values: 'mesosphere'.
#
# [*package_ensure*]
#   The ensure value for the Marathon package.
#
# [*owner*]
#   The owner of the configuration files.
#
# [*group*]
#   The group of the owner of the configuration files.
#
# [*master*]
#   The value of the --master parameter to configure Marathon to connect to the
#   Mesos master(s). Optional.
#
# [*zookeeper*]
#   The value of the --zk parameter to configure Marathon to connect to
#   Zookeeper. Optional.
#
# [*options*]
#   A hash of additional options to configure Marathon with.
#
# [*env_var*]
#   A hash of environment variables to export before starting Marathon.
#
# [*manage_logger*]
#   Whether or not to configure the logger for Marathon.
#
# [*logger*]
#   The logger to configure if manage_logger is true. Currently supported
#   values: 'logback'.
#
# [*log_dir*]
#   The directory to store log files.
#
# [*log_filename*]
#   The name of the logfile to store in the log directory.
#
# [*java_home*]
#   The path to JAVA_HOME to use with Marathon. Optional.
#
# [*java_opts*]
#   String of additional options to pass to the JVM.
#
# [*ulimit*]
#   A ulimit to set when launching Marathon. Note that when Marathon is run as
#   root it will (in most circumstances) set the ulimit to 8192 if it is lower
#   than that.
#
# [*mesos_auth_principal*]
#   Principal for authentification at mesos master. If this parameter is not set
#   then the Mesos authentication secret will not be managed.
#
# [*mesos_auth_secret*]
#   Secret for authentification at mesos master. If this parameter is not set
#   then the Mesos authentication secret will not be managed.
#
# [*mesos_auth_secret_file*]
#   Location for storing the secret. If the principal or secret are not provided
#   then this file will not be managed.
#
# [*service_manage*]
#   Whether or not to manage the state of the Marathon service with Puppet.
#
# [*service_ensure*]
#   What state the service should be kept in - e.g. 'running'
class marathon(
  $repo_manage            = true,
  $repo_source            = 'mesosphere',

  $package_ensure         = 'present',

  $owner                  = 'root',
  $group                  = 'root',
  $master                 = undef,
  $zookeeper              = undef,
  $options                = {},
  $env_var                = {},
  $manage_logger          = true,
  $logger                 = 'logback',
  $log_dir                = '/var/log/marathon',
  $log_filename           = 'marathon.log',
  $java_home              = undef,
  $java_opts              = '-Xmx512m',
  $ulimit                 = undef,
  $mesos_auth_principal   = undef,
  $mesos_auth_secret      = undef,
  $mesos_auth_secret_file = '/etc/marathon/.secret',

  $service_manage         = true,
  $service_ensure         = 'running'
) {

  validate_bool($repo_manage)
  validate_bool($manage_logger)
  validate_hash($options)
  validate_hash($env_var)
  if $ulimit != undef {
    validate_integer($ulimit)
  }
  validate_bool($service_manage)

  class { 'marathon::repo':
    manage => $repo_manage,
    source => $repo_source,
  }

  class { 'marathon::install':
    ensure => $package_ensure,
  }

  class { 'marathon::config':
    owner                  => $owner,
    group                  => $group,
    master                 => $master,
    zookeeper              => $zookeeper,
    options                => $options,
    env_var                => $env_var,
    manage_logger          => $manage_logger,
    logger                 => $logger,
    log_dir                => $log_dir,
    log_filename           => $log_filename,
    java_home              => $java_home,
    java_opts              => $java_opts,
    ulimit                 => $ulimit,
    mesos_auth_principal   => $mesos_auth_principal,
    mesos_auth_secret      => $mesos_auth_secret,
    mesos_auth_secret_file => $mesos_auth_secret_file,
  }

  class { 'marathon::service':
    ensure => $service_ensure,
    manage => $service_manage,
  }

  anchor { 'marathon::begin': }
    -> Class['marathon::repo']
    -> Class['marathon::install']
    -> Class['marathon::config']
    ~> Class['marathon::service']
    -> anchor { 'marathon::end': }
}
