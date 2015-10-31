#!/opt/puppetlabs/puppet/bin/ruby

require 'rugged'

environment = ARGV[0]

repo = Rugged::Repository.discover("/etc/puppetlabs/code/environments/#{environment}")
head  = repo.head
sha = head.target.oid
message = head.target.message.strip
remote = repo.config.to_hash['remote.origin.url']
url = remote.gsub(/.git$/, '')

print "[#{message}](#{url}/tree/#{sha})"
