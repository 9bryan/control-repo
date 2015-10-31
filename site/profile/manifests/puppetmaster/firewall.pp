class profile::puppetmaster::firewall {

  service { 'firewalld':
    ensure => stopped,
    enable => false,
  }

  package { 'iptables-services':
    ensure => installed,
  }
  service { ['iptables', 'ip6tables']:
    ensure => running,
    enable => true,
  }

  Firewall {
    proto   => 'tcp',
    action  => 'accept',
  }

  firewall { '100 allow puppet': dport => '8140', }

  if $trusted['extensions']['pp_role'] == 'master_of_masters' {
    firewall { '200 allow mco': dport => '61613', }
    firewall { '300 allow console https': dport => '443', }
    firewall { '400 allow webhook call from gms': dport => '8088', }
    firewall { '500 allow puppetdb https': dport => '8081', }
    firewall { '600 allow classifer https': dport => '4433', }
  }

}
