# define: nginx::resource::tracker_location 
#   用于tracker的自定义location文件生成控制
#   模板： templates/vhosts/tracker_location.erb
#
# Parameters:
#   [*ensure*]             - 创建或删除对应的配置文件资源：
#     有效值(present|absent).               默认值 present
#   [*location*]           - nginx的有效location字段，此参数不得为空
#     例如： '= /irt'                       默认值：undef(未定义)
#   [*superior*]           - 此location所属的server对应的( init.pp => tracker_servers ) 实例化对应某个tracker_server的name
#     exam: 
#       tracker_servers => {
#         aaa => { ... },
#         bbb => { ... },
#       },
#       tracker_locations => {
#         bwy_aaa => { 
#           ...
#           superior => 'aaa' 
#         },
#         ybw_bbb => { superior => 'bbb' },
#       }
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
#   [*mobile*]             - 是否开启移动端配置,逻辑参考erb模板部分
#     有效值(true[开启]|false[不开启])      默认值： false
#   [*buffer_size*]        - 当开启移动端配置时，client_body_buffer_size具体值
#     有效值参考nginx官方文档               默认值：undef(未定义)
#   [*hypers*]             - location的hypers配置。
#     默认值： '_iwt_id' 
#   [*hypers_cookie*]      - location的hypers_cookie配置.
#     默认 '_iwt_id'
#   [*hypers_cookie_domain*] - location的hypers_cookie_domain配置. 
#     默认值见下方代码
#   [*hypers_extra*]       - tracker location的一些扩展选项是否开启
#     有效值(true[开启]|false[不开启])      默认值： true
#   [*hypers_base*]        - tracker location的一些基础值是否开启
#     有效值(true[开启]|false[不开启])      默认值： true
#   [*hypers_jsonp*]       - tracker location的hypers_jsonp配置
#     有效值参考内部文档                    默认值:  jsonp
#   [*session_code*]       - hypers_session_code和hypers_cookie_session_code的配置
#     有效值参考内部文档. false不设置       默认值:  GU
#   [*rewrite_uri*]        - 配置: hypers_rewrite_uri|hypers_rewrite_cookies|hypers_rewrite_session
#     有效值参考内部文档. false不设置       默认值:  false
#   [*jsonp_add_value*]    - jsonp_add_value相关配置,具体逻辑见erb模板部分
#     有效值(true[开启]|false[不开启])      默认值： true
#   [*custom_lines*]       - 自定义配置行
#     有效数据类型为列表,                   默认值:  undef
define nginx::resource::tracker_location(
  $ensure               = 'present',
  $superior             = undef,
  $location             = undef,
  $log_file_tag         = undef,
  $log_format           = 'iwt',
  $hypers               = '_iwt_id',
  $hypers_cookie        = '_iwt_id',
  $mobile               = false,
  $buffer_size          = undef,
  $hypers_extra         = true, 
  $hypers_base          = true,
  $hypers_jsonp         = 'jsonp',
  $session_code         = 'GU',
  $rewrite_uri          = false,
  $jsonp_add_value      = true,
  $custom_lines         = undef,
  $hypers_cookie_domain = 'bw-y.com=.bw-y.com&www.bw-y.com=.bw-y.com',
){

  $log_file  = $::nginx::log_files[$log_file_tag]
  $log_dir   = dirname($log_file)
  $dest_dir  = "${::nginx::vhost_dir}/${superior}_locations"

  File {
    group   => 0,
    owner   => $::nginx::work_user,
  }
  
  if !defined(File[$log_dir]){
    file { $log_dir: ensure => 'directory' }
  } 

  if defined(File[$dest_dir]) {
    file { "location_${superior}_${name}":
      mode    => 0644,
      ensure  => $ensure,
      path    => "${dest_dir}/${name}.conf",
      content => template('nginx/vhosts/tracker_location.erb')
    }
  } else {
    fail("${dest_dir} no such directory")
  }
}
