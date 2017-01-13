#!/usr/bin/env ruby

require 'yaml'
require 'colorize'

OUTFILE = "../credentials/credentials.yml"

puts "Boo."


def fail_exit(msg)
  STDERR.puts "ERROR: ".bold.red + msg.red
  exit(-1)
end

credential_names = %w(gist-url
  github-private-key
  docker-hub-username
  docker-hub-password
  docker-hub-email
  docker-hub-image-hello-world
  cf-api
  cf-username
  cf-password
  cf-organization
  cf-space
  git-uri-bump-semver
  bosh-director
  bosh-username
  bosh-password
  bosh-stemcell-name
  docker-hub-image-47-tasks
  docker-hub-image-47-tasks-repository
  section-47-git-redis-manifest
  section-47-git-redis-name
  docker-hub-image-dummy-resource
  pivnet-api-token
  aws-access-key-id
  aws-secret-access-key
  aws-region-name
  aws-bosh-init-bucket)

credentials = {}

credential_names.each do |cn|
  env_var_name = cn.gsub(/-/, '_')
  credentials[cn] = ENV[env_var_name]
end

if (File.exist? OUTFILE)
  fail_exit "%{OUTFILE} already exists. Exiting."
end

File.open(OUTFILE, 'w') do |file|
  file.write( credentials.to_yaml )
end
