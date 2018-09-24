description: Concourse の Pipeline には、Pipeline の YAML ファイルの任意の値に対して、パラメータ ((parameter)) を入れることができます。

# Parameterized Pipelines

前のセクションでは、秘密の資格情報と個人用のgit URLを `pipeline.yml` ファイルに配置するように進めました。 これは `pipeline.yml`を、リポジトリにアクセスした人と共有するのを困難にしてしまいます。クレデンシャル情報に誰もがアクセスする必要はありません。

Concourse の Pipeline には、Pipeline の YAML ファイルの任意の値に対して、パラメータ `((parameter))` を入れることができます。

パラメータは全て必須の値です。デフォルト値は設定されません。

今回のレッスンの `pipeline.yml` には、2つのパラメータがあります:

```
jobs:
- name: show-animal-names
  plan:
  - task: show-animal-names
    config:
      platform: linux
      image_resource:
        type: docker-image
        source: {repository: busybox}
      run:
        path: env
        args: []
      params:
        CAT_NAME: ((cat-name))
        DOG_NAME: ((dog-name))
```

`fly set-pipeline`をしてパラメータを指定しなかった場合、Job が実行された時にエラーが発生します:

```
cd ../parameters
fly -t tutorial sp -p parameters -c pipeline.yml
fly -t tutorial up -p parameters
fly -t tutorial trigger-job -j parameters/show-animal-names -w
```

これだと、次のエラーで失敗します:

```
Expected to find variables: cat-name
dog-name
errored
```

## Parameters from fly options

```
fly -t tutorial sp -p parameters -c pipeline.yml -v cat-name=garfield -v dog-name=odie
fly -t tutorial trigger-job -j parameters/show-animal-names -w
```

出力は、`-v`フラグで指定した変数が、Task:`show-animal-names` の `params` セクションに渡されたことを表しています。`params` セクションの値は、Task 内での環境変数になっています:

```
initializing
running env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOME=/root
CAT_NAME=garfield
DOG_NAME=odie
USER=root
```

## Parameters from local file

また、パラメータの値をローカルファイルを使って渡すこともできます。

```bash
cat > credentials.yml <<YAML
cat-name: garfield
dog-name: odie
YAML
```

このファイルを `-v`フラグの代わりに渡すには、` --load-vars-from` フラグ（エイリアス: `-l`）を使います。次のコマンドは、結果の Pipeline の YAML が同じなため、前の手順から Pipeline は変更されていないことに注意してください。

```
fly -t tutorial sp -p parameters -c pipeline.yml -l credentials.yml
```

## Revisiting Publishing Outputs

前のレッスン、[Publishing Outputs](/basics/publishing-outputs/) では、`pipeline.yml` にユーザが追加した2つの変更がありました。これらはパラメータを使って変更できるようになりました。

```
cd ../publishing-outputs
```

`resource-gist` に、2つのパラメータを提供する代わりの `pipeline-parameters.yml` を用意しています:

```yaml
resources:
- name: resource-gist
  type: git
  source:
    branch:      master
    uri:         ((publishing-outputs-gist-uri))
    private_key: ((publishing-outputs-private-key))
```

Gist URL と、秘密鍵をもつ `credentials.yml` を作成しましょう:

```yaml
publishing-outputs-gist-uri: "git@gist.github.com:e028e491e42b9fb08447a3bafcf884e5.git"
publishing-outputs-private-key: |-
    -----BEGIN RSA PRIVATE KEY-----
    MIIEpQIBAAKCAQEAuvUl9YU...
    ...
    HBstYQubAQy4oAEHu8osRhH...
    -----END RSA PRIVATE KEY-----
```

`--load-vars-from` または `-l` フラグを使って、変数をパラメータに渡します:

```
fly -t tutorial sp -p publishing-outputs -c pipeline-parameters.yml -l credentials.yml
```

## Dynamic Parameters and Secret Parameters

パラメータは非常に便利です。それらは変数や秘密情報を埋め込まずに、あなたの `pipeline.yml` を公開リポジトリ上に記述することを可能にしてくれます。

ただし、上記の2つのアプローチには2つの欠点があります。

* パラメータ値を変更するには、`fly set-pipeline` を再実行する必要があります。値が多くのパイプラインで共通している場合は、それらのすべてに対して `fly set-pipeline` を再実行する必要があります。
* パラメータ値はあまり秘匿性の高い状態にはなっていません。Pipeline を set している Team にアクセスできる人は、Pipeline の YAML をダウンロードして、秘密情報を抽出することができます。

    ```
    fly -t tutorial get-pipeline -p parameters
    ```

    2つの潜在的な秘密のパラメータが、平文で表示されることがわかります:

    ```
    ...
    params:
      CAT_NAME: garfield
      DOG_NAME: odie
    run:
      path: env
    ```

これらの問題の解決策は、Concourse の Credentials Manager を使用することです。これについては、[Secret with Credential Manager](/basics/secret-parameters/) のレッスンで説明します。
