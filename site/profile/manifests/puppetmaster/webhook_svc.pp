class profile::puppetmaster::webhook_svc {

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

}
