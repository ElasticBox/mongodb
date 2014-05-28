#
# Class mongodb::config
#
class mongodb::config(
  $port        = 27017,
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
  
  File {
    ensure => present,
    owner  => "${mongodb::params::mongo_user}",
    group  => "${mongodb::params::mongo_user}",
  }
  
  $dbpath = $db_path ? {
    'default' => "${mongodb::params::mongo_path}",
    default   => "${db_path}",
  }
  
  file { $dbpath:
    ensure => directory,
    mode   => 0755,
  }
  
  $logpath = $log_path ? {
    'default' => "${mongodb::params::mongo_log}",
    default   => "${log_path}",
  }
  
  file { $logpath:
    ensure => directory,
    mode   => 0755,
  }
  
  $log = "${logpath}/mongod.log"
  
  case $::operatingsystem {
    /(Amazon|CentOS|Fedora|RedHat)/: {
      $fork = true
    }
    /(Debian|Ubuntu)/: {
      $fork = false
    }
    default: {
      $fork = false
    }
  }
  
  file { "/etc/mongod.conf":
    content => template("mongodb/mongod.conf.erb"),
    require => [File[$logpath], File[$dbpath]]
  }
  
  if $key_file {
    file { $key_file:
      mode => 700
    }
    
    exec { 'mongodb-restart' :
      command   => 'service mongod restart',
      path      => "/usr/bin:/usr/sbin:/bin:/sbin",
      logoutput => true,
      require   => [File[$key_file], File["/etc/mongod.conf"]],
    }
  } else {
    exec { 'mongodb-restart' :
      command   => 'service mongod restart',
      path      => "/usr/bin:/usr/sbin:/bin:/sbin",
      logoutput => true,
      require   => File["/etc/mongod.conf"],
    }
  }
  
  if $username and $username != '' {
    mongodb::admin { $username:
      password       => $password,
      admin_username => $username,
      admin_password => $password,
      require        => Exec['mongodb-restart']
    }
  }
  
}