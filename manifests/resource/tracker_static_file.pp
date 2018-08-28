# define: nginx::resource::tracker_static_file
#   用于被nginx::resource::tracker_server引用，下发tracker静态文件
#   
# Parameters:
#   [*ensure*]             - 创建或删除对应的文件资源，默认值 present
#     (present|absent)
#   [*require_dir*]        - 文件资源依赖的目录，一般为其父目录
#   [*static_dir*]         - puppetmaster上的fileserver的目录关键字，主要用于差异性分发
#   [*dest_dir*]           - 下发到客户端哪个目录内
# 
define nginx::resource::tracker_static_file (
  $ensure = present,
  $require_dir,
  $static_dir,
  $dest_dir,
){

  $s_dir     = "${::nginx::fs_dir}/nginx/static_files/${static_dir}"
  $s_l_dir   = "/usr/local/puppet_files/nginx/static_files/${static_dir}"
  $res_files = get_files(last_str($s_l_dir))

  nginx::resource::file_check{ $res_files:
    ensure      => $ensure,
    mode        => '0644',
    dest_dir    => $dest_dir,
    source_dir  => $s_dir,
    require_dir => File[$require_dir],
    owner       => $::nginx::work_user,
  }

}
