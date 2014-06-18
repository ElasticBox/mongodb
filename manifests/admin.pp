#
# Define mongodb::admin
#
define mongodb::admin(
  $password       = undef,
  $admin_username = undef,
  $admin_password = undef,
) {
  
  include 'mongodb::params'
  
  $noauth = "mongo admin --eval \"db.createUser({user: \\\"${name}\\\",pwd: \\\"${password}\\\",roles:[{role: \\\"root\\\",db: \\\"admin\\\"},{role: \\\"restore\\\",db: \\\"admin\\\"}]})\""
  $auth = "if [ $? -eq 252 ]; then mongo -u ${admin_username} -p ${admin_password} admin --eval \"db.createUser({user: \\\"${name}\\\",pwd: \\\"${password}\\\",roles:[{role: \\\"userAdminAnyDatabase\\\",db: \\\"admin\\\"}]})\";fi"
  $created = "if [ $? -eq 252 ]; then echo 'User already created.';fi"
  $command = "${noauth};${auth};${created}"

  exec { "${name}_create_user" :
    command   => $command,
    path      => "/usr/bin:/usr/sbin:/bin:/sbin",
    logoutput => true,
  }
}
