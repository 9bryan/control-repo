class profile::haproxy {

  require profile::iptables

  class { 'haproxy': }

  haproxy::listen { 'puppet00':
    collect_exported => true,
    mode             => 'tcp',
    ipaddress        => $::networking[interfaces][enp0s8][ip],
    ports            => '8140',
    options          => {
      'option'       => [ 'tcplog' ],
      'balance' => 'roundrobin',
    },
  }

  firewall { '100 allow puppet':
    dport  => '8140',
    proto  => 'tcp',
    action => 'accept',
  }

}
