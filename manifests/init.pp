# == Class: marathon
#
# === Parameters
#
# [*ensure*]
#   The ensure value for the Marathon package.
#
# [*repo*]
#   The repository to use. Currently supported values: undef/blank,
#   'mesosphere'.
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
# [*manage_service*]
#   Whether or not to manage the state of the Marathon service with Puppet.
class marathon(
  $ensure         = 'present',
  $repo           = undef,

  $owner          = 'root',
  $group          = 'root',
  $master         = undef,
  $zookeeper      = undef,
  $options        = {},
  $env_var        = {},
  $manage_logger  = true,
  $logger         = 'logback',
  $log_dir        = '/var/log/marathon',
  $log_filename   = 'marathon.log',
  $java_home      = undef,
  $java_opts      = '-Xmx512m',
  $ulimit         = undef,

  $manage_service = true,
) inherits marathon::params {

  validate_bool($manage_logging)
  validate_hash($options)
  validate_hash($env_var)
  if defined ($ulimit) {
    validate_integer($ulimit)
  }
  validate_bool($manage_service)

  class { 'marathon::install':
    ensure      => $ensure,
    repo_source => $repo,
  }

  class { 'marathon::config':
    owner         => $owner,
    group         => $group,
    options       => $options,
    env_var       => $env_var,
    manage_logger => $manage_logger,
    logger        => $logger,
    log_dir       => $log_dir,
    log_filename  => $log_filename,
    java_home     => $java_home,
    java_opts     => $java_opts,
    ulimit        => $ulimit,
  }

  if ($manage_service) {
    include marathon::service
  }
}
