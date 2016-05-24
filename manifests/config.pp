# == Class: marathon::config
#
class marathon::config(
  $conf_dir_base          = '/etc/marathon',
  $conf_dir_name          = 'conf',
  $owner                  = 'root',
  $group                  = 'root',
  $master                 = undef,
  $zookeeper              = undef,
  $options                = { },
  $env_var                = { },
  $syslog                 = true,
  $manage_logger          = true,
  $logger                 = 'logback',
  $log_dir                = '/var/log/marathon',
  $log_filename           = 'marathon.log',
  $log_level              = 'info',
  $log_levels             = {},
  $ulimit                 = undef,
  $mesos_auth_principal   = undef,
  $mesos_auth_secret      = undef,
  $mesos_auth_secret_file = '/etc/marathon/.secret',
  $java_home              = undef,
  $java_opts              = '-Xmx512m',
  $reporter_graphite      = $marathon::reporter_graphite,
) {
  $conf_dir = "${conf_dir_base}/${conf_dir_name}"
  file { [$conf_dir_base, $conf_dir]:
    ensure => directory,
    owner  => $owner,
    group  => $group,
  }

  if ($mesos_auth_principal != undef and $mesos_auth_secret != undef) {
    validate_absolute_path($mesos_auth_secret_file)
    file { $mesos_auth_secret_file:
      ensure  => file,
      content => $mesos_auth_secret,
      owner   => $owner,
      group   => $group,
      mode    => '0400',
    }

    $secret_options = {
      'mesos_authentication_principal'   => $mesos_auth_principal,
      'mesos_authentication_secret_file' => $mesos_auth_secret_file,
    }

    $real_options = merge($options, $secret_options)
  } else {
    $real_options = $options
  }

  if $master {
    mesos::property { 'marathon_master':
      value   => $master,
      dir     => $conf_dir,
      file    => 'master',
      service => undef,
      owner   => $owner,
      group   => $group,
    }
  }
  
  if $master {
    mesos::property { 'marathon_master':
      value   => $master,
      dir     => $conf_dir,
      file    => 'master',
      service => undef,
      owner   => $owner,
      group   => $group,
    }
  }
  
  if $reporter_graphite {
    file {"${conf_dir_base}/${conf_dir_name}/reporter_graphite":
      ensure  => present,
      content => $reporter_graphite,
      owner   => $owner,
      group   => $group,
    }
  }

  if $zookeeper {
    mesos::property { 'marathon_zk':
      value   => $zookeeper,
      dir     => $conf_dir,
      file    => 'zk',
      service => undef,
      owner   => $owner,
      group   => $group,
    }
  }

  create_resources(mesos::property,
    mesos_hash_parser($real_options, 'marathon'),
    {
      dir     => $conf_dir,
      service => undef,
      owner   => $owner,
      group   => $group,
    }
  )

  # The "--no-logger" flag that disables syslog output is used by Marathon's
  # startup script, not Marathon itself, and so does not behave quite like other
  # configuration options. Using a mesos::property would result in a "--logger"
  # flag when syslog is true, which in this case is not a valid flag.
  $no_logger_ensure = $syslog ? {
    true  => absent,
    false => present,
  }
  file { "${conf_dir}/?no-logger":
    ensure => $no_logger_ensure,
    owner  => $owner,
    group  => $group,
  }

  if $manage_logger {
    file { $log_dir:
      ensure => directory,
      owner  => $owner,
      group  => $group,
    }

    case $logger {
      'logback': {
        $log_config_file = "${conf_dir_base}/logback.xml"
        $log_file = "${log_dir}/${log_filename}"
        $log_archive_pattern = "${log_dir}/${log_filename}.%i.gz"
        file { $log_config_file:
          content => template('marathon/logback.xml.erb'),
          owner   => $owner,
          group   => $group,
          require => File[$conf_dir_base],
        }

        $java_extra_opts = "-Dlogback.configurationFile=file:${log_config_file}"
      }
      default: {
        fail("Logger \"${logger}\" is not currently supported. Only logback is supported at this time.") # lint:ignore:80chars
      }
    }
  }

  case $::osfamily {
    'Debian': {
      file { '/etc/default/marathon':
        ensure  => 'present',
        content => template('marathon/default.erb'),
        owner   => $owner,
        group   => $group,
        mode    => '0644',
      }
    }
    'RedHat': {
      $ensure_service_file = $ulimit ? {
        undef => 'absent',
        default => 'present'
      }

      # this file overwrites config, make sure it is gone for good
      file { '/etc/default/marathon':
        ensure => 'absent',
      }

      file { '/etc/sysconfig/marathon':
        ensure  => 'present',
        content => template('marathon/sysconfig.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
      }

      file { '/etc/systemd/system/marathon.service':
        ensure  => $ensure_service_file,
        content => template('marathon/marathon.service.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Exec['systemctl-daemon-reload_marathon'],
      }

      exec { 'systemctl-daemon-reload_marathon':
        command     => '/usr/bin/systemctl daemon-reload',
        refreshonly => true,
      }
    }
    default: { fail("Unsupported OS family: ${::osfamily}") }
  }
}
