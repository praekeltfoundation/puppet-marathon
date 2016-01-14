# == Class: marathon::service
#
class marathon::service (
  $manage = true,
  $ensure = 'running',
) {
  if $manage {
    service { 'marathon':
      ensure     => $ensure,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
    }
  }
}
