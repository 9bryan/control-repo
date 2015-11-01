class profile::gitlab (
  String $gms_server_url = "https://${::fqdn}",
) {

  require profile::iptables

  firewall { '100 allow https':
    proto  => 'tcp',
    dport  => '443',
    action => 'accept',
  }

  file { ['/etc/gitlab', '/etc/gitlab/ssl'] :
    ensure => directory,
  }

  file { "/etc/gitlab/ssl/${::fqdn}.key" :
    ensure => file,
    source => "${settings::privatekeydir}/${::trusted['certname']}.pem",
    notify => Exec['gitlab_reconfigure'],
  }

  file { "/etc/gitlab/ssl/${::fqdn}.crt" :
    ensure => file,
    source => "${settings::certdir}/${::trusted['certname']}.pem",
    notify => Exec['gitlab_reconfigure'],
  }

  class { 'gitlab':
    external_url => $gms_server_url,
    require      => File[
      "/etc/gitlab/ssl/${::fqdn}.key",
      "/etc/gitlab/ssl/${::fqdn}.key"
    ],
  }

}
