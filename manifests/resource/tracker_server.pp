# define: nginx::resource::tracker_server
#   用于tracker的自定义server文件生成控制
#     模板1： templates/vhosts/tracker_server.erb
#     模板2： templates/vhosts/tracker_default_location.erb
# 
# Parameters:
#   [*ensure*]             - 创建或删除对应的文件资源
#     有效值(present|absent).               默认值 present
#   [*port*]               - 此server_name的的监听端口
#     有效取值：(1-65535)                   默认值 80
#   [*charset*]            - 默认使用的字符集. 
#     有效值: 参考标准的nginx官网配置文档   默认值： 'utf-8'
#   [*server_name*]        - 有效的server_name
#     有效数据类型为Strings                 默认值： undef(未定义)
#   [*hypers_z_rewrite*]   - 私有配置，见内部nginx文档
#                                           默认值： off
#   [*ssl_pem*]            - 需要配置ssl时，证书文件名字，此处仅提供证书名字即可，但有效证书需符合如下要求：
#     1. 证书文件为一个单独的有效文件，其中应包含私钥和证书(一个授权证书[可选的一个或多个根证书])
#     2. 证书文件在客户端的下发路径为 init.pp { $ssl_dir = ? }
#     3. 证书文件在puppet server的路径为此模块下的 files/ssl_certs 目录内,需手工创建或上传
#   [*log_not_found*]      - 此server_name的log_not_found的配置
#     有效取值参考nginx官方文档             默认值 'on'
#   [*limit_cone*]         - 当前server的限速设置 limit_cone
#                                           默认值见代码
#   [*limit_req*]          - 当前server的限速设置 limit_req
#                                           默认值见代码
#   [*gzip_types*]         - 当前server的压缩类型
#                                           默认值见代码
#   [*root*]               - 需要下发静态文件的目录，此参数极为重要，需仔细阅读此项说明，说明如下：
#     1. 此参数有效数据类型为数组(由目录的层次深度不确定性导致)
#     2. 此参数传递的数组不得为空，此参数需要数字至少有一个有效值，譬如 [ '/opt/static_file' ]
#     3. 如果需要使用路径/aa/bb/cc/dd，所需传递参数如下：
#       1) 仅/aa存在时，需传递有效数组为：['/aa/bb/cc/dd', '/aa/bb/cc/dd', ]
#       2) /aa/bb存在时，需传递有效数组为：  ['/aa/bb/cc/dd', '/aa/bb/cc']
#       3) 当/aa/bb/cc都存在时，仅传递数组： ['/aa/bb/cc/dd'] 即可
#   [*static_dir*]         - 静态文件源的puppetserver端的路径关键字，说明如下
#     1. 静态文件默认下发时，文件在puppet上的路径为： ${::nginx::fs_dir}/nginx/static_files/${static_dir}
#     2. 考虑差文件差异性分发，直接在puppet的fileserver中增加一个目录，放置差异的静态文件，然后传递static_dir变量为目录名字即可
#     3. 当前默认值为default，对应路径为： /usr/local/puppet_files/nginx/static_files/default
#   [*log_file_tag*]       - 日志文件所需要的log_files哈希组对应的key,此参数不得为空
#     exam:
#        log_files => {
#          aa => '/var/log/nginx/lab_access.log',
#          bb => '/var/log/nginx/tmp_access.log',
#        },
#        tracker_locations => {
#          'aa_bw' => {
#             ...,
#             log_file_tag => 'aa',
#           },
#          'bb_bw' => {
#             ...,
#             log_file_tag => 'bb',
#           },
#        },
#   [*log_format*]         - 记录日志文件对应的格式
#     有效值取决于nginx.conf定义            默认值： iwt
#   [*mobile_cfg*]         - 是否开启移动端静态页面,逻辑参考模板2
#     有效值(true[开启]|false[不开启])      默认值false
#   [*expires_xml*]        - xml文件的缓存有效时间
#     有效值参考nginx官方文档               默认值 '7d'
#   [*static_server*]      - 是否开启静态文件服务，默认值false，具体逻辑参考templates/vhosts/tracker_default_location.erb
#     有效值(true[开启]|false[不开启])      默认值false
#   [*expires_swf*]        - 开启静态文件服务后，swf文件的缓存有效时间.
#     有效值参考nginx官方文档               默认值 '15d'
#   [*expires_js*]         - 开启静态文件服务后，js文件的缓存有效时间.
#     有效值参考nginx官方文档               默认值 '7d'
#   [*set_cookie_iwt*]     - 开启set_cookie设置
#     有效值true/false                      默认值 true
#   [*default_root*]       - 默认location中/是否配置
#     有效值true/false                      默认值 true
#   [*nielsen_tracker*]    - nielsen tracker的几个默认location
#     有效值: [true(开启)|false(不开启)]    默认值 false
#   [*custom_lines*]       - 自定义配置行
#     有效数据类型为列表,                   默认值:  undef 
define nginx::resource::tracker_server (
  $ensure           = present,
  $port             = 80,
  $charset          = 'utf-8',
  $server_name      = undef,
  $hypers_z_rewrite = 'off',
  $ssl_pem          = undef,
  $log_not_found    = 'on',
  $limit_cone       = 'iwt_zone1 100',
  $limit_req        = 'zone=iwt_zone2 burst=100 nodelay',
  $gzip_types       = 'text/plain application/x-javascript text/css application/xml', 
  $root             = undef,
  $static_dir       = 'default',
  $log_file_tag     = undef, 
  $log_format       = 'iwt',
  $mobile_cfg       = false,
  $expires_xml      = '7d',
  $static_server    = false,
  $expires_swf      = '15d',
  $expires_js       = '7d',
  $set_cookie_iwt   = true,
  $default_root     = true,
  $nielsen_tracker  = false,
  $custom_lines     = undef,
){

  $log_file     = $::nginx::log_files[$log_file_tag]
  $log_dir      = dirname($log_file)
  $location_dir = "${::nginx::vhost_dir}/${name}_locations"

  File {
    group   => 0,
    owner   => $::nginx::work_user,
  }
  
  if !(defined(File[$log_dir])){
    file { $log_dir: ensure => 'directory' }
  }
 
  if !(defined(File[$location_dir])){
    file { $location_dir: ensure => 'directory' }
    file { "${name}_default_location":
      mode    => 0644,
      ensure  => $ensure,
      require => File[$location_dir],
      path    => "$location_dir/${name}_default.conf",
      content => template('nginx/vhosts/tracker_default_location.erb')
    }
  }

  if $ssl_pem {
    if !defined(File["${::nginx::ssl_dir}/${ssl_pem}"]) {
      file { "${::nginx::ssl_dir}/${ssl_pem}":
        source => "puppet:///modules/nginx/ssl_certs/${ssl_pem}"
      }
    }
  }

  if $root != '' {
    #$root_dirs = path_to_array($root[0], $root[1])
    if !(defined(File[$root[0]])){
      file { $root: ensure => 'directory' }
      nginx::resource::tracker_static_file { "tracker_static_${name}":
        dest_dir    => $root[0],
        require_dir => $root,
        static_dir  => $static_dir
      }
    }
  }

  file { "tracker_${name}":
    mode    => 0644,
    ensure  => $eusure,
    path    => "${::nginx::vhost_dir}/tracker_${name}.conf",
    content => template('nginx/vhosts/tracker_server.erb')
  } 

}
