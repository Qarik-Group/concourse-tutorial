# Docker イメージの作成・利用

このセクションでは、Dockerfile のプロジェクトの作成とビルドを行い、Docker Hub に push する方法を紹介します。

![docker-push](/images/docker-push.png)

Docker イメージには、通常の作業で多くの用途があります(Concourse パイプライン用の Docker イメージを収集したいと思うこともあるでしょう)。インターネットから毎回ダウンロードするのではなく、ベースイメージにプリインストールされている依存関係があれば、Concourse の Task は遙かに高速になります。 あなたのチームは、すべてのパイプラインで使用される一連の Docker イメージの収集を始めるかもしれません。

Stark＆Wayne では、パイプラインの Docker イメージを https://github.com/starkandwayne/dockerfiles/ で管理し、パイプラインhttps://ci.starkandwayne.com/teams/main/pipelines/docker-images?groups=* を使って様々な Docker イメージに変換しています。

このレッスンの `pipeline.yml` と Dockerfile の例は次の場所にあります:

```
cd tutorials/miscellaneous/docker-images
```

Docker イメージを定義する
---------------------

このセクションのサブフォルダ `docker` は `Dockerfile` とシンプルな `hello-world` コマンドを含んでいます。

```dockerfile
FROM busybox

ADD hello-world /bin/hello-world

ENV NAME=world
ENTRYPOINT ["/bin/hello-world"]
```

Docker コンテナイメージを作る
-------------------------------

手動で Docker イメージを作成し、Docker Hub に push することもできます。しかしここでは Concourse があるので、今回は代わりにそちらを使ってみましょう。

このレッスンの `pipeline.yml` の目的は、 `docker-image` Resource で `put` を実行することです。

```yaml
resources:
- name: tutorial
  type: git
  source:
    uri: https://github.com/drnic/concourse-tutorial.git
    branch: develop

- name: hello-world-docker-image
  type: docker-image
  source:
    email: ((docker-hub-email))
    username: ((docker-hub-username))
    password: ((docker-hub-password))
    repository: ((docker-hub-username))/concourse-tutorial-hello-world

jobs:
- name: publish
  public: true
  serial: true
  plan:
  - get: tutorial
  - put: hello-world-docker-image
    params:
      build: tutorial/tutorials/miscellaneous/docker-images/docker
```

上記の パイプラインでは、いくつか必要なパラメータがあることが分かります。

## 資格管理マネージャにパラメータを追加する

`bucc`を使っているのであれば、`credhub`を使ってそれらを保存してください。

```
credhub set -n /concourse/main/push-docker-image/docker-hub-email    -t value -v you@email.com
credhub set -n /concourse/main/push-docker-image/docker-hub-username -t value -v you
credhub set -n /concourse/main/push-docker-image/docker-hub-password -t value -v yourpassword
```

あなたの Docker のクレデンシャル情報は、恐らく多くの パイプラインで共通しているので、パイプラインだけでなく、Concourse の `main` Team に登録しておくと良いでしょう:

```
credhub set -n /concourse/main/docker-hub-email    -t value -v you@email.com
credhub set -n /concourse/main/docker-hub-username -t value -v you
credhub set -n /concourse/main/docker-hub-password -t value -v yourpassword
```

次に、パイプラインをセットアップし、Job: `publish` を実行します:

```
fly -t bucc set-pipeline -p push-docker-image -c pipeline.yml -n
fly -t bucc unpause-pipeline -p push-docker-image
fly -t bucc trigger-job -j push-docker-image/publish -w
```

出力結果には以下が含まれます:

```
Successfully built c987adeb0ff8
Successfully tagged you/concourse-tutorial-hello-world:latest
The push refers to a repository [docker.io/you/concourse-tutorial-hello-world]
```

## Docker イメージを利用する

これで、Docker イメージを Task のベースイメージとして使用できるようになりました。

```
  - task: run
    config:
      platform: linux
      image_resource:
        type: docker-image
        source:
          repository: ((docker-hub-username))/concourse-tutorial-hello-world
      run:
        path: /bin/hello-world
        args: []
      params:
        NAME: ((docker-hub-username))
```
