# Tutorial's own CI pipeline


```
fly -t oss set-pipeline -p $(basename $(pwd)) -c ci/pipeline.yml -l ci/credentials.yml
fly -t oss unpause-pipeline -p $(basename $(pwd))
```
