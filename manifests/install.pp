# == Class: marathon::install
#
class marathon::install(
  $ensure      = 'installed',
  $repo_source = undef,
) {
  # Just use the Mesos repo class for now (it only has the mesosphere repo).
  # Don't include if $repo_source is undef or blank so that the class can be
  # excluded if it is defined elsewhere.
  if ($repo_source != undef) and ($repo_source != '') {
    class { 'mesos::repo':
      source => $repo_source,
    }
  }

  package { 'marathon':
    ensure  => $ensure,
    require => Class['mesos::repo']
  }
}
