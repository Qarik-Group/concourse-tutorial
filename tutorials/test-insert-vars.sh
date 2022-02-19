#!/bin/bash

credhub set -n /concourse/main/aws-access-key-id -t value -v "${aws_access_key_id:?required}" >/dev/null
credhub set -n /concourse/main/aws-secret-access-key -t value -v "${aws_secret_access_key:?required}" >/dev/null

credhub set -n /concourse/main/cf-api -t value -v "${cf_api:?required}" >/dev/null
credhub set -n /concourse/main/cf-organization -t value -v "${cf_organization:?required}" >/dev/null
credhub set -n /concourse/main/cf-password -t value -v "${cf_password:?required}" >/dev/null
credhub set -n /concourse/main/cf-space -t value -v "${cf_space:?required}" >/dev/null
credhub set -n /concourse/main/cf-username -t value -v "${cf_username:?required}" >/dev/null

credhub set -n /concourse/main/docker-hub-email -t value -v "${docker_hub_email:?required}" >/dev/null
credhub set -n /concourse/main/docker-hub-password -t value -v "${docker_hub_password:?required}" >/dev/null
credhub set -n /concourse/main/docker-hub-username -t value -v "${docker_hub_username:?required}" >/dev/null

credhub set -n /concourse/main/slack-webhook -t value -v "${slack_webhook:?required}" >/dev/null

credhub set -n /concourse/main/version-aws-bucket -t value -v "${version_aws_bucket:?required}" >/dev/null

credhub set -n /concourse/main/publishing-outputs-gist-uri -t value -v "${publishing-outputs-gist-uri:?required}" >/dev/null
credhub set -n /concourse/main/publishing-outputs-private-key -t value -v "${/publishing-outputs-private-key:?required}" >/dev/null

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
$DIR/test-pipeline-vars.sh
