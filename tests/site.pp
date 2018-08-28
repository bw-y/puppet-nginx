node
  'ubt14-04.lab.com',
  'ubt12-04.mos.com',
  'ubt14-04.mos.com',
  'centos5.mos.com',
  'centos6.mos.com',
  'rhel5.mos.com',
  'rhel6.mos.com'
{
  class { '::nginx':
    log_files => {
      aa => '/var/log/nginx/aa/access.log',
      bb => '/var/log/nginx/bb.log',
    },
    vhosts => {
      tmpserver => {
        upstream      => true,
        real_servers  => ['10.7.0.11:80 fail_timeout=0', '10.1.0.96:80 fail_timeout=2'],
        server_name   => 'www.bw-y.com',
        k_timeout     => 5,
        gzip_types    => 'text/plain application/x-javascript text/css application/xml',
      }
    },
    locations => {
      root => { superior => 'tmpserver' }
    },
    tracker_logrotate => {
      irs => { 
        log_file_tag => 'aa',
        dpath        => '/opt/tracker_irs_tar'
      }
    },
    tracker_servers_defaults => {
      server_name  => 'www.aa.com www.bb.com www.cc.com',
      root         => ['/home/aaa/bb', '/home/aaa'],
      static_dir   => 'default',
      log_file_tag => 'aa',
    },
    tracker_servers => {
      'az' => {},
      'ax' => { port => 443, ssl_pem => 'ax.pem' },
    },
    tracker_locations_defaults => {
      location  => '= /bwy',
    },
    tracker_locations => {
      'bwy_az'     => { superior => 'az', log_file_tag => 'aa' },
      'bwy_ssl_ax' => { superior => 'ax', log_file_tag => 'bb' },
    },
  } 
}
