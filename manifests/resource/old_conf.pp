# define: nginx::resource::old_conf
#   用于下发旧版本的配置，接受一个有效的文件名
#     此文件需要预先放置到此模块的templates/old_conf目录下
#     此处define资源是为了接受一个数组类数据类型，将数组的每个字段，
#     从puppet server端的templates/old_conf/目录内，下发到agent对应的/etc/nginx/vhost/目录中
#   
define nginx::resource::old_conf(
  $ensure = 'present'
){ 

  file { "${::nginx::vhost_dir}/${name}":
    mode    => 0644,
    ensure  => $ensure,
    owner   => $::nginx::work_user,
    require => File[$::nginx::vhost_dir],
    content => template("nginx/old_conf/${name}")
  }

}
