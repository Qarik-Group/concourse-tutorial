# Run Tests Then Deploy

![test-and-cf-deploy](/images/test-and-cf-deploy.png)

このセクションでは、4つのアイデアを使って、より高度な Job を作成していきます:

1. アプリケーションの repo が変更されるたびに Job を起動する
1. アプリケーションの内部ユニットテストを実行する
1. 成功したら、速やかに Web アプリケーションをデプロイする
1. ターゲットのデプロイ先プラットフォームのために秘密パラメータを使用する

生成されるパイプラインは、これまでのレッスンの組み合わせです:

* [Triggers](/basics/triggers/)
* [Job Inputs](/basics/job-inputs/)
* [Outputs to Inputs](/basics/task-outputs-to-inputs/)
* [Secrets with Credentials Manager](/basics/secret-parameters/)

このレッスンでは、サンプルの Go 言語のアプリケーションを、Cloud Foundry プラットフォームにデプロイします。Concourse の Pipeline では、任意のアプリケーションを、任意の対象プラットフォームにデプロイすることができます。

ここでは便宜上、レッスン: [Job Inputs](/basics/job-inputs/) から `tutorials/basic/job-inputs/task-run-tests.sh` を再利用しています。

```yaml
- name: deploy-app
  public: true
  serial: true
  plan:
  - get: tutorial
  - get: app
    trigger: true
  - task: web-app-tests
    config:
      platform: linux

      image_resource:
        type: docker-image
        source: {repository: golang, tag: 1.9-alpine}

      inputs:
      - name: tutorial
      - name: app
        path: gopath/src/github.com/cloudfoundry-community/simple-go-web-app

      run:
        path: tutorial/tutorials/basic/job-inputs/task-run-tests.sh
  - put: deploy-web-app
    params:
      manifest: resource-app/manifest.yml
      path: app
```

`run-tests-before-deploy` Pipeline をデプロイし, Job を 実行/監視 するために、以下のコマンドを実行します:

```
cd tutorials/miscellaneous/run-tests-before-deploy
fly -t bucc set-pipeline -p run-tests-before-deploy -c pipeline.yml
fly -t bucc unpause-pipeline -p run-tests-before-deploy
fly -t bucc trigger-job -j run-tests-before-deploy/deploy-app -w
```

これは、パラメータが存在しないために失敗します。

## Free Cloud Foundry for Lesson

このレッスンを達成するためには、Cloud Foundry にアクセスする必要があります。ここでは、Pivotal 社が運営している [Pivotal Web Services](https://run.pivotal.io/) を試してみることをお勧めします。Pivotal は、Concourse CI のコア開発チームを援助している会社です。彼らはこのレッスンのために十分なほどの無料お試しクレジットを提供しています。

サインアップの後、https://console.run.pivotal.io/ にアクセスし、`run-tests-before-deploy` という名前の "space" を作成してください。 このレッスンの Pipeline は、サンプルアプリケーションをこの space に展開します。

今回の Pipeline によってデプロイされるサンプルアプリケーションは https://github.com/cloudfoundry-community/simple-go-web-app です。

## Required Parameters

![cf-push-expected-variables](/images/cf-push-expected-variables.png)

レッスンフォルダの `pipeline.yml` の例では、`put：deploy-web-app`を介して、アプリケーションをデプロイするための `cf` Resource を利用しています。任意のResource(または手作りの Task) を使用してアプリケーションをデプロイすることができます。 Cloud Foundry や Kubernetes のような宣言的なデプロイメントプラットフォームは、私たちの Pipeline の実装をシンプルにしてくれます。 彼らは CI/CD デプロイメントオーケストレーションにおける "Just Do It"(あとはやるだけ) な存在なのです。

`cf` Resource は Cloud Foundry にアプリケーションをデプロイします。`pipeline.yml` では以下のように記述されます:

```
- name: deploy-web-app
  type: cf
  source:
    api: ((cf-api))
    username: ((cf-username))
    password: ((cf-password))
    organization: ((cf-organization))
    space: ((cf-space))
    skip-cert-check: true
```

[Parameters](/basics/parameters/) と [Secrets with Credentials Manager](/basics/secret-parameters/) で紹介したように、`((cf-api))` の構文は、後でバインドされる変数、秘密情報、またはクレデンシャルのためのものです。これにより、`pipeline.yml` が誰でも利用可能な状態で公開できるようになります。また、オペレーターは中央集権された場所で変数値を更新することができ、その後、すべての Job が新しい変数値を必要に応じて動的に使用します。

`cf-api`、`cf-username`、`cf-password`、`cf-organization` は多くの Pipeline で共通のクレデンシャルですが、 `cf-space`はこのパイプラインに固有のものです。 例えば、`credhub set`コマンドは以下のようになります:

```
credhub set -n /concourse/main/cf-api          -t value -v https://api.run.pivotal.io
credhub set -n /concourse/main/cf-username     -t value -v drnic+ci@starkandwayne
credhub set -n /concourse/main/cf-password     -t value -v secret-password
credhub set -n /concourse/main/cf-organization -t value -v starkandwayne

credhub set -n /concourse/main/run-tests-before-deploy/cf-space -t value -v run-tests-before-deploy
```

Concourse の資格情報マネージャでパラメータを設定したり、変数として渡すために `fly set-pipeline` を再実行したら、Job を再度 trigger してみましょう:

```
fly -t bucc trigger-job -j run-tests-before-deploy/deploy-app -w
```

## Cleanup

作業が完了したので、Cloud Foundry アカウントから、サンプルアプリケーションを削除しても構いません。

Pivotal Web Services を使用している場合は、https://console.run.pivotal.io/ にアクセスして、 `run-tests-before-deploy` space に移動して、アプリケーションを見つけて削除しておいてください。
