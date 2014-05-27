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
  
  $log = "${logpath}/${mongodb::params::mongo_user}.log"
  
  file { "/etc/${mongodb::params::mongo_config}":
    content => template("mongodb/${mongodb::params::mongo_config}.erb"),
  }
  
  $unlock = "rm /var/lib/mongodb/mongod.lock"
  $pkill = "pkill ${mongodb::params::mongo_service}"
  $restart = "service ${mongodb::params::mongo_service} restart"
  $launch = "mongod -f /etc/mongod.conf"
  $command = "${restart};if [ ! $? -eq 0 ]; then ${unlock};${pkill};${launch};fi"
  
  if $key_file {
    file { $key_file:
      mode => 700
    }
    
    exec { 'mongodb-restart' :
      command   => $command,
      path      => "/usr/bin:/usr/sbin:/bin:/sbin",
      logoutput => false,
      require   => [File[$key_file], File["/etc/${mongodb::params::mongo_config}"]],
    }
  } else {
    exec { 'mongodb-restart' :
      command   => $command,
      path      => "/usr/bin:/usr/sbin:/bin:/sbin",
      logoutput => false,
      require   => File["/etc/${mongodb::params::mongo_config}"],
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