# define: nginx::resource::file_check
#   用于下发静态文件资源，并生成其压缩文件
# 
# Parameters:
#   [*ensure*]             - 创建或删除对应的文件资源
#     有效值(present|absent).               默认值 present
#   [*file*]               - 一个有效的文件路径
#     有效值取define资源名
#   [*owner*]              - file资源的owner
#     file资源的owner属性                 默认值: undef
#   [*mode*]               - file资源的mode
#     file资源的mode属性                  默认值: undef
#   [*source_dir*]         - 文件在puppetmaster上的父目录
#     和name拼出file path  -              默认值: undef
#   [*dest_dir*]           - 文件在agent上的父目录
#     和name拼出file path  -              默认值: undef
#   [*require_dir*]        - 此文件的依赖关系，
#     file资源的require属性               默认值: undef

define nginx::resource::file_check (
  $ensure      = present,
  $owner       = undef,
  $mode        = undef,
  $dest_dir    = undef,
  $source_dir  = undef,
  $require_dir = undef,
) {
 
  $file   = "${dest_dir}/${name}" 
  $source = "${source_dir}/${name}"

  if !(defined(File[$file])) {
    file { $file: 
      ensure  => $ensure,
      owner   => $owner,
      mode    => $mode,
      source  => $source, 
      require => $require_dir
    }
    
    exec { "gzip -c ${file} > ${file}.gz":
      refreshonly => true, 
      logoutput   => on_failure,
      subscribe   => File[$file],
      command     => "gzip -c $file > $file.gz",
      path        => $::nginx::exec_path
    }
    
  }
}
