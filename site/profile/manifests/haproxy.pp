class profile::haproxy {

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

}
