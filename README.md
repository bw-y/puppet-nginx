# (注：此模块所依赖的二进制包不提供)
# (注：此模块仅供参考)
     

# nginx

#### Table of Contents

1. [Overview](#overview)
2. [Usage - Configuration options and additional functionality](#usage)
3. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
4. [Limitations - OS compatibility, etc.](#limitations)

## Overview
nginx安装、部署，配置模块

## Usage
例1, 仅安装，不做配置：
```
node 'lab.bw-y.com' {
  class { '::nginx': }
```
例2，安装并配置一个简单的tracker:
```
node 'lab.bw-y.com' {
  class { '::nginx':
    log_files => {
      aa => '/var/log/nginx/lab_access.log',
    },
    tracker_servers => {
      'nginxserver'  => {
        servers      => 'server_name1 server_name2 server_name3',
        root         => [ '/opt/nginx_files/static', '/opt/nginx_files' ],
        static_dir   => 'default',
        log_file_tag => 'aa',
      }
    },
    tracker_locations => {
      'irt_irs' => { 
        location     => '= /av',
        superior     => 'nginxserver',
        log_file_tag => 'aa'
      }
    }
  } 
}
```
## Reference

### Classes
* nginx::params : 参数类，用于平台资源区分
* nginx::pre : 准备工作，文件下发，目录创建等
* nginx::install : 调用安装脚本
* nginx::config : 配置nginx(引用子配置，顺序约束)
  * nginx::config::main : 主配置文件引用
  * nginx::config::default : 默认server的引用
    * nginx::resource::vhost_default : define资源`vhost_default`，用于被config::default调用
  * nginx::config::tracker_server : tracker的server部分引用
    * nginx::resource::tracker_server : define资源`tracker_server`，用于被config::tracker_server调用
  * nginx::config::tracker_location : tracker的location部分引用
    * nginx::resource::tracker_location : define资源`tracker_location`,用于被config::tracker_location调用
  * nginx::config::tracker_logrotate : tracker日志切分引用
    * nginx::resource::tracker_logrotate : define资源`tracker_logrotate`,用于被config::tracker_logrotate调用
* nginx::service : 被config的变更会出发nginx的reload操作
### Other Define
* nginx::resource::file_check : define资源，用于静态文件引用和生产压缩文件
* nginx::resource::pkg_check : define资源，用于依赖安装包检测，并安装
* nginx::resource::tracker_static_file : define资源，用于被tracker_server部分引用，并下发静态文件和生成对应压缩文件

### Parameters
参数部分仅提供init.pp中的参数列表说明，其它resouce中的define资源，见代码文件上方对应的注释部分

#### `down_dir`
安装包和脚本等文件下发到客户端的路径，若无特殊需求，不推荐修改。有效数据类型Strings。 默认值： `/opt/nginx`
#### `conf_dir`
nginx主配置文件目录，若无特殊需求，不推荐修改。有效数据类型Strings。 默认值：`/etc/nginx`
#### `vhost_dir`
nginx子配置文件目录，若无特殊需求，不推荐修改。有效数据类型Strings。 默认值：`/etc/nginx/vhost`
#### `ssl_dir`
nginx的ssl证书存放目录，若无特殊需求，不推荐修改。有效数据类型Strings。 默认值：`/etc/nginx/ssl`
#### `log_dir`
nginx日志存放目录，若无特殊需求，不推荐修改。有效数据类型Strings。 默认值：`/var/log/nginx`
#### `pid_file`
nginx的pid文件路径，若特殊需求，不推荐修改。有效数据类型Strings。 默认值：`/var/run/nginx.pid`
#### `err_log`
nginx的若无日志路径，若特殊需求，不推荐修改。有效数据类型Strings。 默认值：`/var/log/nginx/error.log`
#### `work_user`
nginx运行所使用的用户，若特殊需求，不推荐修改。有效数据类型Strings。 默认值：`www-data`
#### `default_type`
nginx.conf配置文件中的http部分的default_type配置，若特殊需求，不推荐修改。有效数据类型Strings。 默认值：`application/octet-stream`
#### `gzip_types`
nginx.conf配置文件中的http部分的gzip压缩类型配置，若特殊需求，不推荐修改。有效数据类型Strings。 默认值：`application/x-javascript`
#### `nginx_manage`
puppet检查到nginx文件变更时，触发nginx控制脚本的动作。有效值数据类型为Strings，有效值范围[start|stop|restart|reload|status|configtest|rotate]。 默认值：`reload`
#### `worker_connections`
nginx.conf配置文件中的worker_connections配置。有效值数据类型为Integers。默认值：`102400`
#### `worker_rlimit_nofile`
nginx.conf配置文件中的worker_rlimit_nofile配置。有效值数据类型为Integers。默认值：`1048576`
#### `old_conf`
如果暂时无法使用新的配置模板，可以手工将放到模块的templates/old_conf/目录下，将文件名以数组的形式传递即可。  默认值： [] 
#### `log_files`
所有需要使用有效日志路径，有效数据类型为Hashes，此变量主要为了简化日志的重复调用。默认值为空。使用方式如下：
```
node 'lab.bw-y.com' {
  class { '::nginx':
    log_files => {
      log_a => '/var/log/nginx/access.log_a',
      log_b => '/var/log/nginx/access.log_b',
    },
    tracker_logrotate => {
      iwt => { 
        ...,
        ...,
        log_file_tag => 'log_a',
      }
    },
    tracker_servers => {
      'nginxserver'  => {
        ...,
        ...,
        log_file_tag => 'log_a',
      }
    },
    tracker_locations => {
      'irt_irs' => { 
        ...,
        ...,
        log_file_tag => 'log_a'
      }
    }
  } 
}
```
#### `vhosts`
可以配置多个域名映射相同或不同的目录，以http的方式访问，有效数据类型为Hashes，其有效参数参考define资源`nginx::resource::vhost`。 默认值为空
#### `vhosts_vhosts_defaults`
`vhosts`的默认值,参考同`tracker_logrotate_defaults`，默认值为空
#### `locations`
用于`vhosts`对应的location，依赖vhosts，有效数据类型参考define资源`nginx::resource::location`。 默认值为空
#### `locations_defaults`
`locations`的默认值，参考同`tracker_logrotate_defaults`，默认值为空
#### `tracker_logrotate`
配置单个或多个日志切分的有效文件，依赖变量`log_files`，有效数据类型为Hashes，其有效参数参考define资源`nginx::resource::tracker_logrotate`。 默认值为空
#### `tracker_logrotate_defaults`
当`tracker_logrotate`配置多个key时，可以使用此变量优化数据结构，有效数据类型为Hashes，语法参考[puppetlabs官方文档](https://docs.puppetlabs.com/references/latest/function.html#createresources)。 默认值为空
#### `tracker_servers`
此变量用于部署单个或多个tracker时设置，依赖变量`log_files`，有效数据类型为Hashes，其有效参数参考define资源`nginx::resource::tracker_server`。 默认值为空
#### `tracker_servers_defaults`
`tracker_servers`的默认值配置，参考同`tracker_logrotate_defaults`，默认值为空
#### `tracker_locations`
此变量用于配置单个或多个tracker的location，依赖变量`log_files`和`tracker_servers`，有效数据类型为Hashes，其有效参数参考define资源`nginx::resource::tracker_location`。 默认值为空
#### `tracker_locations_defaults`
`tracker_locations`的默认值配置，参考同`tracker_logrotate_defaults`，默认值为空
#### `stage`
执行顺序，见stdlib::stages

## Limitations
此模块目前仅在ubuntu(10.04/12.04/14.04)和redhat(centos)5/6上测试通过。
