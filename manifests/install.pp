# == Class: marathon::install
#
class marathon::install(
  $ensure      = 'installed',
  $manage_repo = true,
  $repo_source = undef,
) {
  if $manage_repo {
    # Just use the Mesos repo class for now (it only has the mesosphere repo).
    class { 'mesos::repo':
      source => $repo_source,
    }
  }

  package { 'marathon':
    ensure  => $ensure,
    require => Class['mesos::repo']
  }
}
