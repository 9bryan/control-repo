class profile::puppetmaster::firewall {

  Firewall {
    proto   => 'tcp',
    action  => 'accept',
  }

  firewall { '100 allow puppet': dport => '8140', }
  firewall { '200 allow mco': dport => '61613', }
  firewall { '300 allow console https': dport => '443', }
  firewall { '400 allow webhook call from gms': dport => '8088', }

}
