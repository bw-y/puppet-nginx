# define: nginx::resource::pkg_check
#   用于检查依赖包是否在其它模块有资源引用
define nginx::resource::pkg_check (
  $pkg    = $name,
  $ensure = present,
){
  if !(defined(Package[$pkg])) {
    package { $pkg:
      ensure => $ensure
    }
  }
}
