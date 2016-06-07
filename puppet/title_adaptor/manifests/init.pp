# Install and configure the stub
class title_adaptor (
    $port = '5010',
    $host = '0.0.0.0',
    $source = 'git@github.com:LandRegistry/dm-title-adaptor-stub.git',
    $branch_or_revision = 'develop',
    $subdomain = 'title',
    $domain = undef,
    $owner = 'vagrant',
    $group = 'vagrant',
    $app_dir = "/opt/${module_name}",
) {
  require ::standard_env

  vcsrepo { "${app_dir}":
    ensure   => latest,
    provider => git,
    source   => $source,
    revision => $branch_or_revision,
    owner    => $owner,
    group    => $group,
    notify   => Service[$module_name],
  }

  file { "${app_dir}/bin/run.sh":
    ensure  => 'file',
    mode    => '0755',
    owner   => $owner,
    group   => $group,
    content => template("${module_name}/run.sh.erb"),
    require => Vcsrepo["/opt/${module_name}"],
    notify  => Service[$module_name],
  }

  file { "/var/run/${module_name}":
    ensure => 'directory',
    owner  => $owner,
    group  => $group,
  }

  file { "/etc/systemd/system/${module_name}.service":
    ensure  => 'file',
    mode    => '0755',
    owner   => $owner,
    group   => $group,
    content => template("${module_name}/service.systemd.erb"),
    notify  => [
      Exec['systemctl-daemon-reload'],
      Service[$module_name]
    ],
  }

  service { $module_name:
    ensure   => 'running',
    enable   => true,
    provider => 'systemd',
    require  => [
      Vcsrepo["${app_dir}"],
      File["/opt/${module_name}/bin/run.sh"],
      File["/etc/systemd/system/${module_name}.service"],
      File["/var/run/${module_name}"],
    ],
  }

  file { "/etc/nginx/conf.d/${module_name}.conf":
    ensure  => 'file',
    mode    => '0755',
    content => template("${module_name}/nginx.conf.erb"),
    owner   => $owner,
    group   => $group,
    notify  => Service['nginx'],
  }

  if $environment == 'development' {
    standard_env::dev_host { $subdomain: }
  }

}
