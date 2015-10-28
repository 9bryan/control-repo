class profile::puppetmaster::r10k_git (
  String  $gms_api_token,
  String  $gms_server_fqdn,
  String  $git_management_system,
  String  $project_name,
  String  $r10k_ssh_key_file,
) {

  class { 'pe_r10k':
    remote       => "git@${gms_server_fqdn}:${project_name}.git",
    git_settings => {
      'provider'    => 'rugged',
      'private_key' => '/root/.ssh/r10k_rsa',
    },
  }

  # Add deploy key and webook to git management system
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

    git_webhook { "web_post_receive_webhook_payload_${::fqdn}" :
      ensure               => present,
      webhook_url          => "http://${::fqdn}:8088/payload",
      token                => $gms_api_token,
      merge_request_events => false,
      project_name         => $project_name,
      server_url           => "https://${gms_server_fqdn}",
      provider             => $git_management_system,
    }

  }

}
