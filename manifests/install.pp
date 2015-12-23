# == Class: marathon::install
#
class marathon::install(
  $ensure      = 'installed',
  $repo_source = undef,
) {
  # Just use the Mesos repo class for now (it only has the mesosphere repo).
  class { 'mesos::repo':
    source => $repo_source,
  }

  package { 'marathon':
    ensure  => $ensure,
    require => Class['mesos::repo']
  }
}
