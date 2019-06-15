description: 外部 Resource を Job 中の Task に渡してみましょう
image_path: /images/task-docker-image-and-run-tests.png

# Task で Resource から読み込んだファイルを利用する

注: パイプラインを使ったユニットテスト実行については、今後のセクションで詳しく説明します。

ユニットテストをもつシンプルなアプリケーションについて考えましょう。このテストを パイプライン の中で実行するには:

* 依存関係を解決する Task `image`
* テストの実行方法を記述した Task スクリプトを含む入力 `resource`
* アプリケーションのソースコード自体を含む入力 `resource`

が必要になります。

Go のアプリケーション [simple-go-web-app](https://github.com/cloudfoundry-community/simple-go-web-app) の例では、Task イメージに Go の実行環境が含まれている必要があります。ここでは、[https://hub.docker.com/_/golang/](https://hub.docker.com/_/golang/) から `golang:1.9-alpine` を利用しています(サイズ、レイヤーについては https://imagelayers.io/?images=golang:1.9-alpine を確認してください)。

Task ファイル `task_run_tests.yml` は以下の内容を含んでいます:

```yaml
image_resource:
  type: docker-image
  source: {repository: golang, tag: 1.9-alpine}

inputs:
- name: resource-tutorial
- name: resource-app
  path: gopath/src/github.com/cloudfoundry-community/simple-go-web-app
```

Resource: `resource-app` はこの時、Task コンテナ内に一緒に読み込まれ、フォルダとして配置されます。デフォルトでは、入力は内容が同じ名前のフォルダに格納されています。この例で代替パス(`path:`項目)を使用するのは、Goのアプリケーション構築とテストに固有の問題であり、このセクションの範囲外です。

パイプライン の中でこの Task を実行するには下記のようにします:

```
cd ../job-inputs
fly -t tutorial sp -p simple-app -c pipeline.yml
fly -t tutorial up -p simple-app
```

パイプラインの UI http://127.0.0.1:8080/teams/main/pipelines/simple-app を見ると、Job が自動的に開始していることがわかるでしょう。

![trigger-job-input](/images/trigger-job-input.png)

`golang:1.9-alpine` イメージをダウンロードするため、Task: `web-app-tests` の最初の実行時には Job は pause した状態になります。

以下の`web-app-tests`の出力が出てくれば、Go のテスト出力に対応できています:

```
ok  	github.com/cloudfoundry-community/simple-go-web-app	0.003s
```

![task-docker-image-and-run-tests](/images/task-docker-image-and-run-tests.png)
