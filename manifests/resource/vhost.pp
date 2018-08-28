# define: nginx::resource::vhost
#   用于默认虚拟主机配置文件管理
#   模板： templates/vhosts/vhost.erb
#
# Parameters:
#   [*ensure*]             - 创建或删除对应的配置文件资源：
#     有效值: (present|absent).             默认值: present
#   [*port*]               - 此server_name的的监听端口
#     有效取值：(1-65535)                   默认值: 80
#   [*upstream*]           - 是否使用upstrem，当为true时，取值为define资源name
#     有效值(true[使用]|false[不使用])      默认值： false
#   [*charset*]            - 默认使用的字符集. 
#     有效值: 参考标准的nginx官网配置文档   默认值： 'utf-8'
#   [*server_name*]        - 有效的server_name
#     有效数据类型为Strings                 默认值： undef(未定义)
#   [*vhost_log*]          - 日志存放路径的最后一层，说明如下
#     1、此路径生成规则为${::nginx::log_dir}/${vhost_log}
#     2、因此，这里不支持放在${::nginx::log_dir}目录以外的路径
#     3、如果需要将日志放在/var/log/nginx/server_aaa，则此处设置值应为： 'server_aaa'  即可
#     4、puppet应用时，会将路径创建，触发nginx更新，会在路径下创建access.log和error.log
#   [*ssl_pem*]            - 需要配置ssl时，证书文件名字，此处仅提供证书名字即可，但有效证书需符合如下要求：
#     1. 证书文件为一个单独的有效文件，其中应包含私钥和证书(一个授权证书[可选的一个或多个根证书])
#     2. 证书文件在客户端的下发路径为 init.pp { $ssl_dir = ? }
#     3. 证书文件在puppet server的路径为此模块下的 files/ssl_certs 目录内,需手工创建或上传
#   [*k_timeout*]          - nginx配置 keepalive_timeout
#     有效取值参考nginx官方文档             默认值： undef(未定义)
#   [*body_size*]          - nginx配置 client_max_body_size
#     有效值为nginx官网文档                 默认值： undef(未定义)
#   [*files_dir*]          - 在不使用upstream时，如果需要http的文件服务器时，配置此项:
#     有效值取值：一个本地的有效路径        默认值： undef(未定义)
#   [*file_location*]      - 当设置files_dir后，默认页面请求的location。
#     有效取值：nginx的有效location字段     默认值： '/'
#   [*index_files*]        - 当设置files_dir后，默认页面的资源类型。
#     有效值参考nginx官网文档               默认值： 'index.html index.htm'
#   [*auto_index*]         - 当设置files_dir后，是否在页面以列出目录结构
#     有效值 (true[列出]|false[不列出])     默认值： false
#   [*custom_lines*]       - 自定义配置行
#     有效数据类型为列表,                   默认值:  undef
#
define nginx::resource::vhost (
  $ensure        = 'present',
  $upstream      = false,
  $real_servers  = [],
  $port          = 80,
  $charset       = 'utf-8',
  $server_name   = undef,
  $vhost_log     = undef,
  $ssl_pem       = undef,
  $k_timeout     = undef,
  $body_size     = undef,
  $gzip_types    = undef,
  $files_dir     = undef,
  $file_location = '/',
  $index_files   = 'index.html index.htm',
  $auto_index    = false,
  $custom_lines  = undef,
) {

  $upstream_name = $name
  $location_dir  = "${::nginx::vhost_dir}/${name}_locations"

  File {
    group   => 0,
    owner   => $::nginx::work_user,
  }

  if !(defined(File[$location_dir])){
    file { $location_dir: ensure => 'directory' }
  }

  file { "vhost_${name}":
    mode    => 0644,
    ensure  => $eusure,
    path    => "${::nginx::vhost_dir}/vhost_${name}.conf",
    content => template('nginx/vhosts/vhost.erb')
  } 

  if ($vhost_log != undef) {
    file { "log_dir_${name}":
      ensure => directory,
      before => File["vhost_${name}"],
      path   => "${::nginx::log_dir}/${vhost_log}",
    }
  }
}
