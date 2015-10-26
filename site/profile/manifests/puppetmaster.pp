class profile::puppetmaster (
  String $gms_api_token         = hiera('gms_api_token', ''),
  String $gms_server_fqdn       = hiera('gms_server_fqdn'),
  String $git_management_system = hiera('git_management_system', 'gitlab'),
  String $project_name          = hiera('project_name', 'puppet/control-repo'),
) {

  Firewall {
    proto   => 'tcp',
    action  => 'accept',
  }
  firewall { '100 allow puppet': dport => '8140', }
  firewall { '200 allow mco': dport => '61613', }
  firewall { '300 allow console https': dport => '443', }
  firewall { '400 allow webhook call from gms': dport => '8088', }

  class { 'hiera':
    hierarchy  => [
      'virtual/%{::virtual}',
      'nodes/%{::trusted.certname}',
      'common',
    ],
    hiera_yaml => '/etc/puppetlabs/code/hiera.yaml',
    datadir    => '/etc/puppetlabs/code/environments/%{environment}/hieradata',
    owner      => 'root',
    group      => 'root',
    notify     => Service['pe-puppetserver'],
  }

  #BEGIN - Generate an SSH key for r10k to connect to git
  $r10k_ssh_key_file = '/root/.ssh/r10k_rsa'
  exec { 'create r10k ssh key' :
    command => "/usr/bin/ssh-keygen -t rsa -b 2048 -C 'r10k' -f ${r10k_ssh_key_file} -q -N ''",
    creates => $r10k_ssh_key_file,
  }
  #END - Generate an SSH key for r10k to connect to git  

  #BEGIN - Add deploy key and webook to git management system

  class { 'pe_r10k':
    remote       => "git@${gms_server_fqdn}:${project_name}.git",
    git_settings => {
      'provider'    => 'rugged',
      'private_key' => '/root/.ssh/r10k_rsa',
    },
  }

  class {'r10k::webhook::config':
    enable_ssl      => false,
    protected       => false,
    use_mcollective => false,
  }

  class {'r10k::webhook':
    user    => 'root',
    group   => '0',
    require => Class['r10k::webhook::config'],
  }

  if ($git_management_system in ['gitlab', 'github']) and ($gms_api_token != '') {

    git_deploy_key { "add_deploy_key_to_puppet_control-${::fqdn}":
      ensure       => present,
      name         => $::fqdn,
      path         => "${r10k_ssh_key_file}.pub",
      token        => $gms_api_token,
      project_name => $project_name,
      server_url   => "https://${gms_server_fqdn}",
      provider     => $git_management_system,
    }

    Git_webhook {
      ensure               => present,
      token                => $gms_api_token,
      merge_request_events => false,
      project_name         => $project_name,
      server_url           => "https://${gms_server_fqdn}",
      provider             => $git_management_system,
    }

    git_webhook { "web_post_receive_webhook_payload_compile_${::fqdn}" :
      webhook_url  => "http://${::fqdn}:8088/payload",
    }
    git_webhook { "web_post_receive_webhook_module_compile_${::fqdn}" :
      webhook_url  => "http://${::fqdn}:8088/module",
    }

  }
  #END - Add deploy key and webhook to git management system

}
