# Parameterized pipelines

In the preceding sections you were asked to private credentials and personal git URLs into the `pipeline.yml` files. This would make it difficult to share your `pipeline.yml` with anyone who had access to the repository. Not everyone needs nor should have access to the shared secrets.

Concourse pipelines can include `((parameter))` parameters for any value in the pipeline YAML file.

Parameters are all mandatory:

```
cd ../14_parameters
fly -t tutorial sp -p publishing-outputs -c pipeline.yml
fly -t tutorial up -p publishing-outputs
```

If you view the pipeline dashboard you will see one of the resource is in an error state:

![pipeline-failing-resource-missing-parameters](/images/pipeline-failing-resource-missing-parameters.png)

Click on the resource and it will show the error:

```
Expected to find variables: gist-url
github-private-key
```

Somewhere secret on laptop create a `credentials.yml` file with keys `gist-url` and `github-private-key`. The values come from your previous `pipeline.yml` files:

```
gist-url: git@gist.github.com:xxxxxxx.git
github-private-key: |-
  -----BEGIN RSA PRIVATE KEY-----
  MIIEpQIBAAKCAQEAuvUl9YUlDHWBMVcuu0FH9u2gSi83PkL4o9TS+F185qDTlfUY
  fGLxDo/bn8ws8B88oNbRKBZR6yig9anIB4Hym2mSwuMOUAg5qsA9zm5ArXQBGoAr
  ...
  iSHcGbKdWqpObR7oau2LIR6UtLvevUXNu80XNy+jaXltqo7MSSBYJjbnLTmdUFwp
  HBstYQubAQy4oAEHu8osRhH1VX8AR/atewdHHTm48DN74M/FX3/HeJo=
  -----END RSA PRIVATE KEY-----
```

To pass in your `credentials.yml` file use the `--load-vars-from` or `-l` options:

```
fly -t tutorial sp -p publishing-outputs -c pipeline.yml -l ../credentials.yml
```
