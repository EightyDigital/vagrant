class eightydigital {

  # force github.com to be in known_hosts
  exec { 'ssh know github':
    command => 'ssh git@github.com -o StrictHostKeyChecking=no; echo 0;',
    path    => '/bin:/usr/bin',
    user    => 'vagrant',
  }

  # Install the nginx package. This relies on apt-get update
  package { 'nginx':
    ensure => 'present',
    require => [
        Exec['apt-get update'],
    ]
  }

  # Make sure that the nginx service is running
  service { 'nginx':
    ensure => running,
    enable => true,
    hasstatus  => true,
    hasrestart => true,
    require => Package['nginx'],
  }

  file { 'vagrant-nginx-eightystaging':
    path => '/etc/nginx/sites-available/eightystaging',
    ensure => file,
    require => Package['nginx'],
    source => 'puppet:///modules/eightydigital/nginx/eightystaging',
  }

  file { 'vagrant-nginx-hotrefis':
    path => '/etc/nginx/sites-available/hotrefis',
    ensure => file,
    require => Package['nginx'],
    source => 'puppet:///modules/eightydigital/nginx/hotrefis',
  }

  # Disable the default nginx vhost
  file { 'default-nginx-disable':
    path => '/etc/nginx/sites-enabled/default',
    ensure => absent,
    require => Package['nginx'],
  }

  # Symlink our vhost in sites-enabled to enable it
  file { 'vagrant-nginx-eightystaging-enable':
    path => '/etc/nginx/sites-enabled/eightystaging',
    target => '/etc/nginx/sites-available/eightystaging',
    ensure => link,
    notify => Service['nginx'],
    require => [
      File['vagrant-nginx-eightystaging'],
      File['default-nginx-disable'],
    ],
  }

  # Symlink our vhost in sites-enabled to enable it
  file { 'vagrant-nginx-hotrefis-enable':
    path => '/etc/nginx/sites-enabled/hotrefis',
    target => '/etc/nginx/sites-available/hotrefis',
    ensure => link,
    notify => Service['nginx'],
    require => [
      File['vagrant-nginx-hotrefis'],
      File['default-nginx-disable'],
    ],
  }

  package { 'ruby-dev':
    ensure => installed,
    require => Exec['apt-get update']
  }

  package { 'sass':
    ensure => '3.4.1',
    provider => 'gem',
  }

  package { 'compass':
    ensure => '1.0.1',
    provider => 'gem',
  }

  # Install the php5-fpm and php5-cli packages
  package { ['php5-fpm', 'php5-intl', 'php5-mysql', 'php5-curl', 'php5-memcached', 'php5-gd', 'php5-mysqlnd']:
    ensure => present,
    require => Exec['apt-get update'],
  }

  # Make sure php5-fpm is running
  service { 'php5-fpm':
    ensure => running,
    require => Package['php5-fpm'],
  }

  # mysql::db { 'sample':
  #     user     => 'sampleuser',
  #     password => 'sample123',
  #     host     => '%',
  #     sql      =>  '/home/vagrant/sample.sql',
  #     require  => Exec['sample.sql'],
  # }

  package { ['memcached']:
    ensure => present,
    require => Exec['apt-get update'],
  }

  service { 'memcached':
    ensure => running,
    require => Package['memcached'],
  }
}
