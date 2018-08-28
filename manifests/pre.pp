#
class nginx::pre {

  nginx::resource::pkg_check { $::nginx::pkg_list: }
  user { $::nginx::work_user:
    ensure => present,
    shell  => '/bin/false',
  }

  $main_dirs = [
    $::nginx::down_dir, $::nginx::conf_dir,
    $::nginx::vhost_dir, $::nginx::ssl_dir,
    $::nginx::log_dir
  ]

  file { $main_dirs:
    ensure  => directory,
    group   => 0,
    mode    => '0755',
    owner   => $::nginx::work_user,
    require => User[$::nginx::work_user],
  }

  file { 'clean_files.py':
    owner  => 0,
    group  => 0,
    mode   => '0755',
    path   => "${::nginx::down_dir}/${::nginx::log_clean_script}",
    source => "puppet:///modules/nginx/${::nginx::log_clean_script}"
  }

  file { 'nginx.tar.gz':
    path    => "${::nginx::down_dir}/${::nginx::nginx_tar_gz}",
    source  => $::nginx::nginx_source,
    require => File[$::nginx::down_dir],
  }

  file { 'openssl.tar.gz':
    path    => "${::nginx::down_dir}/${::nginx::openssl_tar_gz}",
    source  => $::nginx::openssl_source,
    require => File['nginx.tar.gz'],
  }

  file { 'setup_sh':
    owner   => 0,
    group   => 0,
    mode    => '0755',
    require => File['openssl.tar.gz'],
    content => template($::nginx::setup_sh_temp),
    path    => "${::nginx::down_dir}/${::nginx::setup_sh}"
  }

  file { 'err_log':
    ensure  => file,
    group   => 0,
    mode    => '0640',
    path    => $::nginx::err_log,
    owner   => $::nginx::work_user,
    require => File[$::nginx::log_dir]
  }

}
