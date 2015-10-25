class role::all_in_one_pe {

  # I prefer to classify with this in the PE Master console group
  # that way all compile masters get a webhook as well.
  #include profile::webhook_no_mcollective
  include profile::puppetmaster

}
