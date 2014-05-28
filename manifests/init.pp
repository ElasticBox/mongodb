#
# Class mongodb
#
class mongodb(
  $port        = 27017,
  $version     = latest,
  $db_path     = 'default',
  $log_path    = 'default',
  $auth        = true,
  $bind_ip     = undef,
  $username    = undef,
  $password    = undef,
  $replica_set = undef,
  $key_file    = undef,
) {
  
  include 'mongodb::params'
  include 'mongodb::10gen'
  
  Class['mongodb'] -> Class['mongodb::config']

  $config_hash = {
    'port'        => "${port}",
    'db_path'     => "${db_path}",
    'log_path'    => "${log_path}",
    'auth'        => "${auth}",
    'bind_ip'     => "${bind_ip}",
    'username'    => "${username}",
    'password'    => "${password}",
    'replica_set' => "${replica_set}",
    'key_file'    => "${key_file}",
  }
  
  $config_class = { 'mongodb::config' => $config_hash }

  create_resources( 'class', $config_class )

  if $version != 'latest' {
    case $::operatingsystem {
      /(Amazon|CentOS|Fedora|RedHat)/: {
        $mongodb_version = "${version}-1"
      }
      /(Debian|Ubuntu)/: {
        $mongodb_version = "${version}"
      }
    }  
  } else {
    $mongodb_version = latest
  }
  
  package { 'mongodb-org':
    ensure  => "${mongodb_version}",
    require => Class['mongodb::10gen'],
  }

  service { 'mongod' :
    ensure  => running,
    enable  => true,
    require => Package['mongodb-org'],
  }
}