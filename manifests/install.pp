#
class nginx::install {

  exec { 'setup_nginx':
    refreshonly => true,
    timeout     => 1200,
    path        => $::nginx::exec_path,
    subscribe   => File['nginx.tar.gz'],
    command     => "${::nginx::down_dir}/${::nginx::setup_sh}"
  }

  file { 'nginx_ctrl.sh':
    owner   => 0,
    group   => 0,
    mode    => '0755',
    require => Exec['setup_nginx'],
    content => template($::nginx::nginx_ctrl_sh_temp),
    path    => "${::nginx::down_dir}/${::nginx::nginx_ctrl_sh}"
  }

}
