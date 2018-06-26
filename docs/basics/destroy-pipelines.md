description: How to destroy a pipeline, its jobs and resources.

# Destroying Pipelines

The current `hello-world` pipeline will now keep triggering every 2-3 minutes forever. If you want to destroy a pipeline - and lose all its build history - then may the power be granted to you.

You can delete the `hello-world` pipeline:

```
fly -t tutorial destroy-pipeline -p hello-world
```

