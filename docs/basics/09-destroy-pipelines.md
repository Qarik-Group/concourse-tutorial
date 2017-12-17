# Destroying pipelines

The current `helloworld` pipeline will now keep triggering every 2-3 minutes for ever. If you want to destroy a pipeline - and lose all its build history - then may the power be granted to you.

You can delete the `helloworld` pipeline:

```
fly -t tutorial destroy-pipeline -p helloworld
```

