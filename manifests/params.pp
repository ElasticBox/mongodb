#
# Class mongo::params 
#
class mongodb::params() {
  
  case $::operatingsystem {
    /(Amazon|CentOS|Fedora|RedHat)/: {
      $mongo_user = 'mongod'
      $mongo_log  = '/var/log/mongo'
      $mongo_path = '/var/lib/mongo'
    }
    /(Debian|Ubuntu)/: {
      $mongo_user = 'mongodb'
      $mongo_log  = '/var/log/mongodb'
      $mongo_path = '/var/lib/mongodb'
    }
    default: {
      fail('Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}')
    }
  }
}