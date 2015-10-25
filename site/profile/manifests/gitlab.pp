class profile::gitlab {

  file { ['/etc/gitlab', '/etc/gitlab/ssl'] :
    ensure => directory,
  }

  file { "/etc/gitlab/ssl/${fqdn}.key" :
    ensure => file,
    source => "${settings::privatekeydir}/${trusted['certname']}.pem",
    notify => Exec['gitlab_reconfigure'],
  }

  file { "/etc/gitlab/ssl/${fqdn}.crt" :
    ensure => file,
    source => "${settings::certdir}/${trusted['certname']}.pem",
    notify => Exec['gitlab_reconfigure'],
  }

  class { 'gitlab':
    external_url => hiera( 'gms_server_url', "https://${::fqdn}") ,
    require => File["/etc/gitlab/ssl/${fqdn}.key", "/etc/gitlab/ssl/${fqdn}.key"],
  } ->

  git_webhook { 'web_post_receive_webhook' :
    ensure               => present,
    webhook_url          => 'https://master.inf.puppetlabs.com:8088/payload',
    token                => hiera('gms_api_token'),
    merge_request_events => true,
    project_name         => 'puppet/control-repo',
    server_url           => 'http://centos6b.syd.puppetlabs.demo',
    provider             => 'gitlab',
  } ->

  git_webhook { 'web_post_receive_webhook' :
    ensure               => present,
    webhook_url          => 'https://master.inf.puppetlabs.com:8088/module',
    token                => hiera('gms_api_token'),
    merge_request_events => true,
    project_name         => 'puppet/control-repo',
    server_url           => 'http://centos6b.syd.puppetlabs.demo',
    provider             => 'gitlab',
  }

}
