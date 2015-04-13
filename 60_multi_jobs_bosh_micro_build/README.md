60 - multi-stage jobs - bosh-init
=================================

```
./60_*/run.sh stub.yml build-cli
```

The resulting `bosh-init` binary can now be uploaded to S3 and used by other jobs.

```
./60_*/run.sh stub.yml build-save
```

![build-save](http://cl.ly/image/0D42383F0C3W/job-build-bosh-init-cli_-_save_to_s3.png)
