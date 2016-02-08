# == Class: marathon::install
#
class marathon::install(
  $ensure = 'installed',
) {
  package { 'marathon':
    ensure => $ensure,
  }
}
