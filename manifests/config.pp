# == Class: marathon::config
#
class marathon::config(
  $conf_dir_base = '/etc/marathon',
  $conf_dir_name = 'conf',
  $owner         = 'root',
  $group         = 'root',
  $master        = undef,
  $zookeeper     = undef,
  $options       = {},
  $env_var       = {},
  $manage_logger = true,
  $logger        = 'logback',
  $log_dir       = '/var/log/marathon',
  $log_filename  = 'marathon.log',
  $log_level     = 'info',
  $ulimit        = undef,
  $java_home     = undef,
  $java_opts     = '-Xmx512m',
) {
  $conf_dir = "${conf_dir_base}/${conf_dir_name}"
  file { [$conf_dir_base, $conf_dir]:
    ensure => directory,
    owner  => $owner,
    group  => $group,
  }

  if $master {
    mesos::property { 'marathon_master':
      value   => $master,
      dir     => $conf_dir,
      service => Service['marathon'],
      file    => 'master',
    }
  }

  if $zookeeper {
    mesos::property { 'marathon_zk':
      value   => $zookeeper,
      dir     => $conf_dir,
      service => Service['marathon'],
      file    => 'zk',
    }
  }

  create_resources(mesos::property,
    mesos_hash_parser($options, 'marathon'),
    {
      dir     => $conf_dir,
      service => Service['marathon']
    }
  )

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
          notify  => Service['marathon'],
        }

        $java_extra_opts = "-Dlogback.configurationFile=file:${log_config_file}"
      }
      default: {
        fail("Logger \"${logger}\" is not currently supported. Only logback is supported at this time.")
      }
    }
  }

  file { '/etc/default/marathon':
    ensure  => 'present',
    content => template('marathon/default.erb'),
    owner   => $owner,
    group   => $group,
    mode    => '0644',
    require => Package['marathon'],
  }
}
