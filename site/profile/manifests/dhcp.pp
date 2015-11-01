class profile::dhcp {

  require profile::iptables

  class { 'dhcp':
    service_ensure => running,
    dnsdomain      => [ 'puppetlabs.demo', ],
    nameservers    => ['8.8.8.8'],
    interfaces     => ['eth1'],
    pxeserver      => '10.20.1.53',
    pxefilename    => 'undionly-20140116.kpxe',
    #omapi_port     => 7911,
  }

  dhcp::pool{ 'puppetlabs.demo':
    network => '10.20.1.0',
    mask    => '255.255.255.0',
    range   => ['10.20.1.150', '10.20.1.200'],
  }

}
