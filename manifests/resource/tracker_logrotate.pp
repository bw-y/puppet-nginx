# define: nginx::resource::tracker_logrotate
#   用于设置tracker对应的日志切分策略
#
# Parameters:
#   [*dpath*]              - 日志文件切分压缩后存放的目录路径
#     取值范围：一个有效目录路径此。        默认值：undef(未定义)
#   [*log_file_tag*]       - 此参数注释可参考nginx::resource::tracker_location的此参数的注释
#   [*ensure*]             - 创建或删除对应的资源
#     有效值(present|absent).               默认值: present
#   [*cron_min*]           - 日志切分的分钟周期，有效值取crontab的第一个字段
#     默认值： '*/2'
#   [*cron_min*]           - 日志切分的小时周期，有效值取crontab的第二个字段
#     默认值： '*'
#   [*remain_min*]         - 日志压缩后的文件最终保留时间,单位分钟,0表示不使用日志清理功能
#     有效值: int数字                       默认值: 0
#   [*remain_cron_min*]    - 当remain_min不等于0时,定时删除的分钟周期,有效值取crontab的第一个字段
#     默认值: '0'
#   [*remain_cron_hour*]   - 当remain_min不等于0时,定时删除的分钟周期,有效值取crontab的第二个字段
#     默认值: '22'
#   [*backup_dir*]         - 是否在本地节点备份文件,undef等于不做此项相关配置,且相关备份命令为确认删除状态(absent)
#     有效值: 一个长度不为/的有效绝对路径.  默认值: undef  
#   [*backup_days*]	   - 当backup_dir是一个有效路径时,此路径的文件在本地的保留天数
#     有效值: int数字                       默认值: 14
#   [*backup_u_str*]       - 当backup_dir打开时,默认每隔5分钟会备份一次文件到指定路径,在磁盘故障时,为避免多个备份命令(rsync)启动,需要设置一个随机字符串作为进程标识
#     有效值: 大于6位的随机字串(大小写和数字) 默认值: 'BjtcKwgM4Brk'
define nginx::resource::tracker_logrotate (
  $dpath            = undef,
  $log_file_tag     = undef,
  $ensure           = 'present',
  $cron_min         = '*/2',
  $cron_hour        = '*',
  $remain_min       = '0',
  $remain_cron_min  = '0',
  $remain_cron_hour = '22',
  $backup_dir       = undef,
  $backup_days      = '14',
  $backup_u_str     = 'BjtcKwgM4Brk',
){

  $clean_py         = "${::nginx::down_dir}/${::nginx::log_clean_script}"
  if $dpath {
    $valid_dpath    = last_str($dpath)
  }
  if $backup_dir {
    $valid_backup_dir = last_str($backup_dir)
  }

  logrotate::tracker_rule { $name:
    ensure           => $ensure,
    spath            => $::nginx::log_files[$log_file_tag],
    dpath            => $valid_dpath,
    cron_min         => $cron_min,
    cron_hour        => $cron_hour,
    clean_py         => $clean_py,
    remain_min       => $remain_min,
    remain_cron_min  => $remain_cron_min,
    remain_cron_hour => $remain_cron_hour
  }

  if $backup_dir {
    if $backup_dir == '/' {
      fail("nginx::resource::tracker_logrotate[${name}]: backup_dir is an invalid path")
    }
    if !defined(File[$backup_dir]) {
      file { $backup_dir: ensure => directory }
    }
    $backup_dir_ensure = present
  } else {
    $backup_dir_ensure = absent
  }

  rsync::resource::cmd { "${name} backup":
    ensure   => $backup_dir_ensure,
    src      => "${valid_dpath}/",
    dest     => "${valid_backup_dir}/",
    uniq_str => $backup_u_str,
  }
  
  cron { "${name} ${backup_dir} remain ${backup_days} days":
    ensure      => $backup_dir_ensure,
    minute      => '*/5',
    hour        => '*',
    user        => root,
    environment => 'PATH=/bin:/usr/bin:/sbin:/usr/sbin',
    command     => "${clean_py} ${backup_dir} ${backup_days}",
  }

}
