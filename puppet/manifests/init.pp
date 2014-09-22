exec { 'apt-get update':
  path => '/usr/bin',
}

package { 'vim':
  ensure => present,
}

class { 'composer':
  suhosin_enabled => false,
}

class { 'mysql::server':
  override_options => {
    'mysqld' => {
      'bind_address' => '0.0.0.0',
    },
  },
  restart => true,
  require => Exec['apt-get update'],
}

include composer, eightydigital
