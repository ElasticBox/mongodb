#
# Class mongo::params 
#
class mongodb::params() {
  
  case $::operatingsystem {
    /(Amazon)/: {
      $mongo_10gen        = 'mongodb-org'
      $mongo_10gen_server = 'mongodb-org-server'
      $mongo_user         = 'mongod'
      $mongo_service      = 'mongod'
      $mongo_config       = 'mongod.conf'
      $mongo_log          = '/var/log/mongo'
      $mongo_path         = '/var/lib/mongo'
    }
    /(CentOS|Fedora|RedHat)/: {
      $mongo_10gen        = 'mongo-10gen'
      $mongo_10gen_server = 'mongo-10gen-server'
      $mongo_user         = 'mongod'
      $mongo_service      = 'mongod'
      $mongo_config       = 'mongod.conf'
      $mongo_log          = '/var/log/mongo'
      $mongo_path         = '/var/lib/mongo'
    }
    /(Debian|Ubuntu)/: {
      $mongo_10gen        = 'mongodb-10gen'
      $mongo_10gen_server = undef
      $mongo_user         = 'mongodb'
      $mongo_service      = 'mongodb'
      $mongo_config       = 'mongodb.conf'
      $mongo_log          = '/var/log/mongodb'
      $mongo_path         = '/var/lib/mongodb'
    }
    default: {
      fail('Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}')
    }
  }
}