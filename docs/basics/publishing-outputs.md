description: git Resource は、変更が入った gitリポジトリを、remote のエンドポイントに push するためにも使用できます(git repo が最初に clone された場所とは異なる場合があります)。
image_path: /images/broken-resource.png

# ビルドの成果物をアップロードする

ここまで `git` Resource を使って git リポジトリを fetch し、`git` と `time` Resource をトリガーとして使用してきましたが、[`git` Resource](https://github.com/concourse/git-resource) は、変更が入った Git リポジトリを、remote のエンドポイントに push するためにも使用できます(git repo が最初に clone された場所とは異なる場合があります)。

```
cd ../publishing-outputs
cp pipeline-missing-credentials.yml pipeline.yml
fly -t tutorial sp -p publishing-outputs -c pipeline.yml
fly -t tutorial up -p publishing-outputs
```

パイプラインのダッシュボード http://127.0.0.1:8080/teams/main/pipelines/publishing-outputs を見ると、入力した Resource にエラーが発生していることが分かります (オレンジ色の部分を参照してください):

![broken-resource](/images/broken-resource.png)

`pipeline.yml` は、まだ git repo や 書き込み操作に必要な秘密鍵を持っていません。

[Create a Github Gist](https://gist.github.com/) で `bumpme` というファイルを作成し、"Create public gist" ボタンを押してください。

![gist](/images/gist.png)

<<<<<<< HEAD
"Embed"のドロップダウンをクリックし、 "Clone via SSH" を選択し、git URL をコピーします:

![ssh](/images/ssh.png)

それを `pipeline.yml` の `resource-gist` セクションに、以下のようにパラメータとして追加してください:

```
- name: resource-gist
  type: git
  source:
    uri: git@gist.github.com:e028e491e42b9fb08447a3bafcf884e5.git
    branch: master
    private_key: |-
      -----BEGIN RSA PRIVATE KEY-----
      MIIEpQIBAAKCAQEAuvUl9YU...
      ...
      HBstYQubAQy4oAEHu8osRhH...
      -----END RSA PRIVATE KEY-----
```

また、あなたの `~/.ssh/id_rsa` 秘密鍵(もしくは GitHub に登録したもの)を `private_key` セクションに貼り付けてください。
_注意: ここで使う秘密鍵がパスフレーズを使って生成されていないことを確認してください。秘密鍵が受け入れられず、エラーが発生してしまいます。_

パイプラインを更新し、Concourse に強制的にこの Gist のクレデンシャル情報を速やかに再確認してもらった後、Job を実行します:

```
fly -t tutorial sp -p publishing-outputs -c pipeline.yml
fly -t tutorial check-resource -r publishing-outputs/resource-gist
fly -t tutorial trigger-job -j publishing-outputs/job-bump-date -w
```

再度 WebUI を確認しましょう。新しい `git@gist.github.com:XXXX.git` リポジトリを正常に取得できていれば、オレンジ色の Resource は黒色に変わります。

`job-bump-date` が完了したら、あなたの gist を更新してみてください:

![gist-bumped](/images/gist-bumped.png)

この パイプラインは Resource を更新する例です。git repo(あなたの github gist)に新しい git commits を push しました。

_新しい commit はどこからきたのですか?_

`task: bump-timestamp-file` の Task ファイルの設定で、1つの出力 `updated-gist`を指定しています:

```yaml
outputs:
  - name: updated-gist
```

Task: `bump-timestamp-file` は次の `bump-timestamp-file.sh` を実行しています:

```bash
git clone resource-gist updated-gist

cd updated-gist
date > bumpme

git config --global user.email "nobody@concourse-ci.org"
git config --global user.name "Concourse"

git add .
git commit -m "Bumped date"
```

まず、入力された Resource:`resource-gist` を、出力する Resource:`updated-gist` にコピーしました（ `git clone` を使用し、`git`の作法に従っています）。 `updated-gist` ディレクトリにいくつかの変更が加えられ、`updated-gist`フォルダのGitリポジトリを変更する `git commit` が続きます。この `updated-gist` フォルダと、`git commit` が追加され、パイプラインの次のステップで、gist に push されます:

```yaml
- put: resource-gist
  params:
    repository: updated-gist
```

`task: bump-timestamp-file` ステップからの `update-gist` の出力は、Resource:`resource-gist` の `updated-gist`として入力になっています([`git` resource](https://github.com/concourse/git-resource)でより詳しい情報を参照してください)。

## Task の依存ツールはどこでインストールするの？

`bump-timestamp-file.sh` スクリプトは、`git` CLI を必要としました。

`apt-get update; apt-get install git`などを使ってスクリプトの一番上でインストールすることができたでしょうが、これにより Task が非常に遅くなってしまいます(この Task が実行される度にCLIを再インストールしてしまうからです)。

代わりに、`bump-timestamp-file.sh` のステップでは、ベースとなるDocker Image に、すでに `git` CLI が含まれていることを前提としています。

使用されている Docker Image は、Task 設定の `image_resources` セクションに記述されています：

```yaml
  - task: bump-timestamp-file
    config:
      platform: linux
      image_resource:
        type: docker-image
        source: { repository: starkandwayne/concourse }
```

Docker Image: [`starkandwayne/concourse`](https://hub.docker.com/r/starkandwayne/concourse) は、https://github.com/starkandwayne/dockerfiles/ で説明されています。多くの Stark & Wayne の パイプラインで利用されている共通のベースとなる Docker Image です。

あなたの組織は、独自の Docker Image を、パイプライン間で共有するように管理したいかもしれません。この基本レッスンを終えたら、レッスン: [Create and Use Docker Images](/miscellaneous/docker-images/) にアクセスして、コンコースを使用して独自の Docker Image を作成するための パイプラインを作成してみましょう。

## 秘密鍵をそのまま入力してるけど大丈夫？

秘密鍵を平文のテキストファイル(`pipeline.yml`)にコピーし、スクリーンに表示された(`fly set-pipeline -c pipeline.yml`の間)ことへの懸念なら心配ご無用です。この後すぐに [Secret with Credential Manager](/basics/secret-parameters/) についても学びます.
