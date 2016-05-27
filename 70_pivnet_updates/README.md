# Watching for Pivotal Network updates

For users of Pivotal Cloud Foundry, you may want to watch for latest security updates that are posted to [Pivotal Network](https://network.pivotal.io). Perhaps even to automatically install these updates.

Fortunately there is a [`pivnet-resource`](https://github.com/pivotal-cf-experimental/pivnet-resource).

It is a community resource so you add it into your pipeline in the `resource_types:` section:

```yaml
---
resource_types:
- name: pivnet
  type: docker-image
  source:
    repository: pivotalcf/pivnet-resource
    tag: latest-final
```

To get your PivNet API token, go to https://network.pivotal.io/users/dashboard/edit-profile and you'll find it down the bottom of the page.

Put it in a `credentials.yml` file:

```yaml
pivnet-api-token: TOKEN
```

To determine if there are newer stemcells, see the `pipeline.get-only.yml` pipeline:

```yaml
---
resource_types:
- name: pivnet
  type: docker-image
  source:
    repository: pivotalcf/pivnet-resource
    tag: latest-final

resources:
- name: pivnet-stemcells
  type: pivnet
  source:
    api_token: {{pivnet-api-token}}
    product_slug: stemcells

jobs:
- name: stemcells
  public: true
  plan:
  - {get: pivnet-stemcells, trigger: true}
```
