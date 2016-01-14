# == Class: marathon::repo
#
class marathon::repo (
  $manage = true,
  $source = 'mesosphere',
) {
  if $manage {
    # Just use the Mesos repo class for now (it only has the mesosphere repo).
    class { 'mesos::repo':
      source => $source,
    }
    contain 'mesos::repo'
  }
}
