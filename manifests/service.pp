# == Class: marathon::service
#
class marathon::service (
  $manage = true,
  $ensure = 'running',
  $force_provider = undef,
) {
  if $manage {
    service { 'marathon':
      ensure     => $ensure,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      provider   => $force_provider,
    }
  }
}
