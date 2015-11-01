class profile::puppetmaster::firewall {

  require profile::iptables

  Firewall {
    proto   => 'tcp',
    action  => 'accept',
  }

  firewall { '100 allow puppet': dport => '8140', }
  firewall { '200 allow webhook call from gms': dport => '8088', }

  if $::trusted['extensions']['pp_role'] == 'master_of_masters' {
    firewall { '300 allow mco': dport => '61613', }
    firewall { '400 allow console https': dport => '443', }
    firewall { '500 allow puppetdb https': dport => '8081', }
    firewall { '600 allow classifer https': dport => '4433', }
  }

}
