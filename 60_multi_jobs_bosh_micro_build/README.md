60 - multi-stage jobs - bosh-init
=================================

```
cd ../60_multi_jobs_bosh_micro_build
./run.sh ../credentials.yml build-cli
```

The resulting `bosh-init` binary can now be uploaded to S3 and used by other jobs.

```
cd ../60_multi_jobs_bosh_micro_build
./run.sh ../credentials.yml build-cli
```

![build-save](http://cl.ly/image/0D42383F0C3W/job-build-bosh-init-cli_-_save_to_s3.png)
