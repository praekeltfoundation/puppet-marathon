# == Class: marathon::service
#
class marathon::service (
  $ensure = 'running',
) {
  service { 'marathon':
    ensure     => $ensure,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => File['/etc/default/marathon'],
  }
}
