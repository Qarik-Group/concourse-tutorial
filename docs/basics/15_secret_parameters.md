# Secret Parameters

## Add CredHub to Concourse

TODO

## Set variables


```
credhub set -n /concourse/main/tutorial-pipeline/cf-api -t value -v https://api.18-220-96-60.sslip.io
credhub set -n /concourse/main/tutorial-pipeline/cf-username -t value -v admin
credhub set -n /concourse/main/tutorial-pipeline/cf-organization -t value -v system
credhub set -n /concourse/main/tutorial-pipeline/cf-space -t value -v dev
```

```
credhub set -n /concourse/main/tutorial-pipeline/cf-password --type password --password my-secret-password
```

## Credential Lookup Rules

When resolving a parameter such as `((foo_param))`, it will look in the following paths, in order:

* `/concourse/TEAM_NAME/PIPELINE_NAME/foo_param`
* `/concourse/TEAM_NAME/foo_param`

