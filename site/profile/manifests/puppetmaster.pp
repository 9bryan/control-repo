class profile::puppetmaster (
  String  $gms_api_token         = '',
  String  $gms_server_fqdn       = 'gitlab.puppetlabs.demo',
  String  $git_management_system = 'gitlab',
  String  $project_name          = 'puppet/control-repo',
  String  $r10k_ssh_key_file     = '/root/.ssh/r10k_rsa',
  Boolean $generate_new_key      = true,
) {

  require profile::puppetmaster::firewall
  require profile::puppetmaster::hiera
  require profile::puppetmaster::webhook_svc

  # Generate an SSH key for r10k to connect to git
  if $generate_new_key {
    exec { 'create r10k ssh key' :
      command => "/usr/bin/ssh-keygen -t rsa -b 2048 -C 'r10k' -f ${r10k_ssh_key_file} -q -N ''",
      creates => $r10k_ssh_key_file,
    }
  }

  class { 'profile::puppetmaster::r10k_git':
    gms_api_token         => $gms_api_token,
    gms_server_fqdn       => $gms_server_fqdn,
    git_management_system => $git_management_system,
    project_name          => $project_name,
    r10k_ssh_key_file     => $r10k_ssh_key_file,
  }

  # If I'm a compile master, add me to the load balancer pool
  if $trusted['extensions']['pp_role'] == compile_master {
    @@haproxy::balancermember { $::fqdn:
      listening_service => 'puppet00',
      ports             => '8140',
      server_names      => $::hostname,
      ipaddresses       => $::networking[interfaces][enp0s8][ip],
      options           => 'check',
    }
  }

}
