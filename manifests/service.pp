# == Class: marathon::service
#
class marathon::service (
  $manage = true,
  $ensure = 'running',
  $force_provider = undef,
) {
  if $manage {
    if $force_provider {
      service { 'marathon':
        ensure     => $ensure,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
        provider   => $force_provider,
      }
    }else{
      service { 'marathon':
        ensure     => $ensure,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
      }
    }
  }
}
