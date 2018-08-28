# define: nginx::resource::location
#   用于默认虚拟主机配置文件管理
#   模板： templates/vhosts/location.eurb
#
# Parameters:
#   [*ensure*]             - 创建或删除对应的配置文件资源.
#     有效值: (present|absent).             默认值: present
#   [*superior*]           - 解释同=> nginx::resource::tracker_location
#   [*location*]           - nginx的有效location字段，此参数不得为空
#     例如： '/'                            默认值：'/'
#   [*custom_lines*]       - 自定义一个location内容,有效值数据类型为列表,每个字段为一行
#     有效值：不得小于1的列表               默认值：undef
define nginx::resource::location (
  $ensure          = 'present',
  $superior        = undef,
  $location        = '/',
  $custom_lines    = undef,
) {

  if $superior != undef {
    $upstream = $superior
  } else {
    fail("${superior} is a invalid param")
  }
  $dest_dir  = "${::nginx::vhost_dir}/${superior}_locations"

  File {
    group   => 0,
    owner   => $::nginx::work_user,
  }

  if defined(File[$dest_dir]) {
    file { "location_${superior}_${name}":
      mode    => 0644,
      ensure  => $ensure,
      path    => "${dest_dir}/${name}.conf",
      content => template('nginx/vhosts/location.erb')
    }
  } else {
    fail("${dest_dir} no such directory")
  }
}
