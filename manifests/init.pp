class grafana (
    $version            = $grafana::params::version,
    $download_url       = "https://github.com/grafana/grafana/archive/v${version}.tar.gz",
    $install_dir        = $grafana::params::install_dir,
    $symlink            = $grafana::params::symlink,
    $symlink_name       = $grafana::params::symlink_name,
    $grafana_user       = $grafana::params::grafana_user,
    $grafana_group      = $grafana::params::grafana_group,
    $elasticsearch_host = $grafana::params::elasticsearch_host,
    $elasticsearch_port = $grafana::params::elasticsearch_port,
    $graphite_host      = $grafana::params::graphite_host,
    $graphite_port      = $grafana::params::graphite_port,
    $influxdb_host      = $grafana::params::influxdb_host,
    $influxdb_port      = $grafana::params::influxdb_port,
    $influxdb_user      = $grafana::parama::influxdb_user,
    $influxdb_password  = $grafana::params::influxdb_password,
    $influxdb_dbname    = $grafana::params::influxdb_dbname,
) inherits grafana::params {
    archive { "grafana-${version}":
        ensure           => present,
        url              => $download_url,
        target           => $install_dir,
        follow_redirects => true,
        checksum         => false,
    }

    file { "${install_dir}/grafana-${version}/src/config.js":
        ensure  => present,
        content => template('grafana/config.js.erb'),
        owner   => $grafana_user,
        group   => $grafana_group,
        require => Archive["grafana-${version}"],
    }

    if $symlink {
        file { $symlink_name:
            ensure  => link,
            target  => "${install_dir}/grafana-${version}",
            require => Archive["grafana-${version}"],
        }
    }

    $list = query_nodes('Class[collectd]')

    #$filtered_list = inline_template('<%= @list.map {|server| server.gsub!(".","_") } %>')

    notify{"list ${list} ": }
    #notify{"filtered_list ${filtered_list}": }

    file { "${install_dir}/grafana-${version}/src/app/dashboards/default.json": 
        ensure => present,
        content => template('grafana/default.json.erb'),
        owner => $grafana_user,
        group => $grafana_group,
        require => Archive["grafana-${version}"],
    }
}
