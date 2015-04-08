20 - Versioning via S3
======================

Create an s3 bucket:

![create-bucket](http://cl.ly/image/011P2Q1R3o0P/create_s3_bucket.png)

After `put` to create semver resource:

![s3-file](http://cl.ly/image/3l2E3T1s1J3R/s3_bucket_file_for_semver_resource.png)

This will change the `app-version` file; which will in turn trigger the pipeline to start again; which updates the file, etc etc

After running all pipeline tutorial stages, manually modify `pipeline.yml` to `bump: minor` (`1.0.2` to `1.1.0`) and then `bump: major` (`1.1.0` to `2.0.0`).
