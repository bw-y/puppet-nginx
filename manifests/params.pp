#
class nginx::params {

  $fs_dir             = 'puppet:///module_files'

  $nginx_tar_gz       = 'nginx.tar.gz'
  $nginx_un_tar_gz    = 'nginx'
  $nginx_source       = "${fs_dir}/${module_name}/${nginx_tar_gz}"

  $openssl_tar_gz     = 'openssl-1.0.2d.tar.gz'
  $openssl_un_tar_gz  = 'openssl-1.0.2d'
  $openssl_source     = "${fs_dir}/${module_name}/${openssl_tar_gz}"

  $setup_sh           = 'setup.sh'
  $setup_sh_temp      = "${module_name}/setup.sh.erb"

  $nginx_ctrl_sh      = 'nginx_ctrl.sh'
  $nginx_ctrl_sh_temp = "${module_name}/nginx_ctrl.sh.erb"

  $log_clean_script   = 'clean_files.py'
  $exec_path          = '/usr/sbin:/usr/bin:/sbin:/bin'

  case $::operatingsystem {
    'Ubuntu' : {
      $pub_pkgs = [
        'build-essential', 'libpcre3', 'zlib1g', 'libpcre3-dev',
        'zlib1g-dev', 'libssl-dev', 'python-dev', 'libluajit-5.1-dev',
      ]
      if ($::lsbdistcodename in ['trusty', 'precise']) {
        $pkg_list = $pub_pkgs
      }
      if $::lsbdistcodename == 'lucid' {
        $pri_pkg  = ['liblua5.1-0-dev']
        $pkg_list = flatten([$pub_pkgs, $pri_pkg])
      }
    }
    'RedHat','CentOS' : {
      $pkg_list = [
        'pcre', 'pcre-devel', 'python-devel', 'lua-devel',
        'openssl', 'openssl-devel', 'gcc'
      ]
    }
    default: {
      fail("The ${module_name} module is \
not supported on an ${::operatingsystem} based system.")
    }
  }
}
