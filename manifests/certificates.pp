# Copyright (C) 2015, Wazuh Inc.
# Wazuh repository installation
class wazuh::certificates (
  $certs_tmp_dir = '/tmp',
  $wazuh_repository = 'packages.wazuh.com',
  $wazuh_version = '4.14',
  $indexer_certs = [],
  $manager_certs = [],
  $manager_master_certs = [],
  $manager_worker_certs = [],
  $dashboard_certs = []
) {
  file { 'Configure Wazuh Certificates config.yml':
    owner   => 'root',
    path    => "${certs_tmp_dir}/config.yml",
    group   => 'root',
    mode    => '0640',
    content => template('wazuh/wazuh_config_yml.erb'),
  }

  file { "${certs_tmp_dir}/wazuh-certs-tool.sh":
    ensure => file,
    source => "https://${wazuh_repository}/${wazuh_version}/wazuh-certs-tool.sh",
    owner  => 'root',
    group  => 'root',
    mode   => '0740',
  }

  exec { 'Create Wazuh Certificates':
    path    => '/usr/bin:/bin',
    command => "bash ${certs_tmp_dir}/wazuh-certs-tool.sh --all",
    creates => "${certs_tmp_dir}/wazuh-certificates",
    require => [
      File["${certs_tmp_dir}/wazuh-certs-tool.sh"],
      File["${certs_tmp_dir}/config.yml"],
    ],
  }
  file { 'Copy all certificates into module':
    ensure  => 'directory',
    source  => "${certs_tmp_dir}/wazuh-certificates/",
    recurse => 'remote',
    path    => "/etc/puppetlabs/code/environments/${environment}/modules/archive/files/",
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }
}
